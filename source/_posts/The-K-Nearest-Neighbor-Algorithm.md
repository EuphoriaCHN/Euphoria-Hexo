---
title: The K Nearest Neighbor Algorithm
date: 2019-10-15 11:34:41
tags:
- Python
- 人工智能
categories:
- 学校课程
copyright: true
image: "http://www.wqh4u.cn/2019/10/15/The-K-Nearest-Neighbor-Algorithm/1024px-KnnClassification.svg.png"
---

> <span class = 'introduction'>活着的目的不在于永远活着，而在于永远活出自己。</span><br/>
在模式识别领域中，最近邻居法（KNN算法，又译K-近邻算法）是一种用于分类和回归的非参数统计方法。<br />在这两种情况下，输入包含特征空间（Feature Space）中的k个最接近的训练样本。
<br />这次主要实现了使用原生 Python 来模拟一个 KNN 算法。

<!--more-->

<hr/>

## k-nearest neighbors algorithm

**K-NN** 是一种[基于实例的学习](https://en.wikipedia.org/wiki/Instance-based_learning)，或者是局部近似和将所有计算推迟到分类之后的[惰性学习](https://en.wikipedia.org/wiki/Lazy_learning)。k-近邻算法是所有的机器学习算法中最简单的之一。

<ul>
<li>在 <strong>k-NN</strong> 分类中，输出是一个分类族群。一个对象的分类是由其邻居的 <span class="blue-target">“多数表决”</span> 确定的，k个最近邻居（k为正整数，通常较小）中最常见的分类决定了赋予该对象的类别。若 k = 1，则该对象的类别直接由最近的一个节点赋予。</li>
<li>在 <strong>k-NN</strong> 回归中，输出是该对象的属性值。该值是其k个最近邻居的值的平均值。</li>
</ul>

无论是分类还是回归，衡量邻居的权重都非常有用，使较近邻居的权重比较远邻居的权重大。例如，一种常见的加权方案是给每个邻居权重赋值为 1/ d，其中 d 是到邻居的距离。

<div class="note info">邻居都取自一组已经正确分类（在回归的情况下，指属性值正确）的对象。虽然没要求明确的训练步骤，但这也可以当作是此算法的一个训练样本集。</div>

<div class="note danger">k-近邻算法的缺点是对数据的局部结构非常敏感。本算法与K-平均算法（另一流行的机器学习技术）没有任何关系，请勿与之混淆。</div>

## Algorithm

训练样本是多维特征空间向量，其中每个训练样本带有一个类别标签。算法的训练阶段只包含存储的[特征向量](https://zh.wikipedia.org/wiki/%E7%89%B9%E5%BE%81%E5%80%BC%E5%92%8C%E7%89%B9%E5%BE%81%E5%90%91%E9%87%8F)和训练样本的标签。

在分类阶段，k是一个用户定义的常数。一个没有类别标签的向量（查询或测试点）将被归类为最接近该点的k个样本点中最频繁使用的一类。

一般情况下，将[欧氏距离](https://zh.wikipedia.org/wiki/%E6%AC%A7%E5%87%A0%E9%87%8C%E5%BE%97%E8%B7%9D%E7%A6%BB)作为距离度量，但是这是只适用于[连续变量](https://zh.wikipedia.org/wiki/概率分布#连续分布)。在文本分类这种离散变量情况下，另一个度量——重叠度量（或[海明距离](https://zh.wikipedia.org/wiki/汉明距离)）可以用来作为度量。例如对于基因表达微阵列数据，**k-NN** 也与 **Pearson** 和 **Spearman** 相关系数结合起来使用。通常情况下，如果运用一些特殊的算法来计算度量的话，k近邻分类精度可显著提高，如运用[大间隔最近邻居](https://zh.wikipedia.org/wiki/大间隔最近邻居)或者[邻里成分分析法](https://zh.wikipedia.org/wiki/邻里成分分析)。

**“多数表决”** 分类会在类别分布偏斜时出现缺陷。也就是说，出现频率较多的样本将会主导测试点的预测结果，因为他们比较大可能出现在测试点的 K 邻域而测试点的属性又是通过 k 邻域内的样本计算出来的。解决这个缺点的方法之一是在进行分类时将样本到 k 个近邻点的距离考虑进去。k 近邻点中每一个的分类（对于回归问题来说，是数值）都乘以与测试点之间距离的成反比的权重。另一种克服偏斜的方式是通过数据表示形式的抽象。例如，在[自组织映射](https://zh.wikipedia.org/wiki/自组织映射)（SOM）中，每个节点是相似的点的一个集群的代表（中心），而与它们在原始训练数据的密度无关。**K-NN** 可以应用到 **SOM** 中。

## 发展
然而 k 最近邻居法因为计算量相当的大，所以相当的耗时，Ko 与 Seo 提出一算法 **TCFP**（**t**ext **c**ategorization using **f**eature **p**rojection），尝试利用[特征投影法](https://en.wikipedia.org/wiki/Feature_projection)来降低与分类无关的特征对于系统的影响，并借此提升系统性能，其实验结果显示其分类效果与 k 最近邻居法相近，但其运算所需时间仅需k最近邻居法运算时间的五十分之一。

除了针对文件分类的效率，尚有研究针对如何促进k最近邻居法在文件分类方面的效果，如 Han 等人于 2002 年尝试利用[贪心法](https://zh.wikipedia.org/wiki/贪心算法)，针对文件分类实做可调整权重的k最近邻居法 **WAkNN**（**w**eighted **a**djusted **k** **n**earest **n**eighbor），以促进分类效果；而 Li 等人于 2004 年提出由于不同分类的文件本身有数量上有差异，因此也应该依照训练集合中各种分类的文件数量，选取不同数目的最近邻居，来参与分类。

## Python 代码实现 

```python
# -*- coding: utf-8 -*-
"""
author: Wang Qinhong
date: 2019/10/14
title: 模拟 K Nearest Neighbor Algorithm
IDE: Jet Brains PyCharm 2019.2
"""

from sklearn.datasets import load_iris  # 从 sklearn 中导入鸢尾花数据集
import math  # 数学计算标准库
from collections import Counter  # Collection标准库
import numpy as np  # 导入 numpy 科学计算库


class k_nearest_neighbor_algorithm:
    """ Main K Nearest Neighbor Algorithm

    定义了有关 KNN 算法的基础操作

    Attributes:
        x_train: training test of X
        y_train: training test of Y
        k: The numbers of neighbors
    """

    def __init__(self, k):
        """
        Default Constructor
        :param k: The numbers of neighbors
        """
        self.k = k
        self.x_train = None
        self.y_train = None

    def fit(self, x_train, y_train):
        """
        监督训练
        :param x_train: training test of X
        :param y_train: training test of Y
        :return: This object
        """
        self.x_train = x_train
        self.y_train = y_train
        return self

    def predict(self, x_pretest):
        """
        给定待预测数剧集，给出预测结果向量
        :param x_pretest: 给定结果的数据集
        :return: 预测结果向量
        """
        y_pretest = [self.get_answer(x) for x in x_pretest]
        return np.array(y_pretest)

    def get_answer(self, test_data):
        """
        给定单个数据，返回预测类别
        :param test_data: 测试数据
        :return: 预测结果
        """
        # 计算距离
        d = [math.sqrt(np.sum((test_data - self.x_train[iter]) ** 2)) for iter in range(len(self.x_train))]
        near = np.argsort(d)
        top_k = [self.y_train[iter] for iter in near[0:6]]
        votes = Counter(top_k)  # 计算k个最近邻
        return votes.most_common(1)[0][0]  # 预测结果


# 载入数据集,有iris.data和iris.target
iris = load_iris()

print("TEST DATA: ")
for i in iris:
    print(i + ":")
    print(iris.get(i))

knn = k_nearest_neighbor_algorithm(6)  # 设置 K = 6
knn.fit(iris.data[0:149], iris.target[:149])

answer_target = knn.predict([iris.data[149]])
print("*" * 80, )
print("\nThe answer is: ")
for i, j in zip(iris.feature_names, iris.data[149]):
    print(i + ": ", end="")
    print(j)
print("\n" + r"iris.date[149]'s target is : " + str(answer_target), end="")
print(r", It's " + iris.target_names[int(str(answer_target)[1])] + "\n")
print("*" * 80, )

```

### 输出结果

<img src="./run01.png" alt="run01.png" title="可以看到所有鸢尾花数据集"></img>

<img src="./run02.png" alt="run02.png" title="可以看到所有鸢尾花数据集"></img>

<img src="./run03.png" alt="run03.png" title="训练结果集"></img>

<img src="./run04.png" alt="run04.png" title="测试结果集"></img>

## 参考文献

- [k-nearest neighbors algorithm(From Wikipedia, the free encyclopedia)](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm)
- [最近邻居法(维基百科，自由的百科全书)](https://zh.wikipedia.org/wiki/最近鄰居法)
