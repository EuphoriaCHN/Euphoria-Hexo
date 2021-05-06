---
title: Webpack4 最佳实践与原理解析（三）
date: 2020-09-01 00:48:37
updated: 2020-09-01 00:48:37
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
> 在这一篇主要会讲述 <b>使用第三方模块、图片打包、产物分类、多页应用处理...</b>

<!--more-->

<hr/>

## 前言

<ul>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）：什么是 Webpack 与产物浅解析</a></li>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%8C%EF%BC%89/">Webpack4 最佳实践与原理解析（二）：Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint</a></li>
</ul>

<hr />

## 第三方模块的使用

有使用我们会使用 jQuery，直接使用：

```javascript
import $ from 'jquery';
console.log($); // 可以输出

console.log(window.$); // undefined
```

可以发现，webpack 不会将这种类型的库挂载到 window 上，有时会造成奇怪的错误。

### 解决方案一

使用 `expose-loader` 来暴露全局的 loader，常常在代码中使用，也被称作 **内联 Loader**。

```s
npm install expose-loader
```

在代码中使用：

```javascript
// 将 jQuery 暴露为 $
import $ from 'expose-loader?$!jquery';
console.log(window.$); // work!
```

### 解决方案二

配置 webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: require.resolve('jquery'), // 当代码中引入了 jQuery
        use: 'expose-loader?$',
      },
    ],
  },
};
```

这样就不用在使用时，写那么长的内联 Loader 了。

### 解决方案三

上述的两种方法，我们仍需在使用 `jQuery` 时手动地导入它，有没有什么更方便的方法呢？

我们直接将 `$` 直接 **注入** 到每个模块中，这里需要一个 `Webpack` 提供的插件。

修改 Webpack 配置文件：

```javascript
const Webpack = require('webpack');

module.exports = {
  // 省略部分代码...
  plugins: [
    // Webpack 自带的，为每个模块提供插件
    new Webpack.ProvidePlugin({
      $: 'jquery', // 在每个模块中都注入这个 $
    }),
  ],
};
```

这样可以直接在任意一个模块中直接使用 `$`，从而使用 jQuery 了！

<div class="node danger">但是这样，<code>window.$</code> 依然是 <i>undefined</i></div>

### externals 配置

在使用 jQuery 时，有时直接将 jQuery CDN URL 写进了模板中，这样 jQuery 可以正常运作。但如果用户在某个模块中单独 import 了 jQuery，Webpack 会把 jQuery 打包到产物中，增加了产物的体积。

此时可以配置 Webpack 配置文件中的 `externals` 属性，即 **这个模块是外部引入的，它们不参加 Webpack 打包过程，也不会出现在产物中**。

```javascript
module.exports = {
  // 省略部分代码...
  externals: {
    jquery: '$',
  },
};
```

<div class="note info">那我们还需要在每个模块中写入 <i>import</i> 吗？</div>

答案是肯定的，再不济也有个心理安慰（真诚

<hr />

## 打包图片

常见的使用图片方式：

- 在 JS 中创建图片来引入
- 在 CSS 中使用 url 来引入
- 直接使用 HTML img 标签，写死一个图片 src

如果使用 `import pic from './xxx.png'` 这样的方式导入图片，需要对这个文件类型（png）增加一个 Loader：

```s
npm install file-loader -D
```

file-loader 会在内部生成一张图片到 build 目录下，并将生成图片的名字返回回来。

修改 Webpack 配置文件，为图片类型文件增加 Loader：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.(png)|(jpg)|(gif)/,
        use: {
          loader: 'file-loader',
        },
      },
    ],
  },
};
```

### 关于 CSS url 使用图片

在写 CSS 时，常常会使用 `url` 方式去引入一张图片：

```css
#root {
  background: url('./xxx.png');
}
```

其实，因为 CSS 模块都经过了 `css-loader`，它会把这种类型的文件转换为：

```css
#root {
  background: url(require('./xxx.png'));
}
```

所以说这样也是可以进行图片的打包的。

### 在 HTML 中写死图片路径

如果出现了这样的代码：

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
  </head>
  <body>
    <!-- 这里写死了文件路径，但经过 Webpack 打包后，这个路径是错误的 -->
    <img src="./xxx.png" />
  </body>
</html>
```

原因在代码段中说明了，出现这种问题我们需要一个中国人写的插件：`html-withimg-loader` 来解决问题

```s
npm install html-withimg-loader -D
```

修改 Webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码
  module: {
    rules: [
      {
        test: /\.html/,
        use: 'html-withimg-loader',
      },
    ],
  },
};
```

### URL-LOADER

对于一些比较小的图片，我们通常希望它以 BASE64 的形式存在，这样可以很好的减少不必要的 HTTP 请求。而且对于图片来说，我们不经常使用 `file-loader`，取而代之的是 `url-loader`：

```s
npm install url-loader -D
```

修改 Webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码
  module: {
    rules: [
      {
        test: /\.(png)|(jpg)|(gif)/,
        use: {
          loader: 'url-loader',
          options: {
            esModule: false, // 不使用 ESMODULE 加载图片
            limit: 8 * 1024, // 如果一个图片小于 8kb，那么将其转换为 Base 64 格式
            name: '[name].[hash:8].[ext]', // 输出文件名称
          },
        },
      },
    ],
  },
};
```

<hr />

## 产物分类

我们现在已经可以打包很多东西了！但是对于输出目录来说，并没有一个很好的分类，会导致输出目录杂乱无章，难以对产物进行分析。

修改 Webpack 配置文件：

```javascript
// 省略部分代码

module.exports = {
  module: {
    rules: [
      {
        test: /\.(png)|(jpg)|(gif)/,
        use: {
          loader: 'url-loader',
          options: {
            esModule: false,
            limit: 8 * 1024,
            name: '[name].[hash:8].[ext]',
            outputPath: '/images', // 所有的这些产物都会放到 images 目录下
          },
        },
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'styles/styles.[hash:8].css', // 抽离出的 CSS 产物放到 styles 目录下
    }),
  ],
};
```

### 静态资源统一前缀

有时我们在代码打包完成后，会将各种静态资源文件分发到 CDN 上，这时需要在每一个资源前面加上 CDN 路径，我们可以修改 Webpack output 配置来达到这个效果：

```javascript
// 省略部分代码...

module.exports = {
  output: {
    publicPath: 'https://cdn.xxx.net', // 在引用资源时，会统一加上这个值（比如 CDN 服务
  },
};
```

### 仅对某种类型资源增加前缀

有时我们只希望图片部署到 CDN 上，但例如 JS 与 CSS 则放到了服务器中，这时可以修改 **单个 Loader 配置** 来实现：

```javascript
// 省略部分代码...

module.exports = {
  module: {
    rules: [
      {
        test: /\.(png)|(jpg)|(gif)/,
        use: {
          loader: 'url-loader',
          options: {
            esModule: false,
            limit: 8 * 1024,
            name: '[name].[hash:8].[ext]',
            outputPath: '/images',
            publicPath: 'https://cdn.xxx.net', // 仅对这个模块进行增加前缀（比如 CDN 服务
          },
        },
      },
    ],
  },
};
```

<hr />

## 打包多页应用

多个页面具有不同的 JavaScript 文件，即 **多入口** 应用。

修改 Webpack 配置文件中的 `entry` 项与 `output` 项：

```javascript
// 省略部分代码
module.exports = {
  entry: {
    index: './src/index.js',
    other: './src/other.js', // 其他入口
  },
  output: {
    filename: '[name].[hash:8].js', // name 代表着不同的 chunk （代码块）名称
    path: path.resolve(__dirname, 'dist'),
  },
};
```

如果不改变其他配置，此时打包过后的 HTML 文件，由于 `HtmlWebpackPlugin` 插件，会将两个 JS 文件 **一并引入** 到 HTML 文件中。

但，如果需要生成两个 HTML 文件呢？需要修改 Webpack 配置文件：

```javascript
// 省略部分代码
module.exports = {
  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'),
      filename: 'index.html',
      chunks: ['index'], // 仅给这个 HTML 打包对应的入口文件（index.js
      minify: {
        removeAttributeQuotes: true,
        collapseWhitespace: true,
      },
      hash: true,
    }),
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'),
      filename: 'other.html',
      chunks: ['other'], // 仅给这个 HTML 打包对应的入口文件（other.js
      minify: {
        removeAttributeQuotes: true,
        collapseWhitespace: true,
      },
      hash: true,
    }),
  ],
};
```

<hr />

## 小憩一下

在第四章中，会开始介绍更多 Webpack 对于 **SourceMap 源码映射**、**实时打包**、**常用插件配置** 与 **Webpack 跨域问题处理** 等等...
