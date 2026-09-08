@echo off
REM 小蓝书 APK 一键 build（Windows Batch 版，比 PowerShell 兼容性更好）
REM 用法：scripts\build-apk.bat [debug|release] [api_base_url]
REM 示例：scripts\build-apk.bat debug http://192.168.1.5:8765

setlocal EnableDelayedExpansion

set BUILD_TYPE=debug
if not "%~1"=="" set BUILD_TYPE=%~1

set API_BASE=http://10.0.2.2:8765
if not "%~2"=="" set API_BASE=%~2

echo.
echo ===== 小蓝书 APK 构建 =====
echo   build_type : %BUILD_TYPE%
echo   api_base   : %API_BASE%
echo.

REM --- 1) 检测 flutter ---
where flutter >nul 2>nul
if errorlevel 1 (
    echo  X 未找到 flutter
    echo    安装：https://docs.flutter.dev/get-started/install/windows
    echo    或 winget install --id=Flutter.Flutter -e
    pause
    exit /b 1
)
for /f "delims=" %%v in ('flutter --version ^| findstr /R "Flutter "') do echo  + Flutter %%v

REM --- 2) 检测 java ---
where java >nul 2>nul
if errorlevel 1 (
    echo  X 未找到 java
    echo    安装：winget install Microsoft.OpenJDK.17
    pause
    exit /b 1
)
echo  + Java OK

REM --- 3) 检测 Android SDK ---
set SDK=
if not "%ANDROID_HOME%"=="" set SDK=%ANDROID_HOME%
if "%SDK%"=="" if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" set SDK=%LOCALAPPDATA%\Android\Sdk
if "%SDK%"=="" if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" set SDK=%USERPROFILE%\AppData\Local\Android\Sdk
if "%SDK%"=="" if exist "C:\Android\Sdk\platform-tools\adb.exe" set SDK=C:\Android\Sdk
if "%SDK%"=="" if exist "D:\Android\Sdk\platform-tools\adb.exe" set SDK=D:\Android\Sdk
if "%SDK%"=="" (
    echo  X 未找到 Android SDK
    echo    1^] Android Studio ^> SDK Manager
    echo    2^] setx ANDROID_HOME C:\path\to\Android\Sdk
    pause
    exit /b 1
)
echo  + Android SDK: %SDK%

REM --- 4) 设国内镜像 ---
set PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

REM --- 5) pub get ---
echo.
echo  + pub get...
cd /d "%~dp0..\frontend"
flutter pub get
if errorlevel 1 ( echo  X pub get 失败 & pause & exit /b 1 )

REM --- 6) build apk ---
echo.
echo  + flutter build apk --%BUILD_TYPE% --dart-define=API_BASE_URL=%API_BASE%
if /i "%BUILD_TYPE%"=="release" (
    flutter build apk --release --dart-define=API_BASE_URL=%API_BASE%
) else (
    flutter build apk --debug   --dart-define=API_BASE_URL=%API_BASE%
)
if errorlevel 1 ( echo  X build 失败 & pause & exit /b 1 )

echo.
echo  + 完成 ✓
echo.
echo  APK 输出位置：%~dp0..\frontend\build\app\outputs\flutter-apk\
echo  装机命令  ："%SDK%\platform-tools\adb.exe" install -r %~dp0..\frontend\build\app\outputs\flutter-apk\app-%BUILD_TYPE%.apk
echo.

pause