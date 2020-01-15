---
title: JavaScript面向对象-03-原型中的注意点
date: 2020-01-14 00:55:53
updated: 2020-01-14 02:14:37
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
---

> <span class = 'introduction'>有人在光明中注视着阴影，有人在阴影中眺望着光明。</span><br/>
解决了 JS-OOP-02 中的一个小尾巴，也说了一些关于 Getter 和 Setter 对于原型链的访问问题，还有一些奇奇怪怪的问题（甚至还有一个没有搞明白的问题？？？）

<!--more-->

<hr/>

## 上一篇中的小尾巴

在 <a href="https://www.wqh4u.cn/2019/12/08/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-02-Prototype/" target="__blank">JavaScript面向对象-02-Prototype</a> 中，我们利用原型链搞了一个伪继承出来：

```javascript
function Student(name, age, studentId) {
    this.studentId = studentId;
    this.__proto__.name = name; // 为什么不直接写 this.name = name 呢？
    this.__proto__.age = age; // 为什么不直接写 this.age = age 呢？
}

Student.prototype.__proto__ = People.prototype;

let student = new Student('li', 18, 12345);
```

接下来就来处理这个小尾巴！

<hr />

## 特殊的 Getter 和 Setter 机制

### 发现问题

现在我们声明一个类 `ChinesePeople`：

```javascript
function ChinesePeople(name, age) {
    this.name = name;
    this.age = age;
}

let people = new ChinesePeople('Wang', 20);

console.log(people.toString());
```

这样看起来没有什么问题，`toString()` 是 `Object` 原型中的一个方法，又因为 `ChinesePeople.prototype.__proto__` 就是 `Object.prototype`，所以 `ChinesePeople` 的实例调用 `toString()` 方法是没有问题的。

既然原型上的属性或方法是所有对象共享的，那么可以通过原型去当方法区去存储，或者存储一些特殊变量：

```javascript
function ChinesePeople(name, age) {
    this.name = name;
    this.age = age;
}

ChinesePeople.prototype.homeland = 'China No.1';

let people = new ChinesePeople('Wang', 20);

console.log(people.homeland); // China No.1
```

我们可以将其看作一个静态成员变量，所有的对象都是共享的，即使它可以用很多种方式去访问：

```javascript
function ChinesePeople(name, age) {
    this.name = name;
    this.age = age;
}

ChinesePeople.prototype.homeland = 'China No.1';
ChinesePeople.prototype.getHomeland = function() {
    return this.homeland;
};

let people = new ChinesePeople('Wang', 20);

console.log(ChinesePeople.prototype.homeland); // 构造函数.原型对象.属性
console.log(people.homeland); // 对象.属性
console.log(people.getHomeland()); // this.属性
```

突然有一天来了一个 **喜欢玩推特的中国人**：

```javascript
let tweeterLover = new ChinesePeople('建国', 18);
```

然后 ta 突然将 `homeland` 属性改为了 `China No.2`：

```javascript
let people = new ChinesePeople('Wang', 20);

console.log(ChinesePeople.prototype.homeland); // China No.1
console.log(people.homeland); // China No.1
console.log(people.getHomeland()); // China No.1

let tweeterLover = new ChinesePeople('建国', 18);
ChinesePeople.prototype.homeland = 'China No.2';

console.log(ChinesePeople.prototype.homeland); // China No.2
console.log(people.homeland); // China No.2
console.log(people.getHomeland()); // China No.2
```

ta 又觉得这样不太 OK，因为 ta 并没有什么实际性的动作，在冥思苦想后发现了重点：

- 访问 `homeland` 有三种方法；
- ta 使用了 `ChinesePeople.prototype.homeland` 去直接修改；
- ta 没有使用 `对象.属性` 或 `this.属性` 去修改，这样会很没有牌面；

于是 ta 通过自己（`对象.属性`），去修改了 `homeland` 的值：

```javascript
let people = new ChinesePeople('Wang', 20);

console.log(ChinesePeople.prototype.homeland); // China No.1
console.log(people.homeland); // China No.1
console.log(people.getHomeland()); // China No.1

let tweeterLover = new ChinesePeople('建国', 18);
tweeterLover.homeland = 'China No.2';

console.log(ChinesePeople.prototype.homeland); // China No.1
console.log(people.homeland); // China No.1
console.log(people.getHomeland()); // China No.1

console.log(tweeterLover.homeland); // China No.2
console.log(tweeterLover.getHomeland()); // China No.2
```

结果惊人的一幕出现了，别人的 `homeland` 都没有发生改变，并且在这之后也只有 ta 自己的 `homeland` 改为了他想要的，即使调用了存在于原型上的 `getHomeland()` 方法也一样。

### 正常的 Getter

<div class="note success">在读取对象的属性或方法时，会顺序查找原型链，如果当前对象内不存在这个属性，那么就会向上一层去搜索原型链，直到 null。</div>

所以在访问 `homeland` 的时候，因为对象内部并不存在这个属性，此时就会向上不断地去查找原型链，结果在 `People.prototype` 中发现了 `homeland` 的定义，故最开始都会返回 `China No.1`。

### 奇怪的 Setter

<div class="note danger">在设置对象的属性或方法时，<b>不会去访问原型</b>，而是直接给对象添加一个这样的属性，因为对象内部属性查询优先级高于其原型链，那么就会发生覆盖。</div>

这样就真相大白了，建国同志在使用 `tweeterLover.homeland='China No.2'` 的时候，其实是给自己内部添加了一个新的、只属于他自己的 `homeland`。

在设置完成后，即使他使用 `对象.homeland` 去访问，这时候按照 **Getter** 流程，其对象内部就存在了 `homeland` 这个属性，所以也就不会去访问存在于原型链上的值了。

### 奇怪的 Setter（2）

如果对象内部并不存在某个成员，但是它的原型链上存在，就像刚刚的 `homeland` 一样，那么如果出现了下面这样的代码：

```javascript
function ChinesePeople(name, age) {
    this.name = name;
    this.age = age;
}

ChinesePeople.prototype.homeland = 'China No.1';

let people = new ChinesePeople('Wang', 20);

people.homeland = people.homeland; // 真的是一行没有用的语句吗？
```

分析 `people.homeland = people.homeland`：

1. 这是一个赋值表达式，'=' 运算符会将右侧的只赋予左侧的值；
2. 右值是 `people.homeland`，这就相当于 Getter，因为在查询时可以省略写 `__proto__`；
3. 所以，右值也就是 `people.__proto__.homeland`；
4. 然而左值是一个 Setter，其直接使用了 `对象.属性` 的方法，不会去查找原型链；
5. 因为对象可以动态地设置属性 or 方法，所以 `people` 对象会多出来一个 `homeland` 属性，其值与 `people.__proto__.homeland` 相同；

<div class="note info">就是说！拿，可以查找原型链，但是放，不行（不包括直接通过构造函数去设置其原型）。</div>

<hr />

## 更方便地设置 prototype

对于一个自定义类，常常不止一个方法，那么可能会出现以下的情况：

```javascript
People.prototype.methodOne = function() {};
People.prototype.methodTwo = function() {};
People.prototype.methodThree = function() {};
// ......
```

<div class="note danger">这样会非常的麻烦，显得代码十分臃肿。</div>

既然 People.prototype 是一个对象，那么就可以为其进行重新赋值，令一个新的对象以键值对的方式给其赋值：

```javascript
People.prototype = {
    methodOne: function() {},
    methodTwo: function() {},
    methodThree: function() {}
    // ......
};
```

这样提高了代码的可读性，可以重新改变 `prototype`的属性。

<div class="note danger">
但是这样又出现一个问题，<b>People.prototype</b> 被赋予了一个新的值（引用），但 <b>People.prototype</b> 中应该具有一个特殊的属性 <b>People.prototype.constructor</b>
这个属性指向了当前对象所处的构造函数，这个属性也帮助了程序员去获取这个对象的具体类型<b>（但即使这个时候，也可以使用 instanceof，这个不受影响）</b>。</div>

即：如果通过覆盖 `People.prototype`，那么此时 `People.prototype.constructor` 则应该是 `Object` 或 `People.prototype.__protype__.constructor`，而不是 `People`。

<div class="note success">所以在覆盖 People.prototype 时，需要手动地去添加一个 constructor 属性，值为构造函数本身。</div>

```javascript
People.prototype = {
    constructor: People, // 手动地设置其构造器
    methodOne: function() {},
    methodTwo: function() {},
    methodThree: function() {}
    // ......
};
```

<hr />

## 又一个奇怪的问题（尚未解决）

现在必须先在原型中声明某个属性或方法，再去调用。（但是先创建这个对象，再去添加原型，这个对象中仍然会动态地去加入这个新方法？？？）

代码如下：

```javascript
function Student(name, subject, score) {
    this.name = name;
    this.subject = subject;
    this.score = score;
}

let student = new Student("Wang", "Chinese", 100);

console.dir(student); // 这个时候打印出来的对象，原型里面已经包含了 sayHello() 方法？？？（前提是下一行被注释掉）
// student.sayHello(); // 调用失败，错误信息为 sayHello() 未定义
// 如果这一行被注释掉，程序成功运行结束，那么在上面打印出来的 student 中，可以在原型中找到 sayHello() 方法，即使位置在声明前
// 如果这一行没有被注释掉，程序在此时报错中断，那么在上面打印出来的 student 中，就不会出现 sayHello() 方法？？？？？

Student.prototype.sayHello = function() {
    console.log("Hello");
}; // 为原型添加一个方法

console.dir(student); // 此时对象的原型中具有这个方法
student.sayHello(); // 调用成功
```

（也许是类似于变量提升？？？恳请大佬指点）

