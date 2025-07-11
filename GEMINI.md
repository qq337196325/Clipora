# Gemini Agent Project Configuration


## 1. 项目概述 (Project Overview)
*   **项目名称:** Clipora 
*   **目标:** Clipora是款收藏网页与阅读软件、标注笔记工具，能有效管理您的知识库。
*   **核心功能:**
    * 网页内容抓取与本地保存 (MHTML/快照)
    * 文本高亮与笔记标注
    * 内容分类与标签管理
    * 数据云端同步
    * 通过分享菜单从其他App接收链接

## 2. 技术栈 (Tech Stack)
*   **框架:** Flutter
* **语言:** Dart
* **状态管理:** GetX
* **网络请求:** Dio
* **主要依赖:** `flutter_inappwebview`, `isar`, `get_storage`, `go_router`, `intl`, `logger`, `path_provider`, `permission_handler`


## 3. 项目结构 (Project Structure)
*   `lib/main.dart`: 应用入口。
*   `lib/api/`: 存放所有网络请求相关的代码。
* `lib/db/`: Isar 数据库的 schema 和服务。
* `lib/view/`: 存放所有的UI界面 (Widgets/Screens)。
* `assets/`: 存放静态资源，如图片、JS脚本、CSS文件。
* `lib/basics/translations`: i18n 多语言文件


## 6. 对我的指示 (Agent Instructions)
* **语言:** 尽可能以简体中文回复
*   **禁止操作:** "不要直接修改 `pubspec.lock` 文件。"
*  **i18n语言key格式:** 前缀为 `i18n_` 加上 页面名称 加上中文，例如: `i18n_login_登录` i18n_ 为前缀，login 登录页面，登录 名称。
