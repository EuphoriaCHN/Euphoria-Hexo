---
title: Compile C++ Module To JavaScript and GoLang
date: 2021-03-04 20:39:03
updated: 2020-08-31 00:19:08
tags:
- 杂七杂八
categories:
- 杂七杂八
copyright: true
---

> When you’ve written a new code module in a language like C/C++, you can compile it into WebAssembly, or GoLang packages. Let's look at how it works.

<!--more-->

<hr/>

## Compile C++ With node-gyp

### References

- [Node JS Handbook](http://nodejs.cn/api/addons.html)
- [给 Node.js 编译 C++ 扩展](https://github.com/chemdemo/chemdemo.github.io/issues/7)

### Install node-gyp

```shell
npm install node-gyp
```

### Configuration

`/binding.gyp`

```json
{
  "targets": [
    {
      "target_name": "starling_validate",
      "sources": [
        "./src/main.cpp",
        "./src/sayHello.cpp"
      ]
    }
  ]
}
```

- `sources`: Like CMake configuration, write all c++ source file which compiler need.

### Writing C++ Source File

`main.cpp`

```c++
#include <node.h>
#include <v8.h>

void Method(const v8::FunctionCallbackInfo<v8::Value>& args) {
    v8::Isolate* isolate = args.GetIsolate();
    
    args.GetReturnValue().Set(v8::String::NewFromUtf8(isolate, "FUCK").ToLocalChecked());
}

/**
 * @param exports CommonJS exports
 */
void initialize(v8::Local<v8::Object> exports) {
    v8::Isolate *isolate = exports->GetIsolate();
    v8::Local<v8::Context> context = isolate->GetCurrentContext();

    // Set a variable attribute on exports object
    exports->Set(
            context,
            // Key is "Hello"
            v8::String::NewFromUtf8(isolate, "Hello").ToLocalChecked(),
            // Value is "World"
            v8::String::NewFromUtf8(isolate, "World").ToLocalChecked()
    );

    // Set a function attribute on exports object
    // Key is "FUCK"
    // Value is Method function
    NODE_SET_METHOD(exports, "FUCK", Method);
}

// It is not a function call
// Not write semicolon at end!
NODE_MODULE(NODE_GYP_MODULE_NAME, initialize)
```

### Configuration CMakeLists

> This step just let IDE knows c++ libraries path, like clion

`/CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.17)
project(cpp)

set(CMAKE_CXX_STANDARD 14)

include_directories(
        src
        # NodeJS source code
        /Users/bytedance/.node-gyp/14.2.0/include/node
)

add_executable(cpp
        # node-gyp libraries
        node_modules/node-gyp/gyp/data/win/large-pdb-shim.cc
        node_modules/node-gyp/src/win_delay_load_hook.cc
        src/main.cpp
        # If you have other c++ files, write them here
        # Example:
        # src/other.cpp
        )
```

### Build

#### Configure

Run `node-gyp configure` at project root path.

If success, there will create `build` folder at project root path.

#### Build

Run `node-gyp build` to build at **first time**.

If success, there will create `Release` folder at `/build`.

#### Rebuild

Run `node-gyp rebuild` to update compiled product

### Test

Create `.js` file and import node-gyp compiled product:

```javascript
const demo = require('./build/Release');

console.log(demo);
/*
{
  Hello: "World",
  Fuck: [Function]
}
 */
```

## Convert C++ Source File With Emscription

### References

- [Emscription Handbook](https://emscripten.org/index.html)
- [Compiling a New C/C++ Module to WebAssembly](https://developer.mozilla.org/en-US/docs/WebAssembly/C_to_wasm)
- [Learning Emscripten: Compile C/C++ to JavaScript](https://www.dynamsoft.com/codepool/emscripten-compile-cc-javascript.html)

### Install Emscription

```shell
# Get the emsdk repo
git clone https://github.com/emscripten-core/emsdk.git

# Enter that directory
cd emsdk

# Fetch the latest version of the emsdk (not needed the first time you clone)
git pull

# Download and install the latest SDK tools.
./emsdk install latest

# Make the "latest" SDK "active" for the current user. (writes .emscripten file)
./emsdk activate latest

# Activate PATH and other environment variables in the current terminal
source ./emsdk_env.sh
```

### Attention

At `./emsdk install latest`, you may experience network problems:

```text
Installing SDK 'sdk-releases-upstream-fc5562126762ab26c4757147a3b4c24e85a7289e-64bit'..
Installing tool 'node-14.15.5-64bit'..
Error: Downloading URL 'https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v14.15.5-darwin-x64.tar.gz': <urlopen error [Errno 61] Connection refused>
Installation failed!
```

But if you open URL `https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v14.15.5-darwin-x64.tar.gz` in browser and it download successfully.

Then, edit `emsdk.py`, search key word `download_file`, may at line `#678`:

```python
# On success, returns the filename on the disk pointing to the destination file that was produced
# On failure, returns None.
def download_file(url, dstpath, download_even_if_exists=False, filename_prefix=''):
  debug_print('download_file(url=' + url + ', dstpath=' + dstpath + ')')
  file_name = get_download_target(url, dstpath, filename_prefix)

  if os.path.exists(file_name) and not download_even_if_exists:
      print("File '" + file_name + "' already downloaded, skipping.")
      return file_name
```

Modify the `if` judgment logic to:

```python
if os.path.exists(file_name):
    print("File '" + file_name + "' already downloaded, skipping.")
    return file_name
```

Then, create `zip` folder at emsdk root and enter `zip` folder:

```shell
mkdir zip && cd zip
```

Use `curl` or `wget` to download package directly:

```shell
wget https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v14.15.5-darwin-x64.tar.gz
```

Then, back to emsdk root and re-run install scripts:

```shell
cd ../
./emsdk install latest
```

Then, emsdk will print log:

```text
Installing SDK 'sdk-releases-upstream-fc5562126762ab26c4757147a3b4c24e85a7289e-64bit'..
Skipped installing node-14.15.5-64bit, already installed.
```

> Emsdk will install 3 packages at latest, so you will repeat the above steps at least three times!

### Using

If emsdk install successfully, there will create 2 binary files:

- /emsdk/upstream/emscripten/emcc
- /emsdk/upstream/emscripten/em++

> Looks lite `gcc` and `g++` :)

Create a C++ source file and write code:

```c++
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Hello world";
    return 0;
}
```

Then, using emsdk to convert it:

```shell
em++ ./tests.cpp
```

It will create `a.out.js` and `a.out.wasm`, then run `node ./a.out.js` will see result:

```shell
node ./a.out.js
Hello world
```

### Optimization

The optimizations provided by -O2 are much more aggressive. 
If you run the following command and inspect the generated code (a.out.js) you will see that it looks very different:

```shell
em++ -O2 ./tests.cpp
```

### Generating HTML

Emscripten can also generate HTML for testing embedded JavaScript. To generate HTML, use the -o (output) command and specify an html file as the target file:

```shell
em++ ./tests.cpp -o tests.html
```

You can now open hello.html in a web browser.

> Unfortunately several browsers (including Chrome, Safari, and Internet Explorer) do not support file:// XHR requests, and can’t load extra files needed by the HTML (like a .wasm file, or packaged file data as mentioned lower down). For these browsers you’ll need to serve the files using a local webserver and then open http://localhost:8000/tests.html).

## Compile C++ to .so

Example：

- Create module `student.h` and implements it:

```c++
// student.h
#include <iostream>
#include <string>

class Student {
public:
    Student(){}
    ~Student(){}

    void setName(std::string);
    void display(void);
private:
    std::string name;
};

// student.cpp
#include "./student.h"

void Student::setName(std::string _name) {
    this->name = _name;
}

void Student::display() {
    std::cout << "Name: " << this->name << std::endl;
}
```

- Create interface and it need to extern "C":

```c++
// interface.h
#ifdef __cplusplus
extern "C" {
#endif
    void *stuCreate();
    void initName(void *, char* name);
    void display(void *);

#ifdef __cplusplus
};
#endif

// interface.cpp
#include "./interface.h"
#include "./student.h"

#ifdef __cplusplus
extern "C" {
#endif
    void *stuCreate() {
        return new Student();
    }

    void initName(void *p, char* name) {
        static_cast<Student *>(p)->setName(name);
    }

    void display(void *p) {
        static_cast<Student *>(p)->display();
    }
#ifdef __cplusplus
};
#endif
```

Then, use `g++` to compile it:

```shell
g++ student.cpp interface.cpp -fPIC -shared -o libstu.so
```

### Call C++ lib in C

Write a C test case:

```c
#include "interface.h"

int main() {
    void *p = stuCreate();
    char *name = "WQH";

    initName(p, name);

    display(p);

    return 0;
}
```

compile it:

```shell
gcc main.c -L. -lstu
./a.out
```

You can see `Name: WQH` in terminal log.

congratulation! 

### Call C++ lib in GoLang

Write a GoLang test case:

```go
// main.go
package  main

/*
#cgo CFLAGS: -I./
#cgo LDFLAGS: -L./ -lstu
#include <stdlib.h>
#include <stdio.h>
#include "interface.h" //非标准c头文件，所以用引号
*/
import "C"

import(
    "unsafe"
)

func main() {
    name := "test!"
    cStr := C.CString(name)
    defer C.free(unsafe.Pointer(cStr))

    obj := C.stuCreate()
    C.initName(obj, cStr)
    C.display(obj)
}
```

And run it:

```shell
go run main.go
```

You can see `Name: test` in terminal log.

> 第一次写英文的哈哈哈哈，水平有限，不好意思