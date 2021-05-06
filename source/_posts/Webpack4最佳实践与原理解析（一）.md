---
title: Webpack4 最佳实践与原理解析（一）
date: 2020-08-31 00:19:08
updated: 2020-08-31 00:19:08
tags:
- Web
- JavaScript
- Webpack
- 前端架构
categories:
- 前端
- Webpack
copyright: true
image: "http://www.wqh4u.cn/2020/08/31/Webpack4最佳实践与原理解析（一）/main.png"
---

> <span class = 'introduction'>人非要经历一番不同平时的劫难才能脱胎换骨，成为真正能解决问题的人。</span><br/>
第一个超长篇集合来了！在学习前端的过程中，Webpack 是一个必不可少的工具，在这一篇主要会讲述 <b>什么是 Webpack 与产物浅解析</b>

<!--more-->

<hr/>

## 前言

<div class="note danger">本系列文章基于 Webpack 4，完成时间于创建时间（2020-08-31），这也意味着文章中所有的三方模块的版本需要各位读者注意！</div>

<div class="note info">
<p>本系列文章全部假设读者：</p>
<ul>
<li>具有一定的 JavaScript 基础知识，包括但不限于基本语法、Promise、ES6、ES7 等</li>
<li>具有一定的 Node.js 基础知识，包括但不限于 CommonJS 模块化等</li>
<li>具有一定的 Node 包管理知识，包括但不限于 NPM、NPX 等</li>
<li>具有一定的设计模式知识，比如“发布订阅”</li>
</ul>
<p>同时期望读者阅读本文前，曾使用过如 Vue 或 React 等框架，或使用过 vue init 或 create-react-app 创建过工程。本系列文章极少部分举例会使用 React，但不会涉及 React 高阶使用。</p>
</div>

那么就开始探索 Webpack 这个复杂又伟大的工程吧！

<hr />

## 什么是 Webpack

> 本质上，Webpack 是一个现代 JavaScript **应用程序的静态模块打包器**（module bundler）。当 Webpack 处理应用程序时，它会递归地构建一个依赖关系图（dependency graph），其中包含应用程序需要的每个模块，然后将所有这些模块打包成一个或多个 bundle。
> Webpack 就像一条 **生产线**，要经过一系列处理流程后才能将源文件转换成输出结果。这条生产线上的每个处理流程的职责都是单一的，多个流程之间有存在依赖关系，只有完成当前处理后才能交给下一个流程去处理。插件就像是一个插入到生产线中的一个功能，在特定的时机对生产线上的资源做处理。
> Webpack 通过 **Tapable** 来组织这条复杂的生产线。Webpack 在运行过程中会 **广播事件**，插件只需要监听它所关心的事件，就能加入到这条生产线中，去改变生产线的运作。Webpack 的 **事件流机制** 保证了插件的有序性，使得整个系统扩展性很好。 -- 《深入浅出 Webpack》 吴浩麟

总的说就是，Webpack 会把你的各种奇奇怪怪的文件，都进行一个 **打包**，并输出成一些静态资源文件。

<img src="./webpack.png" alt="Webpack 官方配图" title="Webpack 官方配图" />

<hr />

## 安装 Webpack 4

我们一般 **不采用** 全局安装的方法，否则会出现一些因为 Webpack 版本不对而导致项目无法 Run 起来的问题。

在 Webpack 4 中，我们需要安装两个模块才可以正常的使用 Webpack：

- webpack
- webpack-cli

```s
npm install webpack webpack-cli -D
```

`webpack-cli` 里面会去寻找 `webpack.js`，从而进行打包。当我们在命令行使用：

```s
npx webpack
```

来进行打包时，其实会去寻找 `node_modules/.bin/webpack.cmd`（假设 Windows 环境）:

```s
@ECHO off
SETLOCAL
CALL :find_dp0

IF EXIST "%dp0%\node.exe" (
  SET "_prog=%dp0%\node.exe"
) ELSE (
  SET "_prog=node"
  SET PATHEXT=%PATHEXT:;.JS;=;%
)

"%_prog%"  "%dp0%\..\webpack\bin\webpack.js" %*
ENDLOCAL
EXIT /b %errorlevel%
:find_dp0
SET dp0=%~dp0
EXIT /b
```

可以看到它使用了 `webpack.js` 进行打包，最后会生成一个被压缩过的 `dist/main.js`，是一个可以执行的 JS 文件。

<hr />

## 初次使用 Webpack

Webpack 是一个打包工具，打包生成一个 JS 模块，那么我们也可以编写模块化的 JS 文件。

比如在根目录下，我们创建一个名为 `index.js` 的文件，随便写上几行代码，然后使用 `npx webpack` 打包过后，会有一个 Warning：

<div class="note info">
WARNING in configuration
The 'mode' option has not been set, webpack will fallback to 'production' for this value. Set 'mode' option to 'development' or 'production' to enable defaults for each environment.
You can also set it to 'none' to disable any default behavior. Learn more: https://webpack.js.org/configuration/mode/
</div>

这里 Webpack 告诉我们，我们没用配置 `mode` 这个参数，Webpack 将会采用 `production`（即，生产模式）去打包我们的代码，在生产模式下，我们的代码将会被压缩 & 丑化。

如果我们直接在 HTML 引入的 js 文件中使用 `require` 关键字去导入 CommonJS 规范的模块，是不可以的。但是经过 Webpack 打包后的代码，即使使用 CommonJS 规范进行模块化，也可以在浏览器中执行。

也就是说，Webpack 帮我们实现的功能，就是去 **解析 JS 的模块，再去查找有关依赖，并解决了浏览器对 require 的使用问题**。

<hr />

## Webpack 核心概念

### Entry

入口起点（entry point）指示 Webpack 应该使用哪个模块，来作为构建其内部依赖图的开始（就是入口文件）。

进入入口起点后，Webpack 会找出有哪些模块和库是入口起点（直接和间接）依赖的。

每个依赖项随即被处理，最后输出到打包产物中。

### Output

output 属性告诉 Webpack 在哪里输出它累死累活制造的 **打包产物**，以及如何命名这些文件，默认值输出路径为 `./dist`。

基本上，整个应用程序结构，都会被编译到你指定的输出路径的文件夹中。

### Module

模块，在 Webpack 里 **一切皆模块**，一个模块对应着一个文件。Webpack 会从配置的 Entry 开始递归找出所有依赖的模块。

### Chunk

代码块，一个 Chunk 由多个模块组合而成，用于代码合并与分割。

### Loader

loader 让 Webpack 能够去处理那些非 JavaScript 文件 **（Webpack 自身只理解 JavaScript）**。

loader 可以将所有类型的文件转换为 Webpack 能够处理的有效模块，然后你就可以利用 Webpack 的打包能力，对它们进行处理。

本质上，Webpack loader 将所有类型的文件，转换为应用程序的依赖图（和最终的打包产物）可以直接引用的模块。

### Plugin

Loader 被用于转换某些类型的模块，而插件则可以用于执行范围更广的任务。

插件的范围包括：从打包优化和压缩，一直到重新定义环境中的变量。插件接口功能极其强大，可以用来处理各种各样的任务。

<hr />

## 创建配置文件

- 默认配置文件名称：`webpack.config.js`

因为 Webpack 是 Node 写出来的，所以 Webpack 配置文件里面需要使用 Common JS 规范。

先添加这些代码：

```javascript
const path = require('path');

module.exports = {
  mode: 'development', // 开发环境
  entry: './src/index.js', // 入口文件
  output: {
    filename: 'bundle.js', // 打包后的文件名
    path: path.resolve(__dirname, 'dist'), // 输出路径（这个必须是绝对路径
  },
};
```

我们也可以给输出文件加上 **哈希戳**，最简单的方法是这样：`filename: 'bundle.[hash].js'`，或者可以指定长度：`filename: 'bundle.[hash:8].js'`！

### 为什么配置文件叫 webpack.config.js

我们调用的是 `node_modules/webpack` 模块，里面依赖了 `webpack-cli`。

在 `node_modules/webpack-cli/bin/config/config-yargs.js` 中，可以看到源码如下：

```javascript
config: {
    type: "string",
    describe: "Path to the config file",
    group: CONFIG_GROUP,
    defaultDescription: "webpack.config.js or webpackfile.js", // 一般的配置文件就叫这俩名字，当然也可以手动改
    requiresArg: true
}
```

### 设置 webpack 默认配置文件

在 `webpack-cli` 的使用中，我们可以直接在后面加上 `--config` 以表明配置文件的路径：

```s
npx webapck --config <配置文件路径>
```

这时 Webpack 就会根据配置文件中的配置参数去进行打包了！

<hr />

## 打包产物分析

在用 Webpack 进行打包后，我们会发现在 `./dist` 目录下生成了一个文件，这就是 Webpack 的 **打包产物**。

通过观察可以发现，Webpack 生成了一个自调用函数，传入了一个对象作为参数，去掉多余的注释后即：

```javascript
(function (modules) {
  // webpackBootstrap（Webpack 启动函数）
  // 代码省略...
})({
  './src/a.js': function (module, exports) {
    eval(
      "module.exports = 'Euphoria';\r\n\n\n//# sourceURL=webpack:///./src/a.js?"
    );
  },

  './src/index.js': function (module, exports, __webpack_require__) {
    eval(
      'const str = __webpack_require__("./src/a.js");\r\n\r\nconsole.log(str);\r\n\n\n//# sourceURL=webpack:///./src/index.js?'
    );
  },
});
```

<div class="note info">这里我写了两个文件，由 <code>index.js</code> 去引用 <code>a.js</code> 模块导出的字符串并输出。</div>

对象里面每个 Key 就是一个模块的路径，Value 是一个函数，再把这个对象传入 **自调用函数** 中去（也就是 Webpack 启动函数）：

```javascript
(function (modules) {
  // The module cache
  // （Webpack 先定义了一个缓存，如果某个模块已经被加载过了，就直接去缓存中拿
  // （而不是再次去加载这个模块
  var installedModules = {};

  // The require function
  // （实现了一个 require 方法，传入一个模块 ID
  function __webpack_require__(moduleId) {
    // Check if module is in cache
    // （检查这个模块是否在缓存中
    if (installedModules[moduleId]) {
      return installedModules[moduleId].exports;
    }

    // Create a new module (and put it into the cache)
    // 安装这样一个模块，先根据 Key 把模块加入到了缓存中
    var module = (installedModules[moduleId] = {
      i: moduleId, // ID
      l: false, // 是否加载完成
      exports: {},
    });

    // Execute the module function
    // （根据模块的 ID，去调用模块对应的函数
    // （根据 Common JS 规范，这个模块一定是在其依赖的子模块加载完成后，自己才会加载完成
    modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
    );

    // Flag the module as loaded
    // （标记这个模块已经被加载完成了
    module.l = true;

    // Return the exports of the module
    // （返回被加载的模块导出值
    return module.exports;
  }

  // 代码省略...

  // Load entry module and return exports
  // （调用 webpack_require 方法，传入 "./src/index.js"
  // （即，传入入口模块
  return __webpack_require__((__webpack_require__.s = './src/index.js'));
})({
  // 传入的对象
});
```

可以看到 Webpack 手撕了一个 `requrie` 方法，并命名为 `__webpack_require__`。同时创建了 **缓存机制**，将已经加载过的模块保存并记录下来，如果之后这个模块又被加载了，则直接可以从缓存中取出来。

<hr />

## 最后

在第二章中，会开始介绍一些 Webpack 的基础配置，这将使得你会使用 Webpack 进行最基础的 Web 页面开发！
