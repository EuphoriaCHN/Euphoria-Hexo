---
title: 设置你喜欢的live2d看板娘
date: 2019-09-04 16:49:48
tags:
- Hexo
- Nginx
- NexT
categories:
- Hexo
- NexT
- Live2D
copyright: true
---

<style type="text/css">
.redspan {
    color: red;
}
.quotetitle {
    color: #337ab7;
    font-weight: 700;
}
.purpletitle {
    color: #9954bb;
    font-weight: 700;
}
.italic {
    font-style: italic;
}
.markbutton {
    padding: 3px 5px;
    margin: 0 4px;
    font-size: 16px;
    font-weight: 700;
    color: white;
}
.bgblue {
    background-color: #337ab7;
}
.bgpurple {
    background-color: #9954bb;
}
.bgred {
    background-color: red;
}
td {
    text-align: center;
    vertical-align: bottom;
}
table td img {
    max-height: 320px;
    width: 240px;
}
td, th {
    border: 2px dotted gray;
    font-size: 18px;
}
th {
    background-color: #337ab7;
    color: white;
}
.image-display {
    text-align: center;
    font-size: 16px;
}
.image-display img {
    padding-bottom: 8px;
}
.code {
    text-align: left;
}
</style>

> <span class = 'redspan'>从不浪费时间的人，没有工夫抱怨时间不够。</span><br/>
又在踩了无数次坑后，将我的小看板娘配置好了，在这里我会详细的介绍如何配置 <a>Live 2D 看板娘</a> 与我踩过的那些坑。
那么，现在开始配置属于你自己的 <a>Live 2D 看板娘</a> 吧！（多图警告！）

<!--more-->

<hr/>

## 普通版本
之前在我的 [这篇博客](https://www.wqh4u.cn/2019/07/31/Hexo博客的安装与基本配置/#live2d) 中有提到使用 [这个项目](https://github.com/EYHN/hexo-helper-live2d) 来制作个性化的看板娘，其中一个样式如下：

<div class = "image-display">
    <img src = "./shizuku.gif" alt = "shizuku" style = "max-width: 240px;"></img>
    <p> 可爱的 SHIZUKU </p>
</div>

切换至 `Hexo` 根目录下，在终端中输入以下代码：
```bash
$ npm install -save hexo-helper-live2d
```

编辑 <span class = "markbutton bgblue">站点配置文件</span>：（具体配置见 [官方文档](https://github.com/EYHN/hexo-helper-live2d)）
```yml
live2d:
  enable: true
  scriptFrom: local
  pluginRootPath: live2dw/
  pluginJsPath: lib/
  pluginModelPath: assets/
  model:
    use: live2d-widget-model-wanko
  display:
    position: right
    width: 150
    height: 300
  mobile:
    show: true
```

你可以在 [这里](https://github.com/xiazeyu/live2d-widget-models) 找到非常多的 <a>MODEL</a>：

<div class = "image-display">
    <img src = "./models.jpg" alt = "models"></img>
    <p>所有的 <a>Live 2D</a> MODELS</p>
</div>

我尝试配置了一些 <span class = "markbutton bgblue">MODELS</span> 并且做了截图，各位大佬们不用一个个的去试了：

<table style = "margin: 0 auto; max-width: 100%;">
    <tr>
        <td>
            <img src = "./chitose.jpg" alt = "chitose"></img>
            <hr/>
            <p> ChiToSe </p>
        </td>
        <td>
            <img src = "./Epsilon2.1.png" alt = "Epsilon2.1"></img>
            <hr/>
            <p> Epsilon2.1 </p>
        </td>
        <td>
            <img src = "./Gantzert_Felixander.png" alt = "Gantzert_Felixander"></img>
            <hr/>
            <p> Gantzert_Felixander </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./haru.png" alt = "haru"></img>
            <hr/>
            <p> HaRu </p>
        </td>
        <td>
            <img src = "./haruto.png" alt = "haruto"></img>
            <hr/>
            <p> HaRuTo </p>
        </td>
        <td>
            <img src = "./hibiki.png" alt = "hibiki" style = "width: 150px"></img>
            <hr/>
            <p> HiBiKi </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./hijiki.png" alt = "hijiki"></img>
            <hr/>
            <p> HiJiKi </p>
        </td>
        <td>
            <img src = "./izumi.jpg" alt = "izumi"></img>
            <hr/>
            <p> IZuMi </p>
        </td>
        <td>
            <img src = "./koharu.png" alt = "koharu"></img>
            <hr/>
            <p> KoHaRu </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./miku.png" alt = "miku"></img>
            <hr/>
            <p> MiKu </p>
        </td>
        <td>
            <img src = "./nico.png" alt = "nico"></img>
            <hr/>
            <p> NiCo </p>
        </td>
        <td>
            <img src = "./nietzche.png" alt = "nietzche"></img>
            <hr/>
            <p> Nietzche </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./ni-j.png" alt = "ni-j"></img>
            <hr/>
            <p> NI-J </p>
        </td>
        <td>
            <img src = "./nipsilon.png" alt = "nipsilon"></img>
            <hr/>
            <p> Nipsilon </p>
        </td>
        <td>
            <img src = "./nito.png" alt = "nito"></img>
            <hr/>
            <p> Nito </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./shizuku.png" alt = "shizuku"></img>
            <hr/>
            <p> ShiZuKu </p>
        </td>
        <td>
            <img src = "./tororo.png" alt = "tororo"></img>
            <hr/>
            <p> ToRoRo </p>
        </td>
        <td>
            <img src = "./tsumiki.png" alt = "tsumiki" style = "width: 220px;"></img>
            <hr/>
            <p> TsuMiKi </p>
        </td>
    </tr>
    <tr>
        <td>
            <img src = "./Unitychan.png" alt = "Unitychan"></img>
            <hr/>
            <p> Unitychan </p>
        </td>
        <td>
            <img src = "./wanko.png" alt = "wanko"></img>
            <hr/>
            <p> wanko </p>
        </td>
        <td>
            <img src = "./z16.png" alt = "z16"></img>
            <hr/>
            <p> Z16 </p>
        </td>
    </tr>
</table>

<del>（是不是还是感觉 ShiZuKu 还是最好看呢2333...）</del>

<hr/>

## 进阶版本

> 什么？你想要一个 <span class = "markbutton bgblue">能说话</span>、<span class = "markbutton bgblue">能互动</span>、<span class = "markbutton bgblue">能玩游戏</span>、<span class = "markbutton bgblue">能换装</span>的看板娘？<del>呵~</del>

感谢 [张书樵大神](https://zhangshuqiao.org) 的 [Live2D项目](https://github.com/stevenjoezhang/live2d-widget)，让你可以实现你的愿望。

首先，`clone` 项目到你的本地（或你的 `Hexo` 根目录下）：

```bash
git clone https://github.com/stevenjoezhang/live2d-widget
```

> 如果你是在你的 `Hexo` 下配置的，请将项目文件解压至 `你的Hexo根目录/source/live2d-widget/` 下（没有 `live2d-widget` 请手动创建）

如果你想自定义你的看板娘 <span class = "markbutton bgpurple">初始加载模型</span> 或者 <span class = "markbutton bgpurple">互动话语</span> 的话，首先修改 <span class = "markbutton bgblue">live2d-widget</span> 目录下的 <span class = "markbutton bgblue">autoload.js</span> 文件，将：

```javascript
const live2d_path = "https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget/";
// const live2d_path = "/live2d-widget/";
```

改为：

```javascript
// const live2d_path = "https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget/";
const live2d_path = "/live2d-widget/";
```

随后，在 `你的Hexo根目录/themes/next/layout/_layout.swing` 中，`</body>` 之前，增加以下内容：

```html
<script src="/live2d-widget/autoload.js"></script>
```

在 `</head>` 之前，增加以下内容：
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome/css/font-awesome.min.css">
```

在你的 <span class = "markbutton bgpurple">主题配置文件</span> 中，新增以下内容：

```yml
live2d:
  enable: true
```

> 如果你已经使用了 `普通版本` 的 `Live 2D`，请将其他无关属性注释掉！

如果你想自定义看板娘大小、位置或者其他样式，请修改 <span class = "markbutton bgblue">waifu.css</span>

如果你想自定义看板娘言语互动，请修改 <span class = "markbutton bgblue">waifu-tips.js</span> 和 <span class = "markbutton bgblue">waifu-tips.json</span>

<hr/>

## 高级版本中我所踩的那些坑

### jQuery加载失败

时刻注意着你的 `Console`，如果出现了找不到符号 `$`，因为首先加载的 <span class = "markbutton bgblue">autoload.js</span>，里面第一个干的事情就是通过 `Ajax` 去请求 <span class = "markbutton bgblue">live2d.min.js</span> 与 <span class = "markbutton bgblue">waifu-tips.js</span>，所以要保证你已经导入了 `jQuery` 库，如果没有的话请在 `你的Hexo根目录/themes/next/layout/_layout.swing` 中，`</head>` 标签前，手动导入 `jQuery`。

### loadlive2d方法未定义

在你的 <span class = "markbutton bgblue">autoload.js</span> 文件中，将加载 <span class = "markbutton bgblue">live2d.min.js</span> 那一段的 `URL` 请求改为：

```javascript
// 上面省略
url: "https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget/live2d.min.js",
// 下面省略
```

### CROS跨域请求失败

因为 <del>人尽皆知</del> 的原因，在 <span class = "markbutton bgblue">waifu-tips.js</span> 中第 `162` 行向目标发起了一个 `getJSON` 请求你的目标文件 <span class = "markbutton bgblue">waifu-tips.json</span>，这里会出现问题，需要你去设置跨域请求头。

我是用的 `Nginx` 来部署博客的，所以就用 `Nginx` 举例：

在你的 `Nginx` 网站配置文件中，在你的服务里面，添加如下代码：

```bash
add_header 'Access-Control-Allow-Origin' '*';
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
```

然后重启你的 `Nginx` 服务即可解决。

### 奇奇怪怪的问题

使用 `hexo g` 后，在你的 `/public/` 文件夹中会生成一个 `/live2d-widget/` 文件，其中 <span class = "markbutton bgblue">waifu-tips.js</span> 会有一些莫名其妙的问题，你需要将你的 `Hexo/source/live2d-widget/waifu-tips.js` 复制粘贴覆盖掉 `public` 目录下那个有问题的文件中的内容。同理，<span class = "markbutton bgblue">waifu-tips.json</span> 也会有一些奇奇怪怪的问题，也需要你手动的去覆盖一次。

P.S.觉得麻烦的可以写一个 `bash` 脚本，代码大致如下：

```bash
#!/bin/bash
hexo clean
hexo g
rm ./public/live2d-widget/waifu-tips.js
rm ./public/live2d-widget/waifu-tips.json
cp ./source/live2d-widget/waifu-tips.js ./public/live2d-widget/
cp ./source/live2d-widget/waifu-tips.json ./public/live2d-widget/
echo OK
```

然后就可以一键生成辽~
