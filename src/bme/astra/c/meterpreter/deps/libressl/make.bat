@ECHO OFF

SET VS_TITLE=Visual Studio 16 2019
SET VS_VER=VS2019
SET PTS_VER=v141_xp
SET BUILD_64=Y
SET BUILD_86=Y

IF "%1" == "v120_xp" SET PTS_VER=%1
IF "%2" == "v120_xp" SET PTS_VER=%2
IF "%3" == "v120_xp" SET PTS_VER=%3

REM If VS2013 is used, we have to stick to v121_xp
IF "%1" == "VS2013" (
    SET VS_TITLE=Visual Studio 12 2013
    SET PTS_VER=v120_xp
    SET VS_VER=%1
)
IF "%2" == "VS2013" (
    SET VS_TITLE=Visual Studio 12 2013
    SET PTS_VER=v120_xp
    SET VS_VER=%2
)
IF "%3" == "VS2013" (
    SET VS_TITLE=Visual Studio 12 2013
    SET PTS_VER=v120_xp
    SET VS_VER=%3
)

IF "%1" == "x86" SET BUILD_64=N
IF "%2" == "x86" SET BUILD_64=N
IF "%3" == "x86" SET BUILD_64=N
IF "%1" == "x64" SET BUILD_86=N
IF "%2" == "x64" SET BUILD_86=N
IF "%3" == "x64" SET BUILD_86=N


IF "%BUILD_64%" == "Y" (
    @ECHO Building for "%VS_TITLE%" with %PTS_VER% for arch x64
    cmake -G "%VS_TITLE%" -DUSE_STATIC_MSVC_RUNTIMES=ON -DLIBRESSL_APPS=OFF -DLIBRESSL_TESTS=OFF -A x64 -T %PTS_VER% -S . -B build\%VS_VER%\x64 -Wno-dev
    cmake --build build\%VS_VER%\x64 --config Release --clean-first
    IF NOT EXIST "output\%PTS_VER%\x64" mkdir output\%PTS_VER%\x64
    move /Y build\%VS_VER%\x64\ssl\Release\ssl*.lib output\%PTS_VER%\x64
    move /Y build\%VS_VER%\x64\tls\Release\tls*.lib output\%PTS_VER%\x64
    move /Y build\%VS_VER%\x64\crypto\Release\crypto*.lib output\%PTS_VER%\x64
)

IF "%BUILD_86%" == "Y" (
    @ECHO Building for "%VS_TITLE%" with %PTS_VER% for arch x86
    cmake -G "%VS_TITLE%" -DUSE_STATIC_MSVC_RUNTIMES=ON -DLIBRESSL_APPS=OFF -DLIBRESSL_TESTS=OFF -A Win32 -T %PTS_VER% -S . -B build\%VS_VER%\x86 -Wno-dev
    cmake --build build\%VS_VER%\x86 --config Release --clean-first
    IF NOT EXIST "output\%PTS_VER%\x86" mkdir output\%PTS_VER%\x86
    move /Y build\%VS_VER%\x86\ssl\Release\ssl*.lib output\%PTS_VER%\x86
    move /Y build\%VS_VER%\x86\tls\Release\tls*.lib output\%PTS_VER%\x86
    move /Y build\%VS_VER%\x86\crypto\Release\crypto*.lib output\%PTS_VER%\x86
)

:END

