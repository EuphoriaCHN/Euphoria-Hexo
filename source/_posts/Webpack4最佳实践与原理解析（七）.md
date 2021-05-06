---
title: Webpack4 最佳实践与原理解析（七）
date: 2020-09-01 01:13:43
updated: 2020-09-01 01:13:43
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
> 在这一篇我们将要开始 <b>Webpack 其他优化，比如 抽取多入口公共代码、热更新 和 懒加载</b>，这也是 Webpack 最佳实践系列的最后一章！之后将会开始 Webpack 原理分析章节...

<!--more-->

<hr/>

## 前言

<ul>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）：什么是 Webpack 与产物浅解析</a></li>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%8C%EF%BC%89/">Webpack4 最佳实践与原理解析（二）：Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%89%EF%BC%89/">Webpack4 最佳实践与原理解析（三）：使用第三方模块、图片打包、产物分类、多页应用处理</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E5%9B%9B%EF%BC%89/">Webpack4 最佳实践与原理解析（四）：SourceMap 源码映射、实时打包、常用插件配置 与 Webpack 跨域问题处理</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%94%EF%BC%89/">Webpack4 最佳实践与原理解析（五）：区分 Webpack 打包环境</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E5%85%AD%EF%BC%89/">Webpack4 最佳实践与原理解析（六）：Webpack 打包优化、如何提升 Webpack 打包性能、DLL 动态链接库、happypack</a></li>
</ul>

<hr />

## 抽取公共代码

对于 **多页面** 应用程序，对于不同的入口文件可能会引用 **相同的模块**，如果分开打包的话会增加产物体积，那么可以考虑 **将多入口文件中重复的模块 / 代码抽离出来**。

修改 Webpack 配置文件（webpack.prod.js）：

```javascript
// 对产物的优化，选择 生产环境 配置文件
// 省略部分代码
const { merge: WebpackMerge } = require('webpack-merge');

// 导入 Webpack 标准（基本）配置文件
const webpackBaseConfig = require('./webpack.config.js');

module.exports = WebpackMerge(webpackBaseConfig, {
  optimization: {
    // 分割代码块（只有多页应用会用到）
    // 用于抽离不同产物中引入的相同模块
    splitChunks: {
      cacheGroups: {
        // 缓存组，用来缓存一些代码
        vendor: {
          // 第三方模块
          test: /node_modules/, // 只抽离在 node_modules 里面的代码
          minSize: 0, // 下面照抄 common module，或自行根据实际情况配置
          minChunks: 2,
          chunks: 'initial',
          priority: 1, // 权重，默认是 0
        },
        common: {
          // 公共模块
          minSize: 0, // 只要大于 0 字节，就抽离出来
          minChunks: 2, // 这些模块被使用大于等于 2 次，就抽离出来
          chunks: 'initial', // 在入口时，就抽离代码
        },
      },
    },
  },
});
```

<div class="note danger">在 <code>cacheGroups</code> 中，如果权重 <b>priority</b> 相同，抽离顺序是 <b>从上到下的</b>。抽离第三方模块应当在公共模块之前！否则第三方模块也会被当作公共模块（因为没 test）而被抽离出去。</div>

<hr />

## Webpack 懒加载

有一些业务场景下，我们需要 **延迟加载** 某些资源文件，比如视频或其他文件：

```javascript
const button = document.createElemenet('button');
button.addEventListener('click', () => {
  // 按需加载某些资源
});
document.body.appendChild(button);
```

我们可以使用 **ES 6 草案语法**（也被 Webpack 兼容的）`动态 import`：

```javascript
const button = document.createElemenet('button');
button.addEventListener('click', () => {
  // 这个语法底层是用 JSONP 去实现的
  // 会返回一个 Promise 实例
  import('./otherSource.js').then(
    (data) => {
      // 处理 data
    },
    (_) => {}
  );
});
document.body.appendChild(button);
```

这时我们是编译不过的，因为缺少了一个 Babel 解析 **动态导入** 的插件：

```s
npm install @babel/plugin-syntax-dynamic-import -D
```

同时配置 Webpack 配置文件（webpack.config.js）：

```javascript
// 省略部分代码...
module.exports = {
  module: {
    rules: [
      {
        use: 'babel-loader',
        options: {
          plugins: [
            '@babel/plugin-syntax-dynamic-import', // 添加这个 Babel 插件
          ],
        },
      },
    ],
  },
};
```

此时，导出的 `data` 模块就是一个 ES 模块：

```javascript
button.addEventListener('click', () => {
  import('./otherSource.js').then(
    (data) => {
      // 因为是 ES 6 模块，可以从 default 中取默认导出
      // data.default.xxx
    },
    (_) => {}
  );
});
```

像 Vue 中的 **路由懒加载** 和 React 中的懒加载，都是靠这种方式来执行的。分析打包生成的 **动态导入模块代码** 可以很好的看到使用了 **JSONP** 方法：

```javascript
// 省略部分代码...
(window.webpackJsonp = window.webpackJsonp || []).push([1], function (n, p, w) {
  'use strict';
  w.r(p); // 虽然被 Babel 转化过，但还是可以知道 p 就是 ES 模块
  p.default = 'xxx';
});
```

<hr />

## Webpack 热更新

在我们以往的开发中，如果我们重新保存了文件，往往会造成 **整站刷新**，对于一些初始化页面需要大量请求的网站来说，这是非常浪费时间的。

我们更希望的是，**只更新页面上的某个部分**，比如 **一个组件的更新**。

这个时候可以使用 Webpack 的热更新操作，修改 Webpack 配置文件（webpack.dev.js）：

```javascript
// 省略部分代码
const { merge: WebpackMerge } = require('webpack-merge');
const Webpack = require('webpack');

// 导入 Webpack 标准（基本）配置文件
const webpackBaseConfig = require('./webpack.config.js');

module.exports = WebpackMerge(webpackBaseConfig, {
  devServer: {
    hot: true, // 启用热更新
  },

  plugins: [
    // Webpack 热更新插件，对 DevServer 热更新做支持
    new Webpack.HotModuleReplacementPlugin(),

    // 在发生热更新时，会通知用户是【哪个模块】被更新了
    new Webpack.NamedModulesPlugin(),
  ],
});
```

但是这个时候，还不能实现热更新，我们需要通过一个标志位去判断当前模块是否启用了热更新：

```javascript
if (module.hot) {
  module.hot.accept('./需要被热更新的模块', () => {
    const esModule = require('./需要被热更新的模块');
    // 这样就可以拿到更新后的模块，并对其进行操作
    // 这里只能用 require，如果用 import 就变成 Promise 了
  });
}
```

你也可以实现一个巨 Low 的 `react-hot-loader`：

```jsx
import * as React from 'react';
import ReactDom from 'react-dom';

import App from './App';

const root = document.getElementById('root');

if (module.hot) {
  module.hot.accept('./App.jsx', () => {
    // App 根容器发生改动
    const { default: NewApp } = require('./App.jsx');
    // Re-render
    ReactDom.render(<NewApp />, root);
  });
}

ReactDom.render(<App />, root);
```

<hr />

## 放松一下！

至此，《Webpack4 最佳实践与原理解析》系列之“最佳实践”章节已经结束...如有不正还请读者大佬们多指教！

接下来（从 **第八章** 开始），将会进入“原理解析”章节（感觉这是一个大工程啊...
