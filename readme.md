# Nirvana SDK

This is a part of the [Nirvana project](https://github.com/nirvanaos/home).

## Purpose

This repository is used for building and testing the Nirvana SDK.

## Contents

### Nirvana runtime library

```
#include <Nirvana/Nirvana.h>
```

- Runtime support for IDL compiled C++ code.
- IDL definitions of the Nirvana Core interfaces.
- Various utilities.

### Standard C library

Nirvana SDK includes POSIX compatible standard C runtime library built over the Nirvana runtime library.

#### Standard math library

Nirvana SDK includes clone of [Openlibm library](https://github.com/JuliaMath/openlibm) which provides standard C mathematical API.

### Standard C++ library

Nirvana SDK contains [LLVM libc++ library](https://libcxx.llvm.org/) built over Nirvana standard C library.

### Google test library

Google test library libgoogletest-nirvana.a built over Nirvana runtime libraries.
It may be used for unit test creation.

### Platforms

Nirvana was initially designed portable to different platforms.

Currently supported platforms are:

- x64 (AMD 64)
- x86 (Intel 386)

Other platforms will be added in the future.

For each platform SDK includes Debug and Release libraries.

### CMake modules

nirvana.cmake file used as CMake toolchain to use the Nirvana SDK.
NirvanaSDK.cmake contains convenient functions for Nirvana modules development with Nirvana SDK and CMake.

## How to use

The SDK installation included in the Nirvana setup.

## Test and debug strategy

Nirvana C runtime library interacts with Nirvana Core via 3 interfaces:

```
module Nirvana {

pseudo interface Memory;
pseudo interface POSIX;
pseudo interface Debug;

};
```

SDK repository includes the special mock module for testing libraries without the Nirvana Core.
It provides above interfaces and redirects Core interface calls into calls to a host OS.
This lets test and debug SDK components without the Nirvana Core, over the development host OS.
Currently only Microsoft Windows supported as host OS for the SDK development.

## How to develop

### Prerequisites

Currently, only Microsoft Windows may be used as host OS for development.

- Download and unpack [clang+llvm-21.1.0-x86_64-pc-windows-msvc](https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.0/clang+llvm-21.1.0-x86_64-pc-windows-msvc.tar.xz)
- Set environment variable LLVM_PATH to unpacked directory.
- CMake and Ninja must be installed.

We recommend use Visual Studio Code as IDE.

### Prepare build environment

```
.\prepare.ps1
```

### Build

Use CMake with settings from CMakePresets.json file.

### Debug

For debugging x64 platform use [LLDB DAP extension](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.lldb-dap) with lldb-dap.executable-path set to lldb-dap.exe path in the LLVM release unpacked.

For debugging x86 platform I'm using [GDB DAP extension](https://marketplace.visualstudio.com/items?itemName=OlegTolmatcev.gdb-dap)
because using lldb-dap currently causes problems.
