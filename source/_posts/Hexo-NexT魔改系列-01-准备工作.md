---
title: Hexo-NexT魔改系列-01-准备工作
date: 2019-09-08 15:21:16
tags:
- Hexo
- NexT
- 魔改
- 瞎折腾
categories:
- Hexo
- NexT
- 魔改
copyright: true
---

> <span class = 'introduction'>要想改变命运，首先改变自己。</span><br/>
本篇博客介绍了如何魔改你的 `Hexo NexT` 博客的初步配置与常用文件介绍，开始你的魔改之路吧~

<!--more-->

<hr/>

## 前言

在接下来的所有描述中，我们会经常用到 <span class = "blue-target">站点配置文件</span> 与 <span class = "purple-target">主题配置文件</span>，这两个文件将分别会用 <span class = "blue-target">蓝色标注</span> 与 <span class = "purple-target">紫色标注</span> 来标识。<br/>其余文件将统一采用如下格式：`/themes/next/source/css/_custom/custom.styl`，其中 `/` 代表你的 **Hexo** 博客根目录。

## 重要配置文件

### 站点配置文件

<span class = "blue-target">站点配置文件</span> 是位于 `/` 下的 `_config.yml`，我们在里面可以设置：

```yml
# Site
title: Euphoria's Blog # 你的博客名称
subtitle: <strong><font color="#FF0000">Quitters</font> Never Win,<br/> <font color="#007FFF">Winners</font> Never Quit.</strong> # 博客附标题
description: 我摸到了<font color="#FF0000">梦</font>，<br/>也看到了<font color="#007FFF">光</font>。 # 博客简介
keywords: Euphoria # 博客关键字
author: 王钦弘 # 作者信息
language: zh-Hans # 所用语言
timezone: # 时区，默认为当前服务器时区
```

其余设置不变，就是在我的 [Hexo博客的安装与基本配置](https://www.wqh4u.cn/2019/07/31/Hexo博客的安装与基本配置/) 中所设置的所有东西。

<div class = "note info">
如果要在这里设置 CSS 样式的话，可以在 custom.styl 中进行全局设置，或者使用 	&#60;font&#62; 标签来对其进行修饰，如果使用 &#60;span style = "xxx"&#62; 的话，里面的冒号会造成二义性，故不能使用。
</div>

### 主题配置文件

<span class = "purple-target">主题配置文件</span> 是位于 `/themes/next/` 下的 `_config.yml`，这是我们在魔改的时候最常用的一个文件，因为可配置项太多在这里不一一列举，以后的博客中会对所要魔改的项进行解说，其余配置项英语好的小伙伴可以看懂无压力的~

### 自定义配置文件

本系列会使用到大量的 CSS 与 JavaScript 的相关内容，为了更有效率与可观赏性的美化博客，我们将这些美化相关的东西都尽可能地写到一类文件中，方便日后查询与修改。譬如下边的几个文件里，就存放了博客的大部分美化内容：

1. `/themes/next/source/css/_custom/custom.styl`
2. `/themes/next/source/js/src/custom.js`
3. `/themes/next/layout/_partials/head/custom-head.swig`
4. `/themes/next/layout/_custom/custom-foot.swig`

如果没有也请不要过于担心，稍后将会带领创建并引入博客主题内配置。

#### 添加 custom-foot.swig 文件

在 `/themes/next/layout/_custom/` 下创建 `custom-foot.swig` 文件，并加入以下内容：

```html
{# Custom foot in body, Can add script here. #}
<!-- 自定义的js文件 -->
<script type="text/javascript" src="/js/src/custom.js"></script>
```

接着修改 `themes\next\layout\_layout.swig`，在 &#60;/body&#62; 标签前添加一行代码，表示将我们新添加的 `custom-foot.swig` 文件包括进去：

```html
    <body>
        ....
        {% include '_custom/custom-foot.swig' %}
    </body>
</html>
```

这个文件的作用是负责引入我们想要的 js 文件，比如其他第三方 js 的 cdn 等等。因为页面在引入 js 文件时是阻塞式的（你也可以设置 async），如果我们在页面的最开始就引入这些 js 文件，而这些文件又比较大，会造成页面在渲染时长时间处于白屏状态。

#### 添加 custom.js 文件

在 `/themes/next/source/js/src/` 目录下添加 `custom.js` 文件，该文件用来存放我们自己写的 js 函数等等，需要注意的是，我们之前是在 `custom-foot.swig` 文件中的 &#60;script&#62; 标签里引入了该文件，也就是说，在该文件里，我们不能再自己添加 script 标签了，直接书写 js 函数就行了，如下所示：

```javascript
/* 轮播背景图片 */
$(function () {
    $.backstretch([
        "/images/background/bg1.jpg",
        "/images/background/bg2.jpg",
        "/images/background/bg3.jpg",
    ], {duration: 300000, fade: 1500});
}); /*这个是背景轮播图，现在暂时可以不用输入*/
```

### 其它重要文件

#### footer.swig

这个文件位于 `/themes/next/layout/_partials/` 下，里面配置了关于页脚（也就是最开始下面有 **Powered by Hexo** 的那一块地方），因为要设置如 **备案号**、**博客全站统计字数**、**博客共计访客** 等等信息，都要在这个文件中进行设置。

#### sidebar.swig

这个文件位于 `/themes/next/layout/_custom/` 下，里面将会对 **博客已运行时间** 等进行配置。

<div class = "note info">
上面的所有文件（包括其他没有列举出来的文件）请各位仔细阅读其源码（如果有的话），以便各位可以在今后可以自定义自己的博客样式。
</div>

<hr/>

## 开始页面的简单美化

### 改变页面的字体大小

打开 `\themes\next\source\css\_variables\base.styl`，该文件保存了一些基础变量的值，我们找到 `$font-size-base`，将值改为 `16px`（我记得默认是 14px，各位根据自己的心情来改）。

```css
// Font size
$font-size-base           = 16px
```

这个文件里定义了很多常量，有兴趣的可以自己去琢磨琢磨，修改一些其它常量值。

### 文章启用 tags 和 categories

在 [Hexo博客的安装与基本配置](https://www.wqh4u.cn/2019/07/31/Hexo博客的安装与基本配置/) 中，没有对增加这两个页面做过多的阐述，在这里将会带领各位创建这两个页面。

首先，你需要在你的文章中设置 `tags` 和 `categories`，具体操作如下：

```markdown
---
title: Test
tags:
  - YourTag
categories:
  - YourCategory
date: 20xx-xx-xx xx:xx:xx
---
```

在你的 <span class = "purple-target">主题配置文件</span> 中，找到 `menu` 项，修改为如下：

```yml
menu:
  home: / || home
  tags: /tags/ || tags
  categories: /categories/ || th
  archives: /archives/ || archive
```

接着确定是否在 `/source/` 目录下是否已经存在 `tags` 和 `categories` 这两个文件夹，如果不存在需要运行以下命令：

```bash
hexo n page tags
hexo n page categories
```

运行之后会在 `/source/` 目录下生成对应的两个文件夹，在文件夹下会存在一个 `index.md` 文件，打开这两个 `index.md` 文件，分别添加 type: tags 和 type: categories，如下：

**/source/tags/index.md**
```markdown
---
title: 标签
date: 20xx-xx-xx xx:xx:xx
type: tags
---
```

**/source/categories/index.md**
```markdown
---
title: 分类
date: 20xx-xx-xx xx:xx:xx
type: categories
---
```

### 去掉图片边框

NexT主题默认会有图片边框，不太好看，我们可以把边框去掉。打开 `themes\next\source\css\_custom\custom.styl`，添加如下 CSS 代码：

```css
/* 去掉图片边框 */
.posts-expand .post-body img {
    border: none;
    padding: 0px;
}
.post-gallery .post-gallery-img img {
    padding: 3px;
}
```

## 参考文章与推荐

### 大佬们的博客

1. [雨临Lewis大大的博客](https://lewky.cn/posts/ef301a4d.html)
2. [hexo的next主题个性化配置教程](https://segmentfault.com/a/1190000009544924)
3. [打造个性超赞博客Hexo+NexT+GithubPages的超深度优化](https://io-oi.me/tech/hexo-next-optimization/)

### 在线压缩图片

在博客上的图片尽可能的要压缩一下体积，否则轻则会造成图片加载迟缓，重则会造成页面卡住白屏很久。推荐一个 [在线压缩图片](https://imagecompressor.com/zh/) 的链接，常用的除了 `.gif` 格式的都可以，我觉得挺好用的，独乐乐不如众乐乐~