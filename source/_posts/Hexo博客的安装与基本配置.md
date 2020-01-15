---
title: Hexo博客的安装与基本配置
date: 2019-07-31 22:54:59
tags:
- Hexo
- 建站
- Nginx
- NexT
categories:
- Hexo
copyright: true
---

<style type = "text/css">
.quotetitle {
    color: #337ab7;
    font-weight: 700;
}

.redspan {
    color: #ff0000;
}

.italic {
    font-style: italic;
}

</style>

> <span class = 'introduction'>不先经历风雨，怎能见彩虹？</span><br/>
在经历了无数次失败后，终于将我的 [Hexo](https://hexo.io/) 配置到了自己能看得过去的样子。<br/>特此写下 Blog 为更多想了解 Hexo 的人阅读使用。

<!--more-->

<hr/>

## 环境搭建
### 本人环境配置：
- 服务器：腾讯云学生机，`Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-29-generic x86_64)`
- Node.js：在 Hexo 的[官方文档](https://hexo.io/zh-cn/docs/)里面有说，`Node.js` 的版本不得低于 `6.9`，这里提供两种安装 `Node.js` 的方式：

cURL：
``` bash
$ curl https://raw.github.com/creationix/nvm/v0.33.11/install.sh | sh
```
Wget：
``` bash
$ wget -qO- https://raw.github.com/creationix/nvm/v0.33.11/install.sh | sh
```
安装完成后，重启终端并执行下列命令即可安装 Node.js。
``` bash
$ nvm install stable
```
或者可以在 `Node.js` 的官网上[下载安装](https://nodejs.org/en/)。

> <span class = "quotetitle">Windows用户</span><br/>
对于 windows 用户来说，建议使用安装程序进行安装。安装时，请勾选 Add to PATH 选项。
另外，您也可以使用 Git Bash，这是 git for windows 自带的一组程序，提供了 Linux 风格的 shell，在该环境下，您可以直接用上面提到的命令来安装 Node.js。打开它的方法很简单，在任意位置单击右键，选择 “Git Bash Here” 即可。由于 Hexo 的很多操作都涉及到命令行，您可以考虑始终使用 Git Bash 来进行操作。

- Git：我的 `Git` 版本为 *`git version 2.17.1`* 

这里使用 `Ubuntu` 或 `Debian` 系的：
``` bash
$ sudo apt-get install git-core
```
或者使用 `Fedora`、`红帽`或者 `CentOS`：
``` bash
$ sudo yum install git-core
```
像 `Arch Linux` 等其他发行版请自行善用包管理器进行安装。

> <span class = "quotetitle">Windows用户</span><br/>
由于~~众所周知~~的原因，从上面的链接下载 git for windows 最好挂上一个代理，否则下载速度十分缓慢。也可以参考[这里](https://github.com/waylau/git-for-win)，收录了存储于百度云的下载地址。

### 开始安装
现在我们开始安装 `Hexo`：
``` bash
$ npm install -g hexo-cli
```
如果发现下载奇慢，那么请首先更换你的 npm 源：
``` bash
$ npm config set registry https://registry.npm.taobao.org
```

<hr/>

## 开始使用
### 初始化 Hexo
安装 `Hexo` 完成后，请执行下列命令，`Hexo` 将会在指定文件夹中新建所需要的文件。
``` bash
$ hexo init <folder>
$ cd <folder>
```
其中，**`<folder>`** 就是你要在哪个路径下安装 `Hexo`，比如 `/home/ubuntu/hexo/`。
新建完成后，指定文件夹的目录如下：
``` bash
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└── themes
```
详细说明如下：
> 1. `_config.yml` 是 YAML 格式文件，也是 Hexo 的站点 **重要配置文件** ，以后很多的自定义配置都要修改这个文件。
> 2. package.json 配置 Hexo 运行需要的 Node.js 包，不用手动更改。
> 3. scaffolds 是模板文件夹。这个“模板”就是指新建的 markdown 文件的模板，每新建一个 markdown 文件（由于 Hexo 使用 markdown 语法，在渲染生成静态 HTML 页面之前，源文件都是 markdown 文件），就会包含对应模板的内容。 
该文件夹内有三个模板： 
> - draft.md --- 草稿的模板 
> - page.md --- 页面的模板 
> - post.md --- 文章的模板
> 4. source 是资源文件夹，资源文件夹是存放用户资源的地方。除 posts 文件夹之外，开头命名为 (下划线)的文件 / 文件夹和隐藏的文件将会被忽略。Markdown 和 HTML 文件会被解析并放到 public 文件夹，而其他文件会被拷贝过去。 
> 5. themes 是主题文件夹。Hexo 会根据主题来生成静态页面。

### 初次运行Hexo
输入 <span class = 'redspan italic'>hexo generate</span> 命令来生成静态文件。
> <span class = "quotetitle">注意！</span><br/>
1：生成的静态文件存放在 public 文件夹中<br/> 
2：此命令可简写为 *`hexo g`*

然后输入 <span class = 'redspan italic'>hexo server</span> (可简写为 *`hexo s`*)来启动服务器。

默认情况下，端口号为 4000，所以服务器启动成功后，在浏览器中输入 `http://<你的IP地址>:4000` ，即可看到第一次运行的状况。

和 Django 一样，按 *`Ctrl + c`* 结束服务。

> <span class = "quotetitle">注意！</span><br/>
如果运行时没有报任何错误，但是浏览器中显示网页无法访问，可能是你的服务器安全组没有配置，像腾讯云或者阿里云都需要配置端口安全组策略，请先去设置 4000 端口开放形式，再运行 Hexo 服务。

<hr/>

## 安装并配置Nginx
安装 `Nginx` 主要是想让网站能随时随地访问，不像上文中 Hexo 提供的 server，只能手动输入命令后才能访问到网站。
### 安装Nginx
在 `Ubuntu` 上安装 `Nginx` 方法很简单：
``` bash
$ sudo apt install nginx
```
#### 配置防火墙
如果您正在运行防火墙，则还需要打开端口 `80` 和 `443`：
``` bash
$ sudo ufw allow 'Nginx Full'
```
### 启动Nginx服务
``` bash
$ sudo systemctl start nginx
```
此时，用浏览器访问 `http://<你的IP地址>` 便可以看到 `Nginx` 的测试页面，即表示 `Nginx` 启动成功！

继续输入以下命令使 `Nginx` 开机自动启动：
``` bash
$ systemctl enable nginx
```

<hr/>

## 配置静态服务器访问路径
`Nginx` 需要配置静态资源的路径信息才能通过 `url` 正确访问到服务器上的静态资源。 <br/>
即是要将 `Hexo` 生成的静态资源的路径放置到 `Nginx` 的访问路径

打开 `Nginx` 的默认配置文件 `/etc/nginx/nginx.conf` ，将默认的 `root /usr/share/nginx/html` 修改为： `root /…/<folder>/public`，里面的 `<folder>` 就是你刚刚Hexo安装的文件夹。

修改完成后保存，输入以下命令重启 `Nginx`：
```bash
$ nginx -s reload
```
此时再次访问你的 IP 地址，若显示上文的 `Hexo` 初次运行的样子，则说明配置成功。

> <span class = "quotetitle">注意！</span><br/>
可能会报 403 错误，原因是 Nginx 没有权限访问 public文件夹，修改方法有两种： <br/>
1：修改 public 文件夹的权限，修改为 777（即任何人可读可写可执行），不推荐； <br/>
2：修改 nginx.conf 中的 user（可能在第5行），改为可以访问 public文件夹的用户，如 root。

## 配置Hexo
### 站点配置
配置 Hexo 时，需要修改上文提到的根目录下的 `_config.yml` 文件，主要修改的就是这部分：
``` yml
# Site
title: Euphoria Blog      # 网站标题
subtitle:                 # 网站副标题
description:              # 网站描述，可以是你喜欢的一句话 :)
keywords: Euphoria        # 网站关键词  
author: Euphoria          # 你的名字
language: zh-CN           # 网站使用的语言
timezone:                 # 网站时区，默认使用服务器的时区
```
其余的文件内容可以使用默认值，萌新可不必修改，具体参见[官方文档](https://hexo.io/zh-cn/docs/configuration.html)。

> <span class = "quotetitle">注意！</span><br/>
修改yml文件时应注意“:”后面应加空格。

## 配置主题
Hexo 安装主题的方式非常简单，只需要将主题文件拷贝至站点目录的 `themes` 目录下，你可以在[这里](https://hexo.io/themes/)寻找你喜欢的主题，然后修改下配置文件即可。

在 Hexo 中有两份主要的配置文件，其名称都是 `_config.yml`。 其中，一份位于站点根目录下，主要包含 Hexo 本身的配置；另一份位于主题目录下，这份配置由主题作者提供，主要用于配置主题相关的选项。

为了描述方便，在以下说明中，将前者称为 <span class = "blue-target">站点配置文件</span>， 后者称为 <span class = "purple-target">主题配置文件</span>。

这里我强烈推荐 `NexT` 这款主题，接下来为安装及其配置方法：

### 安装 NexT
如果你熟悉 Git，建议你使用 `克隆最新版本` 的方式，之后的更新可以通过 `git pull` 来快速更新， 而不用再次下载压缩包替换。

在终端窗口下，定位到 Hexo 站点目录下。使用 `Git checkout` 代码：
```bash
$ cd your-hexo-site
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

### 启用主题
与所有 `Hexo` 主题启用的模式一样。 当 `克隆/下载` 完成后，打开 <span class = "blue-target">站点配置文件</span>， 找到 `theme` 字段，并将其值更改为 `next`。
```yml
theme: next
```
到此，NexT 主题安装完成。下一步我们将验证主题是否正确启用。在切换主题之后、验证之前， 我们最好使用 `hexo clean` 来清除 Hexo 的缓存。

### 个性化主题
#### 选择 Scheme
Scheme 是 NexT 提供的一种特性，借助于 Scheme，NexT 为你提供多种不同的外观。同时，几乎所有的配置都可以 在 Scheme 之间共用。目前 NexT 支持三种 Scheme，他们是：

- Muse - 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白
- Mist - Muse 的紧凑版本，整洁有序的单栏外观
- Pisces - 双栏 Scheme，小家碧玉似的清新

Scheme 的切换通过更改 <span class = "purple-target">主题配置文件</span>，搜索 scheme 关键字。 你会看到有三行 scheme 的配置，将你需用启用的 scheme 前面注释 # 去除即可。
```yml
# scheme: Muse
scheme: Mist
# scheme: Pisces
```
#### 设置语言
编辑 <span class = "blue-target">站点配置文件</span>， 将 `language` 设置成你所需要的语言。建议明确设置你所需要的语言，例如选用简体中文，配置如下：
```yml
language: zh-Hans
```
目前 NexT 支持的语言如以下表格所示：

|语言|代码|设定示例|
|:--|:--|:------|
|English|en|language: en|
|简体中文|zh-Hans|language: zh-Hans|
|Français|fr-FR|language: fr-FR|
|Português|pt|language: pt or language: pt-BR|
|繁體中文|zh-hk 或者 zh-tw|language: zh-hk|
|Русский язык|ru|language: ru|
|Deutsch|de|language: de|
|日本語|ja|language: ja|
|Indonesian|id|language: id|
|Korean|ko|language: ko|

#### 设置菜单
菜单配置包括三个部分，第一是菜单项（名称和链接），第二是菜单项的显示文本，第三是菜单项对应的图标。 NexT 使用的是 [Font Awesome](https://fontawesome.com/?from=io) 提供的图标， Font Awesome 提供了 600+ 的图标，可以满足绝大的多数的场景，同时无须担心在 Retina 屏幕下 图标模糊的问题。

编辑 <span class = "purple-target">主题配置文件</span>，修改以下内容：

1. 设定菜单内容，对应的字段是 `menu`。 菜单内容的设置格式是：`item name: link`。其中 `item name` 是一个名称，这个名称并不直接显示在页面上，她将用于匹配图标以及翻译。
    ```yml
    menu:
     home: /
     archives: /archives
     #about: /about
     #categories: /categories
     tags: /tags
     #commonweal: /404.html
    ```
    > <span class = "quotetitle">注意！</span><br/>
    若你的站点运行在子目录中，请将链接前缀的 / 去掉！
    
    NexT 默认的菜单项有（标注 * 的项表示需要手动创建这个页面）：
    
    |键值|设定值|显示文本（简体中文）|
    |:--|:----|:------------------|
    |home|home: /|主页|
    |archives|archives: /archives|归档页|
    |categories|categories: /categories|分类页 |
    |tags|tags: /tags|标签页 |
    |about|about: /about|关于页面 |
    |commonweal|commonweal: /404.html|公益 404 |
2. 设置菜单项的显示文本。在第一步中设置的菜单的名称并不直接用于界面上的展示。Hexo 在生成的时候将使用 这个名称查找对应的语言翻译，并提取显示文本。这些翻译文本放置在 NexT 主题目录下的 `languages/{language}.yml` （{language} 为你所使用的语言）。

    以简体中文为例，若你需要添加一个菜单项，比如 `something`。那么就需要修改简体中文对应的翻译文件 `languages/zh-Hans.yml`，在 `menu` 字段下添加一项：
    ```yml
    menu:
      home: 首页
      archives: 归档
      categories: 分类
      tags: 标签
      about: 关于
      search: 搜索
      commonweal: 公益404
      something: 有料
    ```
3. 设定菜单项的图标，对应的字段是 `menu_icons`。 此设定格式是 `item name: icon name`，其中 `item name` 与上一步所配置的菜单名字对应，`icon name` 是 **Font Awesome** 图标的 **名字**。而 `enable` 可用于控制是否显示图标，你可以设置成 `false` 来去掉图标。
    ```yml
    menu_icons:
      enable: true
      # Icon Mapping.
      home: home
      about: user
      categories: th
      tags: tags
      archives: archive
      commonweal: heartbeat
    ```
    > <span class = "quotetitle">注意！</span><br/>
    1: 在菜单图标开启的情况下，如果菜单项与菜单未匹配（没有设置或者无效的 **Font Awesome** 图标名字） 的情况下，NexT 将会使用 **?** 作为图标。<br/>
    2: 请注意键值（如 `home`）的大小写要严格匹配。
    
#### 设置侧栏
默认情况下，侧栏仅在文章页面（拥有目录列表）时才显示，并放置于右侧位置。 可以通过修改 <span class = "purple-target">主题配置文件</span> 中的 `sidebar` 字段来控制侧栏的行为。侧栏的设置包括两个部分，其一是侧栏的位置， 其二是侧栏显示的时机。
1. 设置侧栏的位置，修改 `sidebar.position` 的值，支持的选项有：
    - left - 靠左放置
    - right - 靠右放置
    > <span class = "quotetitle">注意！</span><br/>
    目前仅 Pisces Scheme 支持 position 配置。影响版本 <span class = "red-target">5.0.0</span> 及更低版本。
    ```yml
    sidebar:
      position: left
    ```
2. 设置侧栏显示的时机，修改 sidebar.display 的值，支持的选项有：
    - post - 默认行为，在文章页面（拥有目录列表）时显示
    - always - 在所有页面中都显示
    - hide - 在所有页面中都隐藏（可以手动展开）
    - remove - 完全移除
    ```yml
    sidebar:
      display: post
    ```
    > <span class = "quotetitle">注意！</span><br/>
    已知侧栏在 use motion: false 的情况下不会展示。影响版本 <span class = "red-target">5.0.0</span> 及更低版本。
    
#### 设置头像
编辑 <span class = "purple-target">主题配置文件</span>， 修改字段 `avatar`， 值设置成头像的链接地址。其中，头像的链接地址可以是：

|地址|值|
|:--|:--|
|完整的互联网 URI|http://example.com/avatar.png|
|站点内的地址	|将头像放置主题目录下的 source/uploads/ （新建 uploads 目录若不存在）<br/>配置为：avatar: /uploads/avatar.png<br/>或者 放置在 source/images/ 目录下<br/>配置为：avatar: /images/avatar.png|

```yml
avatar: http://example.com/avatar.png
```

#### 设置代码高亮主题
NexT 使用 [Tomorrow Theme](https://github.com/chriskempson/tomorrow-theme) 作为代码高亮，共有5款主题供你选择。 NexT 默认使用的是白色的 `normal` 主题，可选的值有 `normal`，`night`， `night blue`， `night bright`， `night eighties`：
<div>
<img src="./tomorrow.png" style="width: 19%; display: inline-block; float: left" alt="tomorrow.png"/>
<img src="./tomorrow-night.png" style="width: 19%; display: inline-block; float: left" alt="tomorrow-night.png"/>
<img src="./tomorrow-night-blue.png" style="width: 19%; display: inline-block; float: left" alt="tomorrow-night-blue.png"/>
<img src="./tomorrow-night-bright.png" style="width: 19%; display: inline-block; float: left" alt="tomorrow-night-bright.png"/>
<img src="./tomorrow-night-eighties.png" style="width: 19%; display: inline-block; float: left" alt="tomorrow-night-eighties.png"/>
</div>
<div style = "clear: both;"></div>
更改 <span class = "purple-target">主题配置文件</span> 中 `highlight_theme` 字段，将其值设定成你所喜爱的高亮主题，例如：

```yml
# Code Highlight theme
# Available value: normal | night | night eighties | night blue | night bright
# https://github.com/chriskempson/tomorrow-theme
highlight_theme: normal
```

#### 侧边栏社交链接
侧栏社交链接的修改包含两个部分，第一是链接，第二是链接图标。 两者配置均在 <span class = "purple-target">主题配置文件</span> 中。
1. 链接放置在 `social` 字段下，一行一个链接。其键值格式是 `显示文本: 链接地址`。
    ```yml
    # Social links
    social:
      GitHub: https://github.com/your-user-name
      Twitter: https://twitter.com/your-user-name
      微博: http://weibo.com/your-user-name
      豆瓣: http://douban.com/people/your-user-name
      知乎: http://www.zhihu.com/people/your-user-name
      # 等等...
    ```
2. 设定链接的图标，对应的字段是 `social_icons`。其键值格式是 匹配键: **Font Awesome** 图标名称， 匹配键 与上一步所配置的链接的 显示文本 相同（大小写严格匹配），图标名称 是 **Font Awesome** 图标的名字（不必带 fa- 前缀）。 `enable` 选项用于控制是否显示图标，你可以设置成 `false` 来去掉图标。
    ```yml
    # Social Icons
    social_icons:
      enable: true
      # Icon Mappings
      GitHub: github
      Twitter: twitter
      微博: weibo
    ```
    
#### 开启打赏功能 <sub>由 <a href="https://github.com/iissnan/hexo-theme-next/pull/687">habren</a> 贡献</sub>
越来越多的平台（微信公众平台，新浪微博，简书，百度打赏等）支持打赏功能，付费阅读时代越来越近，特此增加了打赏功能，支持微信打赏和支付宝打赏。 只需要 <span class = "purple-target">主题配置文件</span> 中填入 `微信` 和 `支付宝` 收款二维码图片地址，即可开启该功能。
```yml
reward_comment: 坚持原创技术分享，您的支持将鼓励我继续创作！
wechatpay: /path/to/wechat-reward-image
alipay: /path/to/alipay-reward-image
```

#### 站点建立时间
这个时间将在站点的底部显示，例如 © 2013 - 2015。 编辑 <span class = "purple-target">主题配置文件</span>，新增字段 `since`。
```yml
since: 2013
```

#### 实现 fork me on github
点击 [这里](https://github.com/blog/273-github-ribbons) 或者 [这里](http://tholman.com/github-corners/) 挑选自己喜欢的样式，并复制旁边的对应代码。

然后粘贴刚才复制的代码到 `themes/next/layout/_layout.swig` 文件中(放在 `<div class="headband"></div>` 的下面)，并把 `href` 改为你的 `github` 地址，比如 `https://github.com/euphoriachn`。

<img src="./fork-on-github.png" alt="fork-on-github.png"/>

#### 添加动态背景
> <span class = "quotetitle">注意！</span><br/>
如果 `NexT` 主题在 <span class = "red-target">5.1.1</span> 以上的话就不用我这样设置，直接在主题配置文件中找到 `canvas_nest: false`，把它改为 `canvas_nest: true` 就行了（注意分号后面要加一个空格）。如果发现这样并不行 ~~（像我一样）~~，或者版本低于 `5.1.1` 的话，请按照如下操作进行。

1. 修改 `_layout.swig`

    打开 `next/layout/_layout.swig`
    在 `</body>` 之前添加代码（注意不要放在 `</body>` 的后面）
    ```html
    {# TODO: Euphoria #}
    {% if theme.canvas_nest %}
        <script type="text/javascript" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
    {% endif %}
    ```
    
2. 修改配置文件
    打开 `/next/_config.yml`，在里面添加如下代码：(可以放在最后面)
    ```yml
    # --------------------------------------------------------------
    # background settings
    # --------------------------------------------------------------
    # add canvas-nest effect
    # see detail from https://github.com/hustcc/canvas-nest.js
    canvas_nest: true
    ```
    
3. 试试 `hexo clean` 然后 `hexo g`，最后访问你的个人博客，就能看到效果了~

#### 修改文章内链接文本样式
修改文件 `themes\next\source\css\_common\components\post\post.styl`，在末尾添加如下 `css` 样式：
```css
// 文章内链接文本样式
.post-body p a{
  color: #0593d3;
  border-bottom: none;
  border-bottom: 1px solid #0593d3;
  &:hover {
    color: #fc6423;
    border-bottom: none;
    border-bottom: 1px solid #fc6423;
  }
}
```
其中选择 `.post-body` 是为了不影响标题，选择 `p` 是为了不影响首页 “阅读全文” 的显示样式，颜色可以自己定义。

#### 修改文章底部的那个带 # 号的标签
修改模板 `/themes/next/layout/_macro/post.swig`，搜索 `rel="tag">#`，将 `#` 换成 `<i class="fa fa-tag"></i>` 即可，你也可以在 **Font Awesome** 上寻找自己喜欢的图标。

#### 在每篇文章末尾统一添加 “本文结束” 标记
在路径 `\themes\next\layout\_macro` 中新建 `passage-end-tag.swig` 文件,并添加以下内容：
```html
<div>
    {% if not is_index %}
        <div style="text-align:center;color: #ccc;font-size:14px;">-------------本文结束<i class="fa fa-paw"></i>感谢您的阅读-------------</div>
    {% endif %}
</div>
```
接着打开 `\themes\next\layout\_macro\post.swig` 文件，在 `END POST BODY` 之前添加如下画红色部分代码：
```html
<div>
  {% if not is_index %}
    {% include 'passage-end-tag.swig' %}
  {% endif %}
</div>
```
就像这样：
<img src="./thanks.png" alt="thanks.png"/>

然后打开 <span class="purple-target">主题配置文件</span>，在末尾添加：
```yml
# 文章末尾添加“本文结束”标记
passage_end_tag:
  enabled: true
```

#### 修改``代码块自定义样式
打开 `\themes\next\source\css\_custom\custom.styl`，向里面加入如下代码：(颜色可以自己定义)
```css
// Custom styles.
code {
    color: #ff7600;
    background: #fbf7f8;
    margin: 2px;
}
// 大代码块的自定义样式
.highlight, pre {
    margin: 5px 0;
    padding: 5px;
    border-radius: 3px;
}
.highlight, code, pre {
    border: 1px solid #d6d6d6;
}
```

#### 侧边栏社交小图标设置
打开 <span class="purple-target">主题配置文件</span>，搜索 `social_icons:`，在 **Font Awesome** 图标库找自己喜欢的小图标，并将名字复制在如下位置，保存即可。

<img src="./social-links.png" alt="social-links.png"/>

#### 主页文章添加阴影效果
打开 `\themes\next\source\css\_custom\custom.styl`，向里面加入如下代码：
```css
// 主页文章添加阴影效果
 .post {
   margin-top: 60px;
   margin-bottom: 60px;
   padding: 25px;
   -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5);
   -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5);
  }
```

#### 设置网站的图标 Favicon
你可以在 [EasyIcon](https://www.easyicon.net/) 中找一张 **（32*32）** 的 `ico` 图标，或者去别的网站下载或者制作，并将图标名称改为 `favicon.ico`，然后把图标放在 `/themes/next/source/images` 里，并且修改 <span class="purple-target">主题配置文件</span>：
```yml
# Put your favicon.ico into `hexo-site/source/` directory.
favicon: /favicon.ico
```

#### 在文章底部增加版权信息
在目录 `next/layout/_macro/` 下添加 `my-copyright.swig`：
```html
{% if page.copyright %}
<div class="my_post_copyright">
  <script src="//cdn.bootcss.com/clipboard.js/1.5.10/clipboard.min.js"></script>
  
  <!-- JS库 sweetalert 可修改路径 -->
  <script src="https://cdn.bootcss.com/jquery/2.0.0/jquery.min.js"></script>
  <script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
  <p><span>本文标题:</span><a href="{{ url_for(page.path) }}">{{ page.title }}</a></p>
  <p><span>文章作者:</span><a href="/" title="访问 {{ theme.author }} 的个人博客">{{ theme.author }}</a></p>
  <p><span>发布时间:</span>{{ page.date.format("YYYY年MM月DD日 - HH:mm") }}</p>
  <p><span>最后更新:</span>{{ page.updated.format("YYYY年MM月DD日 - HH:mm") }}</p>
  <p><span>原始链接:</span><a href="{{ url_for(page.path) }}" title="{{ page.title }}">{{ page.permalink }}</a>
    <span class="copy-path"  title="点击复制文章链接"><i class="fa fa-clipboard" data-clipboard-text="{{ page.permalink }}"  aria-label="复制成功！"></i></span>
  </p>
  <p><span>许可协议:</span><i class="fa fa-creative-commons"></i> <a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" title="Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)">署名-非商业性使用-禁止演绎 4.0 国际</a> 转载请保留原文链接及作者。</p>  
</div>
<script> 
    var clipboard = new Clipboard('.fa-clipboard');
    $(".fa-clipboard").click(function(){
      clipboard.on('success', function(){
        swal({   
          title: "",   
          text: '复制成功',
          icon: "success", 
          showConfirmButton: true
          });
	});
    });  
</script>
{% endif %}
```
在目录 `next/source/css/_common/components/post/` 下添加 `my-post-copyright.styl`：
```css
.my_post_copyright {
  width: 85%;
  max-width: 45em;
  margin: 2.8em auto 0;
  padding: 0.5em 1.0em;
  border: 1px solid #d3d3d3;
  font-size: 0.93rem;
  line-height: 1.6em;
  word-break: break-all;
  background: rgba(255,255,255,0.4);
}
.my_post_copyright p{margin:0;}
.my_post_copyright span {
  display: inline-block;
  width: 5.2em;
  color: #b5b5b5;
  font-weight: bold;
}
.my_post_copyright .raw {
  margin-left: 1em;
  width: 5em;
}
.my_post_copyright a {
  color: #808080;
  border-bottom:0;
}
.my_post_copyright a:hover {
  color: #a3d2a3;
  text-decoration: underline;
}
.my_post_copyright:hover .fa-clipboard {
  color: #000;
}
.my_post_copyright .post-url:hover {
  font-weight: normal;
}
.my_post_copyright .copy-path {
  margin-left: 1em;
  width: 1em;
  +mobile(){display:none;}
}
.my_post_copyright .copy-path:hover {
  color: #808080;
  cursor: pointer;
}
```
修改 `next/layout/_macro/post.swig`，在之前添加 **底部阅读完毕** 代码中，再添加如下代码：
```html
{% include 'my-copyright.swig' %}
```
如图所示：
<img src="./my-copyright.png" alt="my-copyright.png"/>
修改 `next/source/css/_common/components/post/post.styl` 文件，在最后一行增加代码：
``` css
@import "my-post-copyright"
```
如果要在该博文下面增加版权信息的显示，需要在 **Markdown** 中增加 `copyright: true` 的设置，如图所示：

<img src="./show-copyright.png" alt="show-copyright.png"/>

#### 隐藏网页底部 powered By Hexo / 强力驱动
打开 `themes/next/layout/_partials/footer.swig`，隐藏之间的代码即可，或者直接删除。位置如图：
<img src="./hide-hexo.png" alt="hide-hexo.png"/>

#### <a name = "live2d" style="cursor: default; color: #fff; border-bottom: none; :hover {color: #fff; border-bottom: none;}">添加 Live 2D 小宠物</a>
切换至 `Hexo` 根目录下，在终端中输入以下代码：
```bash
$ npm install -save hexo-helper-live2d
```

编辑 <span class = "blue-target">站点配置文件</span>：（具体配置见 [官方文档](https://github.com/EYHN/hexo-helper-live2d)）
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

我的 [这一篇博客](https://www.wqh4u.cn/2019/09/04/%E8%AE%BE%E7%BD%AE%E4%BD%A0%E5%96%9C%E6%AC%A2%E7%9A%84live2d%E7%9C%8B%E6%9D%BF%E5%A8%98/) 中写了一些关于 <span class = "blue-target">Live 2D</span> 的一些进阶设置，感兴趣的看官可以参考一下。

> 完~

## 参考文献
1. [文档 | Hexo](https://hexo.io/zh-cn/docs/)
2. [Themes | Hexo](https://hexo.io/themes/)
3. [开始使用 - NexT 使用文档](http://theme-next.iissnan.com/getting-started.html)
4. [结合hexo在GitHub上搭建个人博客——全过程](https://www.cnblogs.com/trista222/p/8017300.html)
5. [阿里云CentOS下Hexo+Nginx建站过程 - 来吧，和鹿丸君一起打豆豆](https://blog.csdn.net/coding01/article/details/80083033)
6. [hexo的next主题个性化教程:打造炫酷网站](http://shenzekun.cn/hexo%E7%9A%84next%E4%B8%BB%E9%A2%98%E4%B8%AA%E6%80%A7%E5%8C%96%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B.html)
