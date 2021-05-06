---
title: Webpack4 最佳实践与原理解析（二）
date: 2020-08-31 01:17:43
updated: 2020-08-31 01:17:43
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
在这一篇主要会讲述 <b>Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint </b>

<!--more-->

<hr/>

## 前言

在 <a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）</a> 中，主要讲述到了 **什么是 Webpack 与产物浅解析**，这次我们继续探索 Webpack 这个复杂又伟大的工程！

<hr />

## HTML 插件

现在打包过后的代码，是以文件的形式存在于 `dist` 目录下，不方便引入到 HTML 中，也不方便调试。所以我们希望启一个服务，去加载 HTML 文件。

### Webpack 内置服务

Webpack 内置了一个服务启动，其依赖了 Express：`webpack-dev-server`，它不会生成一个打包文件，而是一个存在于“内存”中的 bundle。

```s
npx webpack-dev-server
```

它默认会进到当前的静态目录下，但我们并不希望他这样做。我们希望的是它进入到 `build` 或 `dist` 目录中去（因为我们的 html 在那里）

于是可以在 webpack 配置文件中增加一个配置：

```javascript
module.exports = {
  // 部分代码省略
  devServer: {
    // 开发服务器的配置
    port: 3000, // 开发端口
    progress: true, // 打包进度条
    contentBase: './dist', // 默认入口目录
    open: true, // 第一次构建完成时，自动打开浏览器，默认是 false

    compress: true, // 使用 gzip 压缩，对所有的服务器资源采用 gzip 压缩
    // 优点：对 JS，CSS 资源的压缩率很高，可以极大得提高文件传输的速率，从而提升 web 性能
    // 缺点：服务端要对文件进行压缩，而客户端要进行解压，增加了两边的负载

    // Shows a full-screen overlay in the browser when there are compiler errors or warnings.
    overlay: true, // 在浏览器输出编译错误
    // 也可以连 Warnings 一起展示，设置成一个对象即可
    // overlay: {
    //   errors: true,
    //   warnings: true
    // }
  },
};
```

即使这样，HTML 文件还是有问题，仍然需要手动引入 JS 文件。

### 自动把打包后的文件装入 HTML 模板

通过引入了 `webpackDevServer`，我们仍需要一个：

- 自动引入 JS Bundle 结果到 HTML 中
- 再根据 webpack 配置，将最后的结果放到指定的路径下

插件：`html-webpack-plugin`，并修改 webpack 配置文件：

```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  // 省略部分代码...
  plugins: [
    // 数组，存放着 Webpack 的所有插件
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'), // 模板
      filename: 'index.html', // 打包后的文件名
    }),
  ],
};
```

此时我们只需要在 `template` 下创建一个名为 `index.html` 的文件，并在里面写入一些 HTML 模板（比如对一些框架来说，我们总是需要一个 id 为 root 的根组件）。

但我们并不需要手动地引入最后打包生成的 JavaScript 文件，而是仅需要跑起来服务 or 进行打包即可。

- `npx webpack-dev-server --config ./webpack.config.js` 启动本地调试服务
- `npx webpack --config ./webpack.config.js` 启动 Webpack 打包

如果觉得 `npx` 使用太麻烦，就 `npm` 安装到项目下，并修改 `package.json` 添加相应的 `script` 即可。

#### 打包生成压缩过的 HTML 文件

需要给 `HtmlWebpackPlugin` 中再增加一些参数：

```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  // 省略部分代码...
  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'),
      filename: 'index.html',
      minify: {
        // 生产环境打包时压缩 HTML
        removeAttributeQuotes: true, // 删除 HTML 不必要的双引号
        collapseWhitespace: true, // 丑化成一行
      },
      hash: true, // 加上哈希戳
    }),
  ],
};
```

<hr />

## Webpack 打包其他类型模块

创建一个 CSS 文件，随便写一些样式后，在 `index.js` 文件中引入：

```javascript
require('./index.css');
// 省略部分代码...
```

这时候会出现这样的报错：

<div class="note danger">
<p>ERROR in ./src/index.css 1:0</p>
<p>Module parse failed: Unexpected character '#' (1:0)</p>
<p>You may need an appropriate loader to handle this file type, currently no loaders are configured to process this file. See https://webpack.js.org/concepts#loaders</p>
</div>

这个模块解析失败了，你也许需要一个合适的 **Loader** 去解析这个文件。

**其实就是 Webpack 不认识这个文件**，它只认识 `.js`！

### Loader

Loader 就是可以把我们的源代码进行转化，让他变成一个可被 Webpack 识别的模块

### 使用 Loader

以 CSS 文件来举例，我们需要首先安装两个 loader：

```s
npm install style-loader css-loader -D
```

顾名思义，一个是样式 Loader，一个是 CSS 模块的 Loader。

接下来配置 Webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    // 模块
    rules: [
      // 规则
      {
        test: /\.css$/, // 匹配以 .css 结尾的文件
        use: ['style-loader', 'css-loader'], // 采用两个 loader
        // css-loader: 解析 CSS 文件（别忘了 CSS 也支持 @import 这样的语法
        // style-loader: 将 CSS 模块插入到 <head></head> 标签中
      },
    ],
  },
};
```

- Loader 的功能是单一的，这样可以自由组合使用
- 一个 Loader 可以直接写字符串，多个 Loader 则考虑使用数组装起来
- 多个 Loader 的执行顺序是从右往左的，右侧的 Loader 输出将成为左侧 Loader 的输入
- 一个 Loader 可以写成一个对象的格式，里面有一个 loader 值，就是 Loader 的名称。但这样可以多传入一些参数进去：

比如上面的例子：

```javascript
[
  {
    use: ['style-loader', 'css-loader'],
  },
];
```

等价于：

```javascript
[
  {
    use: [{ loader: 'style-loader' }, { loader: 'css-loader' }],
  },
];
```

### style-loader 的小问题

假如有一个写死的样式文件，对于整个页面来说优先级应当是最高的，我们将其使用 `<link>` 标签写死到了模板中。

但 `style-loader` 会默认将样式模块 push 到 `<head>` 标签的尾部，根据 **样式的层叠性**，就有可能覆盖掉不想被覆盖的 Global 样式。

这时候需要给 style-loader 传参，修改添加样式模块的方式：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          {
            loader: 'style-loader',
            options: {
              insertAt: 'top', // 这样样式模块是从 <head> 标签顶部插入的
              // 默认是从底部 append，可能会造成样式覆盖
            },
          },
          'css-loader',
        ],
      },
    ],
  },
};
```

### 其他样式文件处理

对于 `LESS` 和 `SASS` 来说，只需要安装对应的 Loader：

- LESS: `less-loader`
- SASS: `sass-loader`

他们的作用，都是将 **源样式首先转换为 CSS 风格**，再通过 `css-loader` 和 `style-loader` 去真正的插入到页面中，即：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.less$/,
        use: ['style-loader', 'css-loader', 'less-loader'],
        // Less loader 会调用 less 去进行转化
      },
      {
        test: /\.s[ca]ss$/, // 别忘了 SASS 有两个后缀
        use: ['style-loader', 'css-loader', 'sass-loader'],
        // Sass loader 会调用 node-sass 去进行转化
      },
    ],
  },
};
```

<div class="note info">当然对于 <code>stylus</code>，也是一样哒：stylus 和 stylus-loader</div>

### 抽离样式文件

使用 `style-loader` 会将样式模块插入到 `<head>` 标签中，这样如果样式太多了会 **阻塞页面**，是否可以考虑把他抽成若干个 CSS 文件呢？

依赖的插件：`mini-css-extract-plugin`，专门抽离 CSS 的。

```s
npm install mini-css-extract-plugin -D
```

安装后修改 Webpack 配置文件：

```javascript
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  // 省略不必要的代码...
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader, // 不使用 style-loader 了，样式需要抽离出来
          'css-loader',
        ],
      },
      {
        test: /\.less$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'less-loader'],
      },
      {
        test: /\.s[ca]ss$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      },
    ]
  }
  plugins: [
    new MiniCssExtractPlugin({
      // 抽离 CSS 样式
      filename: 'styles.[hash:8].css', // 抽离出的文件名称
    }),
  ]
}
```

- 增加一个 Plugin，代表我们使用了 _MiniCssExtractPlugin_
- 修改模块 Rules，这次不使用 style-loader，而是去使用 _MiniCssExtractPlugin_ 内部的 loader

#### 不同类型样式分开打包

如果想 CSS 打包成一个文件，LESS 打包成一个文件，SCSS 打包成另一个文件。

那就 require 三次 _MiniCssExtractPlugin_ 吧！然后在 plugins 中 new 三个不同的 _MiniCssExtractPlugin_，再给不同的 Loader 装上不同的 _MiniCssExtractPlugin.loader_！

（真诚脸...

### 解决样式浏览器兼容问题

在样式表内手撕所有样式的浏览器前缀，这明显不是一个很优的做法，所以需要某些插件去自动地帮我们加上浏览器前缀。

依赖的插件：`postcss-loader` 和 `autoprefixer`。

```s
npm install postcss-loader autoprefixer -D
```

修改 Webpack 配置文件：

```javascript
module.exports = {
  // 省略不必要的代码...
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          // 在送入 css-loader 之前，需要加上样式浏览器前缀
          'postcss-loader',
        ],
      },
      {
        test: /\.less$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
          'less-loader',
        ],
      },
      {
        test: /\.s[ca]ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
          'sass-loader',
        ],
      },
    ],
  },
};
```

这样还不行，我们还需要一个 **PostCSS 配置文件**，否则是 Run 不起来的！

创建一个名为 `postcss.config.js` 的文件，写入以下配置：

```javascript
module.exports = {
  plugins: {
    autoprefixer: {
      overrideBrowserslist: ['last 3 versions'],
    },
  },
};
```

现在再进行打包，会发现对于像 `transform` 这样的属性，在打包过后 Webpack 会帮你加上相应的浏览器前缀！

### 压缩样式打包产物

通过了各种样式 Loader 产生的产物，在 **生产环境** 下目前还不会被压缩，需要再将其进行压缩。

依赖的插件：`optimize-css-assets-webpack-plugin`：

```s
npm install optimize-css-assets-webpack-plugin -D
```

修改 Webpack 配置文件：

```javascript
const OptimizeCssAssetsWebpackPlugin = require('optimize-css-assets-webpack-plugin');
// 部分代码省略
module.exports = {
  optimization: {
    // Webpack 优化项
    minimizer: [new OptimizeCssAssetsWebpackPlugin()],
  },
};
```

再次进行打包，可以发现 CSS 产物已经可以压缩了，但是在生产环境原来可以压缩的 JS 代码反而不会了！

这里需要手动使用一个叫做 `uglifyjs-webpack-plugin` 的插件，**安装后继续修改配置文件**：

```javascript
const OptimizeCssAssetsWebpackPlugin = require('optimize-css-assets-webpack-plugin');
const UglifyJsWebpackPlugin = require('uglifyjs-webpack-plugin');

// 部分代码省略
module.exports = {
  optimization: {
    // Webpack 优化项
    minimizer: [
      new UglifyJsWebpackPlugin({
        cache: true, // 利用缓存
        parallel: true, // 并发压缩
        sourceMap: true, // 源码映射调试
      }),
      new OptimizeCssAssetsWebpackPlugin(),
    ],
  },
};
```

<div class="note info">
<p>这里可能会报错：</p>
<p>ERROR in bundle.c48b18f6.js from UglifyJs<br />Unexpected token: keyword «const» [./src/index.js:3,0][bundle.c48b18f6.js:93,0]</p>
<p>这是因为没有处理 JS 代码导致的，后续配置 Babel 会处理<br />对于本例，可以先将所有 JS 代码注释掉，只保留样式导入的代码</p>
</div>

<hr />

## 处理 JavaScript 模块

欸？为啥对于 Webpack 来说，还需要处理 JavaScript 文件呢，它不本身就认识吗？

其实对于 ES 6 或更高级的语法，我们是需要通过 Babel 去转化成低级的语法（ES 5 或 ES 3），并且需要解决一些 `polyfill` 的问题。当然还会有像 `.jsx` 和 `.vue` 的文件，也需要让 Webpack 认识他们。

为了兼容，我们需要将高级 JavaScript 语法转换为低版本语法。

依赖插件：`babel-loader`、`@babel/core`、`@babel/preset-env`

```s
npm install babel-loader @babel/core @babel/preset-env -D
```

关于 `@babel/core`：Babel 核心模块，可以调用 `transform` 方法进行源代码转换。

配置 Webpack 配置文件，为 JS 文件添加规则：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
          options: {
            // 用 Babel Loader 把 ES 6 转换为 ES 5
            presets: [
              // 预设配置
              '@babel/preset-env',
            ],
          },
        },
      },
    ],
  },
};
```

### 处理高级 JS 语法

仅使用 `@babel/preset-env` 也不能处理所有的高版本 JS 语法，比如 `class` 关键字，这时候需要给 Babel 安装其他插件：

```s
npm install @babel/plugin-proposal-decorators @babel/plugin-proposal-class-properties -D
```

- `@babel/plugin-proposal-decorators`: 处理装饰器
- `@babel/plugin-proposal-class-properties`：处理 `class` 关键字

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
          options: {
            // 用 Babel Loader 把 ES 6 转换为 ES 5
            presets: [
              // 预设配置
              '@babel/preset-env',
            ],
            plugins: [
              ['@babel/plugin-proposal-decorators', { legacy: true }], // 处理装饰器（需要写到处理 class 关键字插件之前！
              // 采用 legacy 宽松模式
              ['@babel/plugin-proposal-class-properties', { loose: true }], // 处理 class 关键字
            ],
          },
        },
      },
    ],
  },
};
```

### 代码运行时

根据上面的代码，我们将 `class` 关键字转换为了以下的代码：

```javascript
function _classCallCheck(instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError('Cannot call a class as a function');
  }
}

__webpack_require__('./src/index.css');

const str = require('./a.js');

var A = function A() {
  _classCallCheck(this, A);
};
```

可以看到 Babel 实现了一个 `_classCallCheck` 的方法，为了检验使用类时需要 `new` 关键字。

但如果在其他文件中 **再次使用 class 关键字**，Babel 又会在这个模块中实现一遍 `_classCallCheck` 方法。

同理，在使用例如 `generator` 或 `Promise` 时，Babel 也会在对应的模块中生成对应的帮助函数，这造成了一部分的代码冗余！

这时，我们需要借助一个神奇的库：`@babel/plugin-transform-runtime` 来解决问题。

<div class="note info">A plugin that enables the re-use of Babel's injected helper code to save on codesize.</div>

（还是官方的解释好...

同时，虽然 `@babel/plugin-transform-runtime` 是一个开发插件，但是它仍然会往生产环境中注入一些代码，这时还需要一个名为 `@babel/runtime` 的依赖。

```s
npm install @babel/plugin-transform-runtime -D
npm install @babel/runtime
```

修改 Webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
            plugins: [
              ['@babel/plugin-proposal-decorators', { legacy: true }],
              ['@babel/plugin-proposal-class-properties', { loose: true }],
              '@babel/plugin-transform-runtime', // Runtime 助手函数库
            ],
          },
        },
        exclude: /node_modules/, // 避免 Babel 转换 node_modules 里面的 js 代码
        include: path.resolve(__dirname, 'src'), // 仅让 Babel 转换 ./src 里面的 js 代码
      },
    ],
  },
};
```

这时再去查看 Webpack 打包产物，会发现加入了 Babel 的模块：

```javascript
'./node_modules/@babel/runtime/helpers/classCallCheck.js';

```

### Polyfill

JavaScript 具有一些高级的 API，比如 `string.prototype.includes`，低版本浏览器是不认识的，所以需要去实现这个方法以避免低版本浏览器兼容问题。

- `@babel/polyfill`：一个补丁模块，最后会引入到生产环境代码中

```s
npm install @babel/polyfill
```

在入口文件中（其实是任意文件），引入 `@babel/polyfill` 模块：

```javascript
require('@babel/polyfill');
```

打包之后可以发现，Babel 帮你重写实现了这个方法。（当然这样会导致打包产物体积变得非常大，polyfill 会加入很多的代码，**我们后续在提到 DLL 动态链接库时会去解决这个问题**。

<hr />

## ESLint 代码规范

在写 JavaScript 代码时，我们通常希望具有一定的代码风格校验，避免因为 JS 神奇的语法而发生一些难以预料的错误。

```s
npm install eslint eslint-loader -D
```

修改 Webpack 配置文件：

```javascript
module.exports = {
  // 省略部分代码...
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'eslint-loader',
          options: {
            // enforce 是一个配置选项，所以出现在 options 中
            enforce: 'pre', // 强制这个 Loader 最先执行，避免和 Babel Loader 冲突
          },
        },
        exclude: /node_modules/, // 避免 Eslint 校验 node_modules 里面的 js 代码
        include: path.resolve(__dirname, 'src'), // 仅让 Eslint 校验 ./src 里面的 js 代码
      },
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
            plugins: [
              ['@babel/plugin-proposal-decorators', { legacy: true }],
              ['@babel/plugin-proposal-class-properties', { loose: true }],
              '@babel/plugin-transform-runtime',
            ],
          },
        },
        exclude: /node_modules/,
        include: path.resolve(__dirname, 'src'),
      },
    ],
  },
};
```

<div class="note info">
关于 enforce：webpack module rule 会从下到上执行，如果先执行了 Babel Loader，会影响到 ESLint Loader 的使用，但是通过手动控制优先级也不是一个很好的解决方法。所以 Webpack 提供了 <code>enforce</code> 选项，它可以控制 Loader 的执行顺序。
<ul>
<li><code>pre</code>：最先执行</li>
<li><code>normal</code>：普通 Loader，低于 pre</li>
<li><code>post</code>：最后执行的 Loader</li>
</ul>
</div>

<hr />

## 小憩一下

在第三章中，会开始介绍更多 Webpack 对于 **第三方库**、**产物优化**、**打包图片** 等等...