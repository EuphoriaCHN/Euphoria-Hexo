---
title: 关于Object.defineProperty()
date: 2020-03-09 21:57:55
updated: 2020-03-11 17:00:00
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
---

> <span class = 'introduction'>美好的生命应该充满期待、惊喜和感激。</span><br/>
在使用 Vue 中 `v-model` 指令时，有没有想过这种神奇的双向数据绑定是怎么实现的呢？

<!--more-->

<hr/>

## 前言

本文部分内容参考了《你不知道的javascript》上卷，如有理解不正确的地方还请指出。

<hr />

## 在 JavaScript 中定义一个对象

我们经常使用的对象定义和赋值的方法如下：

```javascript
const people = {}; // 定义一个对象
people.name = 'Euphoria'; // 直接使用 . 去动态添加一个属性
people['gender'] = 'male'; // 使用下标取 key 的方式去访问（定义） value
console.log(people.name); // Euphoria
console.log(people['gender']); // male
```

<hr />

## Object.defineProperty()

`Object.defineProperty()` 的作用就是直接在一个对象上定义一个新属性，或者修改一个已经存在的属性：

```javascript
/**
 * @param obj: 需要定义属性的当前对象
 * @param prop: 当前需要定义的属性名
 * @param desc: 属性描述符
 */
Object.defineProperty(obj, prop, desc);
```

一般通过为 **对象的属性赋值** 的情况下，对象的属性可以修改也可以删除，但是通过 `Object.defineProperty()` 定义属性，通过 **描述符** 的设置可以进行更精准的控制对象属性。

### 属性的特性以及内部属性

JavaScript 有三种类型的属性：

1. **命名数据属性**：拥有一个确定的值的属性。这也是最常见的属性；
2. **名访问器属性**：通过 `getter` 和 `setter` 进行读取和赋值的属性；
3. **内部属性**：由 JavaScript 引擎内部使用的属性，不能通过 JavaScript 代码直接访问到，不过可以通过一些方法间接的读取和设置。比如，每个对象都有一个内部属性 `[[Prototype]]`，你不能直接访问这个属性，但可以通过 `Object.getPrototypeOf()` 方法间接的读取到它的值。虽然内部属性通常用一个双吕括号包围的名称来表示，但实际上这并不是它们的名字，它们是一种 **抽象操作**，是不可见的，**根本没有上面两种属性有的那种字符串类型的属性**;

### 属性描述符

通过 `Object.defineProperty()` 为对象定义属性，有两种形式，且不能混合使用，分别为 **数据描述符**，**存取描述符**，下面分别描述下两者的区别：

#### 数据描述符

数据描述符具有两个特有的属性：`value` 和 `writable`。

```javascript
const people = {};
Object.defineProperty(people, 'name', {
   value: 'jack',
   writable: true // 是否可以改变
});
```

如果 `writable` 的值是 `false`：

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  // value 默认是 undefined
  // writable 默认是 false
});
people.name = 'Euphoria'; // 这句是没有用的
console.log(people.name); // undefined
```

再换一种使用方法：

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria'
  // writable 默认是 false
});
people.name = 'WQH'; // 这句是没有用的，因为 writable 仍然是 false
console.log(people.name); // Euphoria
```

最后，如果将 `writable` 也设置为 `true`：

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria',
  writable: true,
});
console.log(people.name); // Euphoria
people.name = 'WQH';
console.log(people.name); // WQH
```

#### 存取描述符

存取描述符是用 **一对 `getter` 和 `setter` 函数功能来描述的属性**：

- `get`： 一个给属性提供 `getter` 的方法，如果没有 `getter` 则为 `undefined`。该方法 **返回值** 被用作属性值；
- `set`： 一个给属性提供 `setter` 的方法，如果没有 `setter` 则为 `undefined`。该方法将接受唯一参数，并将该参数的新值分配给该属性。

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  get() {
    return this.name;
  },
  set(v) {
    this.name = v; // 这一句是没有必要的，不论写不写 this.name 的值都会是 v
  }
});
```

<div class="note danger">这样是大错特错的！因为 <code>get()</code> 里面又访问了 <code>name</code> 属性，会无穷尽地递归下去。</div>

```javascript
const people = {};
let _name = null; // 用另一个变量去暂存数据
Object.defineProperty(people, 'name', {
  get() {
    return _name;
  },
  set(v) {
    _name = v;
  }
});
console.log(people.name); // null
people.name = 'Euphoria';
console.log([people.name, _name]); // [Euphoria, Euphoria]
```

### 特殊描述符

数据描述符和存取描述均具有以下描述符：

1. `configurable`：描述属性是否配置，以及可否删除；
2. `enumerable`：描述属性是否会出现在 `for in` 或者 `Object.keys()` 的遍历中。

#### configurable

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria',
  configurable: false, // 这代表了这个属性不能配置也不能被删除
  writable: true, // 注意，可写 和 配置 是两个不同的概念
});
console.log(people.name); // Euphoria
people.name = 'WQH';
console.log(people.name); // WQH
delete people.name; // 这里是删不掉的，会返回一个 false
```

注意，设置了 **不可写**，但是还是可以通过配置的方式去修改：

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria',
  configurable: true,
  writable: false
});
console.log(people.name); // Euphoria
people.name = 'WQH'; // 不可写！
console.log(people.name); // Euphoria
Object.defineProperty(people, 'name', {
  value: 'WQH', // 配置
});
console.log(people.name); // WQH
```

所以，由以上的代码可以得知：

1. `configurable: false` 时，**不能删除** 当前属性，且不能重新配置当前属性的描述符(有一个小小的意外：可以把 `writable` 的状态由 `true` 改为 `false`，但是无法由 `false` 改为 `true`)，但是在 `writable: true` 的情况下，可以改变 `value` 的值；
2. `configurable: true` 时，可以删除当前属性，可以配置当前属性所有描述符。

#### enumerable

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria',
  enumerable: true // 将 name 属性设置为可以出现在 forin 遍历中
});
people.gender = 'male';
Object.defineProperty(people, 'age', {
  value: 20,
  enumerable: false // 将 age 属性设置不可出现在 forin 遍历中
});
console.log(Object.keys(people)); // ['name', 'gender']
for (const key in people) console.log(key); // ['name', 'gender']
console.log(people.propertyIsEnumerable('name')); // true
console.log(people.propertyIsEnumerable('gender')); // true
console.log(people.propertyIsEnumerable('age')); // false
```

<hr />

## 特性

### 不变性

#### 对象常量

结合 `writable: false` 和 `configurable: false` 就可以创建一个 **真正的常量属性**（不可修改，不可重新定义或者删除）：

```javascript
const people = {};
Object.defineProperty(people, 'name', {
  value: 'Euphoria',
  writable: false,
  configurable: false
});
delete people.name; // 不可删除
people.name = 'WQH'; // 不可写
Object.defineProperty(people, 'name', {
  value: 'WQH', // 不可重新定义
});
console.log(people.name); // Euphoria
// 但是通过赋值，还可以添加新的属性
people.gender = 'male';
console.log(people.gender); // male
```

#### 禁止扩展 

如果你想 **禁止** 一个对象添加新属性并且保留已有属性，就可以使用 `Object.preventExtensions()`：

```javascript
'use strict'; // 严格模式会报错
const people = {
  name: 'Euphoria',
};
Object.preventExtensions(people); // 设置其禁止被扩展
people.gender = 'male'; // 严格模式会报错
console.log(people.gender); // undefined
// Uncaught TypeError: Cannot define property gender, object is not extensible

// 但是仍然可以配置这个对象
Object.defineProperty(people, 'name', {
  value: 'WQH'
});
console.log(people.name); // WQH
```

在非严格模式下，创建属性 `gender` 会静默失败，在严格模式下，将会抛出异常。

#### 密封

`Object.seal()` 会创建一个 **密封的对象**，这个方法实际上会在一个现有对象上调用 `Object.preventExtensions()` 并把 **所有** 现有属性标记为 `configurable: false`：

```javascript
const people = {
  name: 'Euphoria',
};
Object.seal(people);
people.gender = 'male'; // 错！不能扩展
Object.defineProperty(people, 'name', {
  value: 'WQH' // 错！不能配置
});
people.name = 'WQH'; // 但是可写
```

所以， 密封之后不仅不能添加新属性，也不能重新配置或者删除任何现有属性（虽然可以改属性的值）。

#### 冻结

`Object.freeze()` 会创建一个冻结对象，这个方法实际上会在一个现有对象上调用 `Object.seal()`，并把 **所有** 现有属性标记为 `writable: false`，这样就无法修改它们的值：

```javascript
const people = {
  name: 'Euphoria',
};
Object.freeze(people);
people.gender = 'male'; // 错！不能扩展
Object.defineProperty(people, 'name', {
  value: 'WQH' // 错！不能配置
});
people.name = 'WQH'; // 错！不可写
```

这个方法是你可以应用在 **对象上级别最高的不可变性**，它会禁止对于对象本身及其任意直接属性的修改（但是这个对象引用的其他对象是不受影响的）。

你可以 **深度冻结** 一个对象，具体方法为：首先这个对象上调用 `Object.freeze()` 然后遍历它引用的所有对象，并在这些对象上依次调用 `Object.freeze()`。但是一定要小心，因为这么做有可能会无意中冻结其他共享对象。

<hr />

## 总结

如果描述符中的某些属性被省略，会使用以下默认规则：

|属性名|默认值|
|:---|:---|
|value|undefined|
|get|undefined|
|set|undefined|
|writable|false|
|enumerable|false|
|configuration|false|

如果你使用这样定义了一个对象：

```javascript
const obj = {};
obj.name = 'Euphoria'; // 或者 obj['name'] = 'Euphoria'
```

那么它等同于：

```javascript
const obj = {};
Object.defineProperty(obj, 'name', {
  value: 'Euphoria',
  writable: true,
  configurable: true,
  enumerable: true
});
```

但是如果你这样定义对象上面的属性：

```javascript
const obj = {};
Object.defineProperty(obj, 'name', {
  value: 'Euphoria',
});
```

其等同于：

```javascript
const obj = {};
Object.defineProperty(obj, 'name', {
  value: 'Euphoria',
  writable: false,
  configurable: false,
  enumerable: false
});
```
