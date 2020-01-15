---
title: Hexo-NexT魔改系列-03-添加数据统计
date: 2019-09-15 01:39:35
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


> <span class = 'introduction'>志向不过是记忆的奴隶，生气勃勃地降生，但却很难成长。</span><br/>
本篇博客主要介绍了如何给你的博客加上 `各种统计信息` 及其所需要注意的事项，一步一步地美化你的博客吧!

<!--more-->

## 添加博客访问人数统计

在这里我们使用的是 `busuanzi插件`，最终效果图如下：

<div style = "text-align: center;">
    <img src = "busuanzi.png" alt = "busuanzi"></img>
</div>

在你的 `\themes\next\source\js\` 中创建一个文件，名称为 `busuanzi.pure.min.js`，然后打开 [这个网页](http://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js)，将里面的内容拷贝到刚刚你创建的那个文件中，保存。

然后打开 `\themes\next\layout\_partials\footer.swig` 这个文件，在第一行加入以下代码：

```html
<script async src="/js/src/busuanzi.pure.mini.js"></script>
```

在这个文件中，之前在 [这篇博客]() 中注释了一些代码，然后我们在这个位置添加如下代码：

```html
<span id="busuanzi_container_site_pv">
      <span class="post-meta-item-text">博客全站共计访客&#58;</span>
    <span id="busuanzi_value_site_pv"></span> 人
</span>

<!--
{% if theme.footer.powered %}
  <div class="powered-by">{#
  #}{{ __('footer.powered', '<a class="theme-link" target="_blank" href="https://hexo.io">Hexo</a>') }}{#
#}</div>
{% endif %}
......
```

其中注意 `busuanzi_container_site_pv` 这个 id，当后面是 `pv` 的时候，你每刷新一次页面就会多一个访客量。如果不喜欢这样的话可以换成 `uv`，意思是每个用户访问多个页面只记录一次。（记得把两个 id 都要改啊！）

然后 `hexo clean` 与 `hexo g` 二连即可。

## 添加博客文章字数统计

`NexT` 主题默认集成了 `post_wordcount` 插件，我们可以在 <span class = "purple-target">主题配置文件</span> 中找到它，并修改为：

```yml
# Post wordcount display settings
# Dependencies: https://github.com/willin/hexo-wordcount
post_wordcount:
  item_text: true
  wordcount: true         # 单篇 字数统计
  min2read: true          # 单篇 阅读时长
  totalcount: true       # 网站 字数统计
  separated_meta: true
```

然后在 <span class = "red-target">博客根目录</span> 下，利用 npm 安装一个插件：

```bash
npm i --save hexo-wordcount
```

然后打开 `\themes\next\layout\_partials\footer.swig` 这个文件，在上面加入的博客访客量之前，加入以下代码：

```html
<span class="post-meta-item-text">{# {{ __('post.totalcount') }} #}博客全站共&#58;</span>
<span title="{{ __('post.totalcount') }}">
{##}{{ totalcount(site, '0,0.0a') }} 字&nbsp;|&nbsp;{##}
</span>
```

在页脚就形成了这样的样式：

<div style = "text-align: center;">
    <img src = "busuanzi.png" alt = "busuanzi"></img>
</div>

同时你也会看到在你的每一篇博客中也会有详细的字数统计与阅读时间：

<div style = "text-align: center;">
    <img src = "title.png" alt = "title"></img>
</div>

如果要修改这个样式的话，请打开 `/themes/next/layout/_macro/post.swig` 文件，修改【字数统计】，找到如下代码：

```html
<span title="{{ __('post.wordcount') }}">
    {{ wordcount(post.content) }}
</span>
```

修改为:

```html
<span title="{{ __('post.wordcount') }}">
    {{ wordcount(post.content) }} 字
</span>
```

同理，我们修改【阅读时长】，修改后如下：

```html
<span title="{{ __('post.min2read') }}">
    {{ min2read(post.content) }} 分钟
</span>
```

然后 `hexo clean` 与 `hexo g` 二连即可。

## 侧栏加入已运行的时间

你可以在你的主页侧栏中加入你的博客总运行时间，这样你就可以看着你的博客一天天的长大了~

我们打开 `/themes/next/layout/_custom/sidebar.swig` 文件，加入以下代码：

```html
<div id="days"></div>
<script>
function show_date_time(){
    window.setTimeout("show_date_time()", 1000);
    BirthDay = new Date("05/27/2017 15:13:14");
    today = new Date();
    timeold = (today.getTime() - BirthDay.getTime());
    sectimeold = timeold / 1000
    secondsold = Math.floor(sectimeold);
    msPerDay = 24 * 60 * 60 * 1000
    e_daysold = timeold / msPerDay
    daysold = Math.floor(e_daysold);
    e_hrsold = (e_daysold - daysold) * 24;
    hrsold = setzero(Math.floor(e_hrsold));
    e_minsold = (e_hrsold - hrsold) * 60;
    minsold = setzero(Math.floor((e_hrsold - hrsold) * 60));
    seconds = setzero(Math.floor((e_minsold - minsold) * 60));
    document.getElementById('days').innerHTML= "已运行 " + daysold + " 天 " + hrsold + " 小时 " + minsold + " 分 " + seconds + " 秒";
}
function setzero(i) {
    if (i < 10) {
        i = "0" + i
    };
    return i;
}
show_date_time();
</script>
```

上面 `Date` 的值记得改为你自己的，且按上面格式，然后修改 `/themes/next/layout/_macro/sidebar.swig` 文件，修改如下代码：

```html
{# Blogroll #}
{% if theme.links %}
    <div class="links-of-blogroll motion-element {{ "links-of-blogroll-" + theme.links_layout | default('inline') }}">
        <div class="links-of-blogroll-title">
              <i class="fa  fa-fw fa-{{ theme.links_icon | default('globe') | lower }}"></i>
              {{ theme.links_title }}&nbsp;
              <i class="fa  fa-fw fa-{{ theme.links_icon | default('globe') | lower }}"></i>
        </div>
        <ul class="links-of-blogroll-list">
            {% for name, link in theme.links %}
            <li class="links-of-blogroll-item">
                <a href="{{ link }}" title="{{ name }}" target="_blank">{{ name }}</a>
            </li>
            {% endfor %}
        </ul>
        {% include '../_custom/sidebar.swig' %}
    </div>
{% endif %}

<!--       {% include '../_custom/sidebar.swig' %}   -->
```

这样就可以了！当然，要是不喜欢颜色，感觉不好看，就可以在 `/themes/next/source/css/_custom/custom.styl` 中加入你自己的样式：

```css
/* 自定义的侧栏时间样式 */
#days {
    display: block;
    color: rgb(7, 179, 155);
    font-size: 13px;
    margin-top: 15px;
}
```

然后 `hexo clean` 与 `hexo g` 二连即可。

## 更厉害的设置

### 页面宽度问题

如果你很细心的对你的网页进行缩放，你会发现当你的网页宽度小于一定值时，页脚那里会因为文字换行而变得非常难看，那为什么不这样设置一下？如果页面的宽度小于某个值了，可以让某些文字不再显示，那么就不会导致换行问题的发生了！

打开 `\themes\next\layout\_partials\footer.swig` 这个文件，将刚刚加入的 `博客全站共xxx字` 与 `博客全站共计访客xxx人` 那一部分的代码修改为这样：

```
{% if theme.post_wordcount.totalcount %}
    {# <span class="post-meta-divider"><br/></span> #}
    <br/>
    <span class="post-meta-item-icon">
      <i class="fa fa-font"></i>
    </span>
    {% if theme.post_wordcount.item_text %}
     <span class="post-meta-item-text">{# {{ __('post.totalcount') }} #}博客全站共&#58;</span>
    {% endif %}
    <span title="{{ __('post.totalcount') }}">
    {##}{{ totalcount(site, '0,0.0a') }} 字&nbsp;|&nbsp;{##}
    </span>
{% endif %}
<span class="post-meta-item-icon">
    <i class="fa fa-user"></i>
</span>
<span id="busuanzi_container_site_pv">
    {% if theme.post_wordcount.item_text %}
      <span class="post-meta-item-text">博客全站共计访客&#58;</span>
    {% endif %}
    <span id="busuanzi_value_site_pv"></span> 人
</span>
```

二连之后就会发现，当你的博客在 PC 端以一个正常宽度显示的时候，页脚会是这个样子：

<div style = "text-align: center;">
    <img src = "normal_footer.png" alt = "normal_footer"></img>
</div>

当你使用移动端或将 PC 端页面宽度缩小时，会变成这样：

<div style = "text-align: center;">
    <img src = "mini_footer.png" alt = "mini_footer"></img>
</div>

### 加入备案号

紧接着上一步加入的那些代码，在他们之前，加入以下代码：

```html
{% if theme.post_wordcount.item_text %}
    <span class="post-meta-item-text">
      <span>&nbsp;|&nbsp;
        <span class="post-meta-item-icon">
          <i class="fa fa-search"></i>
        </span> 备案号&#58; <a href = "http://www.beian.miit.gov.cn">陕ICP备xxxxxxxx号</a>
      </span>
    </span>
{% endif %}
```

<div class = "note info">这个已经优化过了，当页面缩小的时候这个备案号直接就会消失掉！</div>

<div class = "note info">可能有一些细心的小伙伴们已经发现了，我们控制它在特定宽度下的显示问题就是利用了 <code>theme.post_wordcount.item_text</code> 这个值，那么你也就可以将它用到其他地方了！</div>

### 博客全站人数显示问题

如果你的服务器加载速度有点堪忧（就像我的学生机一样），那么你刷新页面后迅速看你的 `busuanzi` 统计博客人数，会发现变成了这样（没有图，大家意会一下）：

<div class = "note info">博客全站共计访客：人</div>

直到你的插件加载 OK 之后，才会正常的显示人数，但是这一点足够逼疯一些强迫症患者了，我随即研究了一下它这个显示人数的原理，就是替换掉了那个 `<span>` 标签中的东西，那么我们可以写成这样：

```html
<span id="busuanzi_container_site_pv">
    {% if theme.post_wordcount.item_text %}
      <span class="post-meta-item-text">博客全站共计访客&#58;</span>
    {% endif %}
    <span id="busuanzi_value_site_pv"> ???</span> 人
</span>
```

这样即使我们的插件没有加载好，它也会显示：

<div class = "note info">博客全站共计访客：???人</div>

是不是比之前能看起来更舒服一些了~ 当插件加载好之后会直接替换掉 `???` 转而显示数字，赞！

## 参考文章

- [Yulin Lewis's Blog](https://lewky.cn)
- [打造个性超赞博客 Hexo + NexT + GitHub Pages 的超深度优化](https://io-oi.me/tech/hexo-next-optimization/#)
- [Hexo添加字数统计、阅读时长](https://www.cnblogs.com/php-linux/p/8418518.html)