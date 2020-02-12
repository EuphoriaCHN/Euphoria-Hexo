---
title: 实现Common-JS中的require方法
date: 2020-02-10 21:32:49
updated: 2020-02--12 23:15:22
tags:
- Web
- Node.js
categories:
- 前端
- 面经
- Node.js
---

> <span class = 'introduction'>务须咬牙厉志，蓄其气而长其志，切不可恭然自馁也。</span><br/>
require 方法可以说是 Node.js 模块化开发的必需品，这次来手动实现一个 require 方法吧。（不包括寻找系统模块和同名文件夹中 package.json）

<!--more-->

<hr/>

## Require 的模块加载规则

### 指定了路径

指定了路径即：`require('./a')`这样，指定了在某个文件夹下寻找模块。

1. 首先看有没有后缀名，如果有后缀名那就去找这个具体的文件
2. 如果没有后缀名，就在当前文件夹下，按照 .js、.json、.node 去找一遍有没有符合这样的文件
3. 如果没找到，就去看看有没有同名的文件夹（因为没有指定后缀，那么可能是个文件夹）
4. 如果没找到就报错，找到了就去找有没有 package.json 文件
5. 如果没有 package.json 文件，就去找有没有 index.js 文件，没有就报错
6. 如果找到了 package.json 文件，就去找其指定的 main 入口 JS 文件
7. 如果找到了入口文件就执行，没有找到就去找 index.js 文件，都没有就报错

### 未指定路径

指定了路径即：`require('fs')`这样，这样可能就是寻找的系统模块。

1. node 先假设这是个系统模块
2. 如果不是系统模块，就去找 node_modules 文件夹看看有没有这个模块
3. 首先看看有没有这个名字的 js
4. 再看看有没有这个名字的文件夹
5. 假如找到了文件夹，就去找 package.json，其余操作和有指定路径时一样

<hr />

## 导出模块

### 其实就是执行了一遍模块文件

先用原生 `require()` 来做些小测试，现在假设 *a.js* 和 *b.js* 是同级目录下的两个 JavaScript 文件：

```javascript
// a.js
const a = 1;

module.exports = a;
```

```javascript
let a = require('./a');
console.log(a); // 1
```

在我的这篇 <a href="https://www.wqh4u.cn/2020/01/21/%E5%8E%9F%E7%94%9FJavaScript%E5%AE%9E%E7%8E%B0Promise/">Promise</a> 的博客中，最后有一个使用 *promise-aplus-tests* 去测试，那个时候就是使用 `module.exports` 去导出我们自己写的 *Promise* 模块。

其实这个时候，就是去执行力一遍 *a.js* 这个文件，如果把文件改为这样：

```javascript
// a.js
const a = 1;
console.log('a.js 文件被执行了！');
module.exports = a;
```

然后再执行 *b.js* 文件，这个时候就会打印出来那一句话。

### 导出模块的方法

除了使用 `module.exports` 去导出，还可以直接使用 `exports` 这个对象去处理：

```javascript
// a.js
const a = 1;

exports.a = a; // JS特性，动态给对象增加属性
```

然后在 *b.js* 中的执行结果是不变的，那么这两个方法有什么区别呢？我们可以打印出来 *a.js* 文件中的 `this` 看看：

```javascript
// a.js
const a = 1;
module.exports = a;
console.log(this); // 这种方法打印出来会是 {}
```

欸？怎么是空对象呢？那再来看看另一种方法：

```javascript
// a.js
const a = 1;
exports.a = a;
console.log(this); // { a: 1 }
```

如果给 `exports` 加上了一个 a，`this` 的值也随之发生了改变，那他们俩有什么关系呢：

```javascript
// a.js
console.log(this === exports); // true
console.log(module.exports === exports); // true
console.log(module.exports === this); // true
```

那么就可以理解了，Node.js 在执行某个文件时，这个文件会有一些自带的、不用声明的属性，比如 `global`、`module` 和 `exports`，并且 `this` 的指向就是 `exports`！

### 导出多个模块

如果用 `module.exports` 直接赋值的方法，来看一看可不可以导出多个模块（这里盲猜都是不行的但还是要贴代码！）：

```javascript
// a.js
const a = 1;
const b = 2;

module.exports = a;
module.exports = b;
```

想都不用想，在 *b.js* 中的输出会是 **2**。（这一点再摸不透 Euphoria 就实在不知道该怎么解释了）

那如果直接给 `exports` 对象上面挂属性呢？

```javascript
// a.js
const a = 1;
const b = 2;

exports.a = a;
exports.b = b;
```

这样最后在 *b.js* 中会输出一个对象 `{ a: 1, b: 2 }`！

由此可以推导出来：**由 require() 方法导出的模块，就是被导出模块的 module.exports 的值！且 module.exports 和 exports 原本是同一个引用！**

### 总结

通过上面的那些实验，最起码明白了以下几点：

1. Node 执行 JS 文件时，在 JS 文件内部可以使用 `module` 和 `exports` 两个变量，且 `exports === module.exports`；
2. 被执行的 JS 文件中的全局 `this` 就是 `exports` 变量；
3. 有两种方法导出，但获取到的总是 `module.exports` 的值；

现在我们了解了 **加载规则** 和 **导出模块方式**，就可以去实现一个自己的 `require` 方法了！

<hr />

## 实现

首先需要引入三个 Node.js 所提供的系统模块，这里对这三个模块不再有更多的解释：

```javascript
const path = require('path'); // 路径处理
const fs = require('fs'); // 读取文件
const vm = require('vm'); // 主要用与运行 JS 代码
```

然后就可以来定义我们的函数了：

```javascript
/**
 * 自己的精简版 require 方法
 * @param modulePath 传入模块的路径
 */
function myRequire(modulePath) {
    
}

myRequire('./a');
```

### 根据搜寻机制获得正确的文件路径

这里单单传进来一个 `./a` 是无法确定我们需要什么的，所以需要获取它的绝对路径：

首先定义一个自己的 Module，里面存放一些模块的关键信息：

```javascript
class Module {
    constructor(id) {
        this.id = id; // id 就是路径
        this.exports = {}; // 记住这个 exports 哦
    }
    
    // 定义模块可能的扩展名列表（按顺序）
    // 下面是 ES 6 写法奥
    static _extensions = {
        '.js'(module) {},
        '.json'(module) {},
        '.node'(module) {}
    };
}
```

然后实现一个方法，用于寻找正确的文件路径（就像开头所讲，这篇博客的业务仅限于搜索同一目录下的模块，不会去搜寻系统模块以及其他包）：

```javascript
function resolveFileName(modulePath) {
    // 拿到当前路径的绝对路径
    let res = path.resolve(__dirname, modulePath);
    // 因为不知道是否带扩展名，就判断一下这个文件是否存在
    let isExists = fs.existsSync(res);
    if (isExists) {
        return res; // 如果直接存在那就返回这个文件的路径
    } else {
        let ans = undefined; // 尝试的结果
        // 轮询三个可能的后缀名，按顺序逐个判断文件是否存在
        Object.keys(Module._extensions).forEach((value, index) => {
            let tryName = res + value;
            if (fs.existsSync(tryName) && ans === undefined) {
                ans = tryName;
            }
        });
        if (ans === undefined) {
            // 如果还是没有直接就抛错，不去找其他地方了
            throw error('can not find module');
        }
        return ans;
    }
}

// 然后再来看 myRequire 方法
function myRequire(modulePath) {
    let absolutePath = resolveFileName(modulePath); 
    // 这里保证了可以找到 .js、.json 或 .node

    let module = new Module(absolutePath); 
    // 新创建一个 Module，即这个需要被导出的模块
}
```

### 获取已经找到的模块的扩展名

欸，那现在我们知道了要导出的模块的路径，就可以通过读取文件的方式去吧里面的代码拿出来。

首先得需要获得它的扩展名，再维护一个方法：

```javascript
function tryModuleLoad(module) {
    // 获取模块的扩展名
    let extensionName = path.extname(module.id);

    // 这里就调用了 Module 里面定义的那些函数
    Module._extensions[extensionName](module);
}
```

### 生成可执行函数

为了执行文件里面的代码，在读取出文件内容后，需要将其整体打包成一个函数，所以定义一个格式化的字符串：

```javascript
class Module {
    // 以上省略
    static wrapper = [
        '(function(exports, require, module, __dirname, __filename) {',
        '\n})'
    ];
    // 以下省略
}
```

<div class="note info">能看出来这个函数有五个参数，具体待会儿会说</div>

然后实现对应扩展名应该执行的方法，这里以 `.js` 和 `.json` 为例：

```javascript
// 上面省略
static _extensions = {
    '.js'(module) {
        // 第一步就是读文件了
        let script = fs.readFileSync(module.id, 'utf8');
        
        // 拿到文件内容后，将其打包成一个匿名函数
        let closureFunctionString = Module.wrapper.join(script);
        
        // 然后利用 vm 模块，获得一个可以执行的函数
        let closureFunction = vm.runInThisContext(closureFunctionString);

        // 在这里对当前 module 的 exports 属性做一个引用
        let exports = module.exports;

        // 修改 this 指向并执行函数
        closureFunction.apply(exports, [exports, myRequire, module, path.dirname(module.id), module.id]);
    },
    '.json'(module) {
        // JSON 就简单的多，返回这个 JSON 字符串所描述的对象就好
        let json = fs.readFileSync(module.id, 'utf8');
        module.exports = JSON.parse(json);
    }
};
// 下面省略
```

上面用了 `closureFunction.apply();` 去执行了被我们包装好的函数，其实就是执行了整个被导入的模块。

传进去了五个参数：exports、myRequire、module 和两个路径。

与此同时，再看看那些参数的名称：exports, require, module, __dirname, __filename。

是不是已经发现什么了？

#### 说明

- 首先修改了 `this`，即改变了被导出模块的全局 `this` 指向为 `exports`；
- 传入的 `exports` 的参数名称刚好也是 `exports`，所以在被导出模块中可以直接使用这个名称的变量；
- `require` 是一个方法，传入的就是我们的 `myRequire`，因为在被导出的模块里面仍然可能用到了其他的模块，也需要给它提供一个 `require` 方法；
- `module` 是我们定义的，代表当前模块的 `module`，并且在调用它之前，也将 `module.exports` 这个属性多创建了一个引用 `exports` 一并传入，这就解释了为什么在 Node.js 执行的文件中，`module.exports === exports === this` 的原因了；
- 后面两个就是被导入的模块所在路径名和文件路径，这样也就解释了为什么我们不用定义这些变量而直接就可以使用了。

同时，如果使用了 `module.exports` 赋值，原先 `module.exports` 的引用被更改，所以输出的不管是 `this` 还是 `exports` 的值就没有改变（就是空对象）。

反之如果动态地去给 `exports` 增加属性，这样由于 `module.exports` 和它是同引用，所以 `module.exports` 的值也会随之更改。

### 维护缓存

最后维护一个缓存，由原生的 `require()` 方法可以得知，同一个模块只会被导出一次，之后的导出结果将永远是第一次的结果。

只需要在 `Module` 类中维护一个静态的缓存就好：

```javascript
class Module {
    // 以上省略
    static _cache = {};
    // 以下省略
}
```

这时再来看看我们自己定义的 `myRequire` 方法：

```javascript
function myRequire(modulePath) {
    let absolutePath = resolveFileName(modulePath); 

    // 同一个模块被 require 多次始终都是第一次的结果
    if (Module._cache[absolutePath]) {
        return Module._cache[absolutePath];
    }

    let module = new Module(absolutePath);

    tryModuleLoad(module);

    // 记录一次缓存
    Module._cache[absolutePath] = module.exports;

    return module.exports;
}
```

<hr />

## 再贴一遍全部的代码

```javascript
const path = require('path');
const fs = require('fs');
const vm = require('vm');

class Module {
    constructor(id) {
        this.id = id; // id 就是路径
        this.exports = {};
    }

    static _extensions = {
        '.js'(module) {
            let script = fs.readFileSync(module.id, 'utf8');
            let closureFunctionString = Module.wrapper.join(script);
            let closureFunction = vm.runInThisContext(closureFunctionString);

            let exports = module.exports;

            closureFunction.apply(exports, [exports, myRequire, module, path.dirname(module.id), module.id]);
        },
        '.json'(module) {
            let json = fs.readFileSync(module.id, 'utf8');
            module.exports = JSON.parse(json);
        },
        '.node'() {}
    };

    static wrapper = [
        '(function(exports, require, module, __dirname, __filename) {',
        '\n})'
    ];

    static _cache = {};
}

function resolveFileName(modulePath) {
    let res = path.resolve(__dirname, modulePath);
    let isExists = fs.existsSync(res);
    if (isExists) {
        return res;
    } else {
        let ans = undefined;
        Object.keys(Module._extensions).forEach((value, index) => {
            let tryName = res + value;
            if (fs.existsSync(tryName) && ans === undefined) {
                ans = tryName;
            }
        });
        if (ans === undefined) {
            throw error('can not find module');
        }
        return ans;
    }
}

function tryModuleLoad(module) {
    // 获取模块的扩展名
    let extensionName = path.extname(module.id);

    Module._extensions[extensionName](module);
}

function myRequire(modulePath) {
    let absolutePath = resolveFileName(modulePath); // 这里保证了可以找到 .js、.json 或 .node

    // 同一个模块被 require 多次始终都是第一次的结果
    if (Module._cache[absolutePath]) {
        return Module._cache[absolutePath];
    }

    let module = new Module(absolutePath);

    tryModuleLoad(module);

    Module._cache[absolutePath] = module.exports;

    return module.exports;
}
```

<hr />

## 总结

个人觉得这次没当时写 <a href="https://www.wqh4u.cn/2020/01/21/%E5%8E%9F%E7%94%9FJavaScript%E5%AE%9E%E7%8E%B0Promise/">Promise</a> 时那么累了，其实在知道那个 `.apply`（或者你用 `.call` 啊什么的都行）的调用时简直激动地鼓起了掌，因为那一行代码很完美解决了之前的绝大多数疑问和问题。（就和当时看到 Java 中遍历 `LinkedList` 一样，感觉奇妙无比）。

最近在忙着找实习了，更新可能会慢一些，下次也许会更新一个关于 Vue 生命周期的？
