---
title: Webpack4最佳实践与原理解析（八）
date: 2020-09-01 01:32:28
updated: 2020-09-01 14:34:00
tags:
  - Web
  - JavaScript
  - Webpack
  - 前端架构
categories:
  - 前端
  - Webpack
copyright: true
---

> <span class = 'introduction'>人非要经历一番不同平时的劫难才能脱胎换骨，成为真正能解决问题的人。</span><br/>
> 从本章开始，将会进入 Webpack 原理解析章节，从 Webpack 依赖库到手撕 Webpack！首先我们来说说 **Tabaple** 这个关键的三方库吧！

<!--more-->

<hr />

## 前言

如果读者没有基础则首先建议从“<a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">最佳实践系列</a>”开始哦~

<hr />

## Tapable

Webpack 本质上是一种 **事件流** 的机制，它的工作流程就是将各个插件串联起来，而实现这一切的核心就是 `Tapable`，`Tapable` 有点类似 Node 中 Events 库，核心原理也是依赖了 **发布 & 订阅模式**。

可以通过阅读 Webpack 源码：

```javascript
// webpack/lib/Compiler.js 核心编译源码
// 省略部分代码...
const {
  Tapable,
  SyncHook,
  SyncBailHook,
  AsyncParallelHook,
  AsyncSeriesHook,
} = require('tapable');
```

可以看到 Webpack 使用了 Tapable 的一些钩子，对于同步就有同步的钩子，异步有异步的钩子。

- Tapable
  - Sync
    - SyncHook
    - SyncBallHook
    - SyncWaterfallHook
    - SyncLoopHook
  - Async
    - AsyncParallel
      - AsyncParallelHook
      - AsyncParallelBallHook
    - AsyncSeries
      - AsyncSeriesHook
      - AsyncSeriesBallHook
      - AsyncSeriesWaterfallHook

<img src="./Tapable.png" alt="Tapable Hooks" title="Tapable Hooks" />

接下来我们会逐个介绍 Tabaple 里面的钩子，并说明它们的原理...

### 使用 Tapable

tapable 是一个第三方模块，我们首先需要安装这个包：

```s
npm install tapable
```

然后我们可以创建一个名为 `start.js` 的文件，开始尝试使用 tapable。

### 同步 SyncHook

一个很标准的“发布订阅”，通过 `tap` 进行订阅，最后使用 `call` 进行事件的发布：

```javascript
const { SyncHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new SyncHook(['name']),

      // 传入的是参数列表
      twice: new SyncHook(['name', 'event']),
    };
  }

  tap() {
    // 注册监听函数
    this.hooks.arch.tap('webpack', function (name) {
      console.log(`webpack tap ${name}`);
    });

    this.hooks.arch.tap('node', function (name) {
      console.log(`node tap ${name}`);
    });

    // 可以发布多条被监听的消息
    this.hooks.twice.tap('Twice', (name, event) => {
      console.log(`Twice ${name} ${event}`);
    });
  }

  start() {
    this.hooks.arch.call('Euphroia'); // 发布
    this.hooks.twice.call('mouse', 'click');
  }
}

const lesson = new Lesson();

lesson.tap(); // 注册事件

lesson.start(); // 事件触发
```

输出则是：

```text
webpack tap Euphroia
node tap Euphroia
Twice mouse click
```

既然是最基本的“发布订阅”模型，我们可以很简单的撸出它的部分代码：

```javascript
class SyncHook {
  // 钩子是同步的
  constructor(args) {
    // args 就是接收消息的数组
    this.tasks = []; // 订阅 callback 数组
  }
  tap(name, task) {
    // name 仅是一个标识
    this.tasks.push(task);
  }
  call(...args) {
    // 发布消息
    this.tasks.forEach((cb) => {
      cb(...args);
    });
  }
}

const hook = new SyncHook(['name']);

hook.tap('First', (name) => {
  console.log(`First: ${name}`);
});
hook.tap('Second', (name) => {
  console.log(`Second: ${name}`);
});

hook.call('One Event');
hook.call('Other Event');
```

所以，同步钩子会按照顺序且 **同步地** 执行订阅消息。

### 同步保险 SyncBailHook

我们在写同步 hook 时，可以增加一个 **熔断性的保险**，避免被阻塞。使用 `SyncBailHook` 可以解决这个问题，当某个订阅方法返回了一个 **非 undefined 值**，则事件流会就此 **中断**，不会继续向下执行：

```javascript
const { SyncBailHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new SyncBailHook(['name']),
    };
  }

  tap() {
    // 注册监听函数
    this.hooks.arch.tap('webpack', function (name) {
      console.log(`webpack tap ${name}`);
      // 返回了一个非 undefined 的值
      // 那么事件流就不会继续向下执行了
      return '学不动了，不想学了';
    });

    this.hooks.arch.tap('node', function (name) {
      console.log(`node tap ${name}`);
    });

    return this;
  }

  start() {
    this.hooks.arch.call('Euphroia');

    return this;
  }
}

new Lesson().tap().start();
```

因为在 `name` 为 `webpack` 的事件中，返回了一个 **非 undefined 值**，这将导致 **之后的** 通知不会被传达，此时输出是：

```text
webpack tap Euphoria
```

有了编写 `SyncHook` 的经验，只需要监听一下每个注册事件的 **返回值** 即可：

```javascript
// 省略部分代码...
class SyncBailHook {
  call(...args) {
    try {
      this.tasks.forEach((cb) => {
        const _returnValue = cb(...args); // 监听一下返回值，跳出事件流即可
        if (_returnValue) {
          throw _returnValue;
        }
      });
    } catch (e) {}
  }
}
```

### 同步瀑布 SyncWaterfallHook

之前的钩子，在两两事件订阅回调中是 **没有关联关系的**， 但是使用 **同步瀑布钩子** `SyncWaterfallHook`，就可以将前一个订阅方法的 **返回值** 去 **传递给** 下一个方法：

```javascript
const { SyncWaterfallHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new SyncWaterfallHook(['name']),
    };
  }

  tap() {
    // 注册监听函数
    this.hooks.arch.tap('webpack', function (name) {
      console.log(`webpack tap ${name}`);
      return '学不动了，不想学了';
    });

    this.hooks.arch.tap('node', function (data) {
      // 这时的 data 是上面 id 为 webpack 的返回值
      console.log(`node tap ${data}`);
    });

    return this;
  }

  start() {
    this.hooks.arch.call('Euphroia');

    return this;
  }
}

new Lesson().tap().start();
```

此时的输出是：

```text
webpack tap Euphroia
node tap 学不动了，不想学了
```

使用 `SyncWaterfallHook` 需要注意两点：

- 如果位于上层的订阅回调 **没有返回值**，那么下一层的回调参数仍然是 **发布的消息**
- 如果某个钩子回调参数有多个，且上层回调 **具有返回值**，那么仅会 **替换下一层的第一个参数**

实现原理也很简单，记录 **是否出现返回值** 即可，并将其应用于下一层（或逐层传递下去，就像 **瀑布** 那样）。

### 同步循环执行 SyncLoopHook

虽然 Webpack 中并没有怎么使用这个钩子，但还是需要介绍一下。当我们需求 **一次发布，执行某个监听函数多次** 的情况，就可以使用 `SyncLoopHook` 去实现，其效果为：**若某个监听函数的返回值不为 undefined，则重复执行它**。

```javascript
const { SyncLoopHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new SyncLoopHook(['name']),
    };
  }

  tap() {
    // 注册监听函数
    this.hooks.arch.tap('webpack', function (name) {
      console.log(`webpack tap ${name}`);
      // 会发现它会【循环执行】
      return Math.random() < 0.5 ? undefined : 'LOOP!';
    });

    this.hooks.arch.tap('node', function (name) {
      console.log(`node tap ${name}`);
    });

    return this;
  }

  start() {
    this.hooks.arch.call('Euphroia');

    return this;
  }
}

new Lesson().tap().start();
```

有了思路，修改也很好改了，这里不再做过多赘述...

### 异步并行钩子 AsyncParallelHook

如果我们希望多个事件监听函数可以 **并发执行**，此时我们就需要一些 **异步的钩子**。

```javascript
const { AsyncParallelHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new AsyncParallelHook(['name']),
    };
  }

  tap() {
    // 用异步的方法去注册监听函数
    this.hooks.arch.tapAsync('webpack', function (name, cb) {
      setTimeout(() => {
        console.log(`webpack tap ${name}`);
        cb(); // cb 就相当于 Promise 的 resolve
        // 也是代表这个事件监听函数执行完毕的信号
      }, 1000);
    });

    this.hooks.arch.tapAsync('node', function (name, cb) {
      setTimeout(() => {
        console.log(`node tap ${name}`);
        cb();
      }, 500);
    });

    return this;
  }

  start() {
    // 异步的钩子需要使用 callAsync 进行调用
    this.hooks.arch.callAsync('Euphroia', () => {
      // 为异步钩子的执行，提供一个回调方法
      // 如果对应的监听函数【有任何一个没有调用 cb】
      // 那么这整个钩子的回调则不会被调用
      console.log('END');
    });

    return this;
  }
}

new Lesson().tap().start();
```

`cb` 中是可以传递参数的：

- 第一个参数代表 **错误**：如果出错，则会中断串行执行（建议使用可熔断的 `AsyncSeriesBailHook`），为了正常使用第二个参数，其可以传 `null`；
- 第二个参数代表 **瀑布传递**：如果使用 `AsyncSeriesWaterfallHook`，则可以通过第二个参数传递给下游事件监听函数，结果与 `SyncWaterfallHook` 相同。

<div class="note info">并发执行并没有想象中的那么困难，就比如这个 <code>AsyncParallelHook</code>，它的底层实现就给我看懵了...</div>

`AsyncParallelHook` 对于每一个 Hook，内部维护了一个 **计数器**，当 `cb()` 被调用次数达到 **监听函数个数** 时，就会触发整个异步 Hook 的回调。

所以即使我们在一个监听函数中写多个 `cb()`...它也可以调用整个异步 Hook 回调，而且只要 `cb()` 调用次数超过阈值，整个 Hook 的回调还是 **立即调用** 的...

```javascript
const { AsyncParallelHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new AsyncParallelHook(['name']),
    };
  }

  tap() {
    // 用异步的方法去注册监听函数
    this.hooks.arch.tapAsync('webpack', function (name, cb) {
      setTimeout(() => {
        console.log(`webpack tap ${name}`);
        // 没 cb 调用
      }, 1000);
    });

    this.hooks.arch.tapAsync('node', function (name, cb) {
      setTimeout(() => {
        console.log(`node tap ${name}`);
        cb();
        cb(); // 调用两次
      }, 500);
    });

    return this;
  }

  start() {
    this.hooks.arch.callAsync('Euphroia', () => {
      console.log('END');
    });

    return this;
  }
}

new Lesson().tap().start();
```

最后的输出竟然是：

```text
node tap Euphroia      // 延迟 500 ms 出现
END                    // 和上一行 同时 出现
webpack tap Euphroia   // 再等 500 ms 出现
```

> 有点被惊到...

实现方法其实不难，注意一下 `cb` 在传递过程中可能会出现 `this` 指向问题即可，这里也不再赘述。

对于计数器，也可以参考 `Promise.all` 的思想。其实在 tapable 中也有很多 Promise 思想的体现...

### Promise 思想

刚刚介绍了 `tap` 和 `tapAsync`，一个同步一个异步。在异步处理时我们当然会 **首先** 想到 Promise 这个具有跨时代性的产物，在 tapable 中也对其做了处理，我们可以使用 `tapPromise` 去注册一个 Promise 而不是一个普通的函数：

```javascript
const { AsyncParallelHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new AsyncParallelHook(['name']),
    };
  }

  tap() {
    this.hooks.arch.tapPromise('webpack', function (name) {
      // 此时内部是一个 async 函数，返回一个 Promise 实例
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          console.log(`webpack tap ${name}`);
          resolve();
        }, 1000);
      });
    });
    this.hooks.arch.tapPromise('node', function (name) {
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          console.log(`node tap ${name}`);
          resolve();
        }, 500);
      });
    });

    return this;
  }

  start() {
    // 这里其实就是 Promise.all 的思想
    // 当然每一个事件监听函数返回的 Promise 实例必须被确定
    // 否则也会等不到结果
    this.hooks.arch.promise('Euphroia').then(() => {
      console.log('DONE');
    });

    return this;
  }
}

new Lesson().tap().start();
```

我们可以总结出，Tapable 中有三种注册事件的方法：

- tap：同步注册
- tapAsync：注册异步方法
- tapPromise：注册异步方法（Promise）

也有三种发布消息的方法：

- call：对应【同步注册】
- callAsync：对应【异步注册】
- promise：就是 Promise.all 的思想

### 异步串行钩子 AsyncSeriesHook

异步串行钩子稍微复杂一些，它会按照“顺序”（同步）去执行 **异步的事件监听** 方法，你可以将其看作是另一种 `await`：

```javascript
const { AsyncSeriesHook } = require('tapable');

class Lesson {
  constructor() {
    this.hooks = {
      arch: new AsyncSeriesHook(['name']),
    };
  }

  tap() {
    // 异步方法，使用 tapAsync
    this.hooks.arch.tapAsync('webpack', function (name, cb) {
      setTimeout(() => {
        console.log(`webpack tap ${name}`);
        cb();
      }, 1000);
    });
    this.hooks.arch.tapAsync('node', function (name, cb) {
      setTimeout(() => {
        console.log(`node tap ${name}`);
        cb();
      }, 1000);
    });

    return this;
  }

  start() {
    this.hooks.arch.callAsync('Euphroia', () => {
      console.log('DONE');
    });

    return this;
  }
}

new Lesson().tap().start();
```

看看输出结果：

```text
webpack tap Euphroia   # 延迟 1000 ms 输出
node tap Euphroia      # 再延迟 500 ms 输出
DONE                   # 和 node tap Euphoria 一起输出
```

这种方法很像 Express middleware 执行方法一样，第一个中间件执行完毕再去执行第二个，摸清楚思想接下来就可以去实现了：

```javascript
class AsyncSeriesHook {
  constructor(...argsList) {
    this.nextIndex = 0; // 记录下一个方法
    this.hookCallback = null; // 整个 hook 的 callback
    this.publishArgs = null; // 发布消息参数列表
    this.tasks = [];
  }

  cb() {
    // 防止下标越界
    if (this.nextIndex >= this.tasks.length) {
      if (this.hookCallback && typeof this.hookCallback === 'function') {
        this.hookCallback();
      }
      return;
    }
    // 顺序执行下一个
    this.tasks[this.nextIndex](...this.publishArgs, this.cb.bind(this));
    this.nextIndex += 1;
  }

  tapAsync(id, listener) {
    this.tasks.push(listener);
  }

  callAsync(...args) {
    const _hookCallback = args.pop();

    if (typeof _hookCallback !== 'function') {
      args.push(_hookCallback);
      this.hookCallback = null;
    } else {
      this.hookCallback = _hookCallback;
    }

    // 最开始只执行第一个
    // 顺序进行
    this.nextIndex = 1;
    this.publishArgs = args;

    this.tasks[0](...args, this.cb.bind(this));
  }
}
```

对于 `AsyncSeriesHook` 异步串行钩子来说，它也有对 `Promise` 思想的实现，且用法与 `AsyncParallelHook` 完全一样，只是对返回值的处理不同~

如果改写成 Promise 方法，其核心机制是这样：

```javascript
class AsyncSeriesHook {
  promise(...args) {
    const [first, ...others] = this.tasks;
    return others.reduce((nowPromise, nextPromise) => {
      return nowPromise.then(() => {
        nextPromise(...args);
      });
    }, first(...args));
  }
}
```

可以看到这里的源码思想，在 Redux 中也有被使用到，即一个 Promise 的收敛执行。

### 异步串行瀑布 AsyncSeriesWaterfallHook

有了 `SyncWaterfallHook` 的经验，我们知道 **瀑布钩子** 其实是将多个 **事件监听函数** 按照顺序联系到了一起。（这也就解释了为啥 **没有异步并发瀑布钩子**，因为你没办法串起来各个 listener）。

再回顾一下 `cb` 中可以接收的参数列表：

- 第一个参数代表 **错误**：如果出错，则会中断串行执行（建议使用可熔断的 `AsyncSeriesBailHook`），为了正常使用第二个参数，其可以传 `null`；
- 第二个参数代表 **瀑布传递**：如果使用 `AsyncSeriesWaterfallHook`，则可以通过第二个参数传递给下游事件监听函数，结果与 `SyncWaterfallHook` 相同。

部分代码如下：

```javascript
// 省略部分代码...
class Lesson {
  tap() {
    this.hooks.arch.tapAsync('webpack', function (name, cb) {
      setTimeout(() => {
        console.log(`webpack tap ${name}`);

        // 传递给下游消息监听
        cb(null, 'From Webpack waterfall');
      }, 1000);
    });
    this.hooks.arch.tapAsync('node', function (name, cb) {
      setTimeout(() => {
        console.log(`node tap ${name}`);
        cb();
      }, 500);
    });

    return this;
  }
}
```

如果传入一个 `Euphoria` 当作消息，那么最终的结果是：

```text
webpack tap Euphroia             # 初始传递的消息
node tap From Webpack waterfall  # 从上游传递下来的新消息
DONE                             # Hook`s callback
```

当然对于 `AsyncSeriesWaterfallHook` 也有 Promise 方法，其内部通过上游事件监听函数返回一个被 `resolve` 的 Promise 实例，对于下游来说获得的信息就是 _resolve data_，这里不再过多赘述...

<hr />

## 小憩一下

接下来的章节，我们将会开始尝试 **手写 Webpack**！这听起来就很有趣！
