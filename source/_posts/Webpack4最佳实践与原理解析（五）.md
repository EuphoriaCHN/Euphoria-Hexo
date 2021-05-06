---
title: Webpack4 最佳实践与原理解析（五）
date: 2020-09-01 01:04:17
updated: 2020-09-01 01:04:17
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
> 在这一篇我们将要开始 <b>区分 Webpack 打包环境，以及接下来的所有代码都将会涉及到不同打包环境的配置...</b>

<!--more-->

<hr/>

## 前言

<ul>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）：什么是 Webpack 与产物浅解析</a></li>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%8C%EF%BC%89/">Webpack4 最佳实践与原理解析（二）：Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%89%EF%BC%89/">Webpack4 最佳实践与原理解析（三）：使用第三方模块、图片打包、产物分类、多页应用处理</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E5%9B%9B%EF%BC%89/">Webpack4 最佳实践与原理解析（四）：SourceMap 源码映射、实时打包、常用插件配置 与 Webpack 跨域问题处理</a></li>
</ul>

<hr />

## 区分环境

我们在开发与上线时，经常需要对项目配置不同的 **环境参数** 以达到不同的效果。比如说 Ajax 时，在开发环境下会打到本地，在生产环境时会打到其他的主机下。

### 定义环境变量

这时我们需要使用 Webpack **自带** 的一个插件，为全局注入一个变量，最后根据这个变量来区分是开发模式还是上线模式。

修改 Webpack 配置文件：

```javascript
const Webpack = require('webpack');
// 省略部分代码...
module.exports = {
  plugins: [
    new Webpack.DefinePlugin({
      ENV: "'production'", // 在代码中的 ENV 会被替换为 'production'
    }),
  ],
};
```

<div class="note info">注意这里一定是 <code>"'production'"</code>，如果没有双引号就会被替换成一个叫做 <code>production</code> 的变量，然后报 undefined 错误！</div>

但是这样的写法很恶心，一定还有什么其他的解决方法...

```javascript
const Webpack = require('webpack');
// 省略部分代码...
module.exports = {
  plugins: [
    new Webpack.DefinePlugin({
      ENV: JSON.stringify('production'), // hhh...
    }),
  ],
};
```

### 区分不同的配置文件

我们不应当在每次 Debug 或打包到生产时去手动修改配置文件，应当对不同的路径采用不同的配置文件。我们一般将 Webpack 配置文件分为这几类：

- webpack.config.js：标准配置文件
- webpack.prod.js：生产环境适用的配置文件
- webpack.dev.js：开发环境使用的配置文件
- 当然还有其他的...自行配置（比如 DLL 抽离等

这时再去使用 Webpack 时，我们需要将多个配置文件 **合并** 成一个，提供给 Webpack 使用。此时我们需要依赖一个包：`webpack-merge` 去实现：

```s
npm install webpack-merge -D
```

以 `webpack.prod.js` 举例：

```javascript
const { merge: WebpackMerge } = require('webpack-merge');

// 导入 Webpack 标准（基本）配置文件
const webpackBaseConfig = require('./webpack.config.js');

module.exports = WebpackMerge(webpackBaseConfig, {
  mode: 'production', // 生产环境适用

  // 其他 Webpack 配置项...
});
```

这时 Webpack 启动时的配置文件也应当改为 `webpack.prod.js`，因为使用了 _WebpackMerge_，所以会将两个配置文件合并为一个，再传入到 Webpack-cli 中。

**最后根据自行需要，配置不同的 Webpack 配置文件即可**，下面给出 **本系列文章从头至此** 的 Webpack 配置，可选参考（不喜勿喷）：

**webpack.config.js**

```javascript
const path = require('path');

const Webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: {
    // 入口文件
    index: './src/index.js',
    // other: './src/other.js', // 其他入口
  },
  output: {
    filename: '[name].[hash:8].js', // 打包后的文件名
    // name 代表着不同的 chunk （代码块）名称
    path: path.resolve(__dirname, 'dist'), // 输出路径（这个必须是绝对路径
    // publicPath: '', // 在引用资源时，会统一加上这个值（比如 CDN 服务
  },
  resolve: {
    modules: [
      path.resolve(__dirname, 'node_modules'), // 限定包路径
      path.resolve(__dirname, 'src'),
    ],
    alias: {
      // 模块别名
    },
    // 指定扩展名，按顺序查找
    // 这样在 import 时，可以不用写文件扩展名
    // Webpack 会根据顺序查找，如果都没有再报错
    extensions: ['.js', '.jsx', '.ts', '.tsx'],
  },
  module: {
    // 模块
    rules: [
      // 规则
      {
        test: /\.css$/, // 匹配以 .css 结尾的文件
        use: [
          MiniCssExtractPlugin.loader, // 不使用 style-loader 了，样式需要抽离出来
          'css-loader',
          // 在送入 css-loader 之前，需要加上样式浏览器前缀
          'postcss-loader',
        ], // 采用两个 loader
        // Loader 的执行顺序是从右往左的，右侧的 Loader 输出将成为左侧 Loader 的输入
        // css-loader: 解析 CSS 文件（别忘了 CSS 也支持 @import 这样的语法
        // style-loader: 将 CSS 模块插入到 <head></head> 标签中
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
              ['@babel/plugin-proposal-class-properties', { loose: true }], // 处理 class 关键字
              '@babel/plugin-transform-runtime', // Runtime 助手函数库
            ],
          },
        },
        exclude: /node_modules/, // 避免 Babel 转换 node_modules 里面的 js 代码
        include: path.resolve(__dirname, 'src'), // 仅让 Babel 转换 ./src 里面的 js 代码
      },
      {
        test: /\.js$/,
        use: {
          loader: 'eslint-loader',
          options: {
            enforce: 'pre', // 强制这个 Loader 最先执行，避免和 Babel Loader 冲突
          },
        },
        exclude: /node_modules/, // 避免 Eslint 校验 node_modules 里面的 js 代码
        include: path.resolve(__dirname, 'src'), // 仅让 Eslint 校验 ./src 里面的 js 代码
      },
      // {
      //   test: require.resolve('jquery'), // 当代码中引入了 jQuery
      //   use: 'expose-loader?$',
      // },
      {
        test: /\.(png)|(jpg)|(gif)/,
        use: {
          loader: 'url-loader',
          options: {
            esModule: false, // 不使用 ESMODULE 加载图片
            limit: 8 * 1024, // 如果一个图片小于 8kb，那么将其转换为 Base 64 格式
            name: '[name].[hash:8].[ext]', // 输出文件名称
            outputPath: '/images', // 所有的这些产物都会放到 images 目录下
            // publicPath: '', // 仅对这个模块进行增加前缀（比如 CDN 路径
          },
        },
      },
      {
        test: /\.html/,
        use: 'html-withimg-loader',
      },
    ],
  },
  plugins: [
    // 数组，存放着 Webpack 的所有插件
    new MiniCssExtractPlugin({
      // 抽离 CSS 样式
      filename: 'styles/styles.[hash:8].css', // 抽离出的文件名称，抽离出的 CSS 产物放到 styles 目录下
    }),

    // Webpack 自带的，为每个模块提供插件
    new Webpack.ProvidePlugin({
      $: 'jquery', // 在每个模块中都注入这个 $
    }),
  ],
  externals: {
    jquery: '$',
  },
};
```

**webpack.dev.js**

```javascript
const { merge: WebpackMerge } = require('webpack-merge');
const Webpack = require('webpack');
const path = require('path');

// 导入 Webpack 标准（基本）配置文件
const webpackBaseConfig = require('./webpack.config.js');

// 依赖的库
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = WebpackMerge(webpackBaseConfig, {
  mode: 'development', // 开发环境适用

  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'), // 模板
      filename: 'index.html', // 打包后的文件名
      // chunks: ['index'], // 多页面应用使用，仅给这个 HTML 打包对应的入口文件
      hash: true, // 加上哈希戳
    }),

    // Webpack 定义插件（为全局定义一个环境
    new Webpack.DefinePlugin({
      ENV: JSON.stringify('development'), // 在代码中的 ENV 会被替换为 'development'
    }),
  ],

  devtool: 'eval-source-map', // 配置 Source map
  // source-map：产生单独的文件 & 行和列
  // eval-source-map：不会产生单独的文件，但是会展示行和列
  // cheap-module-source-map：不会显示列，仅会展示一个单独的文件
  // cheap-module-eval-source-wmap：不会产生单独的文件，不会展示列，仅会集成在打包后的文件中。

  // watch: true, // 监控代码变化，实时打包
  // watchOptions: {
  //   poll: 1000, // 每秒监控 1000 次，询问是否需要更新
  //   aggregateTimeout: 500, // 防抖，n 毫秒内防抖
  //   ignored: /node_modules/, // 不监控 node_modules
  // },

  devServer: {
    // 开发服务器的配置
    // todo: https://blog.csdn.net/franktaoge/article/details/80083317?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.channel_param
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

    proxy: {
      // Webpack 代理
    },
  },
});
```

**webpack.prod.js**

```javascript
const { merge: WebpackMerge } = require('webpack-merge');
const Webpack = require('webpack');
const path = require('path');

// 导入 Webpack 标准（基本）配置文件
const webpackBaseConfig = require('./webpack.config.js');

// 依赖的库
const OptimizeCssAssetsWebpackPlugin = require('optimize-css-assets-webpack-plugin');
const UglifyJsWebpackPlugin = require('uglifyjs-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = WebpackMerge(webpackBaseConfig, {
  mode: 'production', // 生产环境适用

  // 丑化和压缩 CSS 应当在生产环境
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

  plugins: [
    // 每次打包前，清空打包产物目录
    new CleanWebpackPlugin(),

    // 拷贝不变的文件（比如 doc
    // new CopyWebpackPlugin({
    //   // 这里的 from: './doc'，是以当前路径为相对路径
    //   // 这里的 to: './doc'，是以 output.path 为相对路径
    //   patterns: [{ from: './doc', to: './doc' }],
    // }),

    // 版权署名，会插入到每个打包结果的头部
    new Webpack.BannerPlugin('Make 2019 by Euphoria'),

    // 丑化 HTML，和 development 模式分开
    new HtmlWebpackPlugin({
      template: path.join(__dirname, 'src', 'index.html'), // 模板
      filename: 'index.html', // 打包后的文件名
      // chunks: ['index'], // 多页面应用使用，仅给这个 HTML 打包对应的入口文件
      minify: {
        // 生产环境打包时压缩 HTML
        removeAttributeQuotes: true, // 删除 HTML 不必要的双引号
        collapseWhitespace: true, // 丑化成一行
      },
      hash: true, // 加上哈希戳
    }),

    // Webpack 定义插件（为全局定义一个环境
    new Webpack.DefinePlugin({
      ENV: JSON.stringify('production'), // 在代码中的 ENV 会被替换为 'production'
    }),
  ],
});
```

<hr />

## 小憩一下

在第六章中，我们会去做 **Webpack 打包优化** 以及 **如何提升 Webpack 打包性能** 等等...
