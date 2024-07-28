# meterpreter-deps

This repository contains source tarballs, binary tools, and other
artifacts required to build meterpreter, but that are not part of its
source code directly.

## LibreSSL

The Python extension now makes use of LibreSSL instead of OpenSSL. To update, do the following:

* Make sure you have [CMake for Windows](https://cmake.org/download/) v3.15 or higher installed.
* Pull the latest version of the [source](https://ftp.usa.openbsd.org/pub/OpenBSD/LibreSSL/) into the `libressl` folder.
* Make sure that the `CMakeLists.txt` file contains the `USE_STATIC_MSVC_RUNTIMES` option.
    * If not, `git checkout CMakeLists.txt` again so that the patched version still exists in the report.
    * If so, we can remove the custom version of the `CMakeLists.txt` file from this repo.
* Make sure that the `sleep` function is patched out of `crypto\compat\posix_win.c`.
* Open a command prompt at this location and type `make.bat` to run the build with the default profile of VS 2019 with `v141_xp`. If you can pass in `VS2013` to build with VS 2013, and it'll use `v120_xp` by default. If you specify `v120_xp` on the command line by itself, VS 2019 will be used with this platform toolset.

Outputted binaries are stored in `output\<platform toolset version>\<arch>`.

When done, commit the changes and push.

Done.
