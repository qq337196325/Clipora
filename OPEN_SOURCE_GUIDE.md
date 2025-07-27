# 将私有仓库安全开源到 GitHub 的操作指南

本文档旨在提供一个详细、安全的操作流程，指导如何将一个已存在的私有项目（包含不想公开的后端代码）发布为一个公开的开源项目。

核心策略是：为公开仓库创建一个全新的、干净的 Git 历史，彻底切断与私有历史的关联，从而避免任何敏感信息（如私有代码、API密钥等）被意外泄露。

---

## 阶段一：准备工作（在本地私有仓库进行）

在执行任何操作之前，必须完成以下准备工作。这是整个流程安全和成功的基础。

### 1. **备份项目！**
在开始之前，请务必将你的整个项目文件夹完整地复制一份，或压缩成一个 ZIP 文件。**安全第一！**

### 2. **代码结构分离**
确保你的代码已经完成了公私分离的重构。
*   所有需要保密的、与后端交互的代码都已移动到一个独立的目录中（例如 `lib/private/`）。
*   所有私有功能都通过抽象接口 (`abstract class`) 提供服务，并使用依赖注入（如 GetX 的 `Get.put()`）来解耦。

### 3. **配置 `.gitignore` 文件**
这是防止私有代码被提交到 Git 的关键安全防线。
1.  打开项目根目录下的 `.gitignore` 文件。
2.  在文件末尾添加一行，忽略你的私有代码目录：
    ```gitignore
    # 忽略私有实现和敏感配置
    lib/private/
    ```
3.  保存并关闭文件。

---

## 阶段二：开源发布流程

### 第一步：在本地创建干净的“孤儿”分支

1.  **确保当前在主分支**，并且所有更改都已提交。
    ```bash
    # 切换到你的主开发分支（通常是 main 或 master）
    git checkout main
    
    # 检查工作区是否干净
    git status 
    # 预期输出: "working tree clean"
    ```

2.  **临时删除本地的私有文件夹**。
    由于此文件夹已被 `.gitignore` 忽略，Git 不会跟踪这次删除。这只是为了清理当前工作目录，以便创建一个完全不含私有文件的提交。
    
    *   在 Windows (CMD/PowerShell) 中执行:
        ```cmd
        rmdir /s /q lib\private
        ```
    *   在 macOS / Linux 中执行:
        ```bash
        rm -rf lib/private
        ```

3.  **创建孤儿分支 (`orphan branch`)**。
    此命令会创建一个名为 `public-release` 的全新分支，它不包含任何过去的历史记录。
    ```bash
    git checkout --orphan public-release
    ```
    执行后，所有项目文件都会变为“未暂存”状态，这是一个全新的开始。

4.  **为公开仓库创建第一个提交**。
    ```bash
    # 添加所有（非忽略的）文件到暂存区
    git add .
    
    # 创建一个干净的、作为公开起点的提交
    git commit -m "Initial public release of Clipora"
    ```
    现在，`public-release` 分支拥有了一个独立的、不含任何敏感历史的初始提交。

### 第二步：在 GitHub 上创建仓库并推送

1.  **访问 GitHub.com 创建一个新的公开仓库**。
    *   给仓库命名 (例如 `clipora`)。
    *   设置为 `Public`。
    *   **不要**勾选任何 "Initialize this repository with..." 的选项（如 README, .gitignore, license）。我们需要一个完全空的仓库来接收我们的推送。
    *   点击 "Create repository"。

2.  **将本地仓库关联到新的 GitHub 仓库**。
    *   在 GitHub 仓库页面，复制仓库的 URL (HTTPS 或 SSH)。
    *   回到你的本地项目终端，运行以下命令。我们使用 `public` 作为这个新远程仓库的别名，以区别于你可能存在的私有远程仓库（通常是 `origin`）。
        ```bash
        # 将 <YOUR_GITHUB_REPO_URL> 替换成你自己的仓库 URL
        git remote add public <YOUR_GITHUB_REPO_URL>
        ```

3.  **将干净的分支推送到 GitHub**。
    此命令会将你本地的 `public-release` 分支的内容，推送到 `public` 远程仓库的 `main` 分支上，并建立跟踪关系。
    ```bash
    git push -u public public-release:main
    ```

### 第三步：恢复本地开发环境

推送完成后，你的本地环境还停留在 `public-release` 分支。现在切换回你的私有开发分支。

```bash
git checkout main
```
切换回来后，你会发现 `lib/private` 文件夹又回来了，因为在 `main` 分支的历史中它一直存在。你的私有开发环境完好无损，可以继续进行开发。

---

## 阶段三：后续维护流程

现在你同时拥有了私有仓库和公开仓库，日常开发和版本更新遵循以下流程：

1.  **日常开发**：始终在你的私有分支（`main`）上进行所有开发工作，包括新功能和 Bug 修复。

2.  **同步到公开仓库**：当你希望将一些通用更新发布到开源版本时：
    ```bash
    # 1. 切换到你的公共发布分支
    git checkout public-release
    
    # 2. 从你的主开发分支合并最新的、可公开的更改
    git merge main
    
    # 3. (如果需要) 解决合并冲突。由于 public-release 分支删除了 private 目录，
    #    合并时基本不会有冲突，除非你修改了被 .gitignore 忽略的文件。
    
    # 4. 将更新推送到 GitHub 公开仓库
    git push public main
    
    # 5. 切换回你的主开发分支，继续私有开发
    git checkout main
    ```

通过遵循此流程，你可以长期、安全地维护一个项目的两个版本。
