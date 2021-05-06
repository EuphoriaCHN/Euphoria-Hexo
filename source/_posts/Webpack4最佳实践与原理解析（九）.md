---
title: Webpack4 最佳实践与原理解析（九）
date: 2020-09-02 02:35:02
updated: 2020-09-02 02:35:02
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
> 第三个大型 **手撕代码**，这次我们来 **手撕** 一个简单的 **Webpack**！

<!--more-->

<hr />

## 前言

本作是整站第三个 **手撕实现某库代码** 文章，前两个分别是：

- [原生JavaScript实现Promise](https://www.wqh4u.cn/2020/01/21/%E5%8E%9F%E7%94%9FJavaScript%E5%AE%9E%E7%8E%B0Promise/)
- [实现Common-JS中的require方法](https://www.wqh4u.cn/2020/02/10/%E5%AE%9E%E7%8E%B0Common-JS%E4%B8%AD%E7%9A%84require%E6%96%B9%E6%B3%95/)

经过了前八章的经历，终于这一次，我们要开始 **手撕 Webpack** 了！

<hr />

## 手撕 Webpack

要手撕出来 Webpack，当然首先要安装原生的 Webpack，仔细分析其中的打包原理与方法：

```s
npm init -y
npm install webpack webpack-cli -D
```

目录结构如下：

```javascript
/**
src:
|    a.js
|    index.js
|- base
     b.js
*/

// index.js
const str = require('./a.js');
console.log(str);

// a.js
const b = require('./base/b.js');
module.exports = 'a' + b;

// base/b.js
module.exports = 'b';
```

最后在根目录下创建 Webpack 配置文件 `webpack.config.js`，有了之前的基础，我们可以快速配置一下：

```javascript
const path = require('path');

module.exports = {
  mode: 'development',
  entry: path.join(__dirname, 'src', 'index.js'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js',
  },
};
```

最后执行 `npx webpack`，将会在根目录的 `dist` 文件中生成一个打包产物，我们将没有用的注释去掉是这样的：

```javascript
(function (modules) {
  var installedModules = {};

  function __webpack_require__(moduleId) {
    if (installedModules[moduleId]) {
      return installedModules[moduleId].exports;
    }
    var module = (installedModules[moduleId] = {
      i: moduleId,
      l: false,
      exports: {},
    });

    modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
    );

    module.l = true;

    return module.exports;
  }

  __webpack_require__.m = modules;

  __webpack_require__.c = installedModules;

  __webpack_require__.d = function (exports, name, getter) {
    if (!__webpack_require__.o(exports, name)) {
      Object.defineProperty(exports, name, { enumerable: true, get: getter });
    }
  };

  __webpack_require__.r = function (exports) {
    if (typeof Symbol !== 'undefined' && Symbol.toStringTag) {
      Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
    }
    Object.defineProperty(exports, '__esModule', { value: true });
  };

  __webpack_require__.t = function (value, mode) {
    if (mode & 1) value = __webpack_require__(value);
    if (mode & 8) return value;
    if (mode & 4 && typeof value === 'object' && value && value.__esModule)
      return value;
    var ns = Object.create(null);
    __webpack_require__.r(ns);
    Object.defineProperty(ns, 'default', { enumerable: true, value: value });
    if (mode & 2 && typeof value != 'string')
      for (var key in value)
        __webpack_require__.d(
          ns,
          key,
          function (key) {
            return value[key];
          }.bind(null, key)
        );
    return ns;
  };

  __webpack_require__.n = function (module) {
    var getter =
      module && module.__esModule
        ? function getDefault() {
            return module['default'];
          }
        : function getModuleExports() {
            return module;
          };
    __webpack_require__.d(getter, 'a', getter);
    return getter;
  };

  __webpack_require__.o = function (object, property) {
    return Object.prototype.hasOwnProperty.call(object, property);
  };

  __webpack_require__.p = '';

  return __webpack_require__((__webpack_require__.s = './src/index.js'));
})({
  './src/a.js': function (module, exports, __webpack_require__) {
    eval(
      'const b = __webpack_require__("./src/base/b.js");\r\n\r\nmodule.exports = \'a\' + b;'
    );
  },

  './src/base/b.js': function (module, exports) {
    eval("module.exports = 'b';\r\n\n");
  },

  './src/index.js': function (module, exports, __webpack_require__) {
    eval(
      'const str = __webpack_require__("./src/a.js");\r\nconsole.log(str);\r\n\n\n'
    );
  },
});
```

可以看出，Webpack 自己实现了一个 `require` 方法，叫做 <code>**webpack_require**</code>，里面会默认引入主文件 `index.js`，并且会在执行时传入一个 KV 参数，其中 K 就是文件相对路径，V 就是代码块。

我们可以直接在 `dist` 目录下创建一个 HTML 文件，并直接将打包产物引入，打开 HTML 后发现是可以运行的。

接下来我们要开始写自己的 Webpack 了！

### 创建命令行工具

我们可以新开一个文件夹，代表我们自己的 Webpack。在初始化 `package.json` 后，我们可以加入一个 `bin` 属性，代表命令行工具。

在这个文件夹中，创建一个名为 `bin` 的目录，然后写上自己的 `euphoria-pack.js` 核心文件，随后将其加入到 `package.json` 中：

```json
{
  "name": "euphoria-webpack",
  "version": "1.0.0",
  "description": "手撕 Webpack",
  "bin": {
    "euphoria-webpack": "./bin/euphoria-pack.js"
  },
  "author": "",
  "license": "MIT"
}
```

然后修改 `euphoria-pack.js`，此时我们需要告诉命令行需要如何执行这个文件：

```javascript
#! /usr/bin/env node

console.log('Hello, webpack');
```

随后我们需要将这个命令 **链接** 到全局下，可以通过 `npm link` 完成，在链接之后会出现：

```text
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN euphoria-webpack@1.0.0 No repository field.

up to date in 0.159s
C:\Users\euphoria\AppData\Roaming\npm\euphoria-webpack -> C:\Users\euphoria\AppData\Roaming\npm\node_modules\euphoria-webpack\bin\euphoria-pack.js
C:\Users\euphoria\AppData\Roaming\npm\node_modules\euphoria-webpack -> C:\Users\euphoria\Desktop\program\webpack_study\euphoria-webpack
```

（可以看作软连接？`ln -s`）

### 将自己的包应用到项目

回到最开始的项目文件夹，使用 `npm link euphoria-webpack` 将已经存在于全局的包映射到本地上：

```text
测试目录\node_modules\euphoria-webpack -> 全局命令\euphoria-webpack -> 包目录\euphoria-webpack
```

随后在 **测试目录** 下使用 `npx euphoria-webpack` 命令，会看到结果：

```text
Hello, webpack
```

此时就可以开始工作啦！

<hr />

## Webpack 分析及处理

### 获取命令执行路径

在观察原生 webpack 打包过程时，可以得出：首先需要的是找到当前执行命令的路径，拿到 webpack.config.js。

```javascript
#! /usr/bin/env node

const path = require('path');
// Webpack 内部维护了一个编译类
const Compiler = require('../lib/Compiler.js');

// 获取配置文件（默认就是当前文件夹的 webpack.config.js
const config = require(path.resolve('webpack.config.js'));

// 创建一个编译器
const compiler = new Compiler(config); // 传入配置文件

compiler.run(); // 标识运行代码
```

在自己的 Webpack 中可以创建一个 `lib` 文件夹，里面专门存放我们的 Webpack 源码。

### Compiler 类

在上面，我们可以知道一个 `Compiler` 类：

- 可以 `new` 出实例，并传入配置参数
- 有一个 `run` 方法，表示运行代码

```javascript
class Compiler {
  // 构造器传入配置文件
  constructor(config) {
    this.config = config;

    // 1. 需要保存入口文件路径
    // 2. 需要保存所有模块依赖
  }

  // 表示执行代码
  run() {
    // 1. 解析当前文件依赖
  }
}

module.exports = Compiler;
```

在打包产物中我们可以分析出：

- Webpack 启动函数最开始传入的是 **入口文件路径**
- Webpack 内部维护了所有模块的依赖关系

```javascript
constructor(config) {
  this.config = config;

  // 1. 需要保存入口文件路径
  this.entry = config.entry;
  this.entryId = null; // 保存主模块信息（ID）

  // 2. 需要保存所有模块依赖
  this.modules = {};

  // 获得当前文件的绝对路径（工作路径）
  this.root = process.cwd();
}
```

<div class="note danger">获取工作路径时，请注意不同操作系统的不同用法！这里以 Windows 举例</div>

#### 创建模块依赖关系

Webpack 在运行时，需要维护所有的模块依赖关系，因此需要一个 build 方法，且这个方法在 `run` 中会调用：

```javascript
run() {
  // 传入入口模块，并标明这是一个【主模块】
  this.buildModule(path.resolve(this.root, this.entry), true);

  // 最后也需要发射我们的打包产物
  this.emitFile();
}
```

接下来编写 **构造模块依赖关系** 方法：

```javascript
/**
 * 构造模块依赖关系
 * @param {string} modulePath 模块路径
 * @param {boolean} isEntry   是否为入口模块
 */
buildModule(modulePath, isEntry) {}
```

#### 获取模块内容

我们可以通过 `fs.readFileSync` 去读取文件内容：

```javascript
class Compiler {
  /**
   * 构造模块依赖关系
   * @param {string} modulePath 模块路径
   * @param {boolean} isEntry   是否为入口模块
   */
  buildModule(modulePath, isEntry) {
    // 获取模块内容
    const source = this.getSource(modulePath);
  }

  /**
   * 获取模块信息（为了复用性）
   * @param {string} modulePath 模块绝对路径
   */
  getSource(modulePath) {
    const content = fs.readFileSync(modulePath, 'utf-8');
    return content;
  }
}
```

#### 构造模块 ID

在打包产物中可以看出，每个模块的 ID 就是其对于执行目录的 **相对路径**，然而我们现在获取的 `modulePath` 是一个绝对路径，所以我们需要对其进行处理：

```javascript
class Compiler {
  /**
   * 构造模块依赖关系
   * @param {string} modulePath 模块路径
   * @param {boolean} isEntry   是否为入口模块
   */
  buildModule(modulePath, isEntry) {
    // 获取模块内容
    const source = this.getSource(modulePath);

    // 获取模块 ID
    // path.relative 可以获取两个路径的差
    // 模块绝对路径 - 执行目录绝对路径 = 模块相对路径
    // 取出来的结果类似 'src/index.js'，我们还需要在最前面补上 './'
    const moduleName = '.\\'.concat(path.relative(this.root, modulePath));

    console.log(source);
    console.log(moduleName);
  }
}
```

现在在 **测试目录** 中使用 `npx euphoria-webpack` 看看结果：

```text
const str = require('./a.js');
console.log(str);

.\src\index.js
```

说明我们已经可以读取 **主模块内容** 和 **主模块路径（ID）** 了！

#### 解析源代码

接下来，我们还需要做三件事情：

- 将模块中的 `require` 改为我们自己的 <code>**webpack_require**</code>
- 修改模块 `require` 引入路径，比如 `./a.js` 需要改为 `./src/a.js`
- 对所有模块的引用，都需要加上 `src`

```javascript
class Compiler {
  /**
   * 构造模块依赖关系
   * @param {string} modulePath 模块路径
   * @param {boolean} isEntry   是否为入口模块
   */
  buildModule(modulePath, isEntry) {
    // 获取模块内容
    const source = this.getSource(modulePath);

    // 获取模块 ID
    // path.relative 可以获取两个路径的差
    // 模块绝对路径 - 执行目录绝对路径 = 模块相对路径
    // 取出来的结果类似 'src/index.js'，我们还需要在最前面补上 './'
    const moduleName = '.\\'.concat(path.relative(this.root, modulePath));

    // 保存主入口名称
    if (isEntry) {
      this.entryId = moduleName;
    }

    // 解析源码
    // - 将模块中的 `require` 改为我们自己的 <code>__webpack_require__</code>
    // - 修改模块 `require` 引入路径，比如 `./a.js` 需要改为 `./src/a.js`
    // - 对所有模块的引用，都需要加上 `src`
    // path.dirname 可以拿到某个文件位于文件夹的名称（这里用来取 src）
    // parse 解析会返回一个【依赖列表】
    const { sourceCode, dependencies } = this.parse(
      source,
      path.dirname(moduleName)
    );

    // 安装模块
    // 把相对路径（模块 ID）和各个模块对应起来
    this.modules[moduleName] = sourceCode;
  }
}
```

接下来，我们需要实现 `parse` 解析源码功能，这里就需要去构造 & 解析 AST 抽象语法树了：

```javascript
class Compiler {
  /**
   * 解析模块源码
   * @param {string} source 模块源码
   * @param {string} parentPath 父路径
   */
  parse(source, parentPath) {
    // 使用 AST 解析语法树
  }
}
```

<div class="class note">学过编译原理的小伙伴们应该知道 AST，但是不要被它的复杂逻辑与结构吓到...我们不会去手撕例如【词法分析】、【语法分析】、【语义分析】等等非常复杂的关系图或状态自动机（否则这个系列就完不了了...）</div>

对于 AST 抽象语法树的构造，我们使用 Babel 去完成...

<hr />

## 构造 AST 抽象语法树

<div class="note info">关于 AST，这里不做过多的赘述，对于 AST 结构等可以去 <a href="https://astexplorer.net/">这里</a> 康康</div>

为了构造 AST，我们这里采用一些现成的三方库：

- babylon：主要把源码转换成 AST，内部有一个 `parse` 方法去解析源代码
- @babel/traverse：遍历 AST 节点
- @babel/types：替换 AST 节点
- @babel/generator：生成新的源码

```s
npm install babylon @babel/traverse @babel/types @babel/generator
```

这样我们就可以去使用了：

### 通过 babylon 获取 AST

babylon 中有 `parse` 方法，可以帮助将源代码转换为 AST 抽象语法树：

```javascript
const babylon = require('babylon');

class Compiler {
  parse(source, parentPath) {
    // 获得抽象语法树
    const ast = babylon.parse(source);
  }
}
```

### 通过 traverse 遍历抽象语法树

`traverse` 是一个用来 **遍历抽象语法树** 的方法，传入 AST 和 **遍历控制对象**。在这里我们需要去解析目标文件的 **依赖模块**，所以我们需要对 `require` 进行处理：

```javascript
const babylon = require('babylon');
// traverse 和 generator 是一个 ES 6 模块，需要用 default 来导入 CommonJS
const traverse = require('@babel/traverse').default;

class Compiler {
  parse(source, parentPath) {
    // 获得抽象语法树
    const ast = babylon.parse(source);

    traverse(ast, {
      // 调用表达式，比如 a() 或 require() 就是调用
      // 遇到调用表达式就会进到这里面来
      CallExpression(_path) {
        const node = _path.node; // 获得节点

        if (node.callee.name === 'require') {
          // 对 require 调用进行改造
        }
      },
    });
  }
}
```

### 修改对应代码节点

`types` 可以快速帮我们替换 **AST 节点**，当然如果只是修改某个值可以直接对 AST 进行操作：

```javascript
const babylon = require('babylon');
const types = require('@babel/types');
// traverse 和 generator 是一个 ES 6 模块，需要用 default 来导入 CommonJS
const traverse = require('@babel/traverse').default;

class Compiler {
  parse(source, parentPath) {
    // 获得抽象语法树
    const ast = babylon.parse(source);

    traverse(ast, {
      // 调用表达式，比如 a() 或 require() 就是调用
      // 遇到调用表达式就会进到这里面来
      CallExpression(_path) {
        const node = _path.node; // 获得节点

        if (node.callee.name === 'require') {
          // 对 require 调用进行改造
          node.callee.name = '__webpack_require__';

          let moduleName = node.arguments[0].value; // 模块引用名称
          // moduleName 就是 require('./a') 里面的 './a'

          // 如果没有扩展名，需要对 moduleName 增加扩展名
          moduleName = moduleName.concat(path.extname(moduleName) ? '' : '.js');

          // 现在是 ./a.js，需要将其改为 src/a.js
          if (/^\./.test(moduleName)) {
            moduleName = moduleName.split(/^\./)[1];
          }
          moduleName = parentPath.concat(moduleName);

          // 增加前缀
          if (!/^[(\.\/)(\.\\)]/.test(moduleName)) {
            moduleName = '.\\'.concat(moduleName);
          }

          // 修改源码，通过文档我们可以查出
          // 这里需要一个 stringLiteral 类型的节点
          node.arguments = [types.stringLiteral(moduleName)];
        }
      },
    });
  }
}
```

最后使用 `generator` 导出新的代码，整体代码如下：

```javascript
const babylon = require('babylon');
const types = require('@babel/types');
// traverse 和 generator 是一个 ES 6 模块，需要用 default 来导入 CommonJS
const traverse = require('@babel/traverse').default;
const generator = require('@babel/generator').default;

class Compiler {
  /**
   * 解析模块源码
   * @param {string} source 模块源码
   * @param {string} parentPath 父路径
   */
  parse(source, parentPath) {
    // 解析源码成抽象语法树
    const ast = babylon.parse(source);

    const dependencies = []; // 依赖模块

    traverse(ast, {
      CallExpression(_path) {
        // 调用表达式，比如 a() 或 require() 就是调用
        const node = _path.node; // 获得节点

        if (node.callee.name === 'require') {
          // 对 require 调用进行改造
          node.callee.name = '__webpack_require__';

          let moduleName = node.arguments[0].value; // 模块引用名称
          // moduleName 就是 require('./a') 里面的 './a'

          // 如果没有扩展名，需要对 moduleName 增加扩展名
          moduleName = moduleName.concat(path.extname(moduleName) ? '' : '.js');

          // 现在是 ./a.js，需要将其改为 src/a.js
          if (/^\./.test(moduleName)) {
            moduleName = moduleName.split(/^\./)[1];
          }
          moduleName = parentPath.concat(moduleName);

          // 增加前缀
          if (!/^[(\.\/)(\.\\)]/.test(moduleName)) {
            moduleName = '.\\'.concat(moduleName);
          }

          // 增加依赖模块，就是当前这个源码里面依赖了哪些其他的模块
          // 这里先不考虑引入三方模块
          dependencies.push(moduleName); // 增加依赖

          // 修改源码
          node.arguments = [types.stringLiteral(moduleName)];
        }
      },
    });

    const parsedCode = generator(ast).code; // 获取生成后的代码
    return { sourceCode: parsedCode, dependencies };
  }
}
```

此时我们打印一下返回的 `sourceCode`，再次运行 `npx euphoria-webpack`，就可以看到结果：

```text
const str = __webpack_require__(".\\src/a.js");

console.log(str);
```

输出依赖模块 ID：`dependencies`：

```text
[ '.\\src/a.js' ]
```

看！我们已经可以将代码进行转换了！接下来只需要继续构造打包产物剩下的部分，当然还有实现 <code>**webpack_require**</code> 代码。

<hr />

## 递归依赖解析

现在我们解析了 `index.js`，获得了解析后的源码和它的依赖项 `./src/a.js`，但是在 `a.js` 中又依赖了 `b.js`，所以我们依然需要去解析 `a.js`，这就是一个 **递归解析** 的过程。

```javascript
class Compiler {
  /**
   * 构造模块依赖关系
   * @param {string} modulePath 模块绝对路径
   * @param {boolean} isEntry   是否为入口模块
   */
  buildModule(modulePath, isEntry) {
    const source = this.getSource(modulePath);
    const moduleName = '.\\'.concat(path.relative(this.root, modulePath));

    // 获取当前模块被转换后的源码
    // 还有其所有依赖项目
    const { sourceCode, dependencies } = this.parse(
      source,
      path.dirname(moduleName)
    );
    // 挂载当前这个已经被加载的模块
    this.modules[moduleName] = sourceCode;

    dependencies.forEach((dependency) => {
      // 再去加载当前模块的所有依赖模块
      // 这是一个递归的过程
      this.buildModule(path.join(this.root, dependency), false);
    });
  }
}
```

此时在 `run` 中输出最后解析出来的模块：

```javascript
class Complier {
  // 表示执行代码
  run() {
    this.buildModule(path.resolve(this.root, this.entry), true);

    // 输出解析结果
    console.log(this.modules);

    this.emitFile();
  }
}
```

可以看到结果是这样的：

```javascript
{
  './src\\index.js': 'const str = __webpack_require__("./src/a.js");\n\nconsole.log(str);',
  './src\\a.js': 'const b = __webpack_require__("./src/base/b.js");\n' +
    '\n' +
    "module.exports = 'a' + b;",
  './src\\base\\b.js': "module.exports = 'b';"
}
```

<div class="note info">难怪 Webpack 产物里面有那么多的 '\n' ？</div>

<hr />

## 生成打包结果

我们现在已经获得了 **打包产物对象**，现在需要用它去 **渲染** 定义好的 **产物模板**。

为了方便起见，可以在 `lib` 下创建一个模板 --- `bundle.ejs` 去操作：

```javascript
(function (modules) {
  var installedModules = {};

  function __webpack_require__(moduleId) {
    if (installedModules[moduleId]) {
      return installedModules[moduleId].exports;
    }
    var module = (installedModules[moduleId] = {
      i: moduleId,
      l: false,
      exports: {},
    });

    modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
    );

    module.l = true;

    return module.exports;
  }

  __webpack_require__.m = modules;

  __webpack_require__.c = installedModules;

  __webpack_require__.d = function (exports, name, getter) {
    if (!__webpack_require__.o(exports, name)) {
      Object.defineProperty(exports, name, { enumerable: true, get: getter });
    }
  };

  __webpack_require__.r = function (exports) {
    if (typeof Symbol !== 'undefined' && Symbol.toStringTag) {
      Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
    }
    Object.defineProperty(exports, '__esModule', { value: true });
  };

  __webpack_require__.t = function (value, mode) {
    if (mode & 1) value = __webpack_require__(value);
    if (mode & 8) return value;
    if (mode & 4 && typeof value === 'object' && value && value.__esModule)
      return value;
    var ns = Object.create(null);
    __webpack_require__.r(ns);
    Object.defineProperty(ns, 'default', { enumerable: true, value: value });
    if (mode & 2 && typeof value != 'string')
      for (var key in value)
        __webpack_require__.d(
          ns,
          key,
          function (key) {
            return value[key];
          }.bind(null, key)
        );
    return ns;
  };

  __webpack_require__.n = function (module) {
    var getter =
      module && module.__esModule
        ? function getDefault() {
            return module['default'];
          }
        : function getModuleExports() {
            return module;
          };
    __webpack_require__.d(getter, 'a', getter);
    return getter;
  };

  __webpack_require__.o = function (object, property) {
    return Object.prototype.hasOwnProperty.call(object, property);
  };
  __webpack_require__.p = '';

  return __webpack_require__((__webpack_require__.s = '<%-entryId%>'));
})({
  <%for(let key in modules){%>
    '<%-key%>': function (module, exports, __webpack_require__) {
      eval(`<%-modules[key]%>`);
    },
  <%}%>
});
```

可以在最下面看到我们用 `ejs` 语法进行变量替换的处理：用 `entryId` 去表示 **入口模块**，接下来用循环去放上所有我们项目所依赖的模块对象。

### 编写发射文件方法

首先我们需要获取 **产物输出目录**：

```javascript
class Compiler {
  // 发射一个文件（打包产物）
  emitFile() {
    // 从配置文件中获取输出文件路径
    const bundle = path.join(
      this.config.output.path,
      this.config.output.filename
    );
  }
}
```

为了将 EJS 模板引入，这里需要一个 EJS 模块去处理变量的替换和模板产物的生成：

```s
npm install ejs
```

`ejs` 模块中有一个 `render` 方法，可以填入定义在 EJS 模板中的变量并得到渲染后的结果。

然后我们只需要将这个产物文件发射出去即可：

```javascript
const ejs = require('ejs');

class Compiler {
  // 发射一个文件（打包产物）
  emitFile() {
    // 从配置文件中获取输出文件路径
    const bundle = path.join(
      this.config.output.path,
      this.config.output.filename
    );

    // 初始化产物目录清单（字典）
    this.assets = {};

    // 读取 EJS 模板
    const templateString = this.getSource(path.join(__dirname, 'bundle.ejs'));
    // 渲染 EJS 模板，传入 EJS 变量
    // 获取最终代码块
    const templateCode = ejs.render(templateString, {
      entryId: this.entryId,
      modules: this.modules,
    });

    // 生成产物
    this.assets[bundle] = templateCode;

    Object.keys(this.assets).forEach((key) => {
      // 发射文件
      fs.writeFileSync(key, 'utf-8', this.assets[key]);
    });
  }
}
```

<div class="note danger">这里需要注意，由 <code>path.resolve</code> 和 <code>path.relative</code> 转换出来的代码，对路径的表示是 <b>转义过的反斜杠</b>，但是从 EJS 渲染出来的字符会将其转译成 <b>一个反斜杠</b>，这又会导致在最后的代码中，那个反斜杠被解释成了 <b>转义字符</b>... （绕死了</div>

总之，我们可以对 `path.resolve` 和 `path.relative` 进行 **正则替换**，将所有的 `\\` 替换成 `/`，这样就可以保证输出是统一的格式：

```javascript
{
  './src/index.js': 'const str = __webpack_require__("./src/a.js");\n\nconsole.log(str);',
  './src/a.js': 'const b = __webpack_require__("./src/base/b.js");\n' +
    '\n' +
    "module.exports = 'a' + b;",
  './src/base/b.js': "module.exports = 'b';"
}
```

<hr />

## 成果检验

现在，我们将打包出来的文件 **直接放入** HTML 代码中，并在浏览器中打开。

此时你会惊奇的看见，在控制台中输出了：

```text
ab
```

Congratulation！你造出了一个 **最简易的 Webpack**

<hr />

## 后续

既然我们的 Webpack 打包功能已经 OK，接下来我们将会为我们的 Webpack 制作 **loader** 和 **plugins**，不断地完善它的功能...

<hr />

## 传统收尾

最后，再贴一遍 **整个 Compiler 类** 的代码作为本篇的收尾：

```javascript
const fs = require('fs');
const path = require('path');

const babylon = require('babylon');
// traverse 和 generator 是一个 ES 6 模块，需要用 default 来导入 CommonJS
const traverse = require('@babel/traverse').default;
const types = require('@babel/types');
const generator = require('@babel/generator').default;

const ejs = require('ejs');

class Compiler {
  // 构造器传入配置文件
  constructor(config) {
    this.config = config;

    // 1. 需要保存入口文件路径
    this.entry = config.entry;
    this.entryId = null; // 保存主模块信息（ID）

    // 2. 需要保存所有模块依赖
    this.modules = {};

    // 获得当前文件的绝对路径（工作路径）
    this.root = process.cwd();

    // 输出产物字典
    this.assets = {};
  }

  // 表示执行代码
  run() {
    // 创建模块依赖关系
    this.buildModule(
      path.resolve(this.root, this.entry).replace(/\\/g, '/'),
      true
    );

    // 发射一个文件（打包产物)
    this.emitFile();
  }

  /**
   * 构造模块依赖关系
   * @param {string} modulePath 模块绝对路径
   * @param {boolean} isEntry   是否为入口模块
   */
  buildModule(modulePath, isEntry) {
    // 获取模块内容
    const source = this.getSource(modulePath);

    // 获取模块 ID
    // path.relative 可以获取两个路径的差
    // 模块绝对路径 - 执行目录绝对路径 = 模块相对路径
    // 取出来的结果类似 'src/index.js'，我们还需要在最前面补上 './'
    const moduleName = './'.concat(
      path.relative(this.root, modulePath).replace(/\\/g, '/')
    );

    // 保存主入口名称
    if (isEntry) {
      this.entryId = moduleName;
    }

    // 解析源码
    // - 将模块中的 `require` 改为我们自己的 <code>__webpack_require__</code>
    // - 修改模块 `require` 引入路径，比如 `./a.js` 需要改为 `./src/a.js`
    // - 对所有模块的引用，都需要加上 `src`
    // path.dirname 可以拿到某个文件位于文件夹的名称（这里用来取 src）
    // parse 解析会返回一个【依赖列表】
    const { sourceCode, dependencies } = this.parse(
      source,
      path.dirname(moduleName)
    );

    // 安装模块
    // 把相对路径（模块 ID）和各个模块对应起来
    this.modules[moduleName] = sourceCode;

    dependencies.forEach((dependency) => {
      // 再去加载当前模块的所有依赖模块
      // 这是一个递归的过程
      this.buildModule(
        path.resolve(this.root, dependency).replace(/\\/g, '/'),
        false
      );
    });
  }

  /**
   * 获取模块信息（为了复用性）
   * @param {string} modulePath 模块绝对路径
   */
  getSource(modulePath) {
    const content = fs.readFileSync(modulePath, 'utf-8');
    return content;
  }

  /**
   * 解析模块源码
   * @param {string} source 模块源码
   * @param {string} parentPath 父路径
   */
  parse(source, parentPath) {
    // 解析源码成抽象语法树
    const ast = babylon.parse(source);

    const dependencies = []; // 依赖模块

    traverse(ast, {
      CallExpression(_path) {
        // 调用表达式，比如 a() 或 require() 就是调用
        const node = _path.node; // 获得节点

        if (node.callee.name === 'require') {
          // 对 require 调用进行改造
          node.callee.name = '__webpack_require__';

          let moduleName = node.arguments[0].value; // 模块引用名称
          // moduleName 就是 require('./a') 里面的 './a'

          // 如果没有扩展名，需要对 moduleName 增加扩展名
          moduleName = moduleName.concat(path.extname(moduleName) ? '' : '.js');

          // 现在是 ./a.js，需要将其改为 src/a.js
          if (/^\./.test(moduleName)) {
            moduleName = moduleName.split(/^\./)[1];
          }
          moduleName = parentPath.concat(moduleName);

          // 增加前缀，编程 ./src/a.js
          if (!/^[(\.\/)(\.\\)]/.test(moduleName)) {
            moduleName = './'.concat(moduleName);
          }

          // 增加依赖模块，就是当前这个源码里面依赖了哪些其他的模块
          // 这里先不考虑引入三方模块
          dependencies.push(moduleName); // 增加依赖

          // 修改源码
          node.arguments = [types.stringLiteral(moduleName)];
        }
      },
    });

    const parsedCode = generator(ast).code; // 获取生成后的代码
    return {
      sourceCode: parsedCode,
      dependencies,
    };
  }

  // 发射一个文件（打包产物）
  emitFile() {
    // 从配置文件中获取输出文件路径

    // 解析一下，如果文件路径出现 [name]，就暂时用 bundle.js 替代
    const bundle = path.join(
      this.config.output.path,
      this.config.output.filename.replace(/\[name\]/, 'bundle')
    );

    // 初始化产物目录清单（字典）
    this.assets = {};

    // 读取 EJS 模板
    const templateString = this.getSource(path.join(__dirname, 'bundle.ejs'));
    // 渲染 EJS 模板，传入 EJS 变量
    // 获取最终代码块
    const templateCode = ejs.render(templateString, {
      entryId: this.entryId,
      modules: this.modules,
    });

    // 生成产物
    this.assets[bundle] = templateCode;

    Object.keys(this.assets).forEach((key) => {
      // 发射文件
      fs.writeFileSync(key, this.assets[key], 'utf-8');
    });
  }
}

module.exports = Compiler;
```
