---
title: UML图例详解
date: 2019-08-28 16:13:57
tags:
- 设计模式
- UML
- 软件工程
categories:
- 软件工程
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
td, th {
    border: 2px solid white;
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

> <span class = "redspan">志向和热爱是伟大行为的双翼。</span><br/>
<a name = "UML">UML（Unified Modeling Language）</a>是一种统一建模语言，为面向对象开发系统的产品进行说明、可视化、和编制文档的一种标准语言。<br/>在这里将介绍 `UML` 基本概念以及各个图的使用场景。

<!-- more -->

<hr/>

## `UML` 图例详解
`UML` 分为用例视图、设计视图、进程视图、实现视图和拓扑视图，又可以静动分为静态视图和动态视图。静态图分为：用例图，类图，对象图，包图，构件图，部署图。动态图分为：状态图，活动图，协作图，序列图。

### <i class = "fa fa-angle-double-right"></i> 用例图（UseCase Diagrams）
> 用例是目标系统<a name = "business-process">业务过程（Business Process）</a>的抽象，由<a name = "actor">参与者（Actor）</a>与系统的交互步骤（或事件）组成，参与者通过用例完成具体的业务目标。<br/>即：用例图主要回答了两个问题：<br/>1. <span class = "markbutton bgpurple">是谁用软件</span><br/>2. <span class = "markbutton bgpurple">软件的功能</span><br/>从用户的角度描述了系统的功能，并指出各个功能的执行者，强调用户的使用者，系统为执行者完成哪些功能。

<span class = "markbutton bgblue">系统用例模型</span>通过 `UML` 用例图进行可视化。`UML` 用例图基本符号有 <span class = "markbutton bgpurple">用例（椭圆形标识）、参与者（人性标识）、系统边界（矩形标识）、关联（直线标识）</span>。<br/>

- 如图 `1.1` 所示：

    <div class = "image-display">
        <img src = "./UML_yongli.png" alt = "UML用例图"/>
        <br/>图1.1&nbsp;&nbsp;&nbsp;&nbsp;UML用例图基本符号
    </div>
    
<span class = "markbutton bgblue">用例建模</span> 是面向对象软件分析的重要技术和方法，开发人员在实用用例图进行用例模型可视化时需要<span class = "markbutton bgred">注意如下事项</span>：
<ol>
    <li>用例图无法可视化非交互或非功能性的系统需求；</li>
    <li>用例的定义没有统一标准；</li>
    <li>复杂系统用例模型的全局可视化可能会降低用例图的可用性等。</li>
</ol>

<hr/>

### <i class = "fa fa-angle-double-right"></i> 序列图-时序图（Sequence Diagrams）
> <span class = "markbutton bgblue">UML时序图</span>通过对象、消息、交互顺序等方式可视化软件业务过程中的控制流或数据流。

<span class = "markbutton bgblue">时序图</span>中的对象通过发送消息和接受消息进行交互，消息具有先后顺序。UML时序图基本符号有<span class = "markbutton bgpurple">对象、消息、对象生命线、消息组合片段、终止符号等</span>。

- 时序图如图 `1.2` 所示：

    <div class = "image-display">
        <img src = "./UML_shixu.jpg" alt = "UML时序图"/>
        <br/>图1.2&nbsp;&nbsp;&nbsp;&nbsp;UML时序图基本符号
    </div>
    
> <span class = "markbutton bgblue">消息</span>用从一个对象的生命线到另一个对象生命线的箭头表示。<br/>
> 箭头以<span class = "markbutton bgblue">时间顺序</span>在图中从上到下排列。 
<br/>

#### <i class = "fa fa-angle-right"></i> 生命线

> 生命线名称可带下划线。当使用下划线时，意味着序列图中的生命线代表一个类的特定实例。

- 生命线如图 `1.3` 所示：

    <div class = "image-display">
        <img src = "./shengmingxian.png" alt = "生命线"/>
        <br/>图1.3&nbsp;&nbsp;&nbsp;&nbsp;生命线
    </div>
    
#### <i class = "fa fa-angle-right"></i> 同步消息

> 同步等待消息。

- 同步消息如图 `1.4` 所示：

    <div class = "image-display">
        <img src = "./tongbuxiaoxi.png" alt = "同步消息"/>
        <br/>图1.4&nbsp;&nbsp;&nbsp;&nbsp;同步消息
    </div>
    
#### <i class = "fa fa-angle-right"></i> 异步消息

> 异步发送消息，不需等待。

- 异步消息如图 `1.5` 所示：

    <div class = "image-display">
        <img src = "./yibuxiaoxi.png" alt = "异步消息"/>
        <br/>图1.5&nbsp;&nbsp;&nbsp;&nbsp;异步消息
    </div>
    
#### <i class = "fa fa-angle-right"></i> 注释

- 注释如图 `1.6` 所示：

    <div class = "image-display">
        <img src = "./zhushi.png" alt = "注释"/>
        <br/>图1.6&nbsp;&nbsp;&nbsp;&nbsp;注释
    </div>
    
#### <i class = "fa fa-angle-right"></i> 约束

- 约束如图 `1.7` 所示：

    <div class = "image-display">
        <img src = "./yueshu.png" alt = "约束"/>
        <br/>图1.7&nbsp;&nbsp;&nbsp;&nbsp;约束
    </div>
    
#### <i class = "fa fa-angle-right"></i> 组合
> <span class = "markbutton bgblue">组合片段用来解决交互执行的条件及方式。</span><br/>它允许在序列图中直接表示逻辑组件，用于通过指定条件或子进程的应用区域，为任何生命线的任何部分定义特殊条件和子进程。<br/>常用的组合片段有：<span class = "markbutton bgpurple">抉择、选项、循环、并行</span>。

使用<span class = "markbutton bgblue">时序图</span> 进行对象交互模型可视化时，需要<span class = "markbutton bgred">注意如下事项</span>：
<ol>
    <li>消息类型有同步消息、异步消息、返回消息、自关联消息等；</li>
    <li>如果需要在时序图中标注对象生命周期的终止，可以使用终止符号；</li>
    <li>可以对时序图标注<a name = "type">对象类型（Type）</a>和<a name = "stereotype">构造类型（Stereotype）</a>；</li>
    <li>当系统内部对象需要和系统外部环境交互时，可以将外部环境（第三方系统或用户）标注为对象。</li>
</ol>

<hr/>

### <i class = "fa fa-angle-double-right"></i> 类图（Class Diagrams）
> **类是面向对象软件分析和设计的核心目标。**<br/>定义了静态代码逻辑，是软件内部的<a name = "generalization">泛化（Generalization）</a>类型；对象是类的实例；类的关联是对象写作逻辑的静态表示。<br/><span class = "markbutton bgblue">采用面向对象方法实施软件编码活动的本质是定义类。</span>

用户根据用例图抽象成类，描述类的内部结构和类与类之间的关系，是一种静态结构图。<br/> 在UML类图中，常见的有以下几种关系: 
- <a name = "generalization-inheritance">泛化/继承（Generalization / Inheritance）</a>
- <a name = "realization">实现（Realization）</a>
- <a name = "association">关联（Association)</a>
- <a name = "aggregation">聚合（Aggregation）</a>
- <a name = "composition">组合（Composition）</a>
- <a name = "dependency">依赖（Dependency）</a>

> **类图不仅可以用于呈现需求的业务领域，也可以用于表达逻辑代码的设计模型。**

各种关系的强弱顺序： 泛化（继承） = 实现 > 组合 > 聚合 > 关联 > 依赖

### <i class = "fa fa-angle-right"></i> 泛化（继承）
> `【泛化关系】`：是一种继承关系，表示一般与特殊的关系，它指定了子类如何继承父类的所有特征和行为。<br/>
> 例如：`学生（Student）` 也同样是 `人（Person）`，即有学生的特性也有人类的共性。

<div class = "image-display">
    <img src = "./generalization.png" alt = "泛化"/>
    <br/>泛化（继承）
</div>

<br/>

```java
// 定义 Person 类
class Person {
    private String name;
    private int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    @Override
    public String toString() {
        return "{Name: " + this.name + ", Age: " + this.age + "}\n";
    }
}

// 定义 Student 类，继承 Person 类
class Student extends Person {
    private String studentID;
    
    public Student(String name, int age, String studentID) {
        super(name, age);
        this.studentID = studentID;
    }
    
    @Override
    public String toString() {
        return super.toString() + "{Student ID: " + this.studentID + "}";
    }
}
```

### <i class = "fa fa-angle-right"></i> 实现
> `【实现关系】`：是一种类与接口的关系，表示类是接口所有特征和行为的实现。

<div class = "image-display">
    <img src = "./implements.png" alt = "泛化"/>
    <br/>实现
</div>

<br/>

``` java
// 定义动作接口 Action
interface Action {
    void Running();
    void Sleeping();
}

// 定义 Animals 类，实现动作接口 Action
class Animals implements Action {
    @Override
    public void Running() {
        System.out.println("It's Running!");
    }
    
    @Override
    public void Sleeping() {
        System.out.println("It's Sleeping!");
    }
}
```

### <i class = "fa fa-angle-right"></i> 关联
> `【关联关系】`：是一种拥有的关系，它使一个类知道另一个类的属性和方法；<br/>如：老师与学生，丈夫与妻子关联可以是双向的，也可以是单向的。<br/>双向的关联可以有两个箭头或者没有箭头，单向的关联有一个箭头。<br/>
> `【代码体现】`：成员变量

<div class = "image-display">
    <img src = "./association.png" alt = "关联"/>
    <br/>关联
</div>

<br/>

```java
// 定义学院类 College
class College {
    private String name;
    private ArrayList<Student> student; // 学生与学院 n : 1
    
    public Courses(String name) {
        this.name = name;
        this.student = new ArrayList<>();
    }
    
    // 省略 getter 和 setter 方法...
}

// 定义学生类 Students
class Student {
    private ArrayList<Teacher> teachers; // 学生与老师 n : m
    
    public Student() {
        this.teachers = new ArrayList<>();
    }
    
    // 省略 getter 和 setter 方法...
}

// 定义教师类 Teacher
class Teacher {
    private ArrayList<Student> students; // 学生与老师 n : m
    
    public Teacher() {
        this.students = new ArrayList<>();
    }
    
    // 省略 getter 和 setter 方法...
}
```

### <i class = "fa fa-angle-right"></i> 聚合
> `【聚合关系】`：是整体与部分的关系，且<span class = "markbutton bgblue">部分可以离开整体而单独存在</span>。如车和轮胎是整体和部分的关系，轮胎离开车仍然可以存在。<br/>
> <span class = "markbutton bgblue">聚合关系是关联关系的一种，是强的关联关系；</span> 关联和聚合在语法上无法区分，必须考察具体的逻辑关系。<br/>
> `【代码体现】`：成员变量

<div class = "image-display">
    <img src = "./aggregation.png" alt = "聚合"/>
    <br/>聚合
</div>

<br/>

```java
// 定义引擎类 Engine
class Engine {
    private String name;

    public Engine(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}

// 定义汽车类 Car
class Car {
    private Engine engine; // 1:1 聚合关系
    private Tyre[] tyres = new Tyre[4]; // 1:4 聚合关系

    public Car() {
        engine = new Engine("Engine");
    }

    public Engine getEngine() {
        return engine;
    }

    public Tyre[] getTyres() {
        return tyres;
    }
}

// 定义轮胎类 Tyre
class Tyre {
    public void running() {
        System.out.println("Tyre is running...");
    }
}
```

### <i class = "fa fa-angle-right"></i> 组合
> `【组合关系】`：是整体与部分的关系，但<span class = "markbutton bgblue">部分不能离开整体而单独存在</span>。如公司和部门是整体和部分的关系，没有公司就不存在部门。<br/>
> 组合关系是关联关系的一种，是比聚合关系还要强的关系，它要求普通的聚合关系中代表整体的对象负责代表部分的对象的生命周期。<br/>
> `【代码体现】`：成员变量<br/>
> `【箭头及指向】`：带实心菱形的实线，菱形指向整体

<div class = "image-display">
    <img src = "./composition.png" alt = "组合"/>
    <br/>组合
</div>

<br/>

```java
// 定义公司类 Company
class Company {
    private String name;
    
    public Company(String name) {
        this.name = name;
    }
}

// 定义部门类 Department
class Department {
    private Company company;
    
    public Department(Company company) {
        this.company = company;
    }
}
```

### <i class = "fa fa-angle-right"></i> 依赖
> `【依赖关系】`：是一种使用的关系，即<span class = "markbutton bgblue">一个类的实现需要另一个类的协助</span>，所以要尽量不使用双向的互相依赖.<br/>
> `【代码表现】`：局部变量、方法的参数或者对静态方法的调用<br/>
> `【箭头及指向】`：带箭头的虚线，指向被使用者

<div class = "image-display">
    <img src = "./dependency.png" alt = "依赖"/>
    <br/>依赖
</div>

<br/>

```c
// 定义计算机类 Computer
class Computer {
    private String name;
    private static String cpu = "Intel";

    public Computer(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public static String showCPU() {
        return cpu;
    }
}

// 定义人类 People
class People {
    // 使用局部方法参数
    public void getComputerName(Computer computer) {
        System.out.println(computer.getName());
    }

    // 使用静态方法
    public void getComputerCPU() {
        System.out.println(Computer.showCPU());
    }
}
```

### <i class = "fa fa-angle-right"></i> 类图应用
<div class = "image-display">
    <img src = "./group.png" alt = "类图应用"/>
    <br/>类图应用
</div>

<br/>

使用<span class = "markbutton bgblue">类图</span> 进行建模时，需要<span class = "markbutton bgred">注意如下事项</span>：
<ol>
    <li>类图可以呈现域、方法和类关系等代码要素，但无法表达详细业务流程。因此，如果只有类图模型，则并不能直接进行程序实现；</li>
    <li>类图文档通常与代码实现不一致，且更新代价较高；</li>
    <li>从静态代码形式上看，不同的类关系代码形式常常相同或类似。因此，一般按系统对象的角色或业务职责区分类关系。</li>
</ol>