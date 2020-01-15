---
title: JavaScript面向对象-02-Prototype
date: 2019-12-08 00:42:51
updated: 2020-01-14 00:39:01
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
copyright: true
---

> <span class = 'introduction'>盛年不重来，一日难再晨。及时宜自勉，岁月不待人。</span><br/>
这里由 Euphoria 个人总结了一些 JavaScript 中 prototype 原型的理解与使用方法~来看看叭

<!--more-->

<hr/>

## 为什么要使用 prototype

### 发现问题

在 <a href="http://www.wqh4u.cn/2019/12/07/JavaScript%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-01-Constructor/">上一篇博客</a> 中简单地介绍了 JavaScript 中如何去写 OOP，那趁热来再写一个（不使用 ES6 中的 `class` 关键字，下同）：

```javascript
function People(name, age) {
    this.name = name;
    this.age = age;

    this.getInformation = function () {
        return `{name: ${this.name}, age: ${this.age}}`
    }
}

let people_one = new People('wang', 20);

console.log(people_one.getInformation());
```

显而易见，它会输出 `{name: wang, age: 20}`。

现在让我们再来声明一个对象 `people_two`：

```javascript
let people_two = new People('li', 18);

console.log(people_two.getInformation());
```

在这里我们很容易得知，这两个对象都是 People 类的实例，每个实例拥有两个属性 **name** 和 **age**，每个实例也拥有一个方法 **getInformation()**。

<span class="red-target">但是！JavaScript 看起来并不是那么简单</span>

在 JavaScript 中，如果某个类含有方法，在创建对象时，**每个对象在内存中都有一个方法的存储**，这可就令人头疼，每一个方法都单独的存储在这个对象中，无形中就造成了内存的浪费。

### 一个并不是怎么好的解决方法

不要在构造函数中声明方法，而是声明一个全局的方法，在构造函数中去引用这个函数即可，这样每个对象在创建时，所引用的都为一个方法。

```javascript
function getInformation() {
    return `{name: ${this.name}, age: ${this.age}}`
}

function People(name, age) {
    this.name = name;
    this.age = age;

    this.getInformation = getInformation;
}

let people_one = new People('wang', 20);

console.log(people_one.getInformation());
```

但是这个方法并不建议使用，因为需要去声明一个全局的命名函数，丧失了 OOP 最基本的封装性。

<hr />

## prototype

每一个构造函数，都有一个属性，这个属性就被称作原型（原型对象）。

既然这个值是对象，那么可以给这个对象去动态地去增加一些属性 or 方法：

```javascript
function People(name, age) {
    this.name = name;
    this.age = age;
}

People.prototype.getInformation = function() {
    // 想想这里为什么不能用箭头函数呢？
    return `{name: ${this.name}, age: ${this.age}}`;
};

let people_one = new People('wang', 20);

console.log(people_one.getInformation());
```

既然构造函数在内存中只有一份，那么这个构造方法所对应的原型对象也只有一份，所以这个原型中的值也会只有一份。

通过构造函数所创建的对象，都可以直接地去访问原型中的成员，不需要显式地写 `prototype`。

<h3>对象中的 __proto__</h3>

每个对象也有一个属性 `__proto__` 指向了构造函数的原型，即 `object.__proto__ === Constructor.prototype`。

<div class="note danger">__proto__ 属性是非标准属性，在生产环境中不建议使用。</div>

### constructor

在原型中有一个属性 `constructor`，这个属性指向了构造函数，其作用是记录了创建该对象的构造器。
即 object.`__proto__`.constructor === object.constructor === Constructor === Constructor.prototype.constructor

<hr />

## 原型链

<h3>突然出现的 __proto__</h3>

如果我们在浏览器（默认 Chrome，下同）中打印出来 `People` 的 `prototype` 的话，可以看到它是一个对象，且具有三个值：

<img src="./prototype_dir.png" alt="一个类的原型" />

康康我们发现了什么！我们在 `People` 这个类的 `prototype` 里面竟然发现了一个 `__proto__`！

前面有说到这个 `prototype` 是一个对象，又恰好每个对象都有一个 `__proto__` 属性，这就不难理解了。

来让我们继续康康这个 `__proto__` 中有什么东西：

<img src="./base__proto__.png" alt="上一层原型" />

可以看到一大堆定义的属性和方法，更神奇的是，我们竟然可以直接用 People 的实例去调用这些方法！

```javascript
console.dir(people_one.toString()); // 输出 '[object Object]'
```

在这些方法中，我们又发现了一个特殊的属性 `constructor`，这代表着构造函数，再结合刚刚所说的 object.`__proto__`.constructor === object.constructor === Constructor === Constructor.prototype.constructor，那么就说明这是由一个特殊的类（构造函数）创造的对象中的 `__proto__`！

接下来看看这个 `constructor` 中到底有什么：

<img src="./object.png" alt="Object 构造函数" />

这个构造方法的名称竟然是 `Object`！是不是已经有一些学 Java 的小伙伴懂了。

### 什么是原型链

<img src="./yuanxinglian.png" alt="原型链" />

<div class="note info">原型对象的最顶层，即 Object 的原型对象（`Object.prototype.__proto__`）是 null。</div>

我们可以非常简单地认为，`People` 类继承了 `Object` 类！

为了证实我们的想法，我们再新建一个 `Student` 类：

```javascript
function Student(name, age, studentId) {
    this.studentId = studentId;
}

let student = new Student('li', 18, 12345);
```

为什么接受三个参数呢？因为要搞一个继承出来！按照继承链的写法，我们了解到了：

1. `Student.prototype` 和 `student.__proto__` 严格等于；
2. 'Student.prototype.__proto__' 本来是 `Object`，所以 `student` 可以用 `Object` 中的方法；
3. 'People.prototype.__proto__' 也是 'Object'。

那么我们只需要将 `Student.prototype.__proto__` 设置为 `People.prototype`：

```javascript
function Student(name, age, studentId) {
    this.studentId = studentId;
    this.__proto__.name = name;
    this.__proto__.age = age;
}

Student.prototype.__proto__ = People.prototype;

let student = new Student('li', 18, 12345);
```

<div class="note success">在构造函数中的 this 就是当前对象，那么当前对象的 __proto__ 属性就是它的原型 People，而 name 和 age 又在 People 上，所以写为 this.__proto__.name = name;</div>

<div class="note info">为什么不直接写 this.name = name 呢？</div>

### 方法重载

当调用对象的属性或方法时，会先去寻找当前构造函数中的属性或方法，如果没有，将会去寻找原型中的属性或方法，不断迭代至无上一级原型（null），那么会报错。

先找 当前的构造函数中 => 再找原型 => 原型的构造函数 => 原型构造函数的原型 => ... => null（最顶级原型），这使得 JavaScript 实现了方法的重写。

有了原型链，我们要重载方法也就很简单了：

```javascript
function Student(name, age, studentId) {
    this.studentId = studentId;
    this.__proto__.name = name;
    this.__proto__.age = age;
}

Student.prototype.__proto__ = People.prototype;

// 重载了 People 中的 getInformation 方法
Student.prototype.getInformation = function() {
    return `{name: ${this.name}, age: ${this.age}, studentId: ${this.studentId}}`;
};

let student = new Student('li', 18, 12345);

console.log(student.getInformation());
```

<hr />

## End？

<div class="note info">所有总结、截图与代码均由个人总结，请想转载的哥哥姐姐们一定要记得注明出处奥，要不然挺不好看的。既然是个人总结，难免会有纰漏或错误，如有看官发现还恳请告知，我会及时核对并纠错，在此谢过！</div>

再出一篇 《JavaScript面向对象-03-原型中的注意点》吧~