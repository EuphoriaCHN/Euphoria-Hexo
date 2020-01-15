---
title: JavaScript面向对象-01-Constructor
date: 2019-12-07 23:46:31
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
---

> <span class = 'introduction'>成功的关键在于相信自己有成功的能力。</span><br/>
在类别基础的面向对象程序设计中，构造器（英语： Constructor，有时简称 ctor，别称：构造方法、构造函数、建构子）是一个类里用于创建对象的特殊子程序。它能初始化一个新建的对象，并时常会接受参数用以设定实例变量。<br/>在 JavaScript 中，又是怎么去实现 OOP 编程呢？

<!--more-->

<hr/>

## Atwood's Law

<div class="note info">
Any application that can be written in JavaScript, will eventually be written in JavaScript.<br/>
(任何可以用JavaScript来写的应用，最终都将用JavaScript来写。)
</div>

<hr />

## Before ES6

在 JavaScript 中，创建对象的模板是构造函数（ECMA6之前，没有 `class` 关键字），而在其他语言中创建对象的模板是类。

JavaScript 传统的创建对象方法有点怪异，是用函数的形式去封装一个对象：

```javascript
function Student(name, subject, score) {
    this.name = name; // 通过 this 去给当前对象动态地添加一个属性 or 方法
}

var student = new Student("Wang", "JavaScript", 100); // 通过 new 关键字去创建一个对象
```

### 创建对象的几种方式

#### new Object()

```javascript
var student = new Object();  // 创建一个空对象
student.name = 'wang';       // 动态地去给对象添加属性 or 方法
```

#### 对象字面量 {}

```javascript
let student = {};           // 创建一个空对象，等同于 new Object();
student.name = 'xxx';       // 动态地去给对象添加属性 or 方法
```

或者直接令某个变量去引用一个自定义对象：

```javascript
let student = {
    name: 'xxx',
    age: 20
}; // 类似字典，键就是属性名，值就是属性值
```

#### 工厂函数（工厂方法）

与 <a href="https://zh.wikipedia.org/wiki/%E5%B7%A5%E5%8E%82%E6%96%B9%E6%B3%95" target="_blank">工厂方法模式</a> 类似，Client 去通知某个对象的工厂，传入对应的参数去获得一个对象：

```javascript
function studentFactory(name, age) {
    let student = new Object();
    student.name = name;
    student.age = age;
    return student; // 工厂方法将包装好的对象送给 Client
}
```

<div class="note danger">
但是通过这种方法，Client 所接到的对象类型是 <b>object</b>，因为通过了 <code>new Object()</code> 来创建的，应该令他的类型为 <b>student</b>。

即，这种方法产生的对象，<code>student instanceof Student === false</code>，不方便判断对象类型。

所有对象使用 <code>typeof object</code> 得到的答案都为 <code>object</code>，但使用构造函数可以使用 <code>instanceof</code> 去判断具体类型。
</div>

#### 构造函数

```javascript
// 构造函数首字母大写驼峰（就像类名）
function Student(name, subject, score) {
    this.name = name;
    this.subject = subject;
    this.score = score;

    this.toString = function() {
        return `{name=${this.name}, subject=${this.subject}, score=${this.score}}`;
    };
}
```

1. 构造函数在使用的时候，首先会在内存中创建一个空对象
2. 设置构造函数的 this，让 this 指向刚刚创建好的对象
3. 执行构造函数中的代码
4. 最后返回这个对象（以上的行为都无须用户显式使用）

构造函数创建的对象，使用 typeof 得到的答案仍然为 **object**，但使用构造函数创建的对象，可以使用 <code>student instanceof Student === true</code> 去得知具体类型。

<div class="note info">
每个对象中都有一个属性，student.constructor，这个属性的值为创建这个对象的构造函数本身，
所以也可以使用 <code>student.constructor === Student</code> 去判断对象的类型，但不建议这样使用（这使用的就是 <b>__proto__</b> 中的 <b>constructor</b>，关于原型会在 <a href="https://www.wqh4u.cn/2019/12/08/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-02-Prototype/" target="_blank">JavaScript 原型</a> 中提到）
</div>

### 如何去选择构造器

在 JavaScript 中，使用字面量（静态成员）去创建工具类，而使用构造函数（示例成员）去创建一般类。

工具类就像 Math，一般类就像 Date：

```javascript
// 工具类
var Tools = {
    // 获取一个在 [min, max] 中的随机数
    // 这个函数可以直接由 Tools.getRandomNumber(); 去调用，而不需去 new 一个 Tools 对象
    // 就像 Math.floor()、Math.ceil() 这样
    getRandomNumber: function(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    },
};
console.log(Tools.getRandomNumber(0, 100)); // 就像类的静态方法一样

// 一般类
function Student(name, age) {
    this.name = name;
    this.age = age;
    // ......
}
// 当我们需要使用学生对象时，则需要使用 new 关键字去获得一个学生对象
var student = new Student('Wang', 20);
```

<hr />

## After ES6

在 ES6 标准中，JavaScript 也支持了使用 `class` 关键字这种创建一个类的方法：

```javascript
class Student {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
    
    toString() {
        return `{name=${this.name}, subject=${this.subject}, score=${this.score}}`;
    }
}

let student = new Student('Wang', 20);
console.log(student.toString());
```
