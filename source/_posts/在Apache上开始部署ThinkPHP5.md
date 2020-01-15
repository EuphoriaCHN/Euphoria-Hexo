---
title: 在Apache上开始部署ThinkPHP5
date: 2019-09-23 18:09:43
tags:
- PHP
- ThinkPHP5
- Apache
categories:
- PHP
- ThinkPHP5
copyright: true
---

> <span class = 'introduction'>真正的才智是刚毅的志向。</span><br/>
ThinkPHP框架 - 是由上海顶想公司开发维护的 MVC 结构的开源 PHP 框架，遵循 Apache2 开源协议发布，是为了敏捷 WEB 应用开发和简化企业应用开发而诞生的。

<!--more-->

<hr/>

## Think PHP 框架

我们可以在 <a href = "http://www.thinkphp.cn/down.html">Think PHP框架官网</a> 进行下载，然后将其直接解压至网站根目录下。

他的目录结构如下：

```
project  应用部署目录
├─application           应用目录（可设置）
│  ├─common             公共模块目录（可更改）
│  ├─index              模块目录(可更改)
│  │  ├─config.php      模块配置文件
│  │  ├─common.php      模块函数文件
│  │  ├─controller      控制器目录
│  │  ├─model           模型目录
│  │  ├─view            视图目录
│  │  └─ ...            更多类库目录
│  ├─command.php        命令行工具配置文件
│  ├─common.php         应用公共（函数）文件
│  ├─config.php         应用（公共）配置文件
│  ├─database.php       数据库配置文件
│  ├─tags.php           应用行为扩展定义文件
│  └─route.php          路由配置文件
├─extend                扩展类库目录（可定义）
├─public                WEB 部署目录（对外访问目录）
│  ├─static             静态资源存放目录(css,js,image)
│  ├─index.php          应用入口文件
│  ├─router.php         快速测试文件
│  └─.htaccess          用于 apache 的重写
├─runtime               应用的运行时目录（可写，可设置）
├─vendor                第三方类库目录（Composer）
├─thinkphp              框架系统目录
│  ├─lang               语言包目录
│  ├─library            框架核心类库目录
│  │  ├─think           Think 类库包目录
│  │  └─traits          系统 Traits 目录
│  ├─tpl                系统模板目录
│  ├─.htaccess          用于 apache 的重写
│  ├─.travis.yml        CI 定义文件
│  ├─base.php           基础定义文件
│  ├─composer.json      composer 定义文件
│  ├─console.php        控制台入口文件
│  ├─convention.php     惯例配置文件
│  ├─helper.php         助手函数文件（可选）
│  ├─LICENSE.txt        授权说明文件
│  ├─phpunit.xml        单元测试配置文件
│  ├─README.md          README 文件
│  └─start.php          框架引导文件
├─build.php             自动生成定义文件（参考）
├─composer.json         composer 定义文件
├─LICENSE.txt           授权说明文件
├─README.md             README 文件
├─think                 命令行入口文件
```

<div class = "note danger">
如果是 mac 或者 linux 环境，请确保 <code>runtime</code> 目录有可写权限
</div>

<div class = "note info">
5.0 的部署建议是 public 目录作为 web 目录访问内容，其它都是 web 目录之外，当然，你必须要修改 <code>public/index.php</code> 中的相关路径。如果没法做到这点，请记得设置目录的访问权限或者添加目录列表的保护文件。
</div>

<hr/>

## 新建应用入口文件

在网站的根目录下添加 `index.php` 并加入以下代码：

```php
<?php
// +----------------------------------------------------------------------
// | ThinkPHP [ WE CAN DO IT JUST THINK ]
// +----------------------------------------------------------------------
// | Copyright (c) 2006-2018 http://thinkphp.cn All rights reserved.
// +----------------------------------------------------------------------
// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
// +----------------------------------------------------------------------
// | Author: liu21st <liu21st@gmail.com>
// +----------------------------------------------------------------------

// [ 应用入口文件 ]
namespace think;

header("Access-Control-Allow-Origin: http://localhost:8080");//  add by euphoria
header("Access-Control-Allow-Credentials: true");//  add by euphoria

define('APP_PATH', __DIR__ . '/application/');
// 加载基础文件
require __DIR__ . '/thinkphp/base.php';

// 支持事先使用静态方法设置Request对象和Config对象

// 执行应用并响应
Container::get('app')->run()->send();
```

<hr/>

## Apache 配置伪静态

### 启用 Rewrite

在终端下输入：

```bash
find / -name httpd.conf
```

找到 Apache 的配置文件 `httpd.conf`，找到 `# LoadModule rewrite_module modules/mod_rewrite.so` 去除前面的 #，开启伪静态模块。

### 启动 .htaccess

在系统配置项中找到 Apache 的配置文件 `/etc/httpd/conf/httpd.conf`

将 `AllowOverride None` 修改为： `AllowOverride All`

> 对于配置文件，建议在修改前做下备份

对于网站的伪静态，可以配置为这样：

```yml
<IfModule mod_rewrite.c>
  Options +FollowSymlinks -Multiviews
  RewriteEngine On

  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteRule ^(.*)$ index.php/$1 [QSA,PT,L]
</IfModule>
```

如果你的服务器采用的 <a href = "https://www.bt.cn">宝塔运维面板</a>，那么可以直接在网站设置中配置伪静态。

### 添加自己的视图模块

在你需要的地方创建你的视图文件夹，修改 `/application/index/controller/index.php`：

```php
<?php
namespace app\index\controller;

use think\Controller;

class Index  extends Controller
{
    public function main()
    {
        $this->redirect('https://xxxx.xxxxx.xxxx/你的视图文件目录/');
    }
}
```

也就是加了个重定向过去就好

<hr/>

## 添加自己的 Controller

在 `/application/` 目录下创建一个模块文件夹，里面再创建好控制器 Controller 目录，然后就可以写接口文件了（比如 Main.php）

```php
<?php

namespace app\interfaces\controller; // 这个根据你的文件目录要改 interfaces 这一段话

use think\Controller;

class Main extends Controller {
    /**
    * 默认入口方法
    */
    public function main() {
        return json("OK");
    }
    
    /**
    * 其余方法
    */
    public function demo() {
        return json("...");
    }
}
```

然后就可以通过路由去调用你的接口啦，前端的事情就交给前端去处理吧！
