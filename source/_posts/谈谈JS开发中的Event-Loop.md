---
title: 谈谈JS开发中的Event Loop
date: 2020-02-06 20:20:37
updated: 2020-02-07 19:40:00
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
---

<style>
    .problem,
    .answer-loading {
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
    }
    
    .answer-loading:hover {
        cursor: wait;
    }

    .show-answer {
        cursor: pointer!important;
        color: rgb(70, 130, 197)!important;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
    }
    
    .show-answer:hover {
        text-decoration: underline!important;
    }
</style>

<script type="text/javascript">
'use strict';

window.addEventListener('load', function() {
    $('.answer-loading').hide().parent().find('.show-answer').show();
    $('.show-answer').on('click', function () {
        let id = '#problem-' + $(this).attr('index');
        $(id).toggle().css('display') === 'none' ? $(this).text('点我可看答案哦') : $(this).text('点我可隐藏答案哦');
    });
});
</script>

> <span class = 'introduction'>一个人害怕的事，往往是他应该做的事。</span><br/>
微任务、宏任务、<code>process.nextTick()</code>、Promise、setImmediate()...这些都是事件循环机制中比较关键的点。本篇 Blog 从浏览器到 Node.js，对事件循环机制做一个分析与总结。

<!--more-->

<hr/>

## JavaScript 是单线程的

JavaScript 语言的一大特点就是单线程，也就是说，同一个时间只能做一件事。那么，为什么JavaScript不能有多个线程呢？这样能提高效率啊。

<div class="note info">JavaScript 一开始是作为 <b>脚本语言</b> 运行在客户端的</div>

作为浏览器脚本语言，JavaScript 的主要用途是与用户互动，以及操作 DOM。这决定了它只能是单线程，否则会带来很复杂的同步问题。

比如，假定 JavaScript 同时有两个线程，一个线程在某个 DOM 节点上添加内容，另一个线程删除了这个节点，这时浏览器应该以哪个线程为准？

为了利用多核 CPU 的计算能力，HTML5 提出 <em>Web Worker</em> 标准，允许 JavaScript 脚本创建多个线程，但是 **子线程完全受主线程控制，且不得操作 DOM**。所以，这个新标准并没有改变 JavaScript 是单线程的本质。

### 任务队列

单线程就意味着，所有任务需要排队，**前一个任务结束，才会执行后一个任务**。如果前一个任务耗时很长，后一个任务就不得不一直等着。

如果排队是因为计算量大，CPU 忙不过来，倒也算了，但是很多时候 CPU 是闲着的，因为 IO 设备（输入输出设备）很慢（比如 Ajax 操作从网络读取数据或者 Node 读文件），不得不等着结果出来，再往下执行。

神奇的 JavaScript 语言的设计者意识到，这时主线程完全可以不管 IO 设备，**挂起** 处于等待中的任务，先运行排在后面的任务。等到 IO 设备返回了结果，再回过头，把挂起的任务继续执行下去。

于是，所有任务可以分成两种，一种是 **同步任务（synchronous）**，另一种是 **异步任务（asynchronous）**。

- 同步任务指的是，在主线程上排队执行的任务，只有前一个任务执行完毕，才能执行后一个任务；
- 异步任务指的是，不进入主线程、而进入 **“任务队列” (task queue)** 的任务，只有“任务队列”通知主线程，某个异步任务可以执行了，该任务才会进入主线程执行。

具体地说，异步的执行机制是这样的（这里也可将同步看作没有异步任务的异步执行）：

1. 所有同步任务都在主线程上执行，形成一个 **执行栈**（execution context stack）；
2. 主线程之外，还存在一个 **"任务队列"**（task queue）。只要异步任务有了运行结果，就在"任务队列"之中放置一个事件；
3. 一旦"执行栈"中的所有同步任务执行完毕，系统就会读取"任务队列"，看看里面有哪些事件。那些对应的异步任务，于是结束等待状态，进入执行栈，开始执行；
4. 主线程不断重复上面的第三步。

<img src="./1.jpg" alt="主线程 & 任务队列" title="主线程 & 任务队列" />

### 事件和回调函数

“任务队列”是一个事件的队列（也可以理解成消息的队列），IO 设备完成一项任务，就在“任务队列”中添加一个事件，表示相关的异步任务可以进入“执行栈”了。主线程读取“任务队列”，就是读取里面有哪些事件。

“任务队列”中的事件，除了 IO 设备的事件以外，还包括一些用户产生的事件（比如鼠标点击、页面滚动等等）。只要指定过回调函数，这些事件发生时就会进入“任务队列”，等待主线程读取。

所谓 **“回调函数”（callback）**，就是那些会被主线程挂起来的代码。异步任务必须指定回调函数，当主线程开始执行异步任务，就是执行对应的回调函数。

<hr />

## 浏览器中的 Event Loop

### JavaScript 同步代码的执行流程

JavaScript 引擎在执行通过代码的过程中，会安装顺序依次存储到一个地方去，这个地方就是上面讲的 **执行栈**，当我们调用一个方法的时候，JavaScript 会生成一个和这个方法相对应的 **上下文(context)**。这个执行环境中存在着这个方法的私有作用域，上层作用域的指向，方法的参数，这个作用域中定义的变量以及这个作用域的 this 对象。

既然 “执行栈” 是一个栈，那么不难理解下面代码的执行过程：

```javascript
function a() {
    console.log("1");
}
function b() {
    a();
}
function c() {
    b();
}
c();
```

执行栈可以大致看作是这样的：

1. 全局上下文
2. 全局上下文 -> 函数 c
3. 全局上下文 -> 函数 c -> 函数 b
4. 全局上下文 -> 函数 c -> 函数 b -> 函数 a
5. 全局上下文 -> 函数 c -> 函数 b
6. 全局上下文 -> 函数 c
7. 全局上下文
8. 全部执行完毕，释放资源

### JavaScript 异步代码的执行流程

JavaScript 引擎在遇到一个异步事件时，不会一直等待返回结果而是将它 **挂起**。当异步任务执行完之后会将结果加入到和执行栈中不同的任务队列当中。

需要注意的是：此时放入队列不会立即执行其回调，而是当主线程执行完执行栈中所有的任务之后再去队列中查找是否有任务，如果有则取出排在第一位的事件然后将回调放入执行栈并执行其代码。

如此反复就构成了 **事件循环**。

下图转自Philip Roberts的演讲 <a href="https://vimeo.com/96425312">《Help, I'm stuck in an event-loop》</a>：

<img src="./2.png" alt="事件循环" title="事件循环" />

上图中，主线程运行的时候，产生 **堆（heap）** 和 **栈（stack）**，栈中的代码调用各种外部 API，它们在"任务队列"中加入各种事件（click，load，done...）。只要栈中的代码执行完毕，主线程就会去读取"任务队列"，依次执行那些事件所对应的回调函数。

**执行栈中的代码（同步任务），总是在读取"任务队列"（异步任务）之前执行。**

```javascript
let xml = new XMLHttpRequest();
xml.open('GET', 'http://www.wqh4u.cn');
xml.onreadystatechange = function() {
    // 省略...
};
xml.send();
```

这里 `send()` 方法就是去发请求了，它是一个异步的任务，所以将它和 `onreadystatechange` 的定义交换一下顺序也是可以的，因为定义 `onreadystatechange` 是一个同步的代码，它会在异步之前进行，下面这个例子也能很好的说明这件事：

```javascript
// 程序自上而下运行...
Promise.resolve().then(() => console.log(1)); // 这是个异步操作，会放到队列中
console.log(2); // 在当前上下文中它是同步的，所以先会执行这一行
// 输出的结果不是 1 \n 2，而是 2 \n 1
```

### 微任务和宏任务

上面提到 JavaScript 执行异步方法的时候会将其放到队列中，这是比较笼统的，具体来说，**JavaScript 会根据任务的类型将其放入不同的队列**。

任务类型有两种：微任务、宏任务。那么其对应的哪些是微任务、哪些是宏任务呢？

- 常见的微任务：Promise、process.nextTick()、Object.observer、MutationObserver
- 常见的宏任务：setTimeout()、setInterval()、setImmediate()、整个 JavaScript 代码

浏览器在执行的时候，先从宏任务队列中取出一个宏任务执行宏，然后再 **执行该宏任务下的所有的微任务**，这是一个循环；然后再取出并执行下一个宏任务，再执行所有的微任务，这是第二个循环，以此类推。

**即，先执行同步，再执行异步，先执行队列中第一个宏任务，再执行队列中所有的微任务。**

<div class="note info">注意，整个 JavaScript 代码是第一个宏任务！</div>

来个简单一点的题目吧，看看下面代码的输出结果是什么？

```javascript
console.log(1);
setTimeout(() => console.log(2));
Promise.resolve().then(() => console.log(3));
console.log(4);
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="1" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-1" style="display: none;">：1 4 3 2</span></div>

太简单了？那就再来一个吧，下面代码的输出结果是什么：

```javascript
new Promise(resolve => {
    console.log(1);
    resolve();
}).then(() => console.log(2));

setTimeout(() => {
    Promise.resolve().then(() => console.log(3));
    new Promise(resolve => {
        setTimeout(() => {
            console.log(4);
            resolve();
        });
    }).then(() => console.log(5));
    console.log(6);
});

console.log(7);
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="2" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-2" style="display: none;">：1 7 2 6 3 4 5</span></div>

欸？Promise 不是微任务吗？那为什么先输出的是 1 呢？

<div class="note info">Promise 构造器中传入的是一个函数，这个函数会在返回一个 Promise 对象之前被调用，详情请阅读 <a href="https://www.wqh4u.cn/2020/01/21/%E5%8E%9F%E7%94%9FJavaScript%E5%AE%9E%E7%8E%B0Promise/">我的这篇博客</a>，里面对 Promise 有一个综合的阐述与讲解。</div>

既然立即被调用，那么 `console.log(1)` 这段代码是同步的，按照执行栈中的顺序，它应该被第一个输出。

### 定时器中的坑

除了放置异步任务的事件，“任务队列”还可以放置定时事件，即指定某些代码在多少时间之后执行。这叫做 **“定时器”（timer）** 功能，也就是定时执行的代码。

定时器功能主要由 **setTimeout()** 和 **setInterval()** 这两个函数来完成，它们的内部运行机制完全一样，区别在于前者指定的代码是一次性执行，后者则为反复执行：

```javascript
setTimeout(function inner() {
    console.log(1);
    setTimeout(inner, 1000); // 不建议用 arguments.callee 哦
}, 1000);
```

上面的代码 **执行结果** 和直接使用 `setInterval()` 是 **没有很大区别** 的，都是 **大约经过** 1s 然后去执行 `console.log(1)`。

下面主要来讲 `setTimeout()`，其接受两个参数，第一个是回调函数，第二个是推迟执行的毫秒数。如果将 `setTimeout()` 的第二个参数设为 0，就表示当前代码执行完（执行栈清空）以后，立即执行（0 毫秒间隔）指定的回调函数。

```javascript
setTimeout(() => console.log(1), 0);
console.log(2);
```

上面的执行结果是 2 1，这就不过多解释了。总之，`setTimeout(fn, 0)` 的含义是，**指定某个任务在主线程最早可得的空闲时间执行**，也就是说，尽可能早得执行。它在“任务队列”的尾部添加一个事件，因此要等到同步任务和“任务队列”现有的事件都处理完，才会得到执行。

HTML5 标准规定了 `setTimeout()` 的第二个参数的最小值（最短间隔），不得低于 4 毫秒，如果低于这个值，就会自动增加。在此之前，老版本的浏览器都将最短间隔设为 10 毫秒。另外，对于那些 DOM的 变动（尤其是涉及页面重新渲染的部分），通常不会立即执行，而是每 16 毫秒执行一次。这时使用 `requestAnimationFrame()` 的效果要好于 `setTimeout()`。

而在 Node 中，也做不到 0 毫秒，最少也需要 1 毫秒，根据官方文档，第二个参数的取值范围在 1 毫秒到 2147483647 毫秒之间。

需要注意的是，`setTimeout()` 只是将事件插入了“任务队列”，**必须等到当前代码（执行栈）执行完**，主线程才会去执行它指定的回调函数。要是当前代码耗时很长，有可能要等很久，所以并没有办法保证，回调函数一定会在 `setTimeout()` 指定的时间执行：

```javascript
let before = new Date().getTime(); // 得到程序刚刚开始运行的时间
let setTimeoutBegin = null;

setTimeout(function () {
    let after = new Date().getTime(); // 获得开始执行 setTimeout 的时间
    console.log('Timeout: ' + (after - before + '')); // 当程序执行到这里时的总耗时
    setTimeoutBegin = after; // 记录维护一下这个时间
    let calculateSetTimeoutTimeEnd = new Date().getTime(); // 获得执行完 setTimeout 的时间
    console.log('Set Timeout total time: ' + (calculateSetTimeoutTimeEnd - after + ''));
    // 这里输出一下整个 setTimeout 的回调函数的总共用时
    for (let i = 0; i < 100000000; i += 0.5) {} // 再加一个延时
}, 1000);

setInterval(function () {
    let after = new Date().getTime(); // 获得开始执行当前 setInterval 的时间
    if (setTimeoutBegin !== null) {
        console.log('First interval minus set timeout end: ' + (after - setTimeoutBegin + '')); // 输出第一个 setInterval 的执行时间与当时执行 setTimeout 时间的插值
        setTimeoutBegin = null;
    }
    console.log('Interval: ' + (after - before + '')); // 输出当前 setInterval 的执行时间
}, 1000);

for (let i = 0; i < 100000000; i += 0.5) {
    // 因为这段代码是同步的，主线程必须先把这一段代码执行完毕才可以
}
```

上面的代码设置了两个定时器，我们期望 `setTimeout()` 会在 1000ms 后运行，但实际的结果是：

```text
Timeout: 1213
Set Timeout total time: 6
First interval minus set timeout end: 218
Interval: 1431
Interval: 2431
Interval: 3432
...
```

因为按照在任务队列中的顺序，会先执行 `setTieout`，此时过去了 1213ms，那就是因为有一个同步的 `for` 循环阻塞了线程，造成了 `setTimeout` 没能在约定的时间内执行回调函数。

第二行我们了解到了整个 `setTimeout`（不算里面的 `for` 循环）共用了 6ms。

第三行意味着在执行第一次 `setInterval` 时，距离 `setTimeout` 的执行已经过去了 218ms，减去 6ms 就是 `for` 循环的 **大致** 执行时间 212ms，这就解释了在执行 `setTimeout` 时，多出来的 213ms 是怎么来的了（1ms 的误差就忽略不计了）。

然后就是执行 `setInterval` 的时间，1213 + 218 = 1431，没得赖。

从 2431 到 3432 的这多的 1ms，也就忽略不计了，可以认为是 new Date().getTime() 所浪费掉的时间。

<div class="note danger"><del>Have a good time with JavaScript（笑）</del></div>

<hr />

## Node.js 中的 Event Loop

我们都知道 JavaScript 是单线程运行，异步操作特别重要。只要用到引擎之外的功能，就需要跟外部交互，从而形成异步操作。

Node 的异步语法比浏览器更复杂，因为它可以跟内核对话，不得不搞了一个专门的库 <a href="https://github.com/libuv/libuv">libuv</a> 做这件事。这个库负责各种回调函数的执行时间，毕竟异步任务最后还是要回到主线程，一
个个排队执行，这就是 Node 中的事件循环。

在 <a href="https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/">官方讲解</a> 中，可以找到一个这样的模型：

<img src="./3.png" alt="Node 中的事件循环" title="Node 中的事件循环" />

同时这里也有一个示意图（作者 <a href="https://twitter.com/BusyRich/status/494959181871316992">@BusyRich</a>）：

<img src="4.png" alt="Node.js 系统" title="Node.js 系统" />

根据上图，Node.js 的运行机制如下：

- V8 引擎解析 JavaScript 脚本；
- 解析后的代码，调用 Node API；
- <a href="https://github.com/libuv/libuv">libuv</a> 库负责 Node API 的执行。它将不同的任务分配给不同的线程，形成一个 Event Loop（事件循环），以异步的方式将任务的执行结果返回给 V8 引擎。
- V8 引擎再将结果返回给用户

由官网的那个图可以得到 Node.js 事件循环的六个阶段：

- timers: 该阶段执行定时器的回调，如 setTimeout() 和 setInterval()；
- I/O callbacks: 该阶段执行**除了** close 事件，定时器和 setImmediate() 的回调外的所有回调；
- idle, prepare: 内部使用；
- poll: 等待新的 I/O 事件，Node 在一些特殊情况下会阻塞在这里；
- check: setImmediate() 的回调会在这个阶段执行；
- close callbacks: 例如 socket.on('close', ...) 这种 close 事件的回调。

**Event Loop** 按顺序执行上面的六个阶段，每一个阶段都有一个装有 *Callbacks* 的 *FIFO Queue*，当 Event Loop 运行到一个指定阶段时，Node 将执行该阶段的 *FIFO Queue*，当队列 *Callback* 执行完或者执行 *Callbacks* 数量超过该阶段的上限时，Event Loop 会转入下一下阶段。

### poll 阶段

在 Node.js 里，除了上面几个特定阶段的 *callback* 之外，任何异步方法完成时，都会将其 *callback* 加到 *poll queue* 里。

#### 主要功能

poll 阶段有两个主要的功能：

- 处理 poll 队列 *poll queue* 的事件 *callback*；
- 当到达 *timers* 指定的时间时，执行 *timers* 的 *callback*。

#### 逻辑

<ul>
    <li>
        <p>如果 Event Loop 进入了 poll 阶段，且代码未设定 timer：</p>
        <ul>
            <li>如果 poll queue 不为空，Event Loop 将同步的执行 Queue 里的 Callback，直至 Queue 为空，或执行的 callback 到达系统上限;</li>
            <li>
                <p>如果 poll queue 为空，将会发生下面情况：</p>
                <ul>
                    <li>如果代码已经被 setImmediate() 设定了 callback, Event Loop 将结束 poll 阶段进入 check 阶段，并执行 check 阶段的 Queue (check 阶段的 Queue 是 setImmediate 设定的)；</li>
                    <li>如果代码没有设定 setImmediate(callback)，Event Loop 将阻塞在该阶段等待 Callbacks 加入 poll Queue;</li>
                </ul>
            </li>
        </ul>
    </li>
    <li>
        <p>如果 Event Loop 进入了 poll 阶段，且代码设定了 timer：</p>
        <ul>
            <li>如果 poll queue 进入空状态时（即 poll 阶段为空闲状态），Event Loop 将检查 timers；</li>
            <li>如果有 1 个或多个 timers 时间已经到达，Event Loop 将按循环顺序进入 timers 阶段，并执行 timer Queue。</li>
        </ul>
    </li>
</ul>

### 本轮循环和次轮循环

异步任务可以分成两种：追加在本轮循环的异步任务、追加在次轮循环的异步任务。

所谓 “循环”，指的是事件循环 Event Loop。这是 JavaScript 引擎处理异步任务的方式，本轮循环一定早于次轮循环执行即可。

Node 规定，`process.nextTick` 和 `Promise` 的回调函数，追加在本轮循环，即同步任务一旦
执行完成，就开始执行它们。

而 `setTimeout`、`setInterval`、`setImmediate` 的回调函数，追加在次轮循环。

```javascript
// 下面两行，次轮循环执行
setTimeout(() => console.log(1));
setImmediate(() => console.log(2));
// 下面两行，本轮循环执行
process.nextTick(() => console.log(3));
Promise.resolve().then(() => console.log(4));
```

### Node.js 中的定时器

为了协调异步任务，Node 提供了四个定时器，让任务可以在指定的时间运行：setTimeout、setInterval、<a href="https://nodejs.org/docs/latest/api/timers.html#timers_setimmediate_callback_arg">setImmediate</a>、<a href="https://nodejs.org/docs/latest/api/process.html#process_process_nexttick_callback">process.nextTick</a>。前两个是语言的标准，后两个是 Node 独有的。

#### setTimeout 和 setImmediate

这两个函数的功能还是类似的，不同的是他们处于 EventLoop 的不同阶段：timer 和 check，分析一下这个代码的输出顺序：

```javascript
setTimeout(() => console.log(1));
setImmediate(() => console.log(2));
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="3" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-3" style="display: none;">：答案就是不确定（嘿嘿）</span></div>

因为事件循环里面第一个处理的就是 *timer*，之前也说了 `setTimeout()` 做不到 0ms 立即执行，如果到 *timer* 时还没过 1ms，此时系统就会认为 `setTimeout()` 的时间还没到，就会往下执行 `setImmediate()`（执行到这里的时候绝对过了 1ms 了），在下一轮循环到 *timer* 时再执行 `setTimeout()`。

当然如果在 *timer* 的时候已经到了 1ms 了，那就输出的是 1 2。

<div class="note danger">你以为事情就这么简单吗？JOJO？</div>

如果给上面的代码外面套一层异步 I/O 操作：

```javascript
require('fs').readFile('1.txt', () => {
    setTimeout(() => console.log(1));
    setImmediate(() => console.log(2));
});
```

这时候一定会先执行 `setImmediate()` 的回调函数：

假设现在是第一轮循环，此时只有一个任务就是读取 *1.txt* 这个文件，此时进入了 *poll* 阶段，且 *poll queue* 是空，然后又没有已经设定的 *setImmediate*，此时 Node 就会阻塞到这里一直等着 *1.txt* 读完。

读取完文件后，进入指定好的回调函数，遇到了两个定时器，将它们分别加入 *timer* 和 *check* 的队列中。

对于本轮循环，*timer* 已经执行过了，而 *check* 阶段在 *poll* 之后，所以会先执行 *check* 阶段的 `setImmediate()` 中的回调，在下一轮循环的 *timer* 中再执行 `setTimeout()`。

#### 令人困惑的问题

Node.js 文档中称，`setImmediate` 指定的回调函数，总是排在 `setTimeout` 前面。实际上，这种情况只发生在递归调用的时候：

```javascript
setImmediate(function (){
  setImmediate(function A() {
    console.log(1);
    setImmediate(function B(){console.log(2);});
  });

  setTimeout(function timeout() {
    console.log(3);
  }, 0);
});
// 输出 1 3 2
```

#### 定时器中的坑

```javascript
const fs = require('fs');

const startTime = new Date().getTime();

fs.readFile('Main.js', () => {
    let readFileEndTime = new Date().getTime();
    console.log(`readFile: ${readFileEndTime - startTime}`);
    while (new Date().getTime() - startTime < 1000) {} // 阻塞一下线程
});

process.nextTick(() => {
    console.log(2);
    while (new Date().getTime() - startTime < 200) {} // 阻塞一下线程
});

setTimeout(() => {
    let setImmediateTime = new Date().getTime();
    console.log(`setImmediate: ${setImmediateTime - startTime}`);
}, 201); // 为什么这里填 201 和 200 的结果不同呢？
```

### process.nextTick()

process.nextTick 这个名字有点误导，它是在 **本轮循环** 执行的，而且是所有异步任务里面最快执行的：

```javascript
Promise.resolve().then(() => console.log(1));
process.nextTick(() => console.log(2));
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="4" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-4" style="display: none;">：2 1</span></div>

Node 执行完所有同步任务，接下来就会执行
`process.nextTick` 的任务队列。基本上，如果你希望异步任务尽可能快地执行，那就使用 `process.nextTick`。

`process.nextTick()` 不在 Event Loop 的 **任何阶段** 执行，而是在各个阶段 **切换的中间** 执行，即从一个阶段切换到下个阶段前执行：

```javascript
setTimeout(() => {
    console.log(1);
    Promise.resolve().then(() => console.log(2));
    process.nextTick(() => console.log(3));
}, 0);
setTimeout(() => {
    console.log(4);
    Promise.resolve().then(() => console.log(5));
    process.nextTick(() => console.log(6));
}, 0);
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="5" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-5" style="display: none;">：1 3 2 4 6 5</span></div>

`process.nextTick` 方法可以在当前“执行栈”的尾部----下一次 Event Loop（主线程读取“任务队列”）之前----触发回调函数。也就是说，它指定的任务总是发生在所有异步任务之前。

`setImmediate` 方法则是在当前“任务队列”的尾部添加事件，也就是说，它指定的任务总是在下一次 Event Loop 时执行，这与 `setTimeout()` 很像。看看下面这段代码（via <a href="https://stackoverflow.com/questions/17502948/nexttick-vs-setimmediate-visual-explanation">StackOverflow</a>）：

```javascript
process.nextTick(() => {
  console.log(1);
  process.nextTick(() => console.log(2));
});

setTimeout(() => console.log(3));
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="6" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-6" style="display: none;">：1 2 3</span></div>

上面代码中，由于 `process.nextTick` 方法指定的回调函数，总是在当前“执行栈”的尾部触发，所以两个 `process.nextTick` 都会比 `setTimeout` 先一步执行。这说明，如果有多个 `process.nextTick` 语句（不管它们是否嵌套），将全部在当前“执行栈”执行。

<hr />

## 几个小问题，尝试纯人脑编译哦

**浏览器下**，下面的代码执行结果是什么：

```javascript
Promise.resolve().then(() => {
    setTimeout(() => {
        console.log(1);
        Promise.resolve().then(() => console.log(2));
    });
    new Promise(resolve => {
        console.log(3);
        setTimeout(() => resolve());
    }).then(() => {
        console.log(4);
    });
});

setTimeout(() => {
    setTimeout(() => {
        Promise.resolve().then(() => console.log(5));
        console.log(6);
        setTimeout(() => console.log(7));
    });
    console.log(8);
    new Promise(resolve => {
        console.log(9);
        resolve();
    }).then(() => {
        console.log(10);
    });
});

console.log(11);
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="7" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-7" style="display: none;">：11 3 8 9 10 1 2 4 6 5 7</span></div>

**Node.js** 中，下面的代码输出结果是：

```javascript
setTimeout(() => {
    process.nextTick(() => console.log(1));
    Promise.resolve().then(() => console.log(2));
    setImmediate(() => {
        console.log(3);
        Promise.resolve().then(() => console.log(4));
    });
    console.log(5);
});

new Promise(resolve => {
    console.log(6);
    process.nextTick(() => {
        resolve();
    });
}).then(() => {
    Promise.resolve().then(() => console.log(7));
});

process.nextTick(() => console.log(8));

Promise.resolve().then(() => {
    process.nextTick(() => console.log(9));
    setTimeout(() => console.log(10));
});
```

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="8" style="display: none;">点我可看答案哦</span><span class="problem" id="problem-8" style="display: none;">：6 8 7 9 5 1 2 3 4 10</span></div>

### 来个大的吧

这道题目来自 <a href="https://blog.csdn.net/u013055396/article/details/79689706">青松008的博客</a>：

```javascript
const { readFile, readFileSync } = require('fs')
const { resolve } = require('path')

setImmediate(() => console.log('[阶段3.immediate] immediate 回调1'))
setImmediate(() => console.log('[阶段3.immediate] immediate 回调2'))
setImmediate(() => console.log('[阶段3.immediate] immediate 回调3'))

Promise.resolve().then(() => {
    console.log('[...待切入下一阶段] promise 回调1')

    setImmediate(() => console.log('[阶段3.immediate] promise 回调1 增加的immediate 回调4'))
})

readFile('../package.json', 'utf-8', data => {
    console.log('[阶段2....IO回调] 读文件回调1')

    readFile('../video.mp4', 'utf-8', data => {
        console.log('[阶段2....IO回调] 读文件回调2')

        setImmediate(() => console.log('[阶段3.immediate] 读文件回调2 增加的immediate 回调4'))
    })

    setImmediate(() => {
        console.log('[阶段3.immediate] immediate 回调4')

        Promise.resolve().then(() => {
            console.log('[...待切入下一阶段] promise 回调2')
            process.nextTick(() => console.log('[...待切入下一阶段] promise 回调2 增加的 nextTick 回调5'))
        }).then(() => {
            console.log('[...待切入下一阶段] promise 回调3')
        })
    })

    setImmediate(() => {
        console.log('[阶段3.immediate] immediate 回调6')

        process.nextTick(() => console.log('[...待切入下一阶段] immediate 回调6 增加的 nextTick 回调7'))
        console.log('[...待切入下一阶段] 这块正在同步阻塞的读一个大文件');
        const video = readFileSync(resolve(__dirname, '../video.mp4'), 'utf-8')
        process.nextTick(() => console.log('[...待切入下一阶段] immediate 回调6 增加的 nextTick 回调8'))

        readFile('../package.json', 'utf-8', () => {
            console.log('[阶段2....IO回调] 读文件回调3')

            setImmediate(() => console.log('[阶段3.immediate] 读文件回调3 增加的immediate 回调6'))

            setTimeout(() => console.log('[阶段1....定时器] 读文件回调3 增加的定时器回调8'), 0);
        })
    })

    process.nextTick(() => {
        console.log('[...待切入下一阶段] 读文件回调 1 增加的 nextTick 回调6')
    })

    setTimeout(() => console.log('[阶段1....定时器] 定时器 回调5'), 0)
    setTimeout(() => console.log('[阶段1....定时器] 定时器 回调6'), 0)
})

setTimeout(() => console.log('[阶段1....定时器] 定时器 回调1'), 0)
setTimeout(() => {
    console.log('[阶段1....定时器] 定时器 回调2')

    process.nextTick(() => {
        console.log('[...待切入下一阶段] nextTick 回调5')
    })
}, 0)
setTimeout(() => console.log('[阶段1....定时器] 定时器 回调3'), 0)
setTimeout(() => console.log('[阶段1....定时器] 定时器 回调4'), 0)

process.nextTick(() => console.log('[...待切入下一阶段] nextTick 回调1'))
process.nextTick(() => {
    console.log('[...待切入下一阶段] nextTick 回调2')
    process.nextTick(() => console.log('[...待切入下一阶段] nextTick 回调4'))
})
process.nextTick(() => console.log('[...待切入下一阶段] nextTick 回调3'))
```

直接贴上输出吧：

```text
[...待切入下一阶段] nextTick 回调1
[...待切入下一阶段] nextTick 回调2
[...待切入下一阶段] nextTick 回调3
[...待切入下一阶段] nextTick 回调4
[...待切入下一阶段] promise 回调1
[阶段1....定时器] 定时器 回调1
[阶段1....定时器] 定时器 回调2
[...待切入下一阶段] nextTick 回调5
[阶段1....定时器] 定时器 回调3
[阶段1....定时器] 定时器 回调4
[阶段3.immediate] immediate 回调1
[阶段3.immediate] immediate 回调2
[阶段3.immediate] immediate 回调3
[阶段3.immediate] promise 回调1 增加的immediate 回调4
[阶段2....IO回调] 读文件回调1
[...待切入下一阶段] 读文件回调 1 增加的 nextTick 回调6
[阶段3.immediate] immediate 回调4
[...待切入下一阶段] promise 回调2
[...待切入下一阶段] promise 回调3
[...待切入下一阶段] promise 回调2 增加的 nextTick 回调5
[阶段3.immediate] immediate 回调6
[...待切入下一阶段] 这块正在同步阻塞的读一个大文件
[...待切入下一阶段] immediate 回调6 增加的 nextTick 回调7
[...待切入下一阶段] immediate 回调6 增加的 nextTick 回调8
[阶段1....定时器] 定时器 回调5
[阶段1....定时器] 定时器 回调6
[阶段2....IO回调] 读文件回调3
[阶段3.immediate] 读文件回调3 增加的immediate 回调6
[阶段1....定时器] 读文件回调3 增加的定时器回调8
[阶段2....IO回调] 读文件回调2
[阶段3.immediate] 读文件回调2 增加的immediate 回调4
```