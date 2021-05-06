---
title: Webpack4最佳实践与原理解析（十）
date: 2020-09-04 03:46:47
updated: 2020-09-04 03:46:47
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
> 在实现了一个简单的 Webpack 后，这次我们来看一看 **样式的 Loader** 是怎么实现的吧！一起手撕一个 **简单的 Loader** 和用我们自己的 Webpack 去 **解析 Loader**

<!--more-->

<hr />

## 前言

本篇文章是基于 <a href="https://www.wqh4u.cn/2020/09/02/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B9%9D%EF%BC%89/">Webpack4 最佳实践与原理解析（九）</a> 基础上编写的（因为我们用到了自己写的 Webpack），所以没看过第九章的推荐先去看这个。

当然还有 <a href="https://www.wqh4u.cn/2020/08/31/Webpack4%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5%E4%B8%8E%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90%EF%BC%88%E4%B8%80%EF%BC%89/">Webpack 最佳实践入口</a> 在这里！

<hr />

## 增加 Loader

我们先来简单的为 **Webpack 配置文件** 增加一个对 _LESS_ 的 Loader：

```javascript
// 省略部分代码...
module.exports = {
  module: {
    rules: [
      {
        test: /\.less/,
        use: ['style-loader', 'css-loader', 'less-loader'],
      },
    ],
  },
};
```

随后需要安装对应的包：

```s
npm install less less-loader css-loader style-loader -D
```

我们这次主要来实现这几个 Loader！

### 创建文件

在 Webpack Demo 文件中，创建 _loader_ 文件夹，里面写上三个文件，分别对应三个 Loader：

```javascript
// 文件目录：
// my-webpack-demo
// |
// |- loader
//     |- style-loader.js
//     |- css-loader.js
//     |- less-loader.js
```

### less-loader

我们先对 _less-loader_ 进行分析，在之前我们知道 **Loader 本质上就是一个函数，其接受一个参数，代表源代码**：

```javascript
function lessLoader(source) {
  // Loader 内部逻辑
}

module.exports = lessLoader;
```

随后，**Less-loader 内部是使用了 less 的**，就像 **Sass-loader 内部使用了 node-sass 一样，我们需要引入 **less\*\*：

```javascript
const less = require('less');

function lessLoader(source) {
  // Loader 内部逻辑
}

module.exports = lessLoader;
```

在 Less 中有一个名为 `render` 的方法，其接收 **源码** 作为参数，回调函数也遵循 Node 中 **错误先行原则**，我们从第二个参数中可以拿到转换后的 **CSS** 代码：

```javascript
const less = require('less');

function lessLoader(source) {
  let css = '';

  // Less 内部具有 render 方法
  less.render(source, (err, output) => {
    // output 参数中就有 css 属性，代表结果
    css = output.css.replace(/\n/g, '\\n'); // 替换转义问题，否则打包产物会有问题
  });
  return css;
}

module.exports = lessLoader;
```

### style-loader

<div class="note info">这里先暂时不实现 <code>css-loader</code>，因为 <code>less-loader</code> 的最终结果就是一段 CSS 代码，我们只需要实现 <code>style-loader</code> 的逻辑：<b>将 CSS 代码插入到 head 标签中</b> 即可</div>

对于 `style-loader` 来说，实现的方法比较简单：

```javascript
function styleLoader(source) {
  const styleString = `
    const styleElement = document.createElement('style');
    styleElement.innerHTML = ${JSON.stringify(source)}; // 这里为了处理换行问题
    document.head.appendChild(styleElement);
  `;
  return styleString;
}

module.exports = styleLoader;
```

### 写入 Webpack 配置文件

接下来我们需要将我们写好的 Loader，放入 **原生** Webpack 配置文件中康康效果：

```javascript
const path = require('path');
// 省略部分代码...
module.exports = {
  module: {
    rules: [
      {
        test: /\.less/,
        use: [
          path.resolve(__dirname, 'loader', 'style-loader'),
          path.resolve(__dirname, 'loader', 'less-loader'),
        ],
      },
    ],
  },
};
```

随后再创建一个 Less 文件并引入到入口文件中，再去执行 Webpack 打包...

最后观察原生 Webpack 打包结果：

```javascript
// 省略部分代码...
/***/ "./src/index.less":
/*!************************!*\
  !*** ./src/index.less ***!
  \************************/
/*! no static exports found */
/***/ (function(module, exports) {

eval("\n    const styleElement = document.createElement('style');\n    styleElement.innerHTML = \"body {\\n  background-color: #f00;\\n}\\n\";\n    document.head.appendChild(styleElement);\n  \n\n//# sourceURL=webpack:///./src/index.less?");

/***/ })
```

我们可以看到！通过我们自己写的 Loader，将 less 文件成功转换为了 css 样式并插入到了 DOM 中，最后可以运行一下包含打包产物的 HTML 文件，可以看到对应的效果~耶( •̀ ω •́ )y

<hr />

## 分析 Loader 过程

在我们之前写的 Webpack 代码中，我们抽离了一个名为 `getSource` 的方法，用来根据一个路径去获取某个模块的信息（源代码）。

在标准 Webpack 配置文件中，对 loader 的配置出现在 `module.rules` 中；对于具体的文件匹配名称存放于 `module.rules[i].test`，其中采用 **正则匹配** 的方式去判断对应的 Loader...

### 获取 rules

我们需要从 **配置文件** 中去获取 `rules` 再进行处理，这里需要注意 **防空**：

```javascript
class Compiler {
  /**
   * 获取模块信息（为了复用性）
   * @param {string} modulePath 模块绝对路径
   */
  getSource(modulePath) {
    // 为了增加 Loader，需要获取 rules
    const module = this.config.module;
    let rules = [];

    if (module.rules && module.rules.forEach) {
      // 存在 forEach 方法，将其当作一个数组来看
      rules = module.rules;
    }

    rules.forEach((rule) => {
      // 遍历每个规则，并对其进行处理...
    });

    const content = fs.readFileSync(modulePath, 'utf-8');
    return content;
  }
}
```

### 获取对应的 Loader

在遍历每个 rules 时，我们可以对 **当前模块路径** 进行正则匹配，如果匹配成功则 **对其使用 Loader**。

因为 Loader 的执行顺序是 **从后往前** 的，这里我们首先拿到最后一个 Loader 配置...

<div class="note info">为了方便，这里我们全部假设 <b>use 配置项一定是一个数组</b>，且 <b>每一个 Loader 配置项都是一个字符串</b></div>

```javascript
class Compiler {
  /**
   * 获取模块信息（为了复用性）
   * @param {string} modulePath 模块绝对路径
   */
  getSource(modulePath) {
    let content = fs.readFileSync(modulePath, 'utf-8');

    const module = this.config.module;
    let rules = [];

    if (module.rules && module.rules.forEach) {
      rules = module.rules;
    }

    rules.forEach((rule) => {
      // 遍历每个规则，并对其进行处理...
      const { test, use } = rule;

      // 匹配正则
      if (test.test(modulePath)) {
        // 这个模块需要通过 Loader 来转换
        // 因为 Loader 的顺序是从后往前，这里需要首先获取最后一个 Loader
        // 我们这里假设，所有的 use 配置项都是一个数组
        // 且每一个 Loader 配置项都是一个字符串
        const useLength = use.length;

        // 获取最后一个 Loader（字符串配置项）
        const loaderString = use[useLength - 1];

        // 直接引用这个 loader
        const loader = require(loaderString);

        // 传入源代码，执行 loader 处理
        content = loader(content);
      }
    });

    return content;
  }
}
```

随后为了 **依次逆序调用** 每一个 Loader，这里我们将 **传入 Loader** 的逻辑进行一个封装处理：

```javascript
function normalLoader() {
  // 获取最后一个 Loader（字符串配置项）
  const loaderString = use[useLength--];

  // 直接引用这个 loader
  const loader = require(loaderString);

  // 传入源代码，执行 loader 处理
  content = loader(content);

  // 利用递归进行处理
  if (useLength) {
    // 当前执行的不是最左边的
    // 即，之后还有 loader 需要处理
    normalLoader(); // 递归地去调用，处理下一个 loader
  }
}
```

可以看到，如果当前这个 Loader 执行栈没有执行到 **最后一个**（即，最左边的），那么就 **递归地** 去执行，这里也充分利用了 JS 的 **闭包** 去计算 **当前执行到了第几个 Loader**：

```javascript
class Compiler {
  /**
   * 获取模块信息（为了复用性）
   * @param {string} modulePath 模块绝对路径
   */
  getSource(modulePath) {
    let content = fs.readFileSync(modulePath, 'utf-8');

    // 为了增加 Loader，需要获取 rules
    const module = this.config.module;
    let rules = [];

    if (module.rules && module.rules.forEach) {
      // 存在 forEach 方法，将其当作一个数组来看
      rules = module.rules;
    }

    rules.forEach((rule) => {
      // 遍历每个规则，并对其进行处理...
      const { test, use } = rule;

      // 匹配正则
      if (test.test(modulePath)) {
        // 这个模块需要通过 Loader 来转换
        // 因为 Loader 的顺序是从后往前，这里需要首先获取最后一个 Loader
        // 我们这里假设，所有的 use 配置项都是一个数组
        // 且每一个 Loader 配置项都是一个字符串
        let useLength = use.length - 1;

        function normalLoader() {
          // 获取最后一个 Loader（字符串配置项）
          const loaderString = use[useLength--];

          // 直接引用这个 loader
          const loader = require(loaderString);

          // 传入源代码，执行 loader 处理
          content = loader(content);

          // 利用递归进行处理
          if (useLength >= 0) {
            // 之后还有 loader 需要处理
            normalLoader(); // 递归地去调用，处理下一个 loader
          }
        }

        normalLoader();
      }
    });

    return content;
  }
}
```

接下来咱们来试一试，看看咱们自己写的 Webpack 能不能实现这个功能。

在 Webpack demo 目录下，执行我们自己的 Webpack 脚本：

```s
npx euphoria-webpack
```

然后我们发现打包成功了！出现了产物，接下来我们去看看产物：

```javascript
{
  './src/index.less': function (module, exports,
    __webpack_require__) {
    eval(`const styleElement = document.createElement('style');
styleElement.innerHTML = "body {\\n  background-color: #f00;\\n}\\n";
document.head.appendChild(styleElement);`);
  },
}
```

看起来像成功打包了！接下来去看看浏览器运行结果，发现果然能行！Congratulations！
