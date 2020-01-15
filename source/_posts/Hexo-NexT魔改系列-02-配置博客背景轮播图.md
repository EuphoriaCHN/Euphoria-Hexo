---
title: Hexo-NexT魔改系列-02-配置博客背景轮播图
date: 2019-09-10 12:44:56
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

> <span class = 'introduction'>生命不在长而在于好，只要每一次尽力的演示，都值得鼓励与喝采。</span><br/>
本篇博客主要介绍了如何给你的博客加上 `背景轮播图` 及其所需要注意的事项，一步一步地美化你的博客吧!

<!--more-->

## 了解动态背景图片插件 `jquery-backstretch`

`jquery-backstretch` 是一款简单的 jQuery 插件，可以用来设置动态的背景图片，以下是官方网站的介绍。

 > A simple jQuery plugin that allows you to add a dynamically-resized, slideshow-capable background image to any page or element.
 
 可以直接在页面中引入该插件的 `cdn` 来调用函数，也可以直接下载下来使用，这是 [官方地址](https://www.bootcdn.cn/jquery-backstretch/)。
 
 ## `jquery-backstretch` 的使用方法
 
 ### 引入该插件的cdn
 
 打开我们在 [上个Blog](https://www.wqh4u.cn/2019/09/08/Hexo-NexT魔改系列-01-准备工作/) 中提到的 `\themes\next\layout\_custom\custom-foot.swig`，引入该背景图片插件的 cdn：
 
 ```html
{#Custom foot in body, Can add script here.#}
<!-- 图片轮播js文件cdn -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-backstretch/2.0.4/jquery.backstretch.min.js"></script>

<!-- 自定义的js文件 -->
<script type="text/javascript" src="/js/src/custom.js"></script>
 ```
 
 需要注意的是，我们要引入的插件cdn，都需要在自定义的js文件 `custom.js` 之前引入才行！否则，当加载 `custom.js` 文件内部的 backstretch 插件会在访问页面时无法生效，可以在浏览器的控制台看到报错。
 
 ### 调用 `backstretch` 函数
 
 在 `\themes\next\source\js\src\custom.js` 中添加如下代码：

```javascript
/* 轮播背景图片 */
$(function () {
    $.backstretch([
        "/images/background/bg1.jpg",
        "/images/background/bg2.jpg",
        "/images/background/bg3.jpg",
    ], {duration: 6000, fade: 1500});
});
```

这里可以随意添加你想要轮播的图片，但要确保图片路径是正确的，比如我的背景图片就存放在站点根目录下的 `/images/background/` 目录下。

其中 `duration` 指的是轮换图片的时间，单位是毫秒，也就是说这里的代码表示一分钟就轮换到下一张图。

`fade` 指的是轮换图片时会有个渐进渐出的动作，而这个过程需要花费的时间单位也是毫秒，如果不加上这个参数，就表示离开轮换成下一张图片。

注意这里的 `$.backstretch` 指的是对整个页面设置背景图片，我们也可以专门给某个元素设置背景图片，如下：

```javascript
$(function () {
    $(".euphoira1").backstretch(["/images/background/euphoira1.jpg"]);  
    $(".euphoria2").backstretch(["/images/background/euphoira2.jpg"]);  
});
```

如果只有一张图片，就没必要设置 `duration` 和 `fade` 参数了。

### 为背景图片设置样式

虽然我们设置好了背景图片，但如果页面的许多元素是不透明的，背景图片可能并不能很好地被看见，所以我们可以对背景图片和其他的页面元素进行设置样式。

首先为背景图片设置透明度，因为有的图片颜色比较深厚，而页面多为白色，然后造成喧宾夺主的感觉。

修改 `\themes\next\source\css\_custom\custom.styl`，添加以下代码：

```css
/* 背景图片透明度 */
.backstretch {
    opacity: .75;
}

/* 页面透明度 */
.content-wrap, .sidebar {
    opacity: .9 !important;
}
.header-inner {
    background: rgba(255, 255, 255, 0.9) !important;
}
```

至此，`hexo clean` 与 `hexo g` 二连一下，你就可以在你的博客中看到你自己设置的好看的背景图片了~

## 有一些需要注意的点

我们在加载博客的时候，可以按 `F12` 查看一下加载元素的日志信息：

<img src = "./F12.jpg" alt = "F12.jpg"/>

可以看到它会在第一次加载你的博客任意界面的时候，以队列形式将你所设置的多张背景图一次性加载完成。

如果你有在 [这篇博客](http://www.wqh4u.cn/2019/09/04/设置你喜欢的live2d看板娘/) 中配置了你的高级版本 **Live 2D 看板娘** 的话，你会发现如果你的背景图没有加载完成，你的看板娘是不会出来的，那么就需要利用 [压缩图片](https://imagecompressor.com/zh/) 来压缩你的背景图片以提高加载速率。<del>或者你也可以升级你的服务器</del>

## 参考文章

本篇博客参考了 [雨临Lewis大大的博客](https://lewky.cn/posts/ef301a4d.html) 中的 [Hexo瞎折腾系列(2) - 添加背景图片轮播](https://lewky.cn/posts/576ee548.html)，本站点的很多样式都是基于他的博客来实现的，感兴趣的的小伙伴可以深入阅读一下雨临Lewis大大的博客哦~