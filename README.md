# 小蓝书（Xiaolanbook）— 短视频 + 图文笔记社区

> 反推自 `小蓝书.apk.1` 的优化重写版 · 跨端同步（Android + iOS）· FastAPI 后端

---

# 🚀 5 分钟出 APK — GitHub Actions 路线（**唯一推荐**）

> **为什么走 GitHub**：你本机**不用**装 Flutter SDK（1GB 下载）、**不用**装 JDK、**不用**配置 Android 环境。云端 Actions 自动下 Flutter + Android SDK + 编译 APK，**15 分钟左右**自动产出 `app-debug.apk`，你下载到电脑装手机即可。

## Step 1 — 注册 GitHub + 建空仓库（一次性，2 分钟）

1. 打开 <https://github.com> 注册/登录账号
2. 点右上角 `+` → **New repository**
3. 填：
   - **Repository name**：`xiaolanbook`（或随便）
   - **Public**（必须 public，private 要 GitHub Pro 才能跑 Actions）
   - ⚠️ **Add a README file** ❌ 取消勾选
   - ⚠️ **Add .gitignore** ❌ 取消勾选
   - ⚠️ **Choose a license** ❌ 选 None
4. 点 **Create repository**

记下页面给你的仓库地址，形如：

```
https://github.com/你的用户名/xiaolanbook.git
```

## Step 2 — 解压源码 + 推到 GitHub（3 分钟）

把前面下载的 `xiaolanbook.zip` 解压到任意目录，**路径不要有中文和空格**，例如：

```
D:\project\xiaolanbook\
```

打开 PowerShell，依次跑：

```powershell
# 切到项目根（解压后的目录）
cd D:\project\xiaolanbook

# 第一次用 git 时设一下身份
git config --global user.name "你的名字"
git config --global user.email "你的邮箱@example.com"

# 初始化 + 提交
git init
git add .
git commit -m "init: xiaolanbook auth scaffold"

# 把 main 改成默认分支名
git branch -M main

# 关联远程仓库（替换 URL 里的 用户名）
git remote add origin https://github.com/你的用户名/xiaolanbook.git

# 推送
git push -u origin main
```

> 推送时可能弹窗要求登录 GitHub，按提示在浏览器授权即可。

## Step 3 — 触发 Actions 自动 build（10-15 分钟）

打开浏览器：

```
https://github.com/你的用户名/xiaolanbook/actions
```

你会看到一个 `Build Android APK` workflow 正在跑（橙色转圈）。点进去能看实时日志。

**首次 build 较慢**（≈ 12-15 分钟）—— 因为 Actions 要下载：
- Flutter SDK 3.24（约 1 GB）
- Android SDK + platform-tools + build-tools + platforms-android-34
- Gradle + 所有 npm/pub 包

**第二次 build 很快**（2-3 分钟，因为有缓存）。

## Step 4 — 下载 APK（1 分钟）

Actions 跑完后（绿勾 ✓）：

1. 还在 Actions 页面 → 点完成的 run
2. 页面**最底部 Artifacts** 区域 → 有个 `xiaolanbook-debug.apk` 链接
3. 点下载 → 浏览器保存到 `Downloads\xiaolanbook-debug.apk`

## Step 5 — 装到手机（2 分钟）

```powershell
# 1. 手机开 USB 调试：设置 → 系统 → 开发者选项 → USB 调试（开发者选项默认隐藏，
#    需要到「关于手机」里点 7 次版本号激活）

# 2. USB 数据线连电脑，选「传输文件」模式

# 3. 确认 adb 看到设备
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe devices
# 输出形如："xxxxxxx  device" 就对了

# 4. 装 APK
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe install -r "$env:USERPROFILE\Downloads\xiaolanbook-debug.apk"

# 或者把 Downloads\xiaolanbook-debug.apk 拷到手机文件管理器，点击安装
```

装完桌面会出现 **📘 小蓝书** 图标。点开 → splash → 登录页。

## Step 6 — 连后端

装好的 App 默认连 `http://10.0.2.2:8765`（Android 模拟器地址）。**真机调试要改 IP**：

1. 查电脑 IP：`ipconfig` 找 `IPv4 地址`（形如 `192.168.1.10`）
2. 在项目根 `D:\project\xiaolanbook` 改 Actions 输入：
   - 打开 Actions 页面 → 选 `Build Android APK` → 右侧 **Run workflow**
   - 展开后填 `api_base_url: http://192.168.1.10:8765`（替换成你电脑 IP）
   - 点绿色 **Run workflow** 按钮
3. 等 2-3 分钟 build 完 → 下载新 APK 装机

## ⚠️ 踩过的坑（按出现频率排序）

| 坑 | 表现 | 解决 |
|---|---|---|
| **Repo 勾了 README** | push 时 `git push` 报"rejected"或冲突 | 在 GitHub 网页删掉 repo 重来，**所有勾选都取消** |
| **git 没设 user.email** | commit 报错 "Please tell me who you are" | 跑上面 `git config --global user.email` |
| **Windows 路径有中文** | Actions build 偶尔报路径错误 | 放纯英文路径，如 `D:\project\xiaolanbook` |
| **Release APK 想跑通** | 报"signing config not found" | 当前 workflow 只跑 debug；release 要先在 GitHub Secrets 加 keystore |
| **adb devices 看不到手机** | 列表空 | 检查 USB 调试是否真开 + 数据线模式选"传输文件" + 装手机厂商 USB 驱动（小米/vivo/华为各有） |
| **App 打开白屏/连不上后端** | splash 后卡住 | 后端没启动，或手机和电脑不在同一 WiFi，或后端没绑 `0.0.0.0` |
| **首次 GitHub Actions 慢** | 跑到 Gradle 卡 5 分钟 | 正常，等等就好；失败重试一次 |

---

# 📦 项目结构

```
xiaolanbook/
├── backend/                      FastAPI 后端（已实现并跑通 8 项 curl 测试）
│   ├── app/
│   │   ├── main.py               入口
│   │   ├── config.py             配置（DB / JWT / CORS）
│   │   ├── database.py           SQLAlchemy 引擎
│   │   ├── models.py             User ORM
│   │   ├── schemas.py            Pydantic 契约
│   │   ├── auth.py               bcrypt + JWT
│   │   ├── deps.py               current_user 依赖
│   │   └── routers/users.py      注册/登录/me/send-sms
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/                     Flutter 客户端
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart             ProviderScope 入口
│   │   ├── app.dart              GoRouter
│   │   ├── core/
│   │   │   ├── config.dart       API base URL
│   │   │   ├── network/dio_client.dart   Dio + Bearer 拦截器
│   │   │   ├── storage/token_storage.dart  flutter_secure_storage
│   │   │   └── theme/app_theme.dart       深蓝 #1F365D 主题
│   │   └── features/auth/        Clean Architecture 三层
│   │       ├── data/             DTO + DataSource + Repository Impl
│   │       ├── domain/           Entity + Repository 接口
│   │       └── presentation/     Riverpod + Pages
│   └── analysis_options.yaml
│
├── scripts/                      本机 build 备用脚本（用 GitHub Actions 可忽略）
│   ├── build-apk.ps1
│   └── build-apk.bat
│
└── .github/workflows/
    └── build-apk.yml             ⭐ Actions 自动 build 配置
```

---

# 🛠 备选路线：本机 build（如果你不想用 GitHub）

需要本机装 Flutter SDK（~1 GB 下载）。

```powershell
winget install --id=Flutter.Flutter -e
winget install --id=Microsoft.OpenJDK.17 -e
# 重开 PowerShell
cd D:\project\xiaolanbook
.\scripts\build-apk.ps1
# 产出：frontend\build\app\outputs\flutter-apk\app-debug.apk
```

---

# 🔌 后端 API 协议

| Method | Path | 说明 |
|---|---|---|
| `GET` | `/` | 服务信息 |
| `GET` | `/api/users/health` | 健康检查 |
| `POST` | `/api/users/register` | 注册（phone + password + nickname 可选）→ 返回 token + user |
| `POST` | `/api/users/login` | 登录（phone + password）→ 返回 token + user |
| `POST` | `/api/users/send-sms` | 发送验证码（占位实现：dev 固定 123456） |
| `GET` | `/api/users/me` | 当前用户（Header `Authorization: Bearer <token>`） |

### 错误码

| 状态码 | 含义 |
|---|---|
| 400 | 手机号格式错误 |
| 401 | 密码错 / token 缺失或失效 |
| 403 | 账号已停用 |
| 404 | 用户不存在 |
| 409 | 手机号已注册 |
| 422 | 请求体字段校验失败 |

---

# 🔄 后续路线（按优先级）

1. **Phase 2 — 双 Feed**（下一步）
   - 后端：`Video` / `Note` 模型 + `GET /api/notes` `GET /api/videos` 分页接口
   - 前端：双列瀑布流 + Coil 图片缓存 + Media3 ExoPlayer 视频播放
2. **Phase 3 — 发布 + 评论**
   - 视频上传（Multipart + 阿里云 OSS）
   - 富文本编辑器 / 图片多选
   - 点赞/收藏 toggle 接口
3. **Phase 4 — 推送 + 运营**
   - 极光 Push（小米/华为/vivo 多通道）
   - Bugly 崩溃统计
   - 阿里云 OSS / CDN

---

# ❓ FAQ

**Q: 为什么走 GitHub Actions 而不是本地 build？**
A: 本地 build 要装 Flutter SDK（1GB+）、JDK、Android Studio 等一堆工具，对只装 Android SDK 的环境不友好。云端 build 不用装任何东西，15 分钟出 APK。

**Q: 我不想公开 repo（要 Private）？**
A: GitHub Private repo 的 Actions 是 **GitHub Pro 付费功能**。免费账号只能用 Public repo 跑 Actions。

**Q: Actions 跑失败怎么办？**
A: 在 Actions 页面点失败的 run → 看红色步骤的日志 → 复制错误消息贴给我看，我帮你排查。

**Q: APK 装手机后打开白屏？**
A: 99% 是连不上后端。检查：① 手机和电脑同一 WiFi ② 后端 uvicorn 带 `--host 0.0.0.0` ③ 重新 build 时 `api_base_url` 填对了电脑 IP

**Q: APK 装不上（签名冲突）？**
A: 先卸掉旧版本再装：`adb install -r -d <apk>`（-d 允许降级），或 `adb uninstall com.xiaolanbook` 再装。

---

📌 **当前状态**：源码完整 + GitHub Actions workflow 已配置。你按 Step 1-6 走一遍，15 分钟左右 APK 就在你电脑上了。