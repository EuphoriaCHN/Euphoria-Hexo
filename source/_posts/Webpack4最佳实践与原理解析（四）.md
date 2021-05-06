---
title: Webpack4 最佳实践与原理解析（四）
date: 2020-09-01 00:58:19
updated: 2020-09-01 00:58:19
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
> 在这一篇主要会讲述 <b>SourceMap 源码映射、实时打包、常用插件配置 与 Webpack 跨域问题处理...</b>

<!--more-->

<hr/>

## 前言

<ul>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）：什么是 Webpack 与产物浅解析</a></li>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%8C%EF%BC%89/">Webpack4 最佳实践与原理解析（二）：Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%89%EF%BC%89/">Webpack4 最佳实践与原理解析（三）：使用第三方模块、图片打包、产物分类、多页应用处理</a></li>
</ul>

<hr />

## 配置 Source-Map

我们在解析 JS 的过程中，可能会把高级的 JS 语法转换为低级 JS 语法（通过 Babel）。

但是在我们处于 **生产环境** 时，通常会去浏览器开发者模式进行 Debug，但此时加载的是经过转换并丑化过的文件，增加了 Debug 的难度。

这时，需要一个 **源码映射** 去展示我们本来的代码。

修改 Webpack 配置文件，增加 `devtool` 属性：

```javascript
// 省略部分代码
module.exports = {
  devtool: 'source-map', // 增加映射文件，可以帮助调试
};
```

还可以配置成：

- `eval-source-map`： **不会产生单独的文件**，但是会展示行和列；
- `cheap-module-source-map`：**不会显示行和列**，仅会展示一个单独的文件；
- `cheap-module-eval-source-map`：**不会产生单独的文件，也不会展示行和列**，仅会集成在打包后的文件中。

<hr />

## 实时打包

有时为了节省时间，我们需要 Webpack **实时打包** 出一个实体文件。

为了实现 **实时打包**，我们需要修改 Webpack 配置文件，增加 `watch` 属性：

```javascript
// 省略部分代码
module.exports = {
  watch: true, // 监控代码变化，实时打包
  watchOptions: {
    poll: 1000, // 每秒监控 1000 次，询问是否需要更新
    aggregateTimeout: 500, // 防抖，n 毫秒内防抖
    ignored: /node_modules/, // 不监控 node_modules
  },
};
```

<hr />

## Webpack 常用小插件

- `clean-webpack-plugin`：第三方插件，清理产物目录
- `copy-webpack-plugin`：第三方插件，快速拷贝文档
- `banner-plugin`：Webpack 内置插件，署名代码版权

### clean-webpack-plugin

每次打包后，文件的名称都不一样，会叠加到 `dist` 目录下，神烦。我们希望每次在输出目录之前，都会删除 `dist` 目录下的所有东西，我们 **只希望看到最新的产物**。

```s
npm install clean-webpack-plugin -D
```

修改 Webpack 配置文件：

```javascript
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

// 省略部分代码
module.exports = {
  plugins: [
    // 每次打包前，清空打包产物目录
    new CleanWebpackPlugin(),
  ],
};
```

### copy-webpack-plugin

有的时候会有一些类似 `README.md` 或 doc 文档需要拷贝到 `dist` 目录下，可以借用 `copy-webpack-plugin` 来快速实现：

```s
npm install copy-webpack-plugin -D
```

修改 Webpack 配置文件：

```javascript
const CopyWebpackPlugin = require('copy-webpack-plugin');

// 省略部分代码
module.exports = {
  plugins: [
    // 拷贝不变的文件（比如 doc
    new CopyWebpackPlugin({
      // 这里的 from: './doc'，是以当前路径为相对路径
      // 这里的 to: './doc'，是以 output.path 为相对路径
      patterns: [{ from: './doc', to: './doc' }],
    }),
  ],
};
```

### banner-plugin

有时我们希望在每个打包文件头部加上 **版权说明**，可以使用 Webpack 提供的内置插件 `banner-plugin`：

修改 Webpack 配置文件：

```javascript
const Webpack = require('webpack');

// 省略部分代码
module.exports = {
  plugins: [
    // 版权署名，会插入到每个打包结果的头部
    new Webpack.BannerPlugin('Make 2019 by Euphoria'),
  ],
};
```

<hr />

## Webpack 跨域问题

在写 Ajax 请求时，会遇到跨域的问题，如果后端哥哥们让我们自己解决....

Webpack Dev Server 是基于 Express 的，我们在本地发请求时总是会先打到 Dev 服务上，那么 Webpack 自身是可以将这个请求代理转发至对应 URL，以解决跨域问题。

在 Node 中我们可以使用 `http-proxy` 模块去解决跨域问题，同样在 Webpack 中也可以配置这样的模块：

```javascript
// 省略部分代码
module.exports = {
  devServer: {
    proxy: {
      '/api': {
        // 当我们访问以 /api 开头的路由时，Webpack 就会代理到 http://localhost:3000
        target: 'http://localhost:3000',
        pathRewrite: {
          '/api': '', // 将 /api/xxx 的请求重写为 /xxx
        },
      },
    },
  },
};
```

有时候我们前端开发会去 Mock 一些数据，只想单纯的来模拟数据。因为 Webpack Dev Server 内部就是 Express，我们可以直接在 devServer 中来写一些 Express 接口：

```javascript
// 省略部分代码
module.exports = {
  devServer: {
    before(app) {
      // Webpack Dev Server 提供的一个重写方法
      // 在启动服务之前会调用这个 Hook
      // 这个 app 就是 Express 的应用对象，就像 express 中那样写就好
    },

    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        pathRewrite: {
          '/api': '',
        },
      },
    },
  },
};
```

### 在服务端内部启动 Webpack

如果服务端使用 Node，我们甚至可以直接在服务端启动 Webpack 编译，将 Webpack 服务跑在服务端端口上，这样也可以直接解决跨域问题。

在写代码之前，因为需要把 Webpack 和 Express 整合起来，所以这里需要一个 Webpack 开发服务的一个 Middleware，叫做 `webpack-dev-middleware`，它可以在服务端启动 Webpack：

```s
npm install webpack-dev-middleware -D
```

编写服务端代码：

```javascript
// 服务端代码
const express = require('express');
const app = express();

const webpack = require('webpack'); // 服务端使用 Webpack

// Webpack 开发服务中间件
const webpackDevMiddleware = require('webpack-dev-middleware');

// 获取 Webpack 配置
const config = require('./webpack.config.js');

// 获取 Webpack 编译器
const compiler = webpack(config);

app.use(webpackDevMiddleware(compiler)); // 使用中间件

app.get('/', (req, res) => {
  res.json({ name: 'euphoria' });
});

app.listen(3000);
```

这里我们在启动 Express 后，因为中间件的作用，也会连带着启动 Webpack。这样前端和后端用的是同一个主机和端口，解决了跨域的问题。

<hr />

## Webpack Resolve

通常我们会在代码中引入一些模块，绝大多数模块都是从 **第三方包** 中获取的。在 Common JS 规范中，都是从当前目录开始查找，再一层层往上查找。

有时我们想限定 Webpack 查找 Node 模块的范围，就需要使用到一个重要的属性 `resolve`。

`resolve` 除了限定 Node 模块查找范围，还有一些其他的配置：

- `modules`：限定查找包的路径
- `alias`：路径（包）别名，在 Vue 和 React 中及其常用
- `extensions`：省略扩展名，Webpack 会按照顺序查找
- `mainFields`：指定查找文件优先级（根据 package.json
- `mainFiles`：指定查找文件优先级（根据文件名称

```javascript
const path = require('path');
// 省略部分代码...
module.exports = {
  resolve: {
    modules: [
      path.resolve(__dirname, 'node_modules'), // 限定包路径
      path.resolve(__dirname, 'src'),
    ],
    alias: {
      // 模块别名
      '@utils': path.resolve(__dirname, 'src', 'utils'), // 导入模块别名
      // import util from '/src/utils/util.js';
      // 全等于
      // import util from '@utils/utils.js';
    },

    // 指定扩展名，按顺序查找
    // 这样在 import 时，可以不用写文件扩展名
    // Webpack 会根据顺序查找，如果都没有再报错
    extensions: ['.js', '.jsx', '.ts', '.tsx'],

    // 比如 Bootstrap，直接 import 的话是访问 package.json 中的 main 文件
    // main 文件是一个 JS 文件
    // 然而我们在导入 Bootstrap 时，多半是需要它的 css 文件（即 package.json 中的 style 文件
    // 我们可以通过 mainFields 来设置导入模块优先级顺序
    mainFileds: ['style', 'main'],
    // 同理，甚至可以限定入口文件的名称（用的不多）
    mainFiles: ['index.js'],
  },
};
```

<hr />

## 小憩一下

在第五章中，我们将要开始 **区分 Webpack 打包环境**，以及接下来的所有代码都将会涉及到 **不同打包环境** 的配置...
