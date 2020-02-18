---
title: 看看Vue中的虚拟DOM
date: 2020-02-18 15:28:52
tags:
- Web
- Vue
categories:
- 前端
- 面经
- Vue
---

> <span class = 'introduction'>如果你没有特别幸运，那请你特别努力。</span><br/>
Vue 2.0 引入了虚拟 DOM，比 Vue 1.0 的初始渲染速度提升了 2～4 倍，并大大降低了内存消耗。目前主流的前端框架 Vue、React 核心技术也都使用了虚拟 DOM，你是否好奇为什么要提出虚拟 DOM，虚拟 DOM 是什么，它有什么优势？

<!--more-->

<hr/>

## 真实的 DOM 和它的解析流程是什么

浏览器渲染引擎工作流程都差不多，大致分为 5 步：**创建DOM树 —— 创建StyleRules —— 创建Render树 —— 布局Layout —— 绘制Painting**。

**1. 创建 DOM 树**：浏览器使用 HTML 分析器分析 HTML 元素，**构建一个 DOM 树**。

**2. 创建 StyleRules**：使用 CSS 分析器，分析 CSS 文件和元素上的 inline 样式，生成了页面的样式表。

**3. 创建 Render 树**：将 DOM 树和样式表关联起来，构建一个 Render 树（这一个过程又被称为 Attachment）。每个 DOM 节点都会有一个 `attch` 方法，其用来接受样式的信息，并返回一个 render 对象（也叫 renderer）。这些 render 对象最终会被构建为一个 Render 树。

**4. 布局 Layout**：利用 Render 树，浏览器开始布局，为 Render 树上的每个节点确定一个在屏幕上出现的精确坐标。

**5. 绘制 Painting**：Render 树和节点显示的坐标都有了，然后调用每个节点的 `paint` 方法，将其绘制出来。

### DOM 树的构建是从什么时候开始的

构建 DOM 树是一个 **渐进式** 的过程，为了达到更好的用户体验，渲染引擎会尽快将内容显示在屏幕上。所以渲染引擎 **不必** 等到整个 HTML 文档都解析完成后才开始构建 Render 树和布局。

### Render 树一定是在 DOM 树和样式表构建完才生成的吗

不，这三个过程实际进行的时候会有交叉，即一边加载、一边解析、一边渲染的现象。

<img src="./webkit_dom.png" alt="webkit渲染引擎工作流程" title="webkit渲染引擎工作流程" />

<hr />

## 直接用 JavaScript 操纵 DOM 的代价

用我们传统的开发模式，原生 JavaScript 或使用 jQuery 操作 DOM 时，浏览器会从构建 DOM 树开始从头到尾执行一遍流程。

假如在一次操作中，我需要更新 10 个 DOM 节点，浏览器收到第一个 DOM 请求后并不知道还有 9 次更新操作，因此会马上执行流程，最终执行 10 次。

例如，第一次计算完，紧接着下一个 DOM 更新请求，这个节点的坐标值就变了，前一次计算为无用功。计算 DOM 节点坐标值等都是白白浪费的性能。即使计算机硬件一直在迭代更新，操作 DOM 的代价仍旧是昂贵的，频繁操作还是会出现页面卡顿，影响用户体验。

<hr />

## 虚拟 DOM

### 为什么要提出虚拟 DOM

在 Web 早期，页面的交互比较简单，没有复杂的状态需要管理，也不太需要频繁的操作 DOM，随着时代的发展，页面上的功能越来越多，我们需要实现的需求也越来越复杂，DOM 的操作也越来越频繁。

**通过 js 操作 DOM 的代价很高**，因为会引起页面的重排重绘，增加浏览器的性能开销，降低页面渲染速度，既然操作 DOM 的代价很高那么有没有那种方式可以**减少对 DOM 的操作**？这就是为什么提出虚拟 DOM 一个很重要的原因。

虚拟 DOM 就是为了**解决浏览器性能问题而被设计出来的**。**如前**，若一次操作中有 10 次更新 DOM 的动作，虚拟 DOM 不会立即操作 DOM，而是将这 10 次更新的 diff 内容保存到本地一个 JS 对象中，最终将这个 JS 对象**一次性 attch 到 DOM 树上**，再进行后续操作，避免大量无谓的计算量。

所以，用 JS 对象模拟 DOM 节点的好处是，**页面的更新可以先全部反映在 JS 对象（虚拟 DOM）上，操作内存中的 JS 对象的速度显然要更快，等更新完成后，再将最终的 JS 对象映射成真实的 DOM，交由浏览器去绘制。**

### 模板转换为视图的过程

在正式介绍 Virtual DOM 之前，我们有必要先了解下模版转换成视图的整个过程（如下图）：

<img src="./t2v.png" alt="模板转视图" title="模板转换为视图的过程" />

- Vue.js 通过编译将模板转化为渲染函数 `render`，执行渲染函数就能得到一个 V-DOM；
- 在对模型进行操作的时候，会触发对应的 `Watcher` 对象，其会调用对应的 `update` 来修改视图。这个过程主要是将新旧虚拟 DOM 进行差异对比，然后根据结果进行对比。

在 Vue 的实现上，Vue 将模板编译为虚拟 DOM 渲染函数，结合 Vue 自带的响应系统。在状态改变时可以智能地计算出重新渲染组件的最小代价并应用到 DOM 操作上。

#### 一些概念的理解

- 渲染函数：`render` 是用来生成虚拟 DOM 的。Vue 推荐使用模板来构建我们的应用页面。
- VNode 虚拟节点：可以代表一个真实的 DOM 节点。通过 createElements 方法可以将一个 VNode 渲染为 DOM 节点。即，它描述了应该怎样去创建真实的 DOM 节点。
- patch 算法：VDOM 最核心的部分，它可以将 VNode 渲染成真实的 DOM。这个过程是对比新旧虚拟节点之间有哪些不同，然后根据对比结果找出需要更新的的节点进行更新。这点我们从单词含义就可以看出， patch 本身就有补丁、修补的意思，其实际作用是在现有 DOM 上进行修改来实现更新视图的目的。Vue 的 VDOM Patching 算法是基于 <a href="https://github.com/snabbdom/snabbdom">Snabbdom</a> 的实现，并在些基础上作了很多的调整和改进。

### 模拟一个虚拟 DOM

一个节点上通常会存储一些数据，比如节点的标签名称 `tagName`、节点的属性 `props` 以及这个节点的所有子节点 `children`。现在自行模拟一个 `Element` 构造器，其接受上述的三个参数，用来描述一个节点：

```javascript
function Element(tagName, props, children) {
    
}
```

现在用一个真正的 DOM 树作为演示：

```html
<div class="container">
    <h1>This is Real DOM</h1>
    <p>some text in here</p>
    <ul id="list">
        <li class="f-left">1</li>
        <li class="f-left">2</li>
        <li class="f-left">3</li>
    </ul>
</div>
```

那么根据上面的定义，可以用 JS 对象的形式来模拟出这个真正的 DOM 树：

```javascript
const virtualDOM = Element('div', { class: 'container' }, [
    // div 的所有子节点
    Element('h1', {}, ['This is Real DOM']), // 文本也是一个子节点
    Element('p', {}, ['some text in here']),
    Element('ul', { id: 'list' }, [
        // ul 的所有子节点
        Element('li', { class: 'f-left' }, ['1']),
        Element('li', { class: 'f-left' }, ['2']),
        Element('li', { class: 'f-left' }, ['3']),
    ])
]);
```

不难发现，一个节点的子节点，**既可能是另一个节点，也可能是文本节点**，那么 `Element` 这个方法这两点都要处理：

```javascript
function Element(tagName, props, children) {
    if (!(this instanceof Element)) {
        // 这就是应对文本节点的方法
        return new Element(tagName, props, children); 
        // 既然是 new，里面的 this 一定就是 Element 的实例了
    }
    
    this.tagName = tagName; // 记录这个节点的标签名称
    this.props = props || {}; // props 应该是一个对象
    this.children = children || []; // children 应该是一个数组
    
    this.keys = Object.keys(this.props); // 记录一下这个节点上面定义的所有属性
}
```

通过这样的方法，就形成了一颗简易的虚拟 DOM 树，最后要将其映射成真正的 DOM：

```javascript
Element.prototype.render = function() {
    const el = document.createElement(this.tagName); // 根据 tagName 标签名创建节点
    const props = this.props; // 遍历其所有定义的属性
    
    for (const key in props) {
        el.setAttribute(key, props[key]);
    } // 加属性
    
    this.children.forEach(value => {
        const childElement = (value instanceof Element) ? child.render() : document.createTextNode(value);
        // 如果子节点是一个非文本节点，那么递归进去，调用子节点的渲染
        // 否则就创建一个文本节点
        el.appendChild(childElement);
    });
    
    return el;
};

const realDom = virtualDOM.render();
// virtualDom 上面已经定义过了
document.body.appendChild(realDom); // 这就将结果渲染到了页面上
```

### 当结构发生改变时

同时维护两棵树，一颗是被修改之前（页面上的那个 DOM），一个是已经被修改之后的树，现在要将他们两个进行比较。

<div class="note info">如果要完全比较两棵树，时间复杂度将会达到 O(n<sup>3</sup>)，这样的时间复杂度是完全不能接受的。</div>

这里使用到了 **Diff** 算法，将时间复杂度控制到了 O(n)。即，放弃深搜，而是按父节点逐个对比（平层比较）。这样做也许失去了一些跨层操作的精确度，但是结合实际考虑，跨层移动 DOM 元素的场所少之又少。

<img src="./diff.png" alt="diff" title="diff" />

### 可能发生的变动

**1. 节点的标签名变了**，例如一个 `<p>` 变成了 `<div>`，可以将这个过程称之为 **REPLACE**。那么直接将旧的节点卸载，并重新去装载新的节点。旧节点包括其下面的 **所有子节点** 都会被卸载。但如果新节点和旧节点仅仅是类型不同，他们下面所有子节点都一样时，这样的做法是没有意义的。这也就提醒了开发者，**尽量去避免无谓的节点类型转化**。

**2. 节点的属性变了**，比如 `class="a"` 变成了 `class="b"`，可以将这个过程称之为 **PROPS**，此时则不会触发节点的卸载和装载，仅仅是将这个节点更新一下就好。

**3. 节点内部的文本变了**，这个很简单，修改文字内容就好。

**4. 整个 DOM 树的结构变了**，我们将这个过程称之为 **REORDER**。我们 **简单粗暴** 的做法是遍历每一个新虚拟 DOM 的节点，与旧虚拟 DOM 对比相应节点对比，在旧 DOM 中是否存在，不同就卸载原来的按上新的。

如果是 DOM 树结构发生了改变，可以看看常见的 **最小编辑距离问题**，可以用 **Levenshtein Distance** 算法来实现，时间复杂度是 O(M*N)，但通常我们只要一些简单的移动就能满足需要，降低精确性，将时间复杂度降低到 O(max(M,N)) 即可。

### 找到了 diff 之后

既然虚拟 DOM 有了，Diff 也有了，现在就可以将 Diff 应用到真实 DOM 上了。深度遍历 DOM 将 Diff 的内容更新进去就好。

<hr />

## 虚拟 DOM 的意义

vdom 的真正意义是为了实现跨平台，服务端渲染，以及提供一个性能还算不错 Dom 更新策略。vdom 让整个 mvvm 框架灵活了起来。

Diff 算法只是为了虚拟 DOM 比较替换效率更高，通过 Diff 算法得到 diff 算法结果数据表(需要进行哪些操作记录表)。原本要操作的 DOM 在 vue 这边还是要操作的，只不过用到了 js 的 DOM fragment 来操作 dom（统一计算出所有变化后统一更新一次 DOM）进行浏览器 DOM 一次性更新。

**Virtual DOM 本质上就是在 JS 和 DOM 之间做了一个缓存**。可以类比 CPU 和硬盘，既然硬盘这么慢，我们就在它们之间加个缓存：既然 DOM 这么慢，我们就在它们 JS 和 DOM 之间加个缓存。CPU（JS）只操作内存（Virtual DOM），最后的时候再把变更写入硬盘（DOM）

### 优势

- 跨平台，由于 Virtual DOM 是以 JavaScript 对象为基础而不依赖真实平台环境，所以使它具有了跨平台的能力，比如说浏览器平台、Weex、Node 等。
- 操作 DOM 慢，js 运行效率高。我们可以将 DOM 对比操作放在 JS 层，提高效率。**因为 DOM 操作的执行速度远不如 Javascript 的运算速度快**，因此，把大量的 DOM 操作搬运到 Javascript 中，运用 patch 算法来计算出真正需要更新的节点，最大限度地减少 DOM 操作，从而显著提高性能。
- 提升渲染性能，Virtual DOM 的优势不在于单次的操作，而是在大量、频繁的数据更新下，能够对视图进行合理、高效的更新。

### 总结

Vue 通过编译将模版转换成渲染函数 `render`，执行渲染函数就可以得到一个虚拟 DOM，虚拟 DOM 提供虚拟节点 vnode 和对新旧两个 vnode 进行比对并根据比对结果进行 DOM 操作来更新视图，达到减少对 DOM 的目的，从而减少浏览器的开销，提高渲染速度，改善用户体验。

