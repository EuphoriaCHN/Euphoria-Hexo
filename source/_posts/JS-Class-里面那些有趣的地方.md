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

<hr />

## 类方法与实例方法

最近在封装一个脚手架，需求是解析某个 **类对象** 里面的所有用户自定义方法，并且对每一个方法进行进一步的封装。

这让人很容易就想到了 `Object.getOwnPropertyNames()` 和 `Object.getOwnPropertyDescriptors()`，很快就写出来了这样的代码：

需要导出的类文件（`demo.js`）：

```javascript
class Demo {
  async normal(ctx) {
    console.log(normal)
  }
}
```