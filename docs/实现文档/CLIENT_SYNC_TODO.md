# 客户端同步功能 - 开发备忘录与任务清单

## 1. 功能现状与核心要点总结

我们已经为客户端实现了一个健壮的、离线优先的**上行同步框架** (将本地变更推送到服务器)。

### 核心要点

1.  **变更日志 (`SyncOperation`)**:
    -   **作用**: 这是整个同步系统的核心。它像一个任务队列，记录着所有发生在本地的、需要同步到服务器的数据变更（增、删、改）。
    -   **位置**: 模型定义在 `lib/db/sync_operation.dart`。

2.  **自动记录变更**:
    -   **作用**: 我们改造了 `ArticleService`，使其在执行数据操作（保存、删除、更新状态）时，能自动、原子性地向 `SyncOperation` 表中写入一条对应的日志。
    -   **机制**: 通过在 `saveArticle`, `deleteArticle` 等方法的数据库事务中，调用私有的 `_logSyncOperation` 方法实现。
    -   **位置**: 核心逻辑位于 `lib/db/article/article_service.dart`。

3.  **后台轮询同步 (`SyncService`)**:
    -   **作用**: 这是一个后台服务，应用正常启动后便会运行。它使用定时器，每隔30秒轮询一次 `SyncOperation` 表，检查是否有待处理 (`pending`) 的任务。
    -   **机制**: 如果发现待处理任务，它会按照时间顺序，逐一尝试通过（目前是模拟的）API将变更提交给服务器。
    -   **位置**: `SyncService` 的全部实现位于 `lib/services/sync_service.dart`。

4.  **离线创建与ID管理**:
    -   **作用**: 为了支持离线创建，当一篇新文章在本地诞生时，如果它没有服务端ID (`serviceId`)，我们会为它生成一个临时的 `UUID`。
    -   **机制**: `SyncService` 在处理"创建"操作时，会将这个 `UUID` 连同文章数据发给后端，并期望后端返回一个正式的 `serviceId` (MongoDB ObjectID)，然后用该ID更新本地文章。
    -   **位置**: `ArticleDb` 模型中的 `@Index() String serviceId` 字段 (`lib/db/article/article_db.dart`)，以及 `ArticleService` 和 `SyncService` 中的ID处理逻辑。

## 2. 未完成的任务及后续步骤

### ✅ 任务0: 初始化服务 (已完成)
-   **描述**: 确保 `SyncService` 在应用启动时运行。
-   **状态**: **已完成**。我们在 `lib/main.dart` 中通过 `Get.put(SyncService(), permanent: true);` 来初始化服务。

### 🚧 任务1: 对接真实后端API (当前最优先)
-   **描述**: 将 `SyncService` 中模拟的API调用替换为真实的HTTP请求。
-   **具体步骤**:
    1.  打开 `lib/services/sync_service.dart` 文件。
    2.  定位到 `_handleArticleSync` 方法。
    3.  修改 `case SyncOp.create:`:
        -   解除 `final articleData = jsonDecode(op.data!);` 的注释。
        -   替换 `// TODO:` 部分，使用 `dio` 或 `http` 调用后端 `POST /api/v1/articles` 接口，请求体为 `articleData`。
        -   从API的成功响应中，解析出后端返回的真实 `serviceId`。
        -   将 `newServiceIdFromServer` 变量赋值为这个真实的ID。
    4.  修改 `case SyncOp.update:`:
        -   替换 `// TODO:` 部分，调用 `PUT /api/v1/articles/{op.entityId}`。
    5.  修改 `case SyncOp.delete:`:
        -   替换 `// TODO:` 部分，调用 `DELETE /api/v1/articles/{op.entityId}`。
    6.  **重要**: 为API调用添加完整的错误处理逻辑 (`try-catch`)，确保在网络错误或服务器返回非2xx状态码时，同步任务不会被错误地标记为"已完成"。

### 🔜 任务2: 扩展同步到其他数据模型
-   **描述**: 将我们为 `Article` 实现的同步逻辑，复制到 `Category` 和 `Tag`。
-   **具体步骤**:
    1.  **修改数据模型**:
        -   在 `lib/db/category/category_db.dart` (`CategoryDb`) 和 `lib/db/tag/tag_db.dart` (`TagDb`) 中，添加 `@Index() String serviceId = "";` 字段和 `toJson()` 方法。
    2.  **重新生成代码**:
        -   运行 `flutter pub run build_runner build --delete-conflicting-outputs`。
    3.  **改造数据服务**:
        -   模仿 `ArticleService`，修改 `lib/db/category/category_service.dart` 和 `lib/db/tag/tag_service.dart`，让它们的增删改方法也能调用 `_logSyncOperation` 记录变更。
    4.  **扩展同步服务**:
        -   在 `lib/services/sync_service.dart` 的 `_performSync` 方法的 `switch` 语句中，添加 `case 'CategoryDb':` 和 `case 'TagDb':` 的处理逻辑，并创建对应的 `_handleCategorySync` 和 `_handleTagSync` 方法。

### 🚀 任务3: 实现下行同步 (未来规划)
-   **描述**: 实现从服务器拉取变更到本地的功能，以完成双向同步。
-   **初步思路**:
    1.  在 `SyncService` 中增加一个新的方法，如 `fetchUpdatesFromServer()`。
    2.  该方法调用后端提供的 `GET /api/v1/sync/updates` 接口，传递本地记录的上次成功同步的时间戳。
    3.  后端返回一个变更列表（如 `[{op: 'create', collection: 'Article', data: {...}}, {op: 'delete', collection: 'Category', serviceId: '...'}]`）。
    4.  客户端遍历这个列表，在本地Isar数据库中执行相应的增删改操作。
    5.  这需要一个更复杂的逻辑来处理数据冲突，是同步功能的下一个主要里程碑。 