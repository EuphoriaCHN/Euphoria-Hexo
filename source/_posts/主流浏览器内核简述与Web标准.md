---
title: 主流浏览器内核简述与Web标准
date: 2019-09-28 19:35:56
updated: 2020-01-22 00:43:12
tags:
- HTML
- 浏览器
- web
categories:
- 前端
- 面经
copyright: true
---


> <span class = 'introduction'>时间是个常数，但也是个变数。勤奋的人无穷多，懒惰的人无穷少。</span><br/>
浏览器最重要或者说核心的部分是 <code>“Rendering Engine”</code>，可大概译为“渲染引擎”，不过我们一般习惯将之称为“浏览器内核”。这个问题也是前端面试中最为常见的问题。

<!--more-->

<hr/>

## 什么是浏览器内核

<div class = "note info" style = "text-indent: 2em;">
<p>
浏览器最重要或者说核心的部分是 <code>“Rendering Engine”</code>，可大概译为“渲染引擎”，不过我们一般习惯将之称为“浏览器内核”。</p>
<p>
负责对网页语法的解释（如标准通用标记语言下的一个应用HTML、JavaScript）并渲染（显示）网页。 所以，通常所谓的浏览器内核也就是浏览器所采用的渲染引擎，渲染引擎决定了浏览器如何显示网页的内容以及页面的格式信息。
</p>
<p>
不同的浏览器内核对网页编写语法的解释也有不同，因此同一网页在不同的内核的浏览器里的渲染（显示）效果也可能不同，这也是网页编写者需要在不同内核的浏览器中测试网页显示效果的原因。
</p>
</div>
<p>浏览器内核又可以分成两部分：渲染引擎(Layout Engineer 或者 Rendering Engine)和 JS 引擎。</p>
<div class = "note danger">
    <p><strong>1. 渲染引擎</strong></p>
    <p>它负责取得网页的内容（HTML、XML、图像等等）、整理讯息（例如加入 CSS 等），以及计算网页的显示方式，然后会输出至显示器或打印机。浏览器的内核的不同对于网页的语法解释会有不同，所以渲染的效果也不相同。</p>
    <p><strong>2. JS 引擎</strong></p>
    <p>解析 Javascript 语言，执行 javascript语言来实现网页的动态效果。</p>
</div>

<hr />

## 常见的浏览器内核

### Trident：[ˈtraɪdnt]

国内很多的双核浏览器的其中一核便是 Trident，美其名曰 "兼容模式"。

代表： IE、傲游、世界之窗浏览器、Avant、腾讯TT、猎豹安全浏览器、360极速浏览器、百度浏览器等。

Windows 10 发布后，IE 将其内置浏览器命名为 Edge，Edge 最显著的特点就是新内核 EdgeHTML。

### Gecko：[ˈgekəʊ]

Gecko(Firefox 内核)： Mozilla FireFox(火狐浏览器) 采用该内核，Gecko 的特点是开放源代码、以 C++ 编写的网页排版引擎，是跨平台的。因此，其可开发程度很高，全世界的程序员都可以为其编写代码，增加功能。 

<div class = "note danger">
可惜这几年已经没落了， 比如打开速度慢、升级频繁、猪一样的队友 Flash、神一样的对手 Chrome。
</div>

### Presto：[ˈprestəʊ]

目前公认网页浏览速度最快的浏览器内核，然而代价是牺牲了网页的兼容性。

由 Opera Software 开发的浏览器排版引擎，Opera（欧朋浏览器），但由于市场选择问题，主要应用在手机平台–Opera mini

### Webkit：[webˈkɪt]

一个**开源**的浏览器引擎，同时 WebKit 也是苹果 Mac OS X **系统引擎框架**版本的名称，它拥有**清晰的源码结构、极快的渲染速度**，包含的 WebCore 排版引擎和 JavaScriptCore解析引擎，均是从 **KDE 的 KHTML 及 KJS 引擎**衍生而来。

许多网站都是**按照 IE 来架设**的，很多网站不兼容 Webkit 内核，比如登录界面、网银等网页均不可使用 Webkit 内核的浏览器。

Safari([səˈfɑri]), Google Chrome, 傲游3, 猎豹浏览器, 百度浏览器 opera浏览器 基于 Webkit 开发。

<div class = "note danger">
注1：2013 年 2 月 Opera 宣布转向 WebKit 引擎

注2：2013 年 4 月 Opera 宣布放弃 WEBKIT，跟随 Google 的新开发的 Blink 引擎
</div>

- 2008年9月2日，谷歌公司发布的第一个版本Google Chrome（中文名为谷歌浏览器）就采用了 Webkit 引擎。
- 2009年，广受关注的 Android 的自带的浏览器也是 Webkit 内核，加载网页速度比 IE 手机浏览器快了近一倍。
- 2010年1月24日，搜狗公司发布搜狗浏览器 V2.0Beta，采用 Chromium 引擎，并支持与 **IE 引擎互相切换**。
- 2010年1月24日，傲游浏览器3.0beta发布。2012年5月31日已发布3.3.9.1000。傲游3修正了众多**假死问题**。拥有**双引擎切换功能**。
- 2010年9月16日，**360极速浏览器发布**，这是一款使用 Chromium 开源代码（基于 Webkit 内核）的浏览器，网页浏览比 IE 快一倍。
- 2010年6月11日，**阿里云浏览器**内测第一版(0.1.9.0)发布，这是一款**集成** Chromium 内核、IE 内核的浏览器。
- 2010年5月25日，腾讯推出的 **QQ浏览器** 采用 Webkit 内核以及 IE 内核。
- 2011年7月18日，百度推出的**百度 PC 浏览器**支持 IE 和 Webkit **双内核智能切换**。
- 2013年2月，Opera 宣布将用 WebKit 替代当前的核心浏览器引擎。[4]
- 2013年4月4日，谷歌星期三（4月3日）宣布，他们将利用 WebKit 渲染引擎开发自主的网页渲染引擎 **Blink**。

### Chromium：[ˈkrəʊmiəm]

Google 的 Chrome 浏览器背后的引擎，Chromium 是一个由 Google 主导开发的网页浏览器，其目的是为了创建一个安全、稳定和快速的通用浏览器。

Chromium 相当于 Chrome 的工程版或称实验版。 在 Chromium 项目中研发 Blink 渲染引擎（即浏览器核心），内置于 Chrome 浏览器之中，Blink 其实是 WebKit 的分支。

### 了解一点

<div class = "note info" style = "text-indent=2em">
<p>移动端的浏览器内核主要说的是系统内置浏览器的内核。</p>
<p>目前移动设备浏览器上常用的内核有 Webkit，Blink，Trident，Gecko 等，其中 iPhone 和 iPad 等苹果 iOS 平台主要是 WebKit，Android 4.4 之前的 Android 系统浏览器内核是 WebKit，Android4.4 系统浏览器切换到了 Chromium，内核是 Webkit 的分支 Blink，Windows Phone 8 系统浏览器内核是 Trident。</p>
</div>

<hr />

## Web 标准

Web标准不是某一个标准，而是由W3C和其他标准化组织制定的**一系列标准的集合**。

主要包括结构（Structure）、表现（Presentation）和行为（Behavior）三个方面。

1. 结构标准：结构用于对网页元素进行整理和分类，主要包括 XML 和 XHTML 两个部分；
2. 样式标准：表现用于设置网页元素的版式、颜色、大小等外观样式，主要指的是 CSS；
3. 行为标准：行为是指网页模型的定义及交互的编写，主要包括 DOM 和 ECMAScript 两个部分。

### Web 标准的好处

1. 让Web的发展前景更广阔 
2. 内容能被更广泛的设备访问
3. 更容易被搜寻引擎搜索
4. 降低网站流量费用
5. 使网站更易于维护
6. 提高页面浏览速度
