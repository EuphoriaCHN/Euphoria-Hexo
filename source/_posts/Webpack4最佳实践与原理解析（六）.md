---
title: Webpack4 最佳实践与原理解析（六）
date: 2020-09-01 01:08:33
updated: 2020-09-01 01:08:33
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
> 在这一篇我们将要开始 <b>Webpack 打包优化、如何提升 Webpack 打包性能、DLL 动态链接库、happypack...</b>

<!--more-->

<hr/>

## 前言

<ul>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack4 最佳实践与原理解析（一）：什么是 Webpack 与产物浅解析</a></li>
<li><a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%8C%EF%BC%89/">Webpack4 最佳实践与原理解析（二）：Webpack 的基础配置，Loader 与常见 Loader 的使用以及对 JavaScript 代码使用 Babel 与 ESLint</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%89%EF%BC%89/">Webpack4 最佳实践与原理解析（三）：使用第三方模块、图片打包、产物分类、多页应用处理</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E5%9B%9B%EF%BC%89/">Webpack4 最佳实践与原理解析（四）：SourceMap 源码映射、实时打包、常用插件配置 与 Webpack 跨域问题处理</a></li>
<li><a href="https://www.wqh4u.cn/2020/09/01/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%BA%94%EF%BC%89/">Webpack4 最佳实践与原理解析（五）：区分 Webpack 打包环境</a></li>
</ul>

<hr />

## Webpack 打包优化

### noParse 提升打包性能

有的时候我们会引入一些很大的库（比如 jQuery 或 React 等），Webpack 这时会打包的很慢，因为它总是会去解析这些库中的其他依赖项。

可以通过 `noParse` 配置项去 **忽略** 某些模块的依赖库，**不去解析** 它们从而提升速度。

修改 Webpack 配置文件（webpack.config.js）：

```javascript
// 省略部分代码...
module.exports = {
  module: {
    noParse: /jquery/, // 不去解析 jQuery 中的依赖库
  },
};
```

所以一般情况下，**如果我们已知** 这个包中没有什么其他的依赖项，那么我们就可以手动的把它忽略掉，从而增加 Webpack 的打包速度。

### ignorePlugin 忽略三方模块自带导入

Webpack 在根据 `module.rules` 里面的配置项去解析文件时，有时也会去查找 `node_modules` 里面的文件，这时我们一般加上 `exclude` 去 **排除** 对应的目录 or 文件：

```javascript
// 省略部分代码...
module.exports = {
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
              '@babel/plugin-transform-runtime',
            ],
          },
        },
        // 避免 Babel 转换 node_modules 里面的 js 代码
        exclude: /node_modules/,
        // 仅让 Babel 转换 ./src 里面的 js 代码
        include: path.resolve(__dirname, 'src'),
      },
    ],
  },
};
```

但有些情况下我们会用到一些库，比如 `moment` 时间插件。但是哪怕只使用一个 moment 方法，都会造成打包产物的体积变得巨大，原因是这样的：

- moment 插件的 main 主文件是 `monent.js`
- 在 `monent.js` 中有这么一段代码：

```javascript
var aliasedRequire = require;
aliasedRequire('./locale/' + name);
```

- `locale` 里面放了非常多的语言包，所以在加载 moment 时它会自动把所有的语言包引入，从而导致了打包产物体积变得非常大
- moment 这样做的原因是为了支持 i18n，在使用时可以通过 `moment.locale(zh-cn)` 去设置 i18n 文案

但是我们希望的是，不引入所有的包，可能用户只需要使用极少一部分的文件。即 **忽略掉三方模块自动引入的一些额外文件**，从而减少打包体积过大问题。

Webpack **内置** 了一个名为 `ignorePlugin` 的插件，可以很好的帮我们解决这个问题。

修改 Webpack 配置文件：

```javascript
const Webpack = require('webpack');
// 省略部分代码...
module.exports = {
  plugins: [
    // Webpack 自带插件，忽略三方模块内部注入从而导致打包体积过大问题
    // 如果从 moment 中引入了 ./locale，则忽略掉
    new Webpack.IgnorePlugin(/\.\/locale/, /monent/),
  ],
};
```

这时 Webpack 就不会把 `./locale` 里面的模块引入，用户在使用时则需要 **显式手动引入** 这个模块：

```javascript
import moment from 'moment';

// 手动引入所需要的语言包
import 'moment/locale/zh-cn';

moment.locale('zh-cn');
console.log(moment.endOf('day').formNow());
```

### Webpack DLL 动态链接库

在学习 React 时，我们的第一个程序通常是这样的：

```jsx
import * as React from 'react';
import ReactDom from 'react-dom';

const root = document.getElementById('root');
const element = <h1>Hello, World</h1>;

ReactDom.render(element, root);
```

同时别忘了增加对 React JSX 语法的 Babel 配置：

```s
npm install @babel/preset-react -D
```

同时修改 Webpack 配置文件（webpack.config.js）：

```javascript
// 省略部分代码...
module.exports = {
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
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

这时进行打包会发现，产物的体积会变得 **巨大无比**，因为引入了 React 和 React-Dom 这两个模块，Webpack 在打包时会将它们 **一并放入** JavaScript 文件中去。

解决它们的思路是 **将 React 这些超大包** 单独抽离出来，不放入打包产物中，以此减少产物体积。所以我们需要单独将例如 React 这样的大型第三方库进行打包。

我们可以创建一个叫做 `webpack.config.react.js` 的配置文件，假设它是用来 **单独打包 React** 的配置项，之后我们只需要将 React 打包产物引入到项目中即可：

```javascript
const path = require('path');

module.exports = {
  mode: 'development',
  entry: {
    test: './src/testReact.js',
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
  },
};
```

接下来编写一下 `./src/testReact.js`：

```javascript
module.exports = 'Euphoria'; // 假设这里导出了一个字符串
// 其实对于 React，也是这样导出出来供用户使用的
```

接下来进行 Webpack 打包，看看结果如何：

```s
npx webpack --config webpack.config.react.js
```

在最开始我们分析过 Webpack 产物代码，去除掉暂时没用的代码后是这样的：

```javascript
(function (modules) {
  function __webpack_require__(moduleId) {
    // （缓存机制）

    // （创建新模块）

    // 调用这个模块，获取 module.exports
    modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
    );

    // 设置该模块被调用，供缓存机制使用

    return module.exports; // 返回这个模块的导出结果
  }

  // 通过主入口文件加载，返回模块结果
  return __webpack_require__((__webpack_require__.s = './src/testReact.js'));
})({
  './src/testReact.js': function (module, exports) {
    eval("module.exports = 'Euphoria';");
  },
});
```

这时我们会发现，通过这样的方式，我们无法获取到 `Euphoria` 字符串，因为最大的那个 _立即执行函数_ 的返回值是没有被接收的。

我们可以修改一下 Webpack 打包产物，让他变成这个样子：

```javascript
// 增加一个变量，用于接受主模块
const mainModule = (function (modules) {
  function __webpack_require__(moduleId) {
    // 代码省略
  })({
  './src/testReact.js': function (module, exports) {
    eval("module.exports = 'Euphoria';");
  },
});

console.log(mainModule); // Euphoria
```

再类比到 React，我们可以通过这样的产物，去拿到整个 React 的打包产物，再放到项目代码中去使用，从而 **减少了打包体积**，美滋滋。

总结一下上面的流程，大致是这样的：

- 手撕一个三方库的 Webpack 打包配置
- 手撕获取打包产物结果
- 手动再把结果引入

这样的流程对于大型项目是完全不可取的，所以我们要从 Webpack 自身下手，去用 Webpack **抽离出三方模块** 并实现以上的需求。

通过修改 Webpack 配置文件（webpack.config.react.js）：

```javascript
// 省略部分代码
module.exports = {
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    library: '[name]_[hash:8]', // 指定一个接收名称
  },
};
```

此时我们再进行一次 Webpack 打包，看看结果：

```javascript
// 指定一个名字去接收它
var test_933e20a0 = (function (modules) {
  function __webpack_require__(moduleId) {
    // 代码省略
  })({
  './src/testReact.js': function (module, exports) {
    eval("module.exports = 'Euphoria';");
  },
});
```

当然还有其他参数：

```javascript
module.exports = {
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    library: '[name]_[hash:8]', // 指定一个接收名称
    libraryTarget: 'commonjs', // 可以把当前的结果，放到 exports 属性上
    // commonjs: exports[xxx]
    // umd: 统一资源模式
    // var: default
    // ...
  },
};
```

**那么现在，我们需要正式地打包 React 了！**

```javascript
const path = require('path');
const Webpack = require('webpack');

const UglifyJsWebpackPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  mode: 'production',
  entry: {
    react: ['react', 'react-dom'], // 打包 React 相关
    // 当然这里还能写其他的
    // 比如 react-router-dom、react-router 等
    // 还有其他分类，比如 axios、classnames 等等
  },
  output: {
    filename: '_dll_[name].js', // 注明生成的产物是 DLL 动态链接库文件
    path: path.resolve(__dirname, 'dist', 'dll'),
    library: '[name]_[hash:8]',
  },
  optimization: {
    // Webpack 优化项
    minimizer: [
      new UglifyJsWebpackPlugin({
        cache: true, // 利用缓存
        parallel: true, // 并发压缩
        uglifyOptions: {
          compress: {
            drop_console: true, // 去除 console
            keep_infinity: true, // 去除影响性能的代码
          },
          output: {
            comments: false, // 去除注释
            beautify: false, // 紧凑输出
          },
        },
      }),
    ],
  },
  plugins: [
    new Webpack.DllPlugin({
      // 动态链接库名称，这个必须要和 output.library 同名
      name: '[name]_[hash:8]',

      // 生成一个 JSON 文件，表明动态链接库的路径
      // 这个 JSON 文件也叫【任务清单】
      // 其将会去动态链接库文件里面去查找对应的模块
      path: path.join(__dirname, 'dist', 'manifest.json'),
    }),
  ],
};
```

最后生成的 JSON 文件，里面其实定义的就是一个个模块里面所需的依赖模块入口，感兴趣可以去看一下文件具体内容，这里不再做过多赘述。

然后，只需要在最终生成的 HTML 文件中引入打包过后的动态链接库 �� 可。

<div class="note info">这就完了？才不是，现在我们仍然需要 <b>手动地</b> 引入每个 DLL 文件，这会很麻烦！</div>

当我们在代码中导入 React 时，Webpack 仍然会将其打包至产物中，我们应当告诉 Webpack，**有哪些文件是需要先搜索动态链接库的**，找不到再打包。

修改 Webpack Base 配置文件（webpack.config.js）：

```javascript
const Webpack = require('webpack');
// 省略部分代码
module.exports = {
  plugins: [
    // 引用 DLL 动态链接库文件
    new Webpack.DllReferencePlugin({
      // 查找 DLL 清单，找不到了再打包
      manifest: path.join(__dirname, 'dist', 'manifest.json'),
    }),
  ],
};
```

这里其实还不能解决 DLL 文件没有导入至 HTML 中的问题，我们还需要一个三方库：

```s
npm install add-asset-html-webpack-plugin -D
```

然后修改 Webpack 配置文件（webpack.config.js）：

```javascript
const path = require('path');
const AddAssertHtmlWebpackPlugin = require('add-asset-html-webpack-plugin');

// 省略部分代码
module.exports = {
  plugins: [
    // 将 DLL 文件插入 HTML 代码中
    new AddAssertHtmlWebpackPlugin({
      filepath: path.join(__dirname, 'dist', 'dll', '_dll_react.js'),
    }),
  ],
};
```

这样还觉得不够爽？那就用 `fs` 模块去嗅探 `dist/dll` 目录下的所有 js 文件，将其打包至 Plugins 中：

```javascript
const path = require('path');
const fs = require('fs');
const AddAssertHtmlWebpackPlugin = require('add-asset-html-webpack-plugin');

// 获取所有的 dll modules，并对每一个都用 AddAssertHtmlWebpackPlugin 包起来
const DllModules = fs.readdirSync(path.resolve(__dirname, 'dist', 'dll')).map(
  (filename) =>
    new AddAssertHtmlWebpackPlugin({
      filepath: path.join(__dirname, 'dist', 'dll', filename),
    })
);

// 省略部分代码
module.exports = {
  plugins: [
    // 其他 Plugins
  ].concat(DllModules),
};
```

这样就可以自动拉取到所有的 DLL 动态链接库文件了~

<div class="note info"><p>经过实操，发现如果把 DLL 目录放到 dist 中，在打包生产环境代码时因为 CleanWebpackPlugin 的存在，会先删除整个 dist 文件夹中的内容，从而导致打包时找不到 DLL 目录。</p><p>这时建议把 DLL 目录放到其他位置，而不是 dist 内部。因为 Webpack 在打包过后，dist 内部是会生成对应的 dll 文件的，这样更容易维护与迭代，并且可以在 DLL Webpack Config 中也加入 CleanWebpackPlugin 插件~</p></div>

<div class="note info">每一个 manifest.json 只能对应一个 DLL 库，如果要抽离多个不同的模块，那么需要给 JSON 文件生成时写上 <code>[name]</code> 进行区分，并且也需要导入所有的 JSON 文件</div>

<hr />

## happypack

Webpack 的打包速度还是很慢？这时候我们需要一个“快乐的模块”，叫做 `happypack`，它可以使用 **多线程** 来进行打包。

```s
npm install happypack -D
```

修改 Webpack 配置文件（webpack.config.js）：

```javascript
// 省略部分代码...
const Happypack = require('happypack');

module.exports = {
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          // 使用 happypack 打包 id 为 Happypack-js 的 loader
          loader: 'Happypack/loader?id=Happypack-js',
        },
        exclude: /node_modules/,
        include: path.resolve(__dirname, 'src'),
      },
    ],
  },

  plugins: [
    new Happypack({
      id: 'Happypack-js', // 创建一个 id 为 Happypack-js 的 Loader
      loaders: [
        {
          loader: 'babel-loader', // 原来打包 JS 用的 Loader
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
            plugins: [
              ['@babel/plugin-proposal-decorators', { legacy: true }],
              ['@babel/plugin-proposal-class-properties', { loose: true }],
              '@babel/plugin-transform-runtime',
            ],
          },
        },
      ],
    }),
  ],
};
```

其实就是给原本的 Loader 套了层 happypack 的壳，让他们可以进行多线程打包。

同理，我们可以把其余所有的 `rules` 都经过 happypack 打包~

### happypack 的一个大问题

<div class="note danger">
<p><b>这里有一个特别恐怖的错误！</b></p>
<p>之前我们为了抽离 CSS 文件，使用了 <code>mini-css-extract-plugin</code> 插件，但是它自身 <b>和 happypack 有冲突</b>！</p>
</div>

不论是把 `MiniCssExtractPlugin.loader` 放在 happypack 内部还是外面，都会报错：

内部：

<div class="note danger">TypeError: Cannot read property 'outputOptions' of undefined</div>

外部：

<div class="note danger">UnhandledPromiseRejectionWarning: TypeError: this.getResolve is not a function</div>

经过查阅资料（Github），发现是这样的：

- 用户 joebnb 在 (mini-css-extract-plugin)[https://github.com/webpack-contrib/mini-css-extract-plugin] 的代码库中提出了 (这个 ISSUE)[https://github.com/webpack-contrib/mini-css-extract-plugin/issues/273]，抛出了在 Happypack 内部使用 MiniCssExtractPlugin.loader 而发生的 Cannot read property 'outputOptions' of undefined 问题
- mini-css-extract-plugin 的开发者 evilebottnawi (回复)[https://github.com/webpack-contrib/mini-css-extract-plugin/issues/273#issuecomment-420576095]：“请在 Happypack 里面创建一个 ISSUE，我们使用的都是 Webpack 标准 API”（甩出去了）
- 过了两天，joebnb 去给 Happypack 提 (ISSUE)[https://github.com/amireh/happypack/issues/242]
- Happypack 的开发者 richardsolomou 很快的复现了这个问题
- 过了几个月，Happypack 的另一个开发者 AILINGANGEL (回复)[https://github.com/amireh/happypack/issues/242#issuecomment-520227197]：“复现了这个问题，但没有解决它的思路”
- 然后就没有然后了... 从 2018 年 9 月 13 号一直到了现在（2020 年 8 月 30 号）...

然而在 Webpack 4 之前，有一个叫做 [extract-text-webpack-plugin
](https://github.com/webpack-contrib/extract-text-webpack-plugin) 的库，作用和 mini-css-extract-plugin 差不多，但是在 Webpack 4 之后被废弃了。

所以现在我们用 Webpack 4+，没有三方库可以帮助我们既能使用 happypack 进行多线程打包，也能使用 MiniCssExtractPlugin.loader 进行 CSS 抽离...

**于是本篇文章放弃对 CSS 模块采用 happypack 进行多线程打包。**

<hr />

## Webpack 自带优化

### tree-shaking

默认情况下，我们在使用 `import` 语法进行模块导入时，在 **生产环境下** 会自动去除掉 **没有被用到的代码**。

比如创建了一个这样的模块：

```javascript
const sum = (a, b) => `${a + b} sum`;
const minus = (a, b) => `${a - b} minus`;

export default {
  sum,
  minus,
};
```

然后我们在另一个模块中仅导入 `sum`：

```javascript
import * as calc from './test.js';
console.log(calc.sum(1, 2));
```

此时如果用 **开发环境** 打包，产物中 **也会出现没有被用到的 minus**，但如果用 **生产环境** 进行打包，就不会出现 `minus`。

这就是 Webpack 自身的一个打包优化点，专业一点就叫做 **tree-shaking**（树的摇晃，将没用的叶子摇掉）。

但是这个特性只会作用于 `import` 关键字，如果使用 `require` 语法则不会进行 **tree-shaking**。

### scope-hosting

如果有下面的代码:

```javascript
let a = 1;
let b = 2;
let c = 3;
let d = a + b + c;
console.log(d);
```

如果我们用 webpack 对其进行打包，然而最后的打包产物直接变成了：

```javascript
// 省略部分代码...
console.log(6);
```

在 Webpack 中会自动省略一些可以简化的代码，即 **scope-hosting**（作用域提升）。

<hr />

## 小憩一下

在第七章中，我们会去做 **Webpack 其他优化**，比如 **抽取多入口公共代码**、**热更新** 和 **懒加载**...
