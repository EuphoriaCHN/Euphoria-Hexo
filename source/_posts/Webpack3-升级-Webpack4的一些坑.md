---
title: Webpack 3 升级 Webpack 4 的一些坑
date: 2020-03-11 18:56:17
tags:
- Web
- JavaScript
- Webpack
categories:
- 前端
- Webpack
---

> <span class = 'introduction'>世事总是难以意料，一个人的命运往往在一瞬间会发生转变。</span><br/>
有的时候从网上 clone 下来的项目，人家使用的是 Webpack 3，但是你如果想直接用到自己的 Webpack 4 项目中，那就要小心了！

<!--more-->

<hr/>

## 安装注意

安装 Webpack 4：`yarn add webpack@4 -D`，但是这里还有一个新增依赖 `webpack-cli`。

`webpack-cli` 在 webpack 3 中是和 `webpack` 在一起的，但 webpack 4 将其拆分为两个包去管理。

<hr />

## 运行注意

### UglifyJsPlugin 被移除了

<div class="note danger">Error:webpack.optimize.UglifyJsPlugin has been removed,pleaseuseconfig.optimization.minimizeinstead.</div>

`UglifyJsPlugin` 是用来对最后生成的 JavaScript 文件进行丑化压缩。

webpack 4 中 `UglifyJsPlugin` 被废除，需要安装新的插件 `uglifyjs-webpack-plugin` 进行替换，见<a href="https://webpack.docschina.org/migrate/4/#update-plugins">官方文档</a>。

```bash
yarn add uglifyjs-webpack-plugin -D 
```

更改 *webpack.dll.config.js* || *webpack.prod.config.js*：

```javascript
-  new webpack.optimize.UglifyJsPlugin({
-    compress: {
-      warnings: false
-    },
-    mangle: {
-      safari10: true,
-    },
-    output: {
-      comments: false,
-      ascii_only: true,
-    },
-    sourceMap: false,
-    comments: false
-  }),
```

增加：

```javascript
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
// ...
optimization: { // 与 entry 同级
    minimizer: [
      new UglifyJsPlugin({
        uglifyOptions: {
          compress: false,
          mangle: true,
          output: {
            comments: false,
          },
        },
        sourceMap: false,
      })
    ]   
},
```

`uglifyjs-webpack-plugin` 更多的配置请参考<a href="https://www.npmjs.com/package/uglifyjs-webpack-plugin2">详细配置</a>。

### CommonsChunkPlugin 被移除了

<div class="note danger">Error: webpack.optimize.CommonsChunkPlugin has been removed, please use config.optimization.splitChunks instead.</div>

`CommonsChunkPlugin` 主要是用来提取第三方库和公共模块，已被移除，用 `splitChunks` 替代，见 <a href="https://webpack.docschina.org/migrate/4/#commonschunkplugin">官方文档</a>。

**更改 webpack.base.config.js**：

去除：

```javascript
// new webpack.optimize.CommonsChunkPlugin({
//   children: true,
//   async: true,
//   minChunks: 2,
// }),
```

添加：

```javascript
optimization: {
    splitChunks: {
      chunks: 'async',
      minChunks: 2,
    },
  },
```

`splitChunks` 更多的配置请参考 <a href="https://webpack.docschina.org/plugins/split-chunks-plugin/">详细配置</a>。

### applyPluginsWaterfall 不是一个函数

<div class="note danger">compilation.mainTemplate.applyPluginsWaterfall is not a function</div>

更新 `html-webpack-plugin` 到最新版本：`yarn add html-webpack-plugin@latest -D` 即可。

### 关于 Chunk.entrypoints

<div class="note danger">Chunk.entrypoints: Use Chunks.groupsIterable and filter by instanceof Entrypoint instead</div>

这个最后解决方式是用 `mini-css-extract-plugin` 替代。

#### 解决过程：

1. 更新 `extract-webpack-plugin` 到最新版本：`yarn add extract-text-webpack-plugin@latest`；

这个时候可能会报一个错：

<div class="note danger">Path variable [contenthash] not implemented in this context: static/css/style.[contenthash].css</div>

在之前版本中我们使用 `extract-text-webpack-plugin` 来提取 CSS 文件，不过在 webpack 4 中则应该使用 `mini-css-extract-plugin` 来提取 CSS 到单独文件中，基于 Webpack 3，更改如下：

```javascript
const utils = require('./utils')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
module.exports = {
    //...
    new MiniCssExtractPlugin({
        filename: utils.assetsPath('css/[name].[contenthash:7].css')
    })
}
```

CSS 以及 `mini-css-extract-plugin` 的 rule 配置：

```javascript
module: {
    rules: [
      {
        test: /\.(css|less)$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: 'css-loader',
            options: {
              modules: true,
              importLoaders: 1,
              localIdentName: '[local]'
            }
          },
          {
            loader: 'postcss-loader',
            options: {
              ident: 'postcss',
              plugins: () => [
                require('postcss-flexbugs-fixes'),
                autoprefixer({
                  browsers: [
                    '>1%',
                    'last 4 versions',
                    'Firefox ESR',
                    'not ie < 9', // React doesn't support IE8 anyway
                  ],
                  flexbox: 'no-2009',
                }),
              ],
            }
          },
          {
            loader: 'less-loader',
            options: {
              modifyVars: theme
            }
          }
        ]

      },
    ],
  },
```

### DedupePlugin 不是一个构造器

<div class="note danger">TypeError: webpack.optimize.DedupePlugin is not a constructor</div>

`DedupePlugin` 是用来查找相等或近似的模块，避免在最终生成的文件中出现重复的模块。

这个就比较惨了，被废除了，删除即可，详情见 <a href="https://webpack.docschina.org/migrate/3/#%E7%A7%BB%E9%99%A4-dedupeplugin">官方文档</a>。

### 内存溢出

<div class="note danger">FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of...</div>

这个是内存溢出了，需要在启动命令中加一个空间 `--max_old_space_size=4096`：

```json
"scripts": {
    "start": "better-npm-run start",
},
"betterScripts": {
    "start": {
      "command": "node --max_old_space_size=4096 build/server.js",
      "env": {
        "NODE_ENV": "development",
        "DEPLOY_ENV": "",
        "PUBLIC_URL": "",
        "PORT": "8082"
      }
    },
}
```

### offline-plugin 问题

如果你安装了 `offline-plugin` 且配置了 service worker，这个插件的报错同以上 **UglifyJsPlugin** 的报错！

只需要更新到最新版本即可。

<hr />

## 新增的 TS 打包

### 安装

```bash
npm install --save-dev typescript ts-loader
```

### 添加 tsconfig.json 文件

可以利用 ts 初始化命令自动添加：`tsc --init`。

也可以手动新增文件。

其中配置详情如下，具体查阅 <a href="https://www.typescriptlang.org/docs/handbook/tsconfig-json.html">tsconfig.json 配置详情</a>。

```json
{
  "compilerOptions": {
    "outDir": "./dist/",
    "noImplicitAny": true,
    "module": "commonjs",
    "target": "es5",
    "jsx": "react",
    "allowJs": true,
    "moduleResolution": "node",
    "esModuleInterop": true,
    "experimentalDecorators": true,
    "noUnusedParameters": true,
    "noUnusedLocals": true,
  },
  "module": "ESNext",
  "exclude": ["node_modules"]
}
```

### 配置 webpack 处理 TypeScript

```javascript
// 1. 配置 rules
rules: [
  {
    test: /\.tsx?$/,
    use: 'ts-loader',
    exclude: /node_modules/
  }
]
// 2. 添加需要处理的文件后缀
resolve: {
    extensions: [ '.tsx', '.ts', '.js' ]
},
```

### 测试文件 TestTsLoader.tsx

用来检测是否配置成功，导入相应页面即可测试。

```typescript jsx
import * as React from "react"

interface TsProps {
  name: string
  company: string
}

export default class TestTsLoader extends React.Component<TsProps, {}> {
  render() {
    return (
      <h1>
        Hello, I am {this.props.name}, I in {this.props.company} now!
      </h1>
    )
  }
}
```

<hr />

## 参考资料

<ol>
<li><a href="https://segmentfault.com/a/1190000019864163">webpack3 升级 webpack4踩坑记录</a></li>
<li><a href="https://blog.csdn.net/harsima/article/details/80819747">Vue项目升级到Webpack 4.x初步踩坑总结</a></li>
<li><a href="https://www.typescriptlang.org/docs/handbook/tsconfig-json.html">tsconfig.json</a></li>
<li><a href="https://webpack.docschina.org/migrate/">Webpack 迁移</a></li>
</ol>
