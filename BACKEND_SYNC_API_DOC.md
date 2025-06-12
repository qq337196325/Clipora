# 多端同步功能 - 后端接口规范

## 1. 概述

为了支持客户端（Flutter App）的多端数据同步功能，后端需要提供一套标准的 RESTful API。

客户端采用**离线优先**的策略，所有数据的增、删、改操作都会先在本地数据库记录为一条"待同步操作"，然后通过一个后台服务，在网络连接正常时，将这些操作逐一提交给后端。

## 2. 核心概念：全局唯一ID (`serviceId`)

-   客户端的每条可同步数据（如文章、分类、标签）都需要一个**全局唯一ID**，以便在多端之间识别。
-   这个ID由**后端在创建数据时生成**，通常就是 MongoDB 的 `_id` (ObjectID)。
-   在API交互中，我们将这个字段统一称为 `serviceId`。
-   **特别注意**：当客户端在离线状态下创建一条新数据时，它会先自行生成一个临时的 `UUID` 作为 `serviceId`。当这条"创建"操作同步到后端后，后端需要返回由数据库生成的正式 `serviceId`，客户端会用它来更新本地的临时ID。

## 3. 接口规范 - 以"文章(Article)"为例

以下接口规范以"文章"为例。对于"分类(Category)"和"标签(Tag)"，也需要实现完全相同的接口模式。

### 3.1 创建文章

-   **Endpoint**: `POST /api/v1/articles`
-   **描述**: 客户端提交一篇新创建的文章。
-   **请求体 (Request Body)**:
    -   `Content-Type: application/json`
    -   内容是一个 `Article` 对象的JSON表示。客户端传过来的 `serviceId` 是一个**临时的UUID**。
    ```json
    {
      "serviceId": "c1f7a555-a2d9-4b1a-9c4c-7e285a2b0e1d", // 客户端生成的临时UUID
      "title": "文章标题",
      "url": "https://example.com/article",
      "content": "文章正文...",
      "createdAt": "2023-10-27T10:00:00Z",
      // ... 其他文章字段
    }
    ```
-   **成功响应 (Success Response)**:
    -   `Code: 201 Created`
    -   **响应体必须返回完整的、已存入数据库的文章对象**，其中 `serviceId` 字段的值必须是 **MongoDB 生成的 ObjectID**。这是整个流程的关键。
    ```json
    {
      "serviceId": "653b8e8f8a7b1e4e3a0e1d2c", // << 后端数据库生成的真实ID
      "title": "文章标题",
      "url": "https://example.com/article",
      "content": "文章正文...",
      "createdAt": "2023-10-27T10:00:00Z",
      "updatedAt": "2023-10-27T10:00:00Z",
      // ... 其他文章字段
    }
    ```

### 3.2 更新文章

-   **Endpoint**: `PUT /api/v1/articles/{serviceId}`
-   **描述**: 客户端提交对一篇现有文章的修改。
-   **URL参数**:
    -   `serviceId`: 需要更新的文章的 `serviceId` (MongoDB ObjectID)。
-   **请求体 (Request Body)**:
    -   `Content-Type: application/json`
    -   内容是包含所有更新后字段的 `Article` 对象的完整JSON。
-   **成功响应 (Success Response)**:
    -   `Code: 200 OK`
    -   可以返回更新后的文章对象，或只返回成功状态。

### 3.3 删除文章

-   **Endpoint**: `DELETE /api/v1/articles/{serviceId}`
-   **描述**: 客户端请求删除一篇现有文章。
-   **URL参数**:
    -   `serviceId`: 需要删除的文章的 `serviceId` (MongoDB ObjectID)。
-   **成功响应 (Success Response)**:
    -   `Code: 204 No Content` 或 `200 OK`。

## 4. 其他数据模型的接口

请为以下数据模型实现与 `Article` 结构完全相同的 `POST`, `PUT`, `DELETE` 接口：

-   **分类 (Category)**:
    -   `POST /api/v1/categories`
    -   `PUT /api/v1/categories/{serviceId}`
    -   `DELETE /api/v1/categories/{serviceId}`
-   **标签 (Tag)**:
    -   `POST /api/v1/tags`
    -   `PUT /api/v1/tags/{serviceId}`
    -   `DELETE /api/v1/tags/{serviceId}`

## 5. 未来规划：下行同步接口 (Fetch Updates)

为了实现完整的双向同步，未来客户端需要一个接口来拉取服务端的变更。请在架构上预留可能性。

-   **可能的 Endpoint**: `GET /api/v1/sync/updates?timestamp={lastSyncTimestamp}&limit=100`
-   **描述**: 获取自上次同步时间戳 `lastSyncTimestamp` 之后发生变更的所有数据。
-   **此接口为未来规划，本次开发可暂不实现，但需在架构设计上有所考虑。** 