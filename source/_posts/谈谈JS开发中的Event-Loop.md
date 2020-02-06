---
title: 谈谈JS开发中的Event Loop
date: 2020-02-06 20:20:37
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

<div><span class="answer-loading">答案加载中...请稍后</span><span class="show-answer" index="1" style="display: none;">点我可看答案哦：</span><span class="problem" id="problem-1" style="display: none;">：1 4 3 2</span></div>

**emmm早睡早起身体好，明天再更**

