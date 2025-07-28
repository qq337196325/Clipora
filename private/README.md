你是名UI设计师，精通交互、UI设计、UI页面色彩搭配。我需要你帮我设计下当前页面样式，使得用户体验更好

set http_proxy=http://127.0.0.1:7890
set https_proxy=http://127.0.0.1:7890



"code":"8550","phone":"18127079009"}
"code":"3567","phone":"18127079008"}
"code":"5446","phone":"18127079007"}
"code":"4311","phone":"18127079006"}



后面的工作，要先想一下方案然后再去实现，先提前做好一定的规划先。避免做一些无用功；


Clipora是款收藏网页与阅读软件、标注笔记工具，能有效管理您的知识库。

主要功能是网页收藏/知识管理；重搜索；

### 主要解决用户的痛点
1. 各种笔记收藏分散在各大平台，没有聚合管理；
2. 没有标记功能（标记功能有很多可以完善的地方）；
3. 网页内容可能会被屏蔽、需要一个快照功能；
4. 添加翻译功能；
5. 考虑免登录模式，要考虑离线的情况；
6. 最求极简模式 - 用户可配置模式，自己根据需要进行开启相关功能；
7. 还有个主功能，就是将文章翻译成其他语言
8. 一些网站访问不了的时候，需要提示用户并给出常见问题解答；


### 其他要点
1. 现在是大数据适当，要考虑多收集用户操作数据，进行推荐处理；
2. 应该要把一些预设的，能自动处理的网页加到自动处理上，如果没办法自动处理的需要用户接入手动生成；
3. 不管是客户端还是python，规则要写成AI可以理解的，然后给到对应的网址让AI写规则；


### v1.0.0 版本功能
1. 实现网页快照收藏；
2. 实现将网页保存为图片；（优先）
3. 


我现在应该做的是详情页部分，我应该要定义好数据库结构；


### 系统架构要点
1. 免登录、断网访问；
2. 多语言；
3. 主题更换；
4. 尽可能多的数据收集，进行自动帮用户做一些自动化或者提示；
5. 要做好离线同步更新时间；



WordPress账号密码
Clipora
http://clipora.guanshangyun.com/wp-login.php
qq5202056
4124Yr!qj5Y0m%SFG2





/ 命令：会话与元控制，这类命令用于控制 CLI 本身的行为，管理会话和设置。
/help 或 /?：显示帮助信息，列出所有可用命令。
/chat save：保存当前的对话历史，并打上一个标签，方便后续恢复。
/chat resume：从之前保存的某个标签恢复对话。
/chat list：列出所有已保存的对话标签。
/compress：用一段摘要来替换整个聊天上下文。在进行了长篇对话后，这个命令可以帮你节省大量的 Token，同时保留核心信息。
/memory show：显示当前从所有 GEMINI.md 文件中加载的分层记忆内容。
/memory refresh：重新从 GEMINI.md 文件加载记忆，当你修改了配置文件后非常有用。
/restore [tool_call_id]：撤销上一次工具执行所做的文件修改。这是一个「后悔药」功能，需要在使用 gemini 命令时加上 --checkpointing 标志来开启。
/stats：显示当前会话的详细统计信息，包括 Token 使用量、会话时长等。
/theme：打开主题选择对话框。
/clear (快捷键 Ctrl+L)：清空终端屏幕。
/quit 或 /exit：退出 Gemini CLI。
@ 命令：注入文件与目录上下文
@：将指定文件的内容注入到你的 Prompt 中。例如：What is this file about? @README.md
@：将指定目录及其子目录下所有（未被 gitignore 的）文本文件的内容注入。
! 命令：与你的 Shell 无缝交互 这让你无需退出 Gemini CLI 就能执行系统命令。
!：执行单条 Shell 命令，并返回到 Gemini CLI。例如：!ls -la 或 !git status。
! (单独输入)：切换到「Shell 模式」。在此模式下，你输入的任何内容都会被直接当作 Shell 命令执行，终端提示符也会变色以作区分。再次输入 ! 可以退出 Shell 模式，回到与 AI 的对话中。

```dart
final List<_Language> _allLanguages = [
_Language(name: 'i18n_article_原文'.tr, code: 'original'),
_Language(name: 'i18n_article_英语'.tr, code: 'en-US'),
_Language(name: 'i18n_article_日语'.tr, code: 'ja-JP'),
_Language(name: 'i18n_article_韩语'.tr, code: 'ko-KR'),
_Language(name: 'i18n_article_法语'.tr, code: 'fr-FR'),
_Language(name: 'i18n_article_德语'.tr, code: 'de-DE'),
_Language(name: 'i18n_article_西班牙语'.tr, code: 'es-ES'),
_Language(name: 'i18n_article_俄语'.tr, code: 'ru-RU'),
_Language(name: 'i18n_article_阿拉伯语'.tr, code: 'ar-AR'),
_Language(name: 'i18n_article_葡萄牙语'.tr, code: 'pt-PT'),
_Language(name: 'i18n_article_意大利语'.tr, code: 'it-IT'),
_Language(name: 'i18n_article_荷兰语'.tr, code: 'nl-NL'),
_Language(name: 'i18n_article_泰语'.tr, code: 'th-TH'),
_Language(name: 'i18n_article_越南语'.tr, code: 'vi-VN'),
_Language(name: 'i18n_article_简体中文'.tr, code: 'zh-CN'),
_Language(name: 'i18n_article_繁体中文'.tr, code: 'zh-TW'),
];


```

