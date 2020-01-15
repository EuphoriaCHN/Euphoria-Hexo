---
title: JavaScript的基本组成部分
date: 2019-12-07 21:48:50
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
image: "http://www.wqh4u.cn/2019/12/07/JavaScript的基本组成部分/java-script.jpg"
---

> <span class = 'introduction'>大多数人想改造这个世界，但却罕有人想改造自己。</span><br/>
JavaScript（通常缩写JS）是一种进阶的、直译的程式语言。JavaScript 是一门基于原型、函式先行的语言，是一门多范式的语言，它支援物件导向编程，指令式程式设计，以及函式语言程式设计。它被世界上的绝大多数网站所使用，也被世界主流浏览器（Chrome、IE、Firefox、Safari、Opera）支援。

<!--more-->

<hr/>

## JavaScript 的组成

**Java Script的三个主要组成部分是：ECMAScript(核心)，DOM（文档对象模型），BOM（浏览器对象模型）**

<img src="structure.png" alt="structure.png" title="JavaScript 的组成部分" />

<hr />

## ECMAScript

<div class="note info">
<p><code>ECMAScript</code>是一种由 <em>Ecma</em> 国际（前身为欧洲计算机制造商协会）在标准 <em>ECMA-262</em> 中定义的脚本语言规范。这种语言在万维网上应用广泛，它往往被称为 <em>JavaScript</em> 或 <em>JScript</em>，但实际上后两者是 <em>ECMA-262</em> 标准的实现和扩展。</p>
</div>

ECMA-262 没有参照 web 浏览器，规定了语言的组成部分，具体包括 <b>语法、类型、语言、关键字、保留字、操作符、对象</b>。

<code>ECMAScript</code>就是对该标准规定了各个方面内容的语言的描述。

1. 支持ECMA-262描述的所有“类型，值，对象，属性，函数，以及程序语法和语义” 。

2. 支持Unicode字符标准。

3. 添加ECMA-262没有描述的更多“类型，值，对象，属性，函数”，ECMA-262说说的浙西新增特性，主要是指该标准中没有规定的新对象和对象的新属性。

4. 支持ECMA-262中没有定义的“程序和正则表达式的语法”。也就是说可以修改和扩展内置的正则表达式语法。

**ECMAScript - 语法规范**
- 变量、数据类型、类型转换、操作符
- 流程控制语句：判断、循环
- 数组、函数、作用域、预解析（变量提升、函数提升）
- 对象、属性、方法、简单类型和复杂类型的区别
- 内置对象：Math、Date、Array
- 基本包装类型：Number、String、Boolean
  
<hr />

## Web APIs

### Document Object Models

**DOM(Document Object Models, 文档对象模型)** 是针对 XML 但经过扩展用于 HTML 的应用程序编程接口（API）。

**DOM** 把整个页面映射为一个多层次节点结构。

HTML 或者 XML 页面中的每个组成部分都是某种类型的节点，这些节点又包含着不同类型的数据。

在 **DOM** 中，页面一般可以用分层节点图表示。

<img src="DOM_tree.png" alt="DOM_tree.png" title="DOM 树" />

#### DOM级别

**DOM1** 级于 1998 年 10 月成为 W3C 的推荐标准。BOM1 由两个模块组成分别是 **DOM core 和 DOM HTML**。

<div class="note info">
<b>DOM core</b>：规定如何映射基于 XML 的文档结构，以便简化对文档中任意部分的访问和操作。

<b>DOM HTML</b>：在 DOM core 的基础上加以扩展，添加了针对 HTML 的对象和方法。
</div>

**DOM2** 级在原来 DOM 的基础上有扩充了鼠标和用户界面事件、范围、遍历等细分模块，通过对象接口增加了对 css 的支持。包括以下模块：

<div class="note info">
<b>DOM Views（DOM视图）</b>：定义了跟踪不同文档视图的接口。

<b>DOM Events（DOM事件）</b>：定义了事件与事件处理的接口。

<b>DOM Traversal and Range(DOM遍历和范围)</b>：定义了遍历和操作文档的接口。
</div>

**DOM3** 级则进一步扩展了 DOM，引入了 <span class="blue-target">加载和保存模块</span> 以统一方式加载和保存文档的方法，新增了 DOM 验证模块主要还是验证文档的方法。

### Browser Object Model

**BOM(Brower Object Model，浏览器对象模型)** 处理浏览器窗口和框架，人们习惯上把所有针对浏览器的 JavaScript 扩展算作是 BOM 的一部分。

BOM 包括：

1. 弹出新浏览器窗口的功能。
2. 移动、缩放和关闭浏览器窗口的功能。
3. 提供浏览器所加载页面的详细信息的 navigator 对象。
4. 提供浏览器所加载页面的详细信息的 location 对象。
5. 提供用户分辨率详细信息的screen对象。
6. 对 cookies 的支持。
7. 像 XMLHttpRequest 和 IE 的 ActionXobject 这样的自定义对象。

<hr />

## JavaScript 执行过程

<img src="jszxgc.png" alt="jszxgc.png" title="JavaScript 执行过程" />

- User Interface: 用户界面
- Browser Engine: 浏览器引擎，用来查询和操作渲染的引擎
- Rendering Engine: 渲染引擎，用来显示请求的内容，负责解析 HTML、CSS，并把解析的内容显示出来（生成一个 DOM 树）
- Networking: 网络，负责发送网络请求
- JavaScript Interpreter: JavaScript 解析器，负责执行 JavaScript 代码
- UI Backend: UI后端，用来绘制类似组合框的弹出窗口
- Data Persistence: 数据持久化，数据存储 cookie、sessionStorage
