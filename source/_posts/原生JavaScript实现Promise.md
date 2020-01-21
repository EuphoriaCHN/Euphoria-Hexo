---
title: 原生JavaScript实现Promise
date: 2020-01-21 18:17:36
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
---

> <span class = 'introduction'>孤单一人的时间使自己变得优秀，给来的人一个惊喜，也给自己一个好的交代。</span><br/>
Promise 是前端面试中的高频问题，如果能根据 Promise A+ 规范，写出符合规范的源码，那么对于面试中的 Promise 相关的问题，都能够给出比较完美的答案。
<span class="introduction">长文警告！</span>

<!--more-->

<hr/>

## 前言

此篇博客实操性极强，单纯的阅读是行不通的！

直至博客发布日，Euphoria 已将 Promise 的实现前前后后敲了快二十遍，最快（仅包含 constructor，then，resolvePromise 方法与测试）只需要七分钟，同时通过了 `promises-aplus-tests` 测试 <del>闲得无聊</del>。

Euphoria 建议需要完全理解下面要介绍的 Promise A+ 规范，对照规范多写几次实现。

<hr />

## 为什么会出现 Promise A+ 规范

### 规范出现的原因

在编写 JavaScript 程序时，经常会用到异步，但往往在异步请求数据时，我们并不知道什么时候会返回数据。这对需要处理异步在返回数据之后的逻辑造成了困难，因此我们需要用到 **回调函数**。

然而有时候，我们需要在回调函数中再次嵌套一个异步操作，这个异步操作就又需要一个回调函数...

就这样，形成了 <span class="red-target">回调地狱</span>。

```javascript
// jQuery
$http.get('localhost:8080').success((data, status, config, headers) => {
    setTimeout(() => {
        $(element).fadeIn(1000, function() {
            // 回调地狱
            $(this).fadeOut(1000);
        });
    });
}).error((data, status, config, headers) => {
    
});
```

正是为了杜绝以上两种情况的出现，<a href="https://promisesaplus.com/">Promise/A+</a> 规范诞生了。

<hr />

## 什么是 Promise/A+ 规范

<div class="note info"><b>An open standard for sound, interoperable JavaScript promises—by implementers, for implementers.</b></div>

一个 Promise 表示异步操作的最终结果，与 promise 进行交互主要是通过其 `then` 方法，该方法传入的回调函数以接收 promise 的最终值或 promise 失败的原因。

<a href="https://promisesaplus.com/">Promise/A+</a> 规范详细地介绍了 `then` 方法的行为，提供了可互操作的基础，所有 <a href="https://promisesaplus.com/">Promise/A+</a> 兼容的 Promise 实现都可以依靠该基础来提供。

因此，该规范被认为是非常稳定的。

从历史上看，<a href="https://promisesaplus.com/">Promise/A+</a> 阐明了早期的 <a href="http://wiki.commonjs.org/wiki/Promises/A">Promise/A</a> 提案的行为条款。

核心的 <a href="https://promisesaplus.com/">Promise/A+</a> 是专注于提供一种可以互操作的 `then` 方法。

<hr />

## Promise/A+ 规范解读

以下内容是源自 <a href="https://promisesaplus.com/">Promise/A+</a> 官网的翻译版本 + 个人理解版本，英语好的朋友可以自行阅读 <a href="https://promisesaplus.com/">Promise/A+</a> 官方文档。

### Terminology

**1.1.** "promise" 是一个符合本规范的，并具有 `then` 方法的一个对象或函数

**1.2.** "thenable" 是一个具有 `then` 方法的对象或函数

**1.3.** "value" 可以是任何一个合法的 JavaScript 值，包括 `undefined`、一个 *thenable* 或一个 promise

**1.4.** "exception" 是一个使用 `throw` 关键字所抛出的值

**1.5.** "reason" 是表明这个 promise 被 reject 的原因

### Requirements

#### Promise States

一个 promise 必须处于以下三个状态之一：`pending`、`fulfilled` 或 `rejected`

**2.1.1.** 当处于 `pending` 态时，一个 promise：

<ul style="list-style: none;">
    <li><b>2.1.1.1.</b> 可能会转换为 <code>fulfilled</code> 或 <code>rejected</code> 状态</li>
</ul>

**2.1.2.** 当处于 `fulfilled` 时，一个 promise：

<ul style="list-style: none;">
    <li><b>2.1.2.1.</b> 它绝不会再转变为其他状态</li>
    <li><b>2.1.2.2.</b> 它必须存在一个不可被改变的 <em>value</em> 值，以此表明成功时的值</li>
</ul>

**2.1.3.** 当处于 `rejected` 时，一个 promise：

<ul style="list-style: none;">
    <li><b>2.1.3.1.</b> 它绝不会再转变为其他状态</li>
    <li><b>2.1.3.2.</b> 它必须存在一个不可被改变的 <em>reason</em> 值，以此表明其失败的原因</li>
</ul>

#### The `then` Method

一个 promise 必须提供一个 `then` 方法去访问其最终成功时的值或其失败的原因。

一个 promise 的 `then` 方法可以接收两个参数：

```javascript
promise.then(onFulfilled, onRejected)
```

**2.2.1.** 这两个参数都是可选的参数：

<ul style="list-style: none;">
    <li><b>2.2.1.1.</b> 如果 <code>onFulfilled</code> 不是一个函数，那么必须忽略</li>
    <li><b>2.2.1.2.</b> 如果 <code>onRejected</code> 不是一个函数，那么必须忽略</li>
</ul>

**2.2.2.** 如果 `onFulfilled` 是一个函数：

<ul style="list-style: none;">
    <li><b>2.2.2.1.</b> 它必须在 promise 状态变为 <code>fulfilled</code> 之后调用，并使用 <em>value</em> 的值作为其第一个参数</li>
    <li><b>2.2.2.2.</b> 它绝不能在 promise 状态变为 <code>fulfilled</code> 之前调用</li>
    <li><b>2.2.2.3.</b> 它的调用次数绝不能超过一次</li>
</ul>

**2.2.3.** 如果 `onFulfilled` 是一个函数：

<ul style="list-style: none;">
    <li><b>2.2.3.1.</b> 它必须在 promise 状态变为 <code>rejected</code> 之后调用，并使用 <em>value</em> 的值作为其第一个参数</li>
    <li><b>2.2.3.2.</b> 它绝不能在 promise 状态变为 <code>rejected</code> 之前调用</li>
    <li><b>2.2.3.3.</b> 它的调用次数绝不能超过一次</li>
</ul>

**2.2.4.** `onFulfilled` 和 `onRejected` 在 <a href="https://es5.github.io/#x10.3">执行上下文</a> 堆栈仅包含平台代码前不得调用 [<a href="#point-3-1">3.1</a>]

**2.2.5.** `onFulfilled` 和 `onRejected` 必须作为函数去调用（即使没有 *value* 值）[<a href="#point-3-2">3.2</a>]

**2.2.6.** `then` 方法可能在同一个 promise 中被多次调用：

<ul style="list-style: none;">
    <li><b>2.2.6.1.</b> 如果/当 promise 被 fulfilled 了，那么所有相应的 <code>onFulfilled</code> 回调函数必须按照其对应 <code>then</code> 函数调用顺序依次执行</li>
    <li><b>2.2.6.2.</b> 如果/当 promise 被 rejected 了，那么所有相应的 <code>onRejected</code> 回调函数必须按照其对应 <code>then</code> 函数调用顺序依次执行</li>
</ul>

**2.2.7.** `then` 方法必须返回一个 promise [<a href="#point-3-3">3.3</a>]：

```javascript
promise2 = promise1.then(onFulfilled, onRejected);
```

<ul style="list-style: none;">
    <li><b>2.2.7.1.</b> 如果 <code>onFulfilled</code> 或 <code>onRejected</code> 其中一个返回了值 <code>x</code>，则需要运行 Promise 解决程序 <code>[[Resolve]](promise2, x)</code></li>
    <li><b>2.2.7.2.</b> 如果 <code>onFulfilled</code> 或 <code>onRejected</code> 其中抛出了一个异常 <code>e</code>，则 promise2 必须以 <code>e</code> 为缘由被 <em>reject</em></li>
    <li><b>2.2.7.3.</b> 如果 <code>onFulfilled</code> 不是一个函数，并且 promise1 已经处于成功态，那么 promise2 必须以与 promise1 的 <em>value</em> 相同的值被 <em>resolve</em></li>
    <li><b>2.2.7.4.</b> 如果 <code>onRejected</code> 不是一个函数，并且 promise1 已经处于失败态，那么 promise2 必须以与 promise1 的 <em>reason</em> 相同的值被 <em>reject</em></li>
</ul>

#### The Promise Resolution Procedure

Promise 解决程序是一个抽象的操作 <code>[[Resolve]](promise2, x)</code>，其输入一个 promise 和一个值 `x`。

**2.3.1.** 如果 promise2 和 `x` 是同一个对象，那么令 promise2 为 *reject*，并以 `TypeError` 作为原因

**2.3.2.** 如果 `x` 恰好是一个 Promise 对象，那么采用它的状态 [<a href="#point-3-4">3.4</a>]：

<ul style="list-style: none;">
    <li><b>2.3.2.1.</b> 如果 <code>x</code> 处于 <em>pending</em> 态，那么 promise2 也要处于 <em>pending</em> 态，直到 <code>x</code> 变成了 <em>fulfilled</em> 态或者 <em>rejected</em> 态</li>
    <li><b>2.3.2.2.</b> 如果 <code>x</code> 处于 <em>fulfilled</em> 态，那么 promise2 也以与 <code>x</code> 同样的 <em>value</em> 被 <em>resolve</em></li>
    <li><b>2.3.2.3.</b> 如果 <code>x</code> 处于 <em>rejected</em> 态，那么 promise2 也以与 <code>x</code> 同样的 <em>reason</em> 被 <em>reject</em></li>
</ul>

**2.3.3.** 否则，如果 `x` 是一个对象或函数：

<ul style="list-style: none;">
    <li><b>2.3.3.1.</b> 新建一个变量 <code>then</code>，令其等于 <code>x.then</code> [<a href="#point-3-5">3.5</a>]</li>
    <li><b>2.3.3.2.</b> 如果在 <code>x.then</code> 中抛出了一个异常 <code>e</code>，那么 promise2 将会以 <code>e</code> 被 <em>reject</em></li>
    <li><b>2.3.3.3.</b> 如果 <code>then</code> 是一个函数，那么以 <code>x</code> 为函数中的 <code>this</code> 去调用它，与普通的 <code>then</code> 方法相同，其接收两个参数：<code>onFulfilled</code> 和 <code>onRejected</code>：</li>
    <li>
        <ul style="list-style: none;">
            <li><b>2.3.3.3.1.</b> 如果/当 <code>onFulfilled</code> 被调用了，并且传入的参数是 <code>y</code>，那么再次调用 <code>[[Resolve]](promise2, y)</code></li>
            <li><b>2.3.3.3.2.</b> 如果/当 <code>onRejected</code> 被调用了，并且传入的参数是 <code>r</code>，那么 promise2 需要以 <code>r</code> 为 <em>reason</em> 被 <em>reject</em></li>
            <li><b>2.3.3.3.3.</b> 如果同时调用了 <code>onFulfilled</code> 与 <code>onRejected</code>，或者对同一个函数进行了多次调用，则只执行第一次调用，其余的所有调用都应当被忽略</li>
            <li><b>2.3.3.3.4.</b> 如果在调用 <code>then</code> 时抛出了异常 <code>e</code>：</li>
            <li>
                <ul style="list-style: none;">
                    <li><b>2.3.3.3.4.1.</b> 如果 <code>onFulfilled</code> 或 <code>onRejectde</code> 已经被调用过了，则忽略这个异常</li>
                    <li><b>2.3.3.3.4.2.</b> 否则，以 <code>e</code> 为 <em>reason</em>，令 promise2 被 <em>reject</em></li>
                </ul>
            </li>
        </ul>
    </li>
    <li><b>2.3.3.4.</b> 如果 <code>then</code> 不是一个函数，那么将 <code>x</code> 作为 <em>value</em>，令 promise2 被 <em>resolve</em></li>
</ul>

**2.3.4.** 如果 <code>x</code> 不是一个函数或对象，那么将 <code>x</code> 作为 <em>value</em>，令 promise2 被 <em>resolve</em>

如果 promise2 被一个循环的 *thenable* *resolve* 了，这样会因为 `[[Resolve]](promise, thenable)` 的递归性质最终再次调用 `[[Resolve]](promise, thenable)`，遵循上述算法将会导致递归没有出口。<a href="https://promisesaplus.com/">Promise/A+</a> 规范鼓励（但不是必须的）去检测这种递归，并以 `TypeError` 为 *reason* 使得当前递归栈顶中的 promise 被 *reject*。[<a href="#point-3-6">3.6</a>]

### Notes

<a name="point-3-1" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.1.</b></a> 这里的“平台代码”是指 JS 引擎、环境和 promise 实现代码。实际上，这一要求确保 `onFulfilled` 和 `onRejected` 在调用 `then` 事件循环之后，使用一个新的堆栈去异步执行。这可以通过“宏任务”机制（例如 <a href="https://html.spec.whatwg.org/multipage/webappapis.html#timers">setTimeout</a> 或 <a href="https://dvcs.w3.org/hg/webperf/raw-file/tip/specs/setImmediate/Overview.html#processingmodel">setImmediate</a>）或通过“微任务”机制（例如 <a href="https://dom.spec.whatwg.org/#interface-mutationobserver">MutationObserver</a> 或 <a href="https://nodejs.org/api/process.html#process_process_nexttick_callback">process.nextTick</a>）。由于 promise 的实现被视为了平台代码，因此它本身可能包含一个任务调度队列或调用处理程序的“蹦床”。

<a name="point-3-2" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.2.</b></a> 也就是说，在 JavaScript 的严格模式下，`undefined` 可能会作为 `this` 的值出现，然而在非严格模式下，它将会作为一个全局变量。

<a name="point-3-3" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.3.</b></a> promise 的实现可以允许 `promise2 === promise1`（即：`promise2 === x`），前提是应当满足所有的要求。每个实现都应该记录它是否可以生成 `promise2 === promise1` 以及在什么条件下会生成 `promise1`。

<a name="point-3-4" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.4.</b></a> 一般来说，只有当 `x` 来自于当前的 promise 时，才可以知道它是一个真正的 promise。该条款允许使用特定的手段来采用一些已知且一致的 promise 状态。

<a name="point-3-5" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.5.</b></a> 这个过程首先存储了 `x.then` 的引用，然后测试这个引用（是否是一个函数），然后再调用这个引用。避免了对 x.then 属性的访问。这些预防措施对于确保访问器属性的一致性非常重要，因为访问器属性的值可能在两次检索之间发生变化。

<a name="point-3-6" style="text-decoration: none; color: rgb(100, 98, 97);"><b>3.6.</b></a> 实现不应该对递归循环链的深度做限制，并且假设超过该任意递归限制将会是无线的递归。只有真正的循环才会导致 `TypeError`；如果遇到了无限长的非重复的链，则永远的去递归其正确的行为。

<hr />

## 实现

### 创建 Promise 类

根据术语 1，promise 是一个有 then 方法的对象或者是函数，行为遵循本规范。那么就创建一个类（ES6 写法，下同）：

```javascript
class Promise {
    
}
```

### 完善 Promise 的状态

根据规范 2.1，Promise 必须处于以下三个状态之一: pending, fulfilled 或者是 rejected：

```javascript
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected';

class Promise {
    
}
```

### 完善构造器

根据原生 Promise，在 new 的时候需要传入一个 **executor** 执行器，这个执行器会在 new 返回这个 Promise 实例之前被调用。

在构造器中，令这个 Promise 实例的状态处于 *PENDING* 态。

**executor** 构造器接收两个参数，*resolve* 和 *reject*，他们两个都是函数：

- *resolve* 接收一个参数 *value*，代表当前 Promise 成功时的值（术语 3）
- *reject* 接收一个参数 *reason*，代表当前 Promise 失败的原因（术语 5）

根据规则 2.1.1、2.1.2、2.1.3，在调用 *resolve* 或 *reject* 时，如果当前 Promise 的状态是 *PENDING* 态，那么应该转换成对应的 *FULFILLED* 或 *REJECTED*。

根据原生 Promise 得知，如果 **executor** 在执行中抛出了一个异常，那么当前 promise 则要进入失败态：

```javascript
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected';

class Promise {
    constructor(executor) {
        this.status = PENDING;
        
        // 使用箭头函数是为了保证 this 的一致性
        let resolve = value => {
            if (this.status === PENDING) {
                this.status = FULFILLED;
                this.value = value;
            }
        };
        
        let reject = reason => {
            if (this.status === PENDING) {
                this.status = REJECTED;
                this.reason = reason;
            }
        };
        
        try {
            executor(resolve, reject);
        } catch (e) {
            reject(e);
        }
    }
}
```

### 构造 then 方法

根据规则 2.2.1，`then` 方法接收两个参数 `onFulfilled` 和 `onRejected`：

```javascript
// 上面省略，then 方法是一个成员函数
then(onFulfilled, onRejected) {
    
}
// 下面省略
```

### then 方法的参数

根据规则 2.2.5、2.2.7.3、2.2.7.4，需要对传入的 `onFulfilled` 和 `onRejected` 的类型进行判断：

```javascript
then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason; };
}
```

### then 方法的返回值

根据规则 2.2.7，`then` 方法会返回一个新的 Promise 实例 `promise2`：

```javascript
then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason; };
    
    let promise2 = new Promise((resolve, reject) => {
        
    });
    
    return promise2;
}
```

### 实现返回的新的 Promise 实例

根据规则 2.2.2、2.2.3，需要对原先的 promise（即调用 `then` 方法的 `this`）的状态进行判断，以此来确定 `promise2` 的状态。

根据规则 2.2.4，需要以异步的方式去执行 `onFulfilled` 和 `onRejected`（这里统一采用 `setTimeout`）。

<div class="note info">setTimeout() 可以省略第二个参数，只传入第一个回调函数作为参数，但是由于 JS 引擎与硬件等原因，不可能达到完全的 0ms 立即执行，往往会有一个最小时间（浏览器中通常是 4ms）</div>

```javascript
then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason; };
    
    let promise2 = new Promise((resolve, reject) => {
        // 这里如果不使用箭头函数，这个 this 的值就会变成 promise2
        // 如果使用 function，请在此之前使用 let self = this; 去存储一个 promise 的引用
        if (this.status === FULFILLED) {
            // Promise/A+ 2.2.4 --- setTimeout
            setTimeout(() => {
                onFulfilled(this.value);
            });
        } else if (this.status === REJECTED) {
            setTimeout(() => {
                onRejected(this.reason);
            });
        } else {
            
        }
    });
    
    return promise2;
}
```

### 利用发布订阅解决 PENDING 态的问题

在我的 <a href="https://www.wqh4u.cn/2020/01/14/JavaScript%E8%A7%82%E5%AF%9F%E8%80%85%E6%A8%A1%E5%BC%8F%E4%B8%8E%E5%8F%91%E5%B8%83%E8%AE%A2%E9%98%85/">这篇博客</a> 中解释了什么是发布订阅哦~

根据规则 2.2.6.1、2.2.6.2，如果当前调用 `then` 的 promise 实例还处于 *PENDING* 态，那么所有相应的 `onFulfilled` 和 `onRejected` 都需要等到这个 promise 实例被完成时（改变状态时），去依次执行（这里也解决了同一个 promise 实例多次调用 `then` 方法的问题）。

这其实就用到了 **“发布订阅”** 的思想，首先将所有的 `onFulfilled` 和 `onRejected` 存储起来（订阅），等到 promise 实例的状态改变时（发布），依次调用订阅的回调函数（广播）。

首先修改构造器，增加两个属性去接收订阅的回调函数：

```javascript
class Promise {
    constructor(executor) {
        this.status = PENDING;
        
        // 增加两个属性
        this.onFulfilledCallback = [];
        this.onRejectedCallback = [];
        
        // 以下省略...
    }
}
```

然后修改 `then` 中的方法：

```javascript
then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason; };
    
    let promise2 = new Promise((resolve, reject) => {
        if (this.status === FULFILLED) {
            setTimeout(() => {
                onFulfilled(this.value);
            });
        } else if (this.status === REJECTED) {
            setTimeout(() => {
                onRejected(this.reason);
            });
        } else {
            // 当 this.status === PENDING 时，需要将回调函数进行存储
            // 因为 “发布订阅” 最后是逐个调用订阅回调的，所以这里要 push 一个函数
            this.onFulfilledCallback.push(() => {
                // 又因为规则 2.2.4，即使存储了 onFulfilled 和 onRejected，也要去异步的执行
                setTimeout(() => {
                    onFulfilled(this.value);
                });
            });
            this.onRejectedCallback.push(() => {
                setTimeout(() => {
                    onRejected(this.reason);
                });
            });
        }
    });
    
    return promise2;
```

最后修改构造器中的 *resolve* 和 *reject*，因为它们的调用会造成 promise 状态的改变，既然状态发生了改变，则需要去对订阅者 **发布广播** ：

```javascript
class Promise {
    constructor(executor) {
        // 以上省略...
        
        let resolve = value => {
            if (this.status === PENDING) {
                this.status = FULFILLED;
                this.value = value;
                // publish
                this.onFulfilledCallback.forEach(value => value());
                // 注意这个 value 值，它只是 forEach 回调的第一个参数哦
            }
        };
        
        let reject = reason => {
            if (this.status === PENDING) {
                this.status = REJECTED;
                this.reason = reason;
                // publish
                this.onRejectedCallback.forEach(value => value());
            }
        };
        
        // 以下省略...
    }
}
```

### 定义 Promise Resolution Procedure

根据规则 2.3，我们需要一个承诺解决函数 promiseResolutionProcedure()，我们令其接收四个参数：

- promise2：为 `then` 方法应当返回的值，即 promise2（本身也是对他进行处理）
- x：为 `then` 中，调用 `then` 方法的 promise 实例（就是 `this`）的 `onFulfilled` 和 `onRejected` 的返回值，因为其的可能性太多，所以需要 romise Resolution Procedure 去处理
- resolve：为传入 promise2 的构造器中 **executor** 的第一个参数
- reject：为传入 promise2 的构造器中 **executor** 的第二个参数

这里传入 *resolve* 和 *reject* 的原因之一是方便对 promise2 进行状态确定的处理：

```javascript
class Promise {
    // 省略
}

function promiseResolutionProcedure(promise2, x, resolve, reject) {  
    // 暂时不写
}
```

### 完善 then 方法

根据规则 2.2.7.1 和 2.2.7.2 得知：

- **2.2.7.1** `onFulfilled` 和 `onRejected` 都是会有返回值 `x` 的，并且需要对这个 x 进行 Promise Resolution Procedure
- **2.2.7.2** 如果在 `onFulfilled` 和 `onRejected` 中抛出了异常 `e`，那么 promise2 需要以 `e` 为 *reason* 被 *reject*

这里不要忘了，因为是对所有的 `onFulfilled` 和 `onRejected` 进行处理，所以在 promise.status 为 *PENDING* 态时，也要写进去奥：

```javascript
// 以上省略...

then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason; };
    
    let promise2 = new Promise((resolve, reject) => {
        if (this.status === FULFILLED) {
            setTimeout(() => {
                // 首先根据 2.2.7.2，需要对 onFulfilled 和 onRejected 进行异常处理
                try {
                    // 又因为 2.2.7.1，onFulfilled 和 onRejected 都可能返回一个 x
                    // 这时候需要对 x 进行捕获
                    let x = onFulfilled(this.value);
                    // 捕获完了后就要对 x 的值进行分析
                    // 此时需要调用 Promise Resolution Procedure
                    promiseResolutionProcedure(promise2, x, resolve, reject);
                    // 不用担心这里由于 promise2 是由 let 定义的，从而导致这一句 promise2 的值是 undefined
                    // 因为这块代码是异步执行，在真正执行到这里时对 promise2 的定义早都完了
                } catch (e) {
                    reject(e); // 这个 reject 是 promise2 的 reject，不要搞混了
                }
                // 下同，对每一个 onFulfilled 和 onRejected 都要处理
            });
        } else if (this.status === REJECTED) {
            setTimeout(() => {
                try {
                    let x = onRejected(this.reason);
                    promiseResolutionProcedure(promise2, x, resolve, reject);
                } catch (e) {
                    reject(e);
                }
            });
        } else {
            this.onFulfilledCallback.push(() => {
                setTimeout(() => {
                    try {
                        let x = onFulfilled(this.value);
                        promiseResolutionProcedure(promise2, x, resolve, reject);
                    } catch (e) {
                        reject(e);
                    }
                });
            });
            this.onRejectedCallback.push(() => {
                setTimeout(() => {
                    try {
                        let x = onRejected(this.reason);
                        promiseResolutionProcedure(promise2, x, resolve, reject);
                    } catch (e) {
                        reject(e);
                    }
                });
            });
        }
    });
    
    return promise2;
}

// 以下省略...
```

### 最难的 Promise Resolution Procedure

根据规范 2.3.1，如果 promise2 和 x 是全等的，那么 promise2 应该以 `TypeError('Chaining cycle')` 被 *reject*。

因为一个 promise 对象也是属于 `object` 或一个 `function` 的，所以在执行规范 2.3.2 之前需要去验证规范 2.3.3，即 `x` 是否为一个对象或者函数。

<div class="note danger">注意一点，在神奇的 JavaScript 中，<code>typeof null === 'object'</code></div>

根据规范 2.3.4，如果 `x` 既不是对象也不是函数，那么 promise2 应该处于成功态（被 <em>resolve</em>），且 <em>value</em> 值为 `x`：

```javascript
// 以上省略...
function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // Promise/A+ 2.3.1
    if (promise2 === x) {
        reject(new TypeError('Chaining cycle'));
    }
    
    // Promise/A+ 2.3.3
    if (x && typeof x === 'object' || typeof x === 'function') {
        // 这里由于运算符优先级的问题，不能将 object 和 function 颠倒！
    } else {
        // Promise/A+ 2.3.4
        resolve(x);
    }
}
```

现在就该检查 `x` 是不是一个 *thenable* 了。

根据规范 2.3.3.1，令 `then` 变量与 `x.then` 同引用。

根据规范 2.3.3.3，如果同时调用 `onFulfilled` 和 `onRejected`，或者对同一参数进行了多次调用，则第一个调用优先，而所有其他调用均被忽略，所以需要维护一个值，去判断是否为第一次调用。

根据规范 2.3.3.2，如果在检索 `x.then` 时抛出了异常 `e`，那么 promise2 则应该以 `e` 为 *reason* 被 *reject*。

根据规范 2.3.3.4，如果 `x.then` 不是一个函数（不是 <em>thenable</em>），那么 promise2 则应该以 `x` 为 <em>value</em> 被 *resolve*。

根据规范 2.3.3，如果 `x.then` 是一个函数，且根据 Promise Resolution Procedure 的定义：<b>如果 x 是 <em>thenable</em>，那么最起码在 then 行为类似于一个 promise 实例的情况下，尝试对其采用 promise 实例应该有的方法，否则执行规范 2.3.3.4。</b>

<div class="note info">个人认为，这一步是将规范 2.3.2 结合到了 2.3.3 中去实现，因为 2.3.3 中的 x 也是一个 <em>thenable</em>，又因为 Promise Resolution Procedure 定义也说了，那么只要是一个 <em>thenable</em>，就把它当作一个 promise 实例去试试。</div>

根据规范 2.3.3.3，`then` 是一个函数，那么需要用 `x` 作为调用这个 `then` 的 `this`，并且这个 `then` 接收两个参数 `onFulfilled` 和 `onRejected`。（这就是对于 Promise Resolution Procedure 定义的一个实现，不管他到底是不是真正的 promise 实例的 then 方法，传进去就是了）

根据规范 2.3.3.3.1 和 2.3.3.3.2，对传入 `then` 中的 `onFulfilled` 和 `onRejected` 进行实现：

```javascript
function promiseResolutionProcedure(proemise2, x, resolve, reject) {
    if (promise2 === x) {
        reject(new TypeError('Chaining cycle'));
    }
    
    if (x && typeof x === 'object' || typeof x === 'function') {
        // Promise/A+ 2.3.3.3
        let used = false;
        try {
            // Promise/A+ 2.3.3.1
            let then = x.then;
            
            // Promise/A+ 2.3.3.4
            if (typeof x === 'function') {
                // Promise/A+ 2.3.3.3
                // Promise Resolution Procedure
                then.call(x, y => {
                    // Promise/A+ 2.3.3.3.1
                    if (used) return;
                    used = true;
                    promiseResolutionProcedure(promise2, y, resolve, reject);
                }, reason => {
                    // Promise/A+ 2.3.3.3.2
                    if (used) return;
                    used = true;
                    reject(reason);
                });
            } else {
                if (used) return;
                used = true;
                resolve(x);
            }
        } catch (e) {
            // Promise/A+ 2.3.3.2
            if (used) return;
            used = true;
            reject(e);
        }
    } else {
        resolve(x);
    }
}
```

<hr />

## 测试

### 准备工作

#### 导出模块

如果你的 Promise 代码在一个单独的文件（比如 Promise.js）中，那么需要使用 Node.js 中导出模块：

```javascript
class Promise {
    // 省略...
}

function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // 省略...
}

module.exports = Promise; // 导出模块
```

#### 安装测试脚本

有专门的测试脚本可以测试所编写的代码是否符合 Promise/A+ 的规范：

```bash
npm install -g promises-aplus-tests
```

#### 编写测试代码

在 Promise.js 中，添加如下代码：

```javascript
class Promise {
    // 省略...
}

function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // 省略...
}

Promise.defer = Promise.deferred = function() {
    let dfd = {};
    dfd.promise = new Promise((resolve, reject) => {
        dfd.resolve = resolve;
        dfd.reject = reject;
    });
    return dfd;
};

module.exports = Promise; // 导出模块
```

如果不加的话，可以康康报错，你就懂了 /doge

### 再贴一遍全部的代码吧~

```javascript
'use strict';

// Promise/A+ 2.1 --- 有三个状态
const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected';

// 术语 1 --- Promise 实例
class Promise {
    constructor(executor) {
        this.status = PENDING;

        // Promise/A+ 2.2.6.1 --- onFulfilled 订阅
        // Promise/A+ 2.2.6.2 --- onRejected 订阅
        this.onFulfilledCallback = [];
        this.onRejectedCallback = [];

        // 术语 3 --- resolve 定义
        let resolve = value => {
            if (this.status === PENDING) {
                // Promise/A+ 2.1.1 --- 对于 pending 态的描述
                // Promise/A+ 2.1.2 --- 对于 fulfilled 态的描述
                this.status = FULFILLED;
                this.value = value;
                // Promise/A+ 2.2.6.1 --- 当 resolve（发布）时，则需要广播
                this.onFulfilledCallback.forEach(value => value());
            }
        };

        // 术语 5 --- reject 定义
        let reject = reason => {
            if (this.status === PENDING) {
                // Promise/A+ 2.1.1 --- 对于 pending 态的描述
                // Promise/A+ 2.1.3 --- 对于 rejected 态的描述
                this.status = REJECTED;
                this.reason = reason;
                // Promise/A+ 2.2.6.2 --- 当 reject（发布）时，则需要进行广播
                this.onRejectedCallback.forEach(value => value());
            }
        };

        try {
            // 由原生 Promise 推断而来
            executor(resolve, reject);
        } catch (e) {
            reject(e);
        }
    }

    // Promise/A+ 2.2 --- then 方法
    // Promise/A+ 2.2.1 --- then 方法接收两个参数
    then(onFulfilled, onRejected) {
        // Promise/A+ 2.2.5 --- 这两个参数要作为函数被调用
        // Promise/A+ 2.2.7.3 --- 如果 onFulfilled 不是函数且 this 已 resolve，则 promise2 必须使用与相同的 value 来 resolve
        onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
        // Promise/A+ 2.2.7.4 --- 如果 onFulfilled 不是函数且 this 已 reject，则 promise2 必须使用与相同的 reason 来 reject
        onRejected = typeof onRejected === 'function' ? onRejected : reason => {
            throw reason;
        };

        // Promise/A+ 2.2.7 --- then 方法会返回一个新的 promise 实例
        let nextPromise = new Promise((resolve, reject) => {
            // Promise/A+ 2.2.2 --- 需要对 this 的状态进行判断（不能是 pending），从而调用对应函数
            // Promise/A+ 2.2.3 --- 需要对 this 的状态进行判断（不能是 pending），从而调用对应函数
            if (this.status === FULFILLED) {
                setTimeout(() => {
                    // Promise/A+ 2.2.4 --- 需要以异步的方式去执行
                    try {
                        // Promise/A+ 2.2.7.1 --- 需要对 onFulfilled 的返回值 x 去进行 Promise Resolution Procedure
                        let x = onFulfilled(this.value);
                        promiseResolutionProcedure(nextPromise, x, resolve, reject);
                    } catch (e) {
                        // Promise/A+ 2.2.7.2 --- 如果在执行 onFulfilled 时抛异常，那么 promise2 以异常为 reason 被 reject
                        reject(e);
                    }
                });
            } else if (this.status === REJECTED) {
                // Promise/A+ 2.2.2 --- 需要对 this 的状态进行判断（不能是 pending），从而调用对应函数
                // Promise/A+ 2.2.3 --- 需要对 this 的状态进行判断（不能是 pending），从而调用对应函数
                setTimeout(() => {
                    // Promise/A+ 2.2.4 --- 需要以异步的方式去执行
                    try {
                        // Promise/A+ 2.2.7.1 --- 需要对 onRejected 的返回值 x 去进行 Promise Resolution Procedure
                        let x = onRejected(this.reason);
                        promiseResolutionProcedure(nextPromise, x, resolve, reject);
                    } catch (e) {
                        // Promise/A+ 2.2.7.2 --- 如果在执行 onRejected 时抛异常，那么 promise2 以异常为 reason 被 reject
                        reject(e);
                    }
                });
            } else {
                // Promise/A+ 2.2.6.1 --- 如果还在 pending 态或多次调用，需要以 “发布订阅” 方法去解决 onFulfilled
                this.onFulfilledCallback.push(() => {
                    setTimeout(() => {
                        // Promise/A+ 2.2.4 --- 需要以异步的方式去执行
                        try {
                            // Promise/A+ 2.2.7.1 --- 需要对 onFulfilled 的返回值 x 去进行 Promise Resolution Procedure
                            let x = onFulfilled(this.value);
                            promiseResolutionProcedure(nextPromise, x, resolve, reject);
                        } catch (e) {
                            // Promise/A+ 2.2.7.2 --- 如果在执行 onFulfilled 时抛异常，那么 promise2 以异常为 reason 被 reject
                            reject(e);
                        }
                    });
                });
                // Promise/A+ 2.2.6.2 --- 如果还在 pending 态或多次调用，需要以 “发布订阅” 方法去解决 onRejected
                this.onRejectedCallback.push(() => {
                    setTimeout(() => {
                        // Promise/A+ 2.2.4 --- 需要以异步的方式去执行
                        try {
                            // Promise/A+ 2.2.7.1 --- 需要对 onRejected 的返回值 x 去进行 Promise Resolution Procedure
                            let x = onRejected(this.reason);
                            promiseResolutionProcedure(nextPromise, x, resolve, reject);
                        } catch (e) {
                            // Promise/A+ 2.2.7.2 --- 如果在执行 onRejected 时抛异常，那么 promise2 以异常为 reason 被 reject
                            reject(e);
                        }
                    });
                });
            }
        });
        return nextPromise;
    }
}

// Promise/A+ 2.3 --- 定义 Promise Resolution Procedure
function promiseResolutionProcedure(promise, x, resolve, reject) {
    // Promise/A+ 2.3.1 --- 如果 promise2 和 x 是全等的，那么 promise2 应该以 TypeError('Chaining cycle') 被 reject
    if (x === promise) {
        reject(new TypeError('Chaining cycle'));
    }

    // Promise/A+ 2.3.3 --- x 是否是一个对象或函数
    if (x && typeof x === 'object' || typeof x === 'function') {
        // Promise/A+ 2.3.3.3 --- 维护一个 used，保证只调用一次 onFulfilled 或 onRejected
        let used = false;
        try {
            // Promise/A+ 2.3.3.1 --- 令 then 与 x.then 同引用
            let then = x.then;
            if (typeof then === 'function') {
                // Promise/A+ 2.3.3 --- 如果 then 是一个函数，则将 x 当作 promise 实例来处理
                // Promise Resolution Procedure 定义的实现
                // Promise/A+ 2.3.3.3 --- 以 x 为 this 去调用 then 方法，并传入两个回调函数作为参数
                then.call(x, y => {
                    // Promise/A+ 2.3.3.3.1 --- 继续去以 Promise Resolution Procedure 处理 y 值
                    if (used) {
                        return;
                    }
                    used = true;
                    promiseResolutionProcedure(promise, y, resolve, reject);
                }, reason => {
                    // Promise/A+ 2.3.3.3.2 --- 如果失败了，那么以 reason 去将 promise2 reject
                    if (used) {
                        return;
                    }
                    used = true;
                    reject(reason);
                });
            } else {
                // Promise/A+ 2.3.3.4 --- 如果 then 不是一个函数，那么 promise2 以 x 为 value 被 resolve
                if (used) {
                    return;
                }
                used = true;
                resolve(x);
            }
        } catch (e) {
            // Promise/A+ 2.3.3.2 --- 如果检索 x.then 时抛异常，那么 promise2 应以异常值为 reason 被 reject
            if (used) {
                return;
            }
            used = true;
            reject(e);
        }
    } else {
        // Promise/A+ 2.3.4 --- 如果 x 既不是对象也不是函数，那么 promise2 以 x 为 value 被 resolve
        resolve(x);
    }
}

Promise.defer = Promise.deferred = function() {
    let dfd = {};
    dfd.promise = new Promise((resolve, reject) => {
        dfd.resolve = resolve;
        dfd.reject = reject;
    });
    return dfd;
};

module.exports = Promise;
```

### 开始测试

控制台切到当前目录下，执行以下命令：

```bash
promises-aplus-tests ./Promise.js
```

一共 872 个测试用例（2020.01.22 版本，不知道以后会不会多），如果都 OK 了最后会告诉你：

<div class="note success">872 passing</div>

即使不 OK，他在最后也会告诉你哪个测试点错了，比如在刚刚实现 Promise Resolution Procedure 时，特别强调了这一句话：

```javascript
// 以上省略...
function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // 以上省略...

    if (x && typeof x === 'object' || typeof x === 'function') {
        // 这里由于运算符优先级的问题，不能将 object 和 function 颠倒！
    } else {
        
    }
}
```

原因也说了，`typeof null === 'object'`，那如果颠倒过来，写成这样：

```javascript
// 以上省略...
function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // 以上省略...

    if (x && typeof x === 'function' || typeof x === 'object') {
        
    } else {
        
    }
}
```

再次执行测试，那么最终的结果是：

<div class="note">
    <p>862 passing</p>
    <p>10 failing</p>
</div>

再往下就是错误信息（很贴心了，还告诉你针对哪一个 Promise/A+ 规范错了）：

<ul style="list-style: none;">
    <li>
        <p>1) 2.3.3: Otherwise, if `x` is an object or function, 2.3.3.3: If `then` is a function, call it with `x` as `this`, first argument `resolvePromise`, and second argument `rejectPromise` 2.3.3.3.1: If/when `resolvePromise` is called with value `y`, run `[[Resolve]](promise, y)` `y` is not a thenable `y` is `null` `then` calls `resolvePromise` synchronously via return from a fulfilled promise:</p>
        <p style="color: rgb(255, 107, 104);">Error: timeout of 200ms exceeded. Ensure the done() callback is being called in this test.</p>
        <p style="color: rgb(85, 85, 85);">at Timeout.<anonymous> (NODE_MODULES_PATH\runnable.js:226:19)</p>
    </li>
</ul>

剩下的就不列举了，可以看出来错误原因：run [[Resolve]](promise, y) y is not a thenable y is null then calls resolvePromise...，再往下看其余的错误原因，要么 `x` 是 null 给错了，要么就是 `y` 是 null 给错了，这个时候就知道是查验类型时的报错了~

<hr />

## 后记

### 关于 Promise 其他功能的封装

虽然上述的 Promise 实现已经符合了 Promise/A+ 的规范，但是原生的 Promise 还提供了一些其他方法，比如说这些成员方法:

- catch()
- finally()

还有这些类方法：

- resolve()
- reject()
- all()
- race()

抽空更新这些函数的实现~

### 其他

这算是截至 2020.01.22，个人准备时间最长、最费心的一篇 Blog，算上写这篇博客，满足 Promise/A+ 的实现已经敲了二十次了吧（大概？）。

在准备的时候看到其中讲到了微服务又去看了微服务，看微服务的时候又看到了“HTTP的三次握手和四次挥手”，于是也就有了 <a href="https://www.wqh4u.cn/2020/01/19/%E6%9D%A5%E8%AF%B4%E8%AF%B4TCP%E7%9A%84%E4%B8%89%E6%AC%A1%E6%8F%A1%E6%89%8B%E5%92%8C%E5%9B%9B%E6%AC%A1%E6%8C%A5%E6%89%8B%E5%90%A7/">这篇博客</a> 的诞生。

快过年了🎉🎉🎉，给 2020 年所有看到这篇 Blog 的人说一声新年快乐（这句话是在 2020-01-22 04:11 时写下的）

<span class="red-target">若需转载，请一定注明来源！</span>

（下次更新一个关于微服务的？）
