# 小蓝书 Android APK 构建脚本（Windows 本机用）
# 用法：在 PowerShell 里跑 .\scripts\build-apk.ps1
#
# 需要本机已装：
#   1. Flutter SDK (3.19+)        — https://docs.flutter.dev/get-started/install/windows
#   2. JDK 17 (Temurin)            — winget install Microsoft.OpenJDK.17
#   3. Android SDK (你有)          — 默认 C:\Users\19703\AppData\Local\Android\Sdk
#   4. Android Studio (推荐)       — 一键配齐 SDK + emulator + platform-tools
#
# 自定义后端地址：.\scripts\build-apk.ps1 -ApiBaseUrl http://192.168.1.5:8765

param(
    [string]$ApiBaseUrl = "http://10.0.2.2:8765",
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug"
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  ✗ $msg" -ForegroundColor Red }

# ---------- 1. 环境检测 ----------

Write-Step "环境检测..."

# Flutter
try {
    $flutterVer = (& flutter --version 2>&1) | Select-Object -First 1
    Write-Ok "Flutter: $flutterVer"
} catch {
    Write-Err "未找到 flutter 命令"
    Write-Host "    安装：https://docs.flutter.dev/get-started/install/windows"
    Write-Host "    或 PowerShell：winget install --id=Flutter.Flutter -e"
    exit 1
}

# Java
try {
    $javaVer = (& java -version 2>&1) | Select-Object -First 1
    Write-Ok "Java: $javaVer"
} catch {
    Write-Err "未找到 java 命令"
    Write-Host "    安装：winget install Microsoft.OpenJDK.17"
    exit 1
}

# Android SDK
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $candidates = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "C:\Android\Sdk",
        "D:\Android\Sdk"
    )
    foreach ($p in $candidates) {
        if (Test-Path "$p\platform-tools\adb.exe") { $androidHome = $p; break }
    }
}
if (-not $androidHome -or -not (Test-Path "$androidHome\platform-tools\adb.exe")) {
    Write-Err "未找到 Android SDK"
    Write-Host "    1) 打开 Android Studio → More Actions → SDK Manager"
    Write-Host "    2) 或设环境变量：`setx ANDROID_HOME C:\path\to\Android\Sdk`"
    Write-Host "    3) 验证：`$androidHome\platform-tools\adb.exe --version`"
    exit 1
}
$env:ANDROID_HOME = $androidHome
Write-Ok "Android SDK: $androidHome"

# ---------- 2. 项目定位 ----------

Write-Step "定位项目..."
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$frontendDir = Join-Path $projectRoot "frontend"

if (-not (Test-Path "$frontendDir\pubspec.yaml")) {
    Write-Err "找不到 frontend\pubspec.yaml（项目根=$projectRoot）"
    exit 1
}
Write-Ok "项目根: $projectRoot"
Write-Ok "Flutter 工程: $frontendDir"

# ---------- 3. Flutter 配置 ----------

Write-Step "Flutter doctor 快速检查..."
$doctorOut = & flutter doctor 2>&1
$doctorOut | ForEach-Object { Write-Host "    $_" }

Write-Step "设置国内镜像（清华源）..."
$env:PUB_HOSTED_URL = "https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# ---------- 4. Pub get ----------

Write-Step "拉依赖（flutter pub get）..."
Push-Location $frontendDir
try {
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { Write-Err "pub get 失败"; exit 1 }
    Write-Ok "依赖装好"
} finally {
    Pop-Location
}

# ---------- 5. Build APK ----------

Write-Step "构建 APK（$BuildType, API=$ApiBaseUrl）..."
Push-Location $frontendDir
try {
    $apkName = "app-$($BuildType).apk"
    if ($BuildType -eq "release") {
        & flutter build apk --release --dart-define=API_BASE_URL=$ApiBaseUrl
    } else {
        & flutter build apk --debug   --dart-define=API_BASE_URL=$ApiBaseUrl
    }
    if ($LASTEXITCODE -ne 0) { Write-Err "build apk 失败"; exit 1 }
    Write-Ok "APK 编译成功"

    $apkPath = Join-Path $frontendDir "build\app\outputs\flutter-apk\$apkName"
    if (Test-Path $apkPath) {
        $size = (Get-Item $apkPath).Length / 1MB
        Write-Ok "输出: $apkPath ($([math]::Round($size, 1)) MB)"
        Write-Host ""
        Write-Host "  📦 装机方式（任选其一）：" -ForegroundColor Cyan
        Write-Host "    1) USB 连手机 + 打开开发者模式/USB 调试 →"
        Write-Host "       $androidHome\platform-tools\adb.exe install -r `"$apkPath`""
        Write-Host "    2) 把 APK 文件传到手机（QQ/微信/网盘），手机端点击安装"
        Write-Host "    3) 启动 emulator（emulator -avd Pixel_7）后再 adb install"
        Write-Host ""
    } else {
        Write-Warn "找不到 $apkPath，请到 $frontendDir\build\app\outputs\flutter-apk\ 看实际文件名"
    }
} finally {
    Pop-Location
}

Write-Ok "完成 ✓"