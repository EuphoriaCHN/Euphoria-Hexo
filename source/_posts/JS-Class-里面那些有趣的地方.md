---
title: JS class 里面那些有趣的地方
date: 2020-07-29 17:47:00
tags:
- Web
- JavaScript
categories:
- 前端
- JavaScript
updated: 2020-07-29 17:47:00
---

> <span class = 'introduction'>不是井里没有水，而是你挖的不够深。不是成功来得慢，而是你努力的不够多。</span><br/>
JavaScript 在 ES 6 中引入了 `class` 关键字，这个甜甜的语法糖给 JS OOP 带来了更多可能...

<!--more-->

<hr/>

## 前言

之前已经写过三篇 Blog，主要讲述了 JavaScript OOP 的初步入门、this 指向、原型链等：

<ul>
  <li><a href="https://www.wqh4u.cn/2019/12/07/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-01-Constructor/" rel="noopener noreferrer">JavaScript面向对象-01-Constructor</a></li>
  <li><a href="https://www.wqh4u.cn/2019/12/08/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-02-Prototype/" rel="noopener noreferrer">JavaScript面向对象-02-Prototype</a></li>
  <li><a href="https://www.wqh4u.cn/2020/01/14/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-03-%E5%8E%9F%E5%9E%8B%E4%B8%AD%E7%9A%84%E6%B3%A8%E6%84%8F%E7%82%B9/" rel="noopener noreferrer">JavaScript面向对象-03-原型中的注意点</a></li>
</ul>

故本篇不再赘述～

<div class="note info">本篇博客长时间更新，一次更新若干章节哦~</div>

<hr />

## 类方法与实例方法

最近在封装一个脚手架，需求是解析某个 **类对象** 里面的所有用户自定义方法，并且对每一个方法进行进一步的封装。

这让人很容易就想到了 `Object.getOwnPropertyNames()` 和 `Object.getOwnPropertyDescriptors()`，很快就写出来了这样的代码：

需要导出的类文件（`demo.js`）：

```javascript
class Demo {
  async normal(ctx) {
    console.log('normal');
  }
}

module.exports = new Demo();
```

入口文件（`index.js`）：

```javascript
const demo = require('./demo');

console.log(Object.getOwnPropertyDescriptors(demo));
```

这样看似没什么问题，demo 对象可以调用 `normal` 方法，通过 `Object.getOwnPropertyDescriptors` 应该可以拿到。

但执行的结果却是 `{}`...

什么？不太对，那我换一种方法写 `Demo` 类呢：

```javascript
class Demo {
  arrow = async ctx => {
    console.log('normal');
  }
}

module.exports = new Demo();
```

再次执行 `index.js`，得到的结果是神奇的 `{ arrow: {...} }`...（地铁老人看手机

来康康 MDN 上对 `getOwnPropertyDescriptors` 的解释：

<div class="note info"><b>Object.getOwnPropertyDescriptors()</b> 方法用来获取一个对象的所有自身属性的描述符。</div>

哦？一个对象的所有 **自身属性** 的描述符？

- 那么 `normal` 方法不是对象的自身属性了？
- `normal` 方法和原型链有什么关系？

随后又测试了一下，直接对 `Demo` 构造器执行 `Object.getOwnPropertyDescriptors`，发现可以展示出 `normal` 方法，并且不展示 `arrow` 方法...

那么 JS 引擎又是怎么解析这两个 ES6 语法糖的呢？上 Babel 看看..

```javascript
function _defineProperty(obj, key, value) {
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }
  return obj;
}

class Demo {
  constructor() {
    _defineProperty(this, 'arrow', async ctx => {
      console.log('arrow');
    });
  }

  async normal(ctx) {
    console.log('normal');
  }

}

module.exports = new Demo();
```

破案了，Babel 首先搞了个 `Object.defineProperty` 的 `Polyfill`，对于 `normal` 方法则直接放到了类里面，但对于 `arrow` 则是动态绑定到了 `this` 上，在对象使用 `normal` 时则是通过 property getter 搜寻到原型链上的方法。

可以很容易写出 Function 的写法：

```javascript
function Demo() {
  this.arrow = async ctx => {
    console.log('arrow');
  };
}

Demo.prototype.normal = ctx => {
  console.log('normal');
};

module.exports = new Demo();
```