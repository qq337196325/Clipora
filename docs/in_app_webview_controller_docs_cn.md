# InAppWebViewController 详解

`InAppWebViewController` 是您用来与 `InAppWebView` 小部件进行交互的"遥控器"。当您创建 `InAppWebView` 并在 `onWebViewCreated` 回调中获取到它的实例后，您就可以调用其上的各种方法来控制网页的行为。

下面我将 `InAppWebViewController` 的主要方法和参数分类进行详细介绍：

### 1. 页面加载与导航

这类方法用于控制 WebView 加载什么内容以及如何在页面间跳转。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `loadUrl` | `urlRequest`: `URLRequest` 对象，可以包含URL、方法（GET/POST）、请求头、请求体等。 | `Future<void>` | **最常用**的方法，用于加载一个指定的 URL。 |
| `postUrl` | `url`: `WebUri`，要请求的URL。<br>`postData`: `Uint8List`，要POST的数据。 | `Future<void>` | 向指定 URL 发送 POST 请求。 |
| `loadData` | `data`: `String`，要加载的HTML/TEXT内容。<br>`mimeType`: `String`，内容的MIME类型，默认为`text/html`。<br>`encoding`: `String`，编码格式，默认为`utf8`。<br>`baseUrl`: `WebUri`，用于解析相对路径的基URL。 | `Future<void>` | 直接加载一个HTML字符串。这对于显示动态生成的HTML内容非常有用。 |
| `loadFile` | `assetFilePath`: `String`，Flutter项目中 `assets` 目录下的文件路径。 | `Future<void>` | 加载本地 `assets` 文件夹中的文件（如HTML、JS、CSS文件）。 |
| `reload` | (无) | `Future<void>` | 重新加载当前页面。 |
| `stopLoading` | (无) | `Future<void>` | 停止当前页面的加载。 |
| `reloadFromOrigin` | (无) | `Future<void>` | 从源服务器重新加载当前页面，忽略任何本地缓存。 |

---

### 2. 历史记录管理

这些方法用于操作 WebView 的浏览历史记录。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `goBack` | (无) | `Future<void>` | 后退到历史记录中的上一个页面。 |
| `canGoBack` | (无) | `Future<bool>` | 判断是否可以后退。 |
| `goForward` | (无) | `Future<void>` | 前进到历史记录中的下一个页面。 |
| `canGoForward`| (无) | `Future<bool>` | 判断是否可以前进。 |
| `goBackOrForward`| `steps`: `int`，要移动的步数，负数表示后退，正数表示前进。 | `Future<void>` | 在历史记录中前进或后退指定的步数。 |
| `canGoBackOrForward`| `steps`: `int`，同上。 | `Future<bool>` | 判断是否可以在历史记录中前进或后退指定的步数。 |
| `getCopyBackForwardList`| (无) | `Future<WebHistory?>` | 获取一个包含完整前进/后退历史记录列表的副本。 |
| `clearHistory`| (无) | `Future<void>` | 清除 WebView 的前进和后退历史记录。 |

---

### 3. 内容获取与状态检查

这类方法用于从当前网页中提取信息或检查 WebView 的状态。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `getUrl` | (无) | `Future<WebUri?>` | 获取当前页面的URL。 |
| `getTitle` | (无) | `Future<String?>` | 获取当前页面的标题。 |
| `getProgress` | (无) | `Future<int?>` | 获取页面的加载进度，范围是 0 到 100。 |
| `getHtml` | (无) | `Future<String?>` | 获取当前页面的完整HTML源代码。 |
| `getSelectedText`| (无) | `Future<String?>` | 获取用户在 WebView 中当前选择的文本。 |
| `getHitTestResult`| (无) | `Future<InAppWebViewHitTestResult?>`| 获取最后一次触摸事件（`onLongPress`）位置的元素信息，例如链接URL、图片URL等。 |
| `isLoading` | (无) | `Future<bool>` | 判断页面当前是否正在加载。 |
| `isInFullscreen`| (无) | `Future<bool>` | 判断 WebView 当前是否处于全屏模式（例如视频播放）。 |

---

### 4. JavaScript 和 CSS 注入与执行

这是 `InAppWebViewController` 非常强大的功能，允许 Flutter 与网页进行深度交互。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `evaluateJavascript` | `source`: `String`，要执行的JavaScript代码字符串。<br>`contentWorld`: `ContentWorld`，可选，指定JS运行的上下文环境。 | `Future<dynamic>` | **核心功能**。在当前页面执行一段JavaScript代码，并返回最后一条语句的执行结果。 |
| `injectJavascriptFileFromUrl`| `urlFile`: `WebUri`，JS文件的URL。 | `Future<void>` | 从一个URL注入并执行一个JS文件。 |
| `injectCSSCode`| `source`: `String`，CSS代码字符串。 | `Future<void>` | 向页面注入CSS代码来改变页面样式。 |
| `injectCSSFileFromUrl` | `urlFile`: `WebUri`，CSS文件的URL。 | `Future<void>` | 从一个URL注入一个CSS文件。 |
| `addJavaScriptHandler`| `handlerName`: `String`，处理器的名称。<br>`callback`: `JavaScriptHandlerCallback`，一个回调函数 `(List<dynamic> args) => ...`。 | `void` | **核心功能**。注册一个JS处理器。网页端可以通过 `window.flutter_inappwebview.callHandler('handlerName', arg1, arg2, ...)` 来调用Dart代码。 |
| `removeJavaScriptHandler`| `handlerName`: `String`，要移除的处理器名称。 | `JavaScriptHandlerCallback?` | 移除之前注册的JS处理器。 |
| `callAsyncJavaScript`| `functionBody`: `String`，JS函数体。<br>`arguments`: `Map`，传递给JS函数的参数。 | `Future<CallAsyncJavaScriptResult?>`| 异步执行一个JS函数，可以处理 `Promise` 等异步操作。 |

---

### 5. 用户界面与交互

控制 WebView 的视觉表现和用户交互。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `scrollTo` | `x`: `int`，横坐标。<br>`y`: `int`，纵坐标。<br>`animated`: `bool`，是否带动画。 | `Future<void>` | 将页面滚动到指定的 (x, y) 位置。 |
| `scrollBy` | `x`: `int`，横向滚动的距离。<br>`y`: `int`，纵向滚动的距离。<br>`animated`: `bool`，是否带动画。 | `Future<void>` | 在当前位置的基础上，将页面滚动指定的距离。 |
| `zoomIn` / `zoomOut` | (无) | `Future<bool>` | 放大 / 缩小页面。 |
| `takeScreenshot`| `screenshotConfiguration`: `ScreenshotConfiguration`，截图配置，如格式、质量等。 | `Future<Uint8List?>` | 对 WebView 当前可见部分进行截图，返回图片的字节数据。 |
| `clearFocus` | (无) | `Future<void>` | 清除WebView的焦点，通常用于关闭软键盘。 |
| `setContextMenu`| `contextMenu`: `ContextMenu`，自定义上下文菜单。 | `Future<void>` | 自定义用户长按网页内容时弹出的菜单。 |

---

### 6. 设置与缓存

管理 WebView 的配置和数据。

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `setSettings` | `settings`: `InAppWebViewSettings`，包含各种WebView设置的对象。 | `Future<void>` | **非常重要**。动态更新 WebView 的设置，例如更改 `User-Agent`、启用/禁用JS、控制缓存模式等。 |
| `getSettings` | (无) | `Future<InAppWebViewSettings?>`| 获取当前的 WebView 设置。 |
| `clearCache` | (无) | `Future<void>` | **[已废弃]** 清除此 WebView 的缓存。推荐使用静态方法 `InAppWebViewController.clearAllCache()`。 |
| `clearAllCache`| (静态方法) `includeDiskFiles`: `bool`，是否也清除磁盘文件。 | `static Future<void>` | 清理所有 WebView 的缓存，包括cookie、历史记录等。 |
| `clearSslPreferences` | (无) | `Future<void>` | 清除存储的SSL偏好设置。 |
| `clearFormData` | (无) | `Future<void>` | 清除此 WebView 自动填充的表单数据。 |

---

### 7. 生命周期管理

| 方法名 | 参数 | 返回值 | 描述 |
| :--- | :--- | :--- | :--- |
| `dispose` | `isKeepAlive`: `bool`，是否是为 `KeepAlive` 而销毁。 | `void` | **必须调用**。当包含 `InAppWebView` 的 Widget 被销毁时，必须调用此方法来释放控制器和 WebView 占用的资源，以防止内存泄漏。 |

这个 `InAppWebViewController` 功能非常丰富，掌握了它的用法，你就可以随心所欲地控制 WebView，实现各种复杂的混合应用需求。 