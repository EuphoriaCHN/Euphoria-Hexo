---
title: Hexo-NexT魔改系列-04-进阶设置
date: 2019-09-23 12:27:40
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


> <span class = 'introduction'>没有退路的时候，正是潜力发挥最大的时候。</span><br/>
Hey~ 这里有你不知道的一些进阶 CSS 配置哦~ 来这里看看吧！<br/>完结撒花！！！

<!--more-->

<hr/>

## 页脚美化

首先来康康效果图哟:

<div style = "text-align: center;">
    <img src = "footer.png" alt = "footer"></img>
</div>

接下来将一步步带领大家美化你的页脚！

<div class = "note info">在我的 <a href = "http://www.wqh4u.cn/2019/09/15/Hexo-NexT魔改系列-03-添加数据统计/">这篇博客</a> 已经有对即将要修改的文件的初始操作，还请各位小伙伴首先阅读链接中的博客哦</div>

### 跳动的心

首先编辑你的博客中的 <span class = "purple-target">主题配置文件</span> 修改 `footer` 值：

```yml
footer:
    icon: heart
```

然后编辑 `/themes/next/layout/_partials/footer.swig` 文件，找到 `<span class="with-love">` 将其修改为：

```html
<span class="with-love" id="heart">
```

再编辑 `/themes/next/source/css/_custom/custom.styl` 文件，加入以下代码：

```css
/* 自定义页脚跳动的心样式 */
@keyframes heartAnimate {
    0%,100%{transform:scale(1);}
    10%,30%{transform:scale(0.9);}
    20%,40%,60%,80%{transform:scale(1.1);}
    50%,70%{transform:scale(1.1);}
}
#heart {
    animation: heartAnimate 1.33s ease-in-out infinite;
}
.with-love {
    color: rgb(255, 113, 168);
}
```

其中，`color` 的值可以设置成你喜欢的值，灵感来自 <a href = "">DIYgod</a> 大佬的博客，CSS代码参考 [这篇文章](https://www.jianshu.com/p/73b46c376188)。

最新版本的 `NexT` 主题已经内嵌支持，无需添加代码，详情参考 [这里](https://theme-next.org/docs/theme-settings/footer)。

### 页脚样式美化

修改 `/themes/next/layout/_partials/footer.swig` 文件，将 `<div class = "copyright"></div>` 改为：

```
<div class="copyright custom-footer">
```

这里就是加上一个 class 然后你就可以在 `/themes/next/source/css/_custom/custom.styl` 文件中写下你喜欢的样式了~ 这里贴上我的样式作为参考：

```css
.custom-footer {
  color: rgba(52, 52, 52, 1.0);
  border-top: 3px solid #9370db;
  background-color: rgba(255, 255, 255, 0.75);
  padding: 10px 0;
  font-size: 15px;
}
```

<hr/>

## SideBar美化

### Side Title

在 `/themes/next/source/css/_custom/custom.styl` 文件中加入以下样式：

```css
.site-title:hover {
  webkit-background-clip: text;
  -webkit-text-fill-color: #000;
  -webkit-text-stroke: 1px #ddd;
}

.site-title {
  display: inline-block;
  vertical-align: top;
  line-height: 36px;
  font-size: 21px;
  font-weight: 700;
  font-family: Lato, "PingFang SC", "Microsoft YaHei", sans-serif;
  text-shadow: 5px 5px 3px rgba(47, 138, 216, 0.47);
  color: #329edc;
}
```

这个是修改了你的博客左上角的主页按钮，简介的话之前有说，可以使用 `<font>` 来修改颜色。

### 友情链接

修改 <span class = "purple-target">主题配置文件</span>，找到 `Blog rolls`，修改为如下：

```yml
# Blog rolls
links_icon: thumbs-o-up
links_title: 哥哥们的博客
links_layout: block
#links_layout: inline
links:
  #Title: http://example.com/
  【全能选手Hang_ccccc】: https://hangcc.cn
  【金牌选手LuKe】: https://www.cnblogs.com/317zhang/
```

就可以啦！

<hr/>

## 自定义样式

众所周知 `MarkDown` 可以变成 `HTML5`，那么我们可以加上自己设置的样式来美化文章，打开 `/themes/next/source/css/_custom/custom.styl`，我在这里贴上我所用的样式供各位小伙伴们参考:

```css
// Custom styles.
/* 文章内链接文本样式 */
.post-body p a,
.post-body li a {
  color: #0593d3;
  border-bottom: none;
  border-bottom: 1px solid #0593d3;

  &:hover {
    color: #fc6423;
    border-bottom: none;
    border-bottom: 1px solid #fc6423;
  }
}

/* 主页文章添加阴影效果 */
.post {
  margin-top: 60px;
  margin-bottom: 60px;
  padding: 25px;
  -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5);
  -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5);
}

/* 背景图片透明度 */
.backstretch {
  opacity: .85;
}

/* 页面透明度 */
.content-wrap, .sidebar {
  opacity: .9 !important;
}

.header-inner {
  background: rgba(255, 255, 255, 0.9) !important;
}

/* 去掉图片边框 */
.posts-expand .post-body img {
  border: none;
  padding: 0;
}

.post-gallery .post-gallery-img img {
  padding: 3;
}

.euphoria-footer {
  color: rgba(52, 52, 52, 1.0);
  border-top: 3px solid #9370db;
  background-color: rgba(255, 255, 255, 0.75);
  padding: 10px 0;
  font-size: 15px;
}

/* 自定义页脚跳动的心样式 */
@keyframes heartAnimate {
  0%, 100% {
    transform: scale(1);
  }
  10%, 30% {
    transform: scale(0.9);
  }
  20%, 40%, 60%, 80% {
    transform: scale(1.1);
  }
  50%, 70% {
    transform: scale(1.1);
  }
}

#heart {
  animation: heartAnimate 1.33s ease-in-out infinite;
}

.with-love {
  color: rgb(255, 113, 168);
}

/* 自定义的侧栏时间样式 */
#days {
  display: block;
  color: #007FFF;
  font-size: 14px;
  margin-top: 15px;
}

/*By Euphoria*/

.introduction {
  color: #ff0000;
}

td {
  text-align: center;
  vertical-align: bottom;
}

td, th {
  border: 2px solid white;
  font-size: 18px;
}

th {
  background-color: #337ab7;
  color: white;
}

.code {
  text-align: left;
  font-size: 14px;
}

code {
  color: rgba(213, 0, 252, 0.91);
  background: rgba(78, 240, 233, 0.55);
  margin: 0 4px;
  font-size: .9em;
  border: 1px solid #d6d6d6;
  border-radius: 3px;
  padding: 2px 4px;
  word-wrap: break-word;
}

code, pre {
  font-family: consolas, Menlo, "PingFang SC", "Microsoft YaHei", monospace;
}

.blue-target {
  padding: 3px 5px;
  margin: 0 4px;
  font-size: 16px;
  font-weight: 700;
  color: white;
  background-color: #337ab7;
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
}

.purple-target {
  padding: 3px 5px;
  margin: 0 4px;
  font-size: 16px;
  font-weight: 700;
  color: white;
  background-color: #9954bb;
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
}

.green-target {
  padding: 3px 5px;
  margin: 0 4px;
  font-size: 16px;
  font-weight: 700;
  color: white;
  background-color: #2b6600;
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
}

.red-target {
  padding: 3px 5px;
  margin: 0 4px;
  font-size: 16px;
  font-weight: 700;
  color: white;
  background-color: #ff0000;
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
}

.post-body h2 {
  background: #2b6695;
  border-radius: 6px 6px 6px 6px;
  border: none;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
  color: #fff;
  font-family: "微软雅黑", "宋体", "黑体", Arial;
  font-weight: 700;
  line-height: 1.3;
  margin: 18px 0 18px -10px !important;
  padding: 10px;
  text-shadow: 2px 2px 3px #222;
  font-size: 1.45em;
  display: block;
}

.post-body h3 {
  background: #2b6600;
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
  color: #fff;
  font-family: "微软雅黑", "宋体", "黑体", Arial;
  font-size: 1.2em;
  font-weight: 700;
  line-height: 1.5;
  margin: 12px 0 12px -3px !important;
  padding: 5px 10px 3px 10px;
  text-shadow: 2px 2px 3px #222;
  border-bottom: 1px solid #eee;
  display: block;
}

.post-body h4 {
  background: rgba(103, 58, 183, 0.72);
  border-radius: 6px 6px 6px 6px;
  box-shadow: 0 0 0 1px #5f5a4b, 1px 1px 6px 1px rgba(10, 10, 0, 0.5);
  color: #fff;
  font-family: "微软雅黑", "宋体", "黑体", Arial;
  font-size: 1em;
  font-weight: 700;
  line-height: 1.5;
  margin: 12px 0 12px -3px !important;
  padding: 5px 10px 3px 10px;
  text-shadow: 2px 2px 3px #222;
  border-bottom: 1px solid #eee;
  display: block;
}

.post-body h2 code, .post-body h3 code, .post-body h4 code {
  font-size: inherit;
  color: #f7ab01;
  background: 0 0;
  border: none;
}

.site-title:hover {
  webkit-background-clip: text;
  -webkit-text-fill-color: #000;
  -webkit-text-stroke: 1px #ddd;
}

.site-title {
  display: inline-block;
  vertical-align: top;
  line-height: 36px;
  font-size: 21px;
  font-weight: 700;
  font-family: Lato, "PingFang SC", "Microsoft YaHei", sans-serif;
  text-shadow: 5px 5px 3px rgba(47, 138, 216, 0.47);
  color: #329edc;
}

.note {
  position: relative;
  padding: 15px;
  margin-bottom: 20px;
  border: initial;
  border-left: 3px solid #eee;
  background-color: #f9f9f9;
  border-radius: 3px;
}

.note.info {
  background-color: #eef7fa;
  border-left-color: #428bca;
}

.post-tags {
  margin-top: 0;
}

.post-widgets {
  padding-top: 10px;
  padding-bottom: 25px;
  margin-top: 0;
}
```

<hr/>

<div class = "info note">
至此，我们的 <code>Hexo-NexT魔改系列</code> 暂时告一段落了（要找工作辽顶不住），有问题或者更好的建议的小伙伴可以在下方留言或添加 QQ 879969355 来找到菜鸡本人。<br/>祝各位的博客越变越漂亮~<br/><br/><span class = "red-target">(完结撒花)</span></div>