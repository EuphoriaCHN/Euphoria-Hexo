---
title: 来说说TCP的三次握手和四次挥手吧
date: 2020-01-19 20:38:53
tags:
- 计算机网络
categories:
- 计算机网络
- TCP
copyright: true
---

> <span class = 'introduction'>活得快乐的最重要因素是人生有事干、有人可去爱，以及生命中有所冀望。</span><br/>
在面试中，三次握手和四次挥手可以说是问的最频繁的一个知识点了。今天重点围绕着面试，我们应该掌握哪些比较重要的点，哪些是比较被面试官给问到的呢？

<!--more-->

<hr/>

## TCP 报文格式

在了解三次握手和四次挥手之前，先知道TCP报文内部包含了哪些东西。

<img src="./TcpMessage.png" alt="TCP 报文格式" />

TCP 报头中的源端口号和目的端口号同 IP 数据报中的源 IP 与目的 IP 唯一确定一条 TCP 连接。TCP在发送数据前必须在彼此间建立连接，这里连接意思是：双方需要内保存对方信息（例如：IP，Port…）

报文主要段的意思大致是这样：

|字段|含义|
|:---|:---|
|序号|表示发送的数据字节流，确保 TCP 传输有序，对每个字节编号|
|确认序号|发送方期待接收的下一序列号，接收成功后的数据字节序列号加 1。只有 ACK = 1 时才有效。|
|URG|紧急指针是否有效。如果为 1，则表示某一位需要被优先处理（告知系统此报文段有紧急数据）|
|ACK|确认号是否有效，一般置为 1|
|PSH|提示接收端应用程序立即从 TCP 缓冲区把数据读走（Push，一般 PSH = 1 的情况只出现在 DATA 内容不为 0 的包中，即表示有真正的 TCP 数据包内容被传递）|
|RST|对方要求重新建立连接，复位。当 RST = 1 时，表明 TCP 连接中出现严重差错，必须释放连接再重新建立连接|
|SYN|请求建立连接，并在其序列号的字段进行序列号的初始值设定。建立连接，设置为 1|
|FIN|希望断开连接，当 FIN = 1 时，表明此报文段的发送方数据已经发送完毕，要求断开连接|

<hr />

## 状态值（不看这个是看不懂接下来的东西的哦）

|状态名|含义|
|:---|:---|
|Listen|侦听来自远方 TCP 端口的连接请求|
|SYN-Sent|在发送连接请求后等待匹配的连接请求|
|SYN-Received|在收到和发送一个连接请求等待对连接请求的确认|
|Established|代表一个打开的连接，数据可以传送|
|FIN-Wait-1|等待远程 TCP 的连接中断请求，或先前的连接中断请求的确认|
|FIN-Wait-2|从远程 TCP 连接中断请求|
|Close-Wait|等待从本地用户发来的连接中断请求|
|Last-ACK|等待原来发向远程 TCP 的连接中断请求的确认|
|Time-Wait|等待的时间以确保远程 TCP 接收到连接中断请求的确认|  
|Closed|没有任何连接状态|

<hr />

## 三次握手

### 过程

#### 正经一点的

**刚开始客户端处于 closed 的状态，服务端处于 listen 状态**。然后：

1. 第一次握手：客户端给服务端发一个 `SYN` 报文，并指明客户端的初始化序列号 `ISN(c)`。此时客户端处于 **`SYN_Sent`** 状态。
2. 第二次握手：服务器收到客户端的 `SYN` 报文之后，会以自己的 `SYN` 报文作为应答，并且也是指定了自己的初始化序列号 `ISN(s)`，同时会把客户端的 `ISN + 1` 作为 `ACK` 的值，表示自己已经收到了客户端的 `SYN`，此时服务器处于 **`SYN_REVD`** 的状态。
3. 第三次握手：客户端收到 `SYN` 报文之后，会发送一个 `ACK` 报文，当然，也是一样把服务器的 `ISN + 1` 作为 `ACK` 的值，表示已经收到了服务端的 `SYN` 报文，此时客户端处于 **`establised`** 状态。
4. 服务器收到 `ACK` 报文之后，也处于 **`establised`** 状态，此时，双方以建立起了链接。

<img src="./three.png" alt="TCP 三次握手" />

来个动图叭：

<img src="./three.gif" alt="TCP 三次握手" />

#### 不正经的

<img src="./three01.png" alt="TCP 三次握手" />

### 为什么得握三次？两次不行吗？

需要三次握手主要是 **双方彼此确认对方的接收与发送能力是否正常**，因为双方中间是有距离的，而除了发包通信又没其他办法联系到对方：

1. 第一次握手：客户端给服务端发包，服务端收到了，那么服务端就知道 **客户端的发送能力没问题**，但此时客户端并不知道服务端收到了它发送的这条消息；
2. 第二次握手：服务端向客户端回复，此时：
    1. **客户端知道了服务端发送能力没问题**；
    2. 既然客户端收到了服务端发来的消息，那么也就证明了，**服务端收到了客户端最开始发送的消息**，即客户端也同时知道了 **服务端的接收能力没问题**；
3. 第三次握手：客户端向服务端发包，服务端收到了这个回复，那么一定是客户端收到了服务端的上一条消息，这个时候服务端也就知道了 **客户端的接收能力没问题**。

因此，需要三次握手才能确认双方的接收与发送能力是否正常。

<div class="note info">3次握手完成两个重要的功能，既要双方做好发送数据的准备工作（双方都知道彼此已准备好），也要允许双方就初始序列号进行协商，这个序列号在握手过程中被发送和确认。</div>

现在把三次握手改成仅需要两次握手，这样就可能发生 **死锁**。

作为例子，考虑计算机 S 和 C 之间的通信，假定 C 给 S 发送一个连接请求分组，S 收到了这个分组，并发送了确认应答分组。按照两次握手的协定，**S 认为连接已经成功地建立了，可以开始发送数据分组**。可是，C 在 S 的应答分组在传输中被丢失的情况下，将不知道 S 是否已准备好，不知道 S 建立什么样的序列号，**C 甚至怀疑 S 是否收到自己的连接请求分组**。在这种情况下，**C 认为连接还未建立成功，将忽略 S 发来的任何数据分组，只等待连接确认应答分组**。而 S 在发出的分组超时后，重复发送同样的分组。

这样就形成了死锁。

### 三次握手的作用是什么

1. 确认双方的接受能力、发送能力是否正常；
2. 指定自己的初始化序列号，为后面的可靠传送做准备；
3. 如果是 https 协议的话，三次握手这个过程，还会进行数字证书的验证以及加密密钥的生成。

### 三次握手中可以携带数据吗

第一次、第二次握手不可以携带数据，而第三次握手是可以携带数据。

<div class="note danger"><b>假如第一次握手可以携带数据</b> 的话，如果有人要恶意攻击服务器，那他每次都在第一次握手中的 <code>SYN</code> 报文中放入大量的数据，因为 <b>攻击者根本就不理服务器的接收、发送能力是否正常</b>，然后疯狂着重复发 <code>SYN</code> 报文的话，这会让服务器花费很多时间、内存空间来接收这些报文。也就是说，第一次握手可以放数据的话，其中一个简单的原因就是会让服务器更加容易受到攻击了。</div>

而对于第三次的话，此时客户端已经处于 **`established`** 状态，也就是说，对于客户端来说，他已经建立起连接了，并且也已经知道服务器的接收、发送能力是正常的了，所以能携带数据页没啥毛病。

### （ISN）是固定的吗

三次握手的一个重要功能是客户端和服务端交换 ISN（Initial Sequence Number）, 以便让对方知道接下来接收数据的时候如何按序列号组装数据。

如果 `ISN` 是固定的，攻击者很容易猜出后续的确认号，**因此 `ISN` 是动态生成的**。

### 什么是半连接队列

服务器第一次收到客户端的 `SYN` 之后，就会处于 **`syn_rcvd`** 状态，此时双方还没有完全建立其连接，服务器会把此种状态下请求连接放在一个队列里，我们把这种队列称之为半连接队列。

**`syn_sent`** 是主动打开方的 **「半打开」状态**，**`syn_rcvd`** 是被动打开方的 **「半打开」状态**。客户端是主动打开方，服务端是被动打开方。

当然还有一个全连接队列，就是已经完成三次握手，建立起连接的就会放在全连接队列中。**如果队列满了就有可能会出现丢包现象**。

<div class="note info">这里再补充一点关于 <b><code>SYN-ACK</code> 重传次数</b> 的问题：服务器发送完 <b><code>SYN-ACK</code></b> 包，如果未收到客户确认包，服务器进行首次重传，等待一段时间仍未收到客户确认包，进行第二次重传，如果重传次数超过系统规定的最大重传次数，系统将该连接信息从半连接队列中删除。注意，每次重传等待的时间不一定相同，一般会是指数增长，例如间隔时间为 1s, 2s, 4s, 8s, ….</div>

### 如果已经建立了连接，但客户端突然出现了故障？

显然，客户端如果出现故障，服务器不能一直等下去，白白浪费资源。

**TCP** 设有一个 **保活计时器**，**服务器每收到一次客户端的请求后都会重新复位这个计时器**，时间通常是设置为 2 小时，若两小时还没有收到客户端的任何数据，服务器就会发送一个**探测报文段**，以后每隔 75 秒钟发送一次。

若一连发送 10 个探测报文仍然没反应，服务器就认为客户端出了故障，接着就关闭连接。

### 其他需要补充的

#### TCP 重传

A 发送了一个 data，如果 B 收到了要向 A 回复自己收到了（ACK），但是如果 A 发送完 data 半天都没得到 B 的回复，那么 A 就会认为自己的 data 半路被大风刮跑了，需要重新发送一遍，**这就是 TCP 重传**。

但是也有可能是 B 收到了 A 的消息，只不过是 B 给 A 的 ACK 回复半路被刮跑了，以至于 A 收不到 B 的回复。

那么既然 A 不能判断究竟是自己的 data 半路没了，还是 B 的回复半路没了，那就干脆不管了，重新发送一遍 data 就行。

既然发生了 TCP 重传，那么 B 就有可能同一个消息收到了多次，这里就需要 **「去重」**，**「重传」** 和 **「去重」** 工作在操作系统的网络内核模块都已经帮我们处理好了，用户层是不用关心的。

#### TCP 的双工通信

A 可以向 B 喊话，同样 B 也可以向 A 喊话，因为 **TCP 链接是「双工的」**，双方都可以主动发起数据传输。

**不过无论是哪方喊话，都需要收到对方的确认才能认为对方收到了自己的喊话。**

A 可能是个高射炮，一连说了八句话，这时候 B 可以不用一句一句回复，而是连续听了这八句话之后，一起向对方回复说前面你说的八句话我都听见了，这就是**批量 ACK**。

网络环境的数据交互同人类之间的对话还要复杂一些，它存在数据包乱序的现象。

同一个来源发出来的不同数据包在 **「网际路由」** 上可能会走过不同的路径，最终达到同一个地方时，顺序就不一样了。

操作系统的网络内核模块会负责对数据包进行排序，到用户层时顺序就已经完全一致了（所以说我们不用管咯？）。

<hr />

## 四次挥手

### 过程

#### 正经一点的

刚开始双方都处于 `establised` 状态，假如是客户端先发起关闭请求，则：

1. 第一次挥手：第一次挥手：客户端发送一个 `FIN` 报文，报文中会指定一个序列号。此时客户端处于 **`FIN-Wait-1`** 状态；
2. 第二次挥手：服务端收到 `FIN` 之后，会发送 `ACK` 报文，且把 **客户端的序列号值 + 1** 作为 `ACK` 报文的序列号值，表明已经收到客户端的报文了，此时服务端处于 **`Close-Wait`** 状态，客户端收到后进入 **`FIN-Wait-2`** 状态；
3. 第三次挥手：如果服务端也想断开连接了，和客户端的第一次挥手一样，向客户端发送 `FIN` 报文，且指定一个序列号。此时服务端处于 **Last-ACK** 的状态。
4. 第四次挥手：客户端收到来自服务端的 `FIN` 之后，一样发送一个 `ACK` 报文作为应答，且把 **服务端的序列号值 + 1** 作为自己 `ACK` 报文的序列号值，此时客户端处于 **`Time-Wait`** 状态。需要过一阵子以 **确保服务端收到** 自己的 `ACK` 报文之后才会进入 **`Closed`** 状态。
5. 服务端收到 `ACK` 报文之后，就处于关闭连接了，处于 **`Closed`** 状态。

<img src="four.png" alt="TCP 四次挥手" />

也来个动图叭：

<img src="four.gif" alt="TCP 四次挥手" />

#### 不正经的

<img src="four01.png" alt="TCP 四次挥手" />

### 超级重要的 Time-Wait 状态

#### 什么是 Time-Wait

为什么客户端发送 ACK 之后不直接关闭，而是要等一阵子才关闭？

**`Time-Wait`** 是主动关闭的一方在回复完对方的挥手后进入的一个长期状态。

这个状态标准的持续时间是 4 分钟，4 分钟后才会进入到 **`Closed`** 状态，释放套接字资源。不过在具体实现上这个时间是可以调整的。

4 分钟就是 2 个 MSL，每个 MSL 是 2 分钟。MSL 就是 **Maximum Segment Lifetime —— 最长报文寿命**。

这个时间是由官方 RFC 协议规定的。至于为什么是 2 个 MSL 而不是 1 个 MSL，还没有看到一个非常满意的解释。

它就好比主动分手方要承担的责任，是你提出的要分手，你得付出代价。这个后果就是持续 4 分钟的 **`Time-Wait`** 状态，不能释放套接字资源(端口)，就好比守寡期，这段时间内套接字资源(端口)不得回收利用。

它的作用是重传最后一个 `ACK` 报文，确保对方可以收到。因为如果对方没有收到 `ACK` 的话，会重传 `FIN` 报文，处于 **`Time-Wait`** 状态的套接字会立即向对方重发 ack 报文。

即：要确保服务器是否已经收到了我们的 `ACK` 报文，如果没有收到的话，服务器会重新发 `FIN` 报文给客户端，客户端再次收到 `FIN` 报文之后，就知道之前的 `ACK` 报文丢失了，然后再次发送 `ACK` 报文。

#### 为什么必须要经过 2 MSL 才能返回到 Close 状态

虽然按道理，四个报文都发送完毕，我们可以直接进入 **`Close`** 状态了，但是我们必须假象网络是不可靠的，有可以最后一个 `ACK` 丢失。所以 **`Time-Wait`** 状态就是用来重发可能丢失的 `ACK` 报文。

在客户端发送出最后的 `ACK` 回复后，该 `ACK` 可能丢失。服务端如果没有收到 `ACK`，将不断重复发送 `FIN` 片段。**所以客户端不能立即关闭，它必须确认服务端接收到了该 `ACK`**。

客户端会在发送出 `ACK` 之后进入到 **`Time-Wait`** 状态。客户端会设置一个计时器，等待 2 MSL 的时间。

如果在该时间内再次收到 `FIN`（因为服务端没收到客户端最后的 `ACK` 就会重发 `FIN`，如果客户端在等待 2 MSL 的时候又收到了来自服务端的 `FIN`，那就说明自己之前的 `ACK` 丢了），那么客户端会重发 `ACK` 并再次等待 2 MSL。

MSL 指一个片段在网络中最大的存活时间，2 MSL 就是一个发送和一个回复所需的最大时间。如果直到 2 MSL，客户端都没有再次收到来自服务端的 `FIN`，那么服务端就有理由推断自己的最后一个 `ACK` 已经被成功接收，则结束 `TCP` 连接。

### 总是四次挥手吗？

四次挥手也并不总是四次挥手，中间的两个动作有时候是可以合并一起进行的。

这个时候就成了三次挥手，主动关闭方就会从 **`FIN-Wait-1`** 状态直接进入到 **`Time-Wait`** 状态，跳过了 **`FIN-Wait-2`** 状态。

### 为什么连接的时候要三次握手，而关闭的时候要四次挥手

因为当服务端收到客户端端的 `SYN` 连接请求报文后，可以直接发送 `SYN + ACK` 报文。其中 `ACK` 报文是用来应答的，`SYN` 报文是用来同步的。

但是关闭连接时，当服务端端收到 `FIN` 报文时，很可能并不会立即关闭 `SOCKET`，所以只能先回复一个 `ACK` 报文，告诉客户端：**"你发的 `FIN` 报文我收到了"**。只有等到我这边（服务端）所有的报文都发送完了，我才能发送 `FIN` 报文，因此不能一起发送。**故需要四步挥手。**

<hr />

## 总结

一图胜千言了...

<img src="total.png" alt="总览" />

<hr />

## 参考资料

- [6张动态图轻松学习TCP三次握手和四次挥手](http://www.sohu.com/a/246199963_463994)
- [TCP的三次握手与四次挥手理解及面试题（很全面）](https://blog.csdn.net/qq_38950316/article/details/81087809)
- [关于三次握手与四次挥手面试官想考什么？](https://blog.csdn.net/weixin_44460333/article/details/89369316)
- [TCP三次握手和四次挥手通俗理解](https://www.cnblogs.com/jainszhang/p/10641728.html)
- [在深谈TCP/IP三步握手&四步挥手原理及衍生问题——长文解剖IP](http://www.pianshen.com/article/1002102250/)