---
title: 原生JavaScript实现Ajax
date: 2019-11-18 19:15:53
tags:
- Web
- 浏览器
categories:
- 前端
- 面经
copyright: true
image: "http://www.wqh4u.cn/2019/11/18/原生JavaScript实现Ajax/image.jpg"
---

> <span class = 'introduction'>没有礁石，就没有美丽的浪花；没有挫折，就没有壮丽的人生。</span><br />
Ajax 即“Asynchronous Javascript And XML”（异步 JavaScript 和 XML），是指一种创建交互式网页应用的网页开发技术。<br />通过在后台与服务器进行少量数据交换，Ajax 可以使网页实现异步更新。这意味着可以在不重新加载整个网页的情况下，对网页的某部分进行更新。

<!--more-->

<hr/>

## 什么是 Ajax

<div class="note info">
<p>
AJAX 即 “Asynchronous JavaScript and XML”（非同步的 JavaScript 与 XML 技术），指的是一套综合了多项技术的浏览器端网页开发技术。Ajax的概念由杰西·詹姆士·贾瑞特所提出。
</p>
<p>
传统的 Web 应用允许用户端填写表单（form），当送出表单时就向网页伺服器发送一个请求。伺服器接收并处理传来的表单，然后送回一个新的网页，但这个做法浪费了许多带宽，因为在前后两个页面中的大部分 HTML 码往往是相同的。由于每次应用的沟通都需要向伺服器发送请求，应用的回应时间依赖于伺服器的回应时间。这导致了用户界面的回应比本机应用慢得多。
</p>
<p>
与此不同，AJAX应用可以仅向伺服器发送并取回必须的数据，并在客户端采用 JavaScript 处理来自伺服器的回应。因为在伺服器和浏览器之间交换的数据大量减少，伺服器回应更快了。同时，很多的处理工作可以在发出请求的客户端机器上完成，因此 Web 伺服器的负荷也减少了。
</p>
<p>
类似于 DHTML 或 LAMP，AJAX 不是指一种单一的技术，而是有机地利用了一系列相关的技术。虽然其名称包含 XML，但实际上数据格式可以由 JSON 代替，进一步减少数据量，形成所谓的 AJAJ。而客户端与服务器也并不需要异步。一些基于 AJAX 的 “派生／合成” 式（derivative/composite）的技术也正在出现，如 AFLAX。
</p>
</div>

### Ajax 的运行原理
页面发起请求，会将请求发送给游览器的内核中的Ajax引擎中，Ajax引擎会提交请求到服务器端。

在这段时间里，客服端可以任意进行操作，直到服务器将数据返回Ajax之后，会触发你设置事件。

从而执行自定义的js逻辑代码完成某种页面的功能，实现页面的局部刷新。

<hr />

## Ajax 的优缺点

<div class="note info">
<p>
使用 Ajax 的最大优点，<code>就是能在不更新整个页面的前提下维护数据</code>。这使得 Web 应用程序更为迅捷地回应用户动作，并避免了在网络上发送那些没有改变的信息。
</p>
<p>
Ajax 不需要任何浏览器插件，但需要用户允许 JavaScript 在浏览器上执行。就像 DHTML 应用程序那样，Ajax 应用程序必须在众多不同的浏览器和平台上经过严格的测试。
</p>
<p>
随着 Ajax 的成熟，一些简化 Ajax 使用方法的程序库也相继问世。同样，也出现了另一种辅助程序设计的技术，为那些不支持 JavaScript 的用户提供替代功能。
</p>
</div>

<div class="note danger">
<p>
对应用Ajax最主要的批评就是，它可能破坏浏览器的后退与加入收藏书签功能。
</p>
<p>
在动态更新页面的情况下，用户无法回到前一个页面状态，这是因为浏览器仅能记下历史记录中的静态页面。一个被完整读入的页面与一个已经被动态修改过的页面之间的可能差别非常微妙；
</p>
<p>用户通常都希望单击后退按钮，就能够取消他们的前一次操作，但是在Ajax应用程序中，却无法这样做。不过开发者已想出了种种办法来解决这个问题，HTML5 之前的方法大多是在用户单击后退按钮访问历史记录时，通过建立或使用一个隐藏的IFRAME来重现页面上的变更。（例如，当用户在 Google Maps 中单击后退时，它在一个隐藏的 IFRAME 中进行搜索，然后将搜索结果反映到 Ajax 元素上，以便将应用程序状态恢复到当时的状态）。
</p>
</div>

### Ajax 的兼容性

JavaScript 编程的最大问题来自不同的浏览器对各种技术和标准的支持。

`XmlHttpRequest` 对象在不同浏览器中不同的创建方法，以下是跨浏览器的通用方法：

```javascript
// Provide the XMLHttpRequest class for IE 5.x-6.x:
// Other browsers (including IE 7.x-8.x) ignore this
//   when XMLHttpRequest is predefined
var xmlHttp;
if (typeof XMLHttpRequest != "undefined") {
    xmlHttp = new XMLHttpRequest();
} else if (window.ActiveXObject) {
    var aVersions = ["Msxml2.XMLHttp.5.0", "Msxml2.XMLHttp.4.0", "Msxml2.XMLHttp.3.0", "Msxml2.XMLHttp", "Microsoft.XMLHttp"];
    for (var i = 0; i < aVersions.length; i++) {
        try {
            xmlHttp = new ActiveXObject(aVersions[i]);
            break;
        } catch (e) {}
    }
}
```

<div class="note info">此内容来自 <a href="https://zh.wikipedia.org/zh/AJAX">维基百科-Ajax</a>。</div>

<hr />

## 实现 Ajax

主要思路有以下五点：
<ol>
<li>创建一个 Ajax 对象，使用 <code>XMLHttpRequest</code>；</li>
<li>绑定监听函数 <code>onreadystatechange</code>；</li>
<li>绑定处理请求的地址，对 <code>async</code> 参数的选项：<code>true</code> 为异步，<code>false</code> 为同步；</li>
<li>POST 提交设置的协议头（GET方式省略）</li>
<li>发送请求</li>
</ol>

上代码：

```javascript
let ajax = request => {
    // 创建 Ajax 对象
    let xmlHttp = new XMLHttpRequest();
    
    // 绑定处理请求的地址，启动一个请求
    // 请求方式，目标地址，是否异步
    xmlHttp.open(request.type, request.url, request.async || true);

    // 若请求为 POST 方法，则设置请求协议头
    xmlHttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    if (!(request.data instanceof Object)) {
        request.error('error');
        return;
    }

    // 绑定监听函数
    // 每当 readyState 改变时，就会触发 onreadystatechange 事件
    // readyState 总是在 0~4 之间变化
    // 0：请求未初始化，未调用open()方法
    // 1：服务器链接已经建立，已调用open()方法
    // 2：请求已接收，已调用send()方法，尚未收到响应
    // 3：请求处理中，已接收到部分响应数据
    // 4：请求已完成，已经接收到全部响应数据，且已经可以在客户端使用了
    xmlHttp.onreadystatechange = () => {
        // 判断数据是否正常返回
        if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
            // 回调函数
            // 返回一个 JSON 字符串，格式化为对象后传入 success callback
            request.success(JSON.parse(xmlHttp.responseText));
        }
    };

    let data = [];
    for (let key in request.data) {
        data[data.length] = `${key}=${request.data[key]}`
    }

    // POST 将会提交参数，GET 则不用
    // 若不需要发送任何数据则填写 null
    // 发送数据格式为：'key1=value1&key2=value2'
    xmlHttp.send(data.join('$'));
};
```

就可以像使用 `jQuery` 那样去调用这个函数：

```javascript
ajax({
    url: 'http://xxx.xxxxxx.xxx',
    type: 'post',
    data: {
        xxx: 'xxx'
    },
    success(res) {
        console.log(res);
    },
    error(e) {
        console.error(e);
    }
});
```

### 类 Axios 调用

Axios 是一个易用、简洁且高效的 http 库，<a href="http://www.axios-js.com/">这是蓝链</a>。使用 Axios 时可以以一种 “舒服” 的方式去使用 callback，那么我们需要使用 Promise 去实现一个类 Axios 的调用。

这是 Axios 的原版调用：

```javascript
// Make a request for a user with a given ID
axios.get('/user?ID=12345')
    .then(function (response) {
        // handle success
        console.log(response);
    })
    .catch(function (error) {
        // handle error
        console.log(error);
    })
    .then(function () {
        // always executed
    });
  
// Optionally the request above could also be done as
axios.get('/user', {
    params: {
        ID: 12345
    }
  })
  .then(function (response) {
      console.log(response);
  })
  .catch(function (error) {
      console.log(error);
  })
  .then(function () {
      // always executed
  });  

// Want to use async/await? Add the `async` keyword to your outer function/method.
async function getUser() {
    try {
        const response = await axios.get('/user?ID=12345');
        console.log(response);
    } catch (error) {
        console.error(error);
    }
}
```

那么我们可以这样去模仿：

```javascript
let axios = {
    post: (url, data) => {
        return new Promise((resolve, reject) => {
            // 康康 data 格式对不对
            if (!(data instanceof Object)) {
                reject('error');
            }

            // Ajax 对象
            let xmlHttpRequest = new XMLHttpRequest();
            
            // 启动一个 post 异步请求
            xmlHttpRequest.open('post', url, true);
            
            // 为 post 设置请求协议头
            xmlHttpRequest.setRequestHeader('Content-type', 'application/x-www-urlencoded');

            // 消息相应函数
            xmlHttpRequest.onreadystatechange = () => {
                if (xmlHttpRequest.readyState === 4 && xmlHttpRequest.status === 200) {
                    resolve(JSON.parse(xmlHttpRequest.responseText))
                }
            };

            // 格式化请求数据格式
            let requestData = [];
            for (let key in data) {
                requestData[requestData.length] = `${key}=${data[key]}`
            }

            // 发送请求
            xmlHttpRequest.send(requestData.join('&'));
        });
    }
};
```

愉快调用：

```javascript
axios.post('http://xxx.xxxxx.xxx',
    {
        xxx: 'xxx'
    })
    .then(resolve => {
        console.log(resolve);
    })
    .catch(reject => {
        console.error(reject);
    })
    .finally(() => {
        // Always
    });
```

<del>当然还是直接用轮子的好~</del>
