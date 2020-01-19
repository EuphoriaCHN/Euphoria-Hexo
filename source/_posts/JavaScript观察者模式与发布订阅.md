---
title: JavaScript观察者模式与发布订阅
date: 2020-01-14 19:55:10
updated: 2020-01-18 16:25:07
tags:
- Web
- JavaScript
- 设计模式
categories:
- 前端
- 面经
- JavaScript
- 设计模式
copyright: true
---

> <span class = 'introduction'>青少年是一个美好而又是一去不可再得的时期，是将来一切光明和幸福的开端。</span><br/>
如果面试官问到你：“What is the difference between the Observer pattern and Pub-Sub pattern?”，你该怎么回答呢？

<!--more-->

<hr/>

## 背景

<div class="note info">设计模式是在面向对象软件设计过程中针对特定问题的简洁而优雅的解决方案。</div>

在《Head First 设计模式》一书中有讲到：

> Publishers + Subscribers = Observer pattern

但 **发布订阅** 和 **观察者模式** 真的是完全相同的吗？

<hr />

## Observer Pattern

### 定义

所谓观察者模式，其实就是为了实现 **松耦合**(loosely coupled)。

观察者模式定义了对象间的一种 **一对多** 的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都将得到通知，并自动更新。

观察者模式属于 **行为型模式**，行为型模式关注的是对象之间的通讯，观察者模式就是观察者和被观察者之间的通讯。

<img src="ObserverPattern.png" alt="Observer design pattern" />

### 实现

被观察者（Subject，或者叫 Observable），它只需维护一套观察者（Observer）的集合，这些 Observer 实现相同的接口，Subject 只需要知道，通知 Observer 时，需要调用哪个统一方法就好了：

```javascript
class User {
    constructor(name) {
        this.name = name;
        this.subscriberlList = []; // 每个人都可能会有其订阅者
    }

    publish(rewards) {
        console.log(`${this.name} 用户发布了价值为 ${rewards} 的物品！`);
        this.subscriberlList.forEach(value => value(rewards)); 
        // 逐个调用发布者的订阅列表中，与订阅者约定好的的通知方法
    }

    subscribe(subject, callback) {
        console.log(`${this.name} 用户订阅了 ${subject.name}！`);
        subject.subscriberlList.push(callback); // 送入被订阅者的订阅列表中
    }
}
```

现在有四个用户 *wang*, *li*, *zhang*, *sun*，*wang* 手中即将新进一批货物，其余三人则 *订阅* 了 *wang*，当其发布了新物品时需要通知到这三个人：

```javascript
let wang = new User('wang');
let li = new User('li');
let zhang = new User('zhang');
let sun = new User('sun');

li.subscribe(wang, rewards => {
    console.log(`li ${rewards > 100 ? '觉得太贵了，不' : ''}决定购买这件物品！`);
});

zhang.subscribe(wang, rewards => {
    console.log(`zhang ${rewards > 50 ? '觉得太贵了，不' : ''}决定购买这件物品！`);
});

sun.subscribe(wang, rewards => {
    console.log(`sun ${rewards > 25 ? '觉得太贵了，不' : ''}决定购买这件物品！`);
});

wang.publish(75); // 最后，wang 发布一个消息，其即将会通知到所有已订阅的人
```

```txt
li 用户订阅了 wang！
zhang 用户订阅了 wang！
sun 用户订阅了 wang！
wang 用户发布了价值为 75 的物品！
li 决定购买这件物品！
zhang 觉得太贵了，不决定购买这件物品！
sun 觉得太贵了，不决定购买这件物品！
```

从这里我们可以看出来，发布者会直接主动通知其订阅者，即双方互相“认识”。

### 观察者模式的优缺点

<div class="note success">
    <p>1、具体主题和具体观察者是 <b>松耦合</b> 关系。由于主题接口仅仅依赖于观察者接口，因此具体主题只是知道它的观察者是实现观察者接口的某个类的实例，但不需要知道具体是哪个类。同样，由于观察者仅仅依赖于主题接口，因此具体观察者只是知道它依赖的主题是实现主题接口的某个类的实例，但不需要知道具体是哪个类。</p>
    <p>2、观察者模式满足 <b>“开-闭原则”</b>。主题接口仅仅依赖于观察者接口，这样，就可以让创建具体主题的类也仅仅是依赖于观察者接口，因此，如果增加新的实现观察者接口的类，不必修改创建具体主题的类的代码。。同样，创建具体观察者的类仅仅依赖于主题接口，如果增加新的实现主题接口的类，也不必修改创建具体观察者类的代码。</p>
</div>

<div class="note danger">
    <p>1、如果一个被观察者对象有很多的直接和间接的观察者的话，将所有的观察者 <b>都通知到会花费很多时间</b>。</p>
    <p>2、如果在观察者和观察目标之间有循环依赖的话，观察目标 <b>会触发它们之间进行循环调用</b>，可能导致系统崩溃。</p>
    <p>3、观察者模式没有相应的机制让观察者知道所观察的目标对象是怎么发生变化的，而仅仅只是知道观察目标发生了变化。</p>
</div>

<hr />

## Pub-Sub Pattern

### 定义

在 *Pub-Sub Pattern* 中，发布者，并不会直接通知订阅者，换句话说，发布者和订阅者，彼此互不相识。

<div class="note info">In ‘Publisher-Subscriber’ pattern, senders of messages, called <b>publishers</b>, do not program the messages to be sent directly to specific receivers, called <b>subscribers</b>.</div>

既然这意味着发布者和订阅者互相不知道彼此的存在，那么就需要第三个组件，其被称为 **代理**（消息代理、事件总线）。发布者和订阅者都知道它，它过滤所有传入的消息并相应地分发它们。

换句话说，**Pub-Sub** 是一种模式，用于在不同的系统组件之间传递消息，而这些组件之间不了解彼此的身份，如果有兴趣了解更多请戳蓝链 => <a href="https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern#Message_filtering">维基百科对此已经进行了很好的解释</a>。

<img src="./PubSubPattern.gif" alt="Pub-Sub Pattern" />

现在让我们再来对比一下观察者模式和发布订阅的主要区别：

<img src="vs.jpeg" alt="观察者模式 vs 发布订阅" />

大致总结一下就是：

- 在 **观察者** 模式中，**观察者知道主题**，**主题也维护观察者的记录**。而在 **发布订阅** 中，发布者和订阅者 **不需要彼此了解**。他们只是在消息队列或代理的帮助下进行通信。
- 在 **发布订阅** 模式中，与 **观察者** 模式相反，组件是松散耦合的。
- **观察者** 模式主要以 **同步** 方式实现，即，当某个事件发生时，Subject 调用其所有观察者的适当方法。而 **发布订阅** 通常使用的是 **消息队列** 去维护。
- **观察者** 模式需要在单个应用程序地址空间中实现。**发布订阅** 更多地是跨应用程序模式.

尽管这些模式之间存在差异，但有些人可能会说 **Publisher-Subscriber** 是 **Observer** 模式的变体，因为它们之间在概念上相似。而且这根本没有错。无需认真对待差异。

- 如果以结构来分辨模式，发布订阅模式相比观察者模式多了一个中间件订阅器，所以发布订阅模式是不同于观察者模式的；
- 如果以意图来分辨模式，他们都是 **实现了对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都将得到通知，并自动更新**，那么他们就是同一种模式，发布订阅模式是在观察者模式的基础上做的优化升级。

<div class="note success"><b>分辨模式的关键是意图而不是结构</b> --- 《JavaScript设计模式与开发实践》</div>

### 实现

在观察者模式的实现背景中，增加一个中介者（Broker）：

```javascript
class Broker {
    constructor(name) {
        this.name = name;
        this.topicsList = [];
    }

    publish(topic, rewards, publisher) {
        if (!this.topicsList[topic]) {
            return 'No subscribers'; // 对于 target 事件没有任何的订阅者
        }
        this.topicsList[topic].forEach(value => value(rewards, publisher));
        // 由 Broker 去通知订阅 topic 的订阅者
    }

    subscribe(topic, callback) {
        if (!this.topicsList[topic]) {
            this.topicsList[topic] = []; // 如果这个事件是全新的，就去对这个事件维护一个序列
        }
        this.topicsList[topic].push(callback);
    }

    letsSomebodyJoin(...users) {
        users.forEach(value => {
            console.log(`用户 ${value.name} 加入了 ${this.name}！`);
            value.brokersList.push(this);
        });
    }
}
```

对于 User 类的定义，只需要稍做一些改动：

```javascript
class User {
    constructor(name) {
        this.name = name;
        this.brokersList = [];
    }

    subscribe(topic, callback) {
        this.brokersList.forEach(value => {
            console.log(`用户 ${this.name} 在 ${value.name} 中介里订阅了 ${topic}！`);
            value.subscribe(topic, callback); // 对于当前订阅者所在的 Broker 中去订阅 topic
        });
    }

    publish(topic, rewards) {
        this.brokersList.forEach(value => {
            console.log(`用户 ${this.name} 向 ${value.name} 发布了价值为 ${rewards} 的 ${topic}！`);
            value.publish(topic, rewards, this); // 对于当前订阅者所在的 Broker 中去发布 topic
        });
    }
}
```

Client:

```javascript
let broker = new Broker('Broker');

let wang = new User('wang');
let li = new User('li');
let zhang = new User('zhang');
let sun = new User('sun');

broker.letsSomebodyJoin(wang, li, zhang, sun);

li.subscribe('窝窝头', (rewards, publisher) => {
    console.log(`li ${rewards > 100 ? '觉得太贵了，不' : ''}决定购买 ${publisher.name} 发布的窝窝头！`);
});

zhang.subscribe('窝窝头', (rewards, publisher) => {
    console.log(`zhang ${rewards > 50 ? '觉得太贵了，不' : ''}决定购买 ${publisher.name} 发布的窝窝头！`);
});

sun.subscribe('窝窝头', (rewards, publisher) => {
    console.log(`sun ${rewards > 25 ? '觉得太贵了，不' : ''}决定购买 ${publisher.name} 发布的窝窝头！`);
});

wang.publish('窝窝头', 35);
```

*wang* 发布了 35 价值的窝窝头，可以预想的到是 *sun* 没有购买：

```txt
用户 wang 加入了 Broker！
用户 li 加入了 Broker！
用户 zhang 加入了 Broker！
用户 sun 加入了 Broker！
用户 li 在 Broker 中介里订阅了 窝窝头！
用户 zhang 在 Broker 中介里订阅了 窝窝头！
用户 sun 在 Broker 中介里订阅了 窝窝头！
用户 wang 向 Broker 发布了价值为 35 的 窝窝头！
li 决定购买 wang 发布的窝窝头！
zhang 决定购买 wang 发布的窝窝头！
sun 觉得太贵了，不决定购买 wang 发布的窝窝头！
```

### 发布订阅的优缺点

<div class="note success">
    <p>1. <b>松耦合</b>：发布者与订阅者松耦合，<b>甚至不需要知道它们的存在</b>。由于 <b>主题才是关注的焦点</b>，发布者和订阅者可以对系统拓扑结构保持一无所知。各自继续正常操作而无需顾及对方。在传统的紧耦合的客户端-服务器模式中，当服务器进程不运行时，客户端无法发送消息给服务器，服务器也无法在客户端不运行时接收消息。许多发布/订阅系统不但将发布者和订阅者 <b>从位置上解耦</b>，还 <b>从时间上解耦</b> 他们。中间件分析师对这种发布/订阅使用的常用策略，是拆卸一个发布者来让订阅者处理完积压的工作（带宽限制的一种形式）。</p>
    <p>2. <b>可扩展性</b>：通过并行操作，消息缓存，基于树或基于网络的路由等技术，<b>发布/订阅提供了比传统的客户端–服务器更好的可扩展性</b>。然而，在某些类型的紧耦合、高容量的企业环境中，随着系统规模上升到由上千台服务器组成的数据中心所共享的发布/订阅基础架构，现有的供应商系统经常失去这项好处；在这些高负载环境下，发布/订阅产品的扩展性是一个研究课题。</p>
    <p>另一方面，在企业环境之外，发布/订阅范式已经证明了它的可扩展性远超过一个单一的数据中心，通过网络聚合协议如 <a href="https://baike.baidu.com/item/RSS/24470">RSS</a> 和 <a href="https://baike.baidu.com/item/atom/353868#viewPageContent">Atom</a> 提供互联网范围内分发的消息。在交互时，为了能够即便是用低档Web服务器也能将消息播出到(可能)数以百万计的独立用户节点，这些聚合协议接受更高的延迟和无保障交付。</p>
</div>

<div class="note danger">
    <p>发布/订阅系统最严重的问题是 <b>其主要优点的副作用：发布者解耦订阅者</b>。</p>
    <p>消息交付问题：发布/订阅系统必须仔细设计，才能提供特定的应用程序可能需要的更强大的系统性能，例如有保障的交付。</p>
    <ul>
        <li>发布/订阅系统的中介（broker）可能设计为在指定时间发送消息，随后便停止尝试发送，无论是否已收到所有用户成功接收消息的确认回复。这样设计的发布/订阅系统 <b>不能保证消息能够传递到所有需要这种有保障交付的应用程序</b>。要达成有保障交付，必须在发布/订阅架构之外强制执行这种发布者和订阅者之间在设计上更紧密的耦合（例如，通过要求订阅者宣布消息已接收）。</li>
        <li>发布/订阅系统中的 <b>发布者会“假定”订阅者正在监听</b>，而实际上可能没有。一个工厂可能会使用发布/订阅系统来允许设备发布问题和故障，订阅者将问题显示并记录。<b>如果记录器失败（崩溃了），那么设备故障发布者不一定收到记录器失败的通知，发布/订阅系统的任何设备都不会显示和记录错误消息</b>。</li>
    </ul>
    <p>在有少量发布者和订阅节点的小型网络和低信息量时发布/订阅能够自如伸缩。然而，随着节点和消息量的增长，不稳定性随之增长，限制了发布/订阅网络的最大可扩展性。大规模时吞吐量不稳定的例子包括：</p>
    <ul>
        <li><b>负载激增</b> - 订阅请求使网络流量饱和，随后进入低信息量（未充分利用网络带宽）</li>
        <li><b>速度变慢</b> - 越来越多的应用程序使用该系统（即使它们是在不同的发布/订阅频道通信）消息量流入单个订阅者的速度缓慢</li>
    </ul>
</div>

<hr />

## 参考资料

- [Observer vs Pub-Sub pattern](https://hackernoon.com/observer-vs-pub-sub-pattern-50d3b27f838c)
- [Publish–subscribe pattern](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern#Message_filtering)
- [观察者模式 vs 发布订阅模式](https://zhuanlan.zhihu.com/p/51357583)
- [Javascript中理解发布--订阅模式](https://www.cnblogs.com/itgezhu/p/10947405.html)
- [观察者和发布订阅模式的区别](https://www.cnblogs.com/viaiu/p/9939301.html)
- [发布订阅模式与观察者模式](https://blog.csdn.net/hf872914334/article/details/88899326)