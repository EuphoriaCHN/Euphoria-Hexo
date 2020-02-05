---
title: 使用jQuery去检测scroll和resize的结束事件
date: 2020-02-05 19:58:09
tags:
- Web
- JavaScript
categories:
- 前端
- 面经
- JavaScript
---

> <span class = 'introduction'>人生的上半场打不好没关系，还有下半场，只要努力。</span><br/>
有时候会遇到这样的业务：需要检测用户对页面的 scroll 或 resize 动作结束时需要触发一个固定的回调函数，但 HTML 只有 `onresize` 或 `onscroll` 这样的方法，这时候就得自己去定义了...

<!--more-->

<hr/>

## 转载来源

<a href="https://stackoverflow.com/questions/3701311/event-when-user-stops-scrolling">https://stackoverflow.com/questions/3701311/event-when-user-stops-scrolling</a>

<hr />

## scroll end

```javascript
$.fn.scrollEnd = function(callback, timeout) {          
  $(this).scroll(function(){
    var $this = $(this);
    if ($this.data('scrollTimeout')) {
      clearTimeout($this.data('scrollTimeout'));
    }
    $this.data('scrollTimeout', setTimeout(callback,timeout));
  });
};
 
// with a 1000ms timeout
$(window).scrollEnd(function(){
    alert('stopped scrolling');
}, 1000);
```

<hr />

## resize end

```javascript
$.fn.resizeEnd = function (callback, timeout) {
    $(this).resize(function () {
        var $this = $(this);
        if ($this.data('resizeTimeout')) {
            clearTimeout($this.data('resizeTimeout'));
        }
        $this.data('resizeTimeout', setTimeout(callback, timeout));
    });
};
 
// with a 800ms timeout
$(document).resizeEnd(function () {
    alert('stopped resizing');
}, 800);
```