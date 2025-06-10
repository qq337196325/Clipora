import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';

import '../../basics/upload.dart';
import 'article_markdown_widget.dart';
import 'article_mhtml_widget.dart';
import 'article_web_widget.dart';
import '../../api/user_api.dart';
import '../../controller/article_controller.dart';
import '../../basics/logger.dart';
import '../../db/article/article_service.dart';


class ArticlePage extends StatefulWidget {

  final int id;

  const ArticlePage({
    super.key,
    required this.id,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with TickerProviderStateMixin,ArticlePageBLoC {

  final double _topBarHeight = 52.0;
  final double _bottomBarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    // 使用Obx来监听文章加载状态
    return Obx(() {
      if (articleController.hasError) {
        return Scaffold(body: _buildErrorView(context));
      }

      if (articleController.isLoading && !articleController.hasArticle) {
        return Scaffold(body: _buildInitialLoadingView());
      }
      
      // 主内容UI
      return Scaffold(
        body: Stack(
          children: [
            // 主要内容区域
            _buildContentView(context),
            
            // 顶部操作栏
            _buildTopBar(context),
            
            // 底部操作栏
            _buildBottomBar(context),
          ],
        ),
      );
    });
  }

  /// 构建主要内容视图
  Widget _buildContentView(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + _topBarHeight;
    final bottomPadding = mediaQuery.padding.bottom + _bottomBarHeight;

    // 更新Markdown组件的边距
    // 注意：这里我们直接更新了 `ArticleMarkdownWidget` 的参数，
    // 在下一次 `Obx` 重建时，新的 padding 会被传递下去。
    // 为了使切换标签页时也能及时更新其他组件的padding，
    // 我们可能需要更精细的状态管理或回调机制。
    // 目前，这个实现主要针对 `ArticleMarkdownWidget`。
    
    // 我们需要更新ArticleMarkdownWidget的padding
    // 通过在initState中创建widget列表，然后在build中更新它们
    // 来确保padding可以动态变化
    _updateTabWidgets(EdgeInsets.only(top: topPadding, bottom: bottomPadding));
    
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: tabController,
      children: tabWidget,
    );
  }

  /// 构建顶部操作栏
  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        offset: _isBottomBarVisible ? Offset.zero : const Offset(0, -1.5),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          height: MediaQuery.of(context).padding.top + _topBarHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedTabControl(
                controller: tabController,
                barDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                tabTextColor: Theme.of(context).colorScheme.onSurfaceVariant,
                selectedTabTextColor: Theme.of(context).colorScheme.onPrimary,
                squeezeIntensity: 4,
                height: 36,
                tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 1.5),
        child: Container(
          height: _bottomBarHeight + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildBottomBarItem(
                  context,
                  icon: Icons.arrow_back_ios_new,
                  tooltip: '返回',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.camera_alt_outlined,
                  tooltip: '生成快照',
                  onPressed: generateSnapshot,
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.download_outlined,
                  tooltip: '下载快照',
                  onPressed: downloadSnapshot,
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.share_outlined,
                  tooltip: '分享',
                  onPressed: () {
                    BotToast.showText(text: '分享功能待开发');
                  },
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.more_horiz,
                  tooltip: '更多',
                  onPressed: () {
                    BotToast.showText(text: '更多功能待开发');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            articleController.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadArticleData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建初始加载视图
  Widget _buildInitialLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载文章...'),
        ],
      ),
    );
  }
}

mixin ArticlePageBLoC on State<ArticlePage> {

  // 文章控制器
  // final ArticleController articleController = Get.put(ArticleController());
   final ArticleController articleController = Get.find<ArticleController>();

  late TabController tabController;
   List<SegmentTab> tabs = [];
  List<Widget> tabWidget = [];
  
  // 用于存储ArticleWebWidget的GlobalKey，以便调用其方法
  final GlobalKey<State<ArticleWebWidget>> _webWidgetKey = GlobalKey<State<ArticleWebWidget>>();

  String snapshotPath = "";
  bool isUploading = false; // 添加上传状态标识

  // 添加markdown内容状态管理
  final RxString _markdownContent = ''.obs;
  String get markdownContent => _markdownContent.value;
  
  // 用于控制UI显隐的状态
  bool _isBottomBarVisible = true;

   @override
  void initState() {
    super.initState();
    
    tabController = TabController(
     length: 4,
     vsync: this as TickerProvider,
     animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
   );

    _initializeTabs();

    // 加载文章数据
    _loadArticleData();
  }

  void _initializeTabs() {
    tabs = [
      const SegmentTab(label: '图文', color: Color(0xFF00BCF6)),
      const SegmentTab(label: '网页', color: Color(0xFF00BCF6)),
      const SegmentTab(label: '快照', color: Color(0xFF00BCF6)),
      const SegmentTab(label: '快照图', color: Color(0xFF00BCF6)),
    ];
  }

  void _updateTabWidgets(EdgeInsets padding) {
    tabWidget = [
      // 图文
      Obx(() => ArticleMarkdownWidget(
        markdownContent: _markdownContent.value,
        article: articleController.currentArticle,
        onScroll: _handleScroll,
        contentPadding: padding,
      )),
      // 网页
      Obx(() => ArticleWebWidget(
        key: _webWidgetKey,
        onSnapshotCreated: _onSnapshotCreated,
        url: articleController.articleUrl.isNotEmpty 
          ? articleController.articleUrl 
          : null,
        articleId: widget.id,
        // TODO: ArticleWebWidget也需要支持contentPadding和onScroll
      )),
      // 快照
      Obx(() => ArticleMhtmlWidget(
        mhtmlPath: articleController.hasArticle 
          ? articleController.currentArticle!.mhtmlPath 
          : '',
        title: articleController.hasArticle 
          ? articleController.currentArticle!.title 
          : null,
      )),
      // 快照图
      Container(),
    ];
  }

  /// 处理滚动事件，用于显示/隐藏UI元素
  void _handleScroll(ScrollDirection direction, double scrollY) {
    // 滚动到顶部，总是显示
    if (scrollY < 50) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
      return;
    }

    // 向下滚动，隐藏
    if (direction == ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
      }
    } 
    // 向上滚动，显示
    else if (direction == ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    }
  }

  /// 加载文章数据
  Future<void> _loadArticleData() async {
    await articleController.loadArticleById(widget.id);
    
    if (articleController.hasArticle) {
      await _loadMarkdownContent();
    }
  }

  /// 加载Markdown内容
  Future<void> _loadMarkdownContent() async {
    final article = articleController.currentArticle;
    if (article == null) {
      getLogger().w('⚠️ 当前文章为空，无法加载Markdown内容');
      return;
    }

    try {
      getLogger().i('📄 开始检查Markdown内容，文章ID: ${article.id}');
      
      // 检查数据库中的markdown字段是否为空
      if (article.markdown.isEmpty) {
        getLogger().i('📄 数据库中Markdown字段为空，从服务端获取');
        
        // 检查是否有serviceId
        if (article.serviceId.isEmpty) {
          getLogger().w('⚠️ 文章serviceId为空，无法从服务端获取Markdown内容');
          _markdownContent.value = '';
          return;
        }

        // 从服务端获取文章内容
        await _fetchMarkdownFromServer(article.serviceId, article.id);
      } else {
        getLogger().i('✅ 使用数据库中的Markdown内容，长度: ${article.markdown.length}');
        _markdownContent.value = article.markdown;
      }
    } catch (e) {
      getLogger().e('❌ 加载Markdown内容失败: $e');
      _markdownContent.value = '';
    }
  }

  /// 从服务端获取Markdown内容
  Future<void> _fetchMarkdownFromServer(String serviceId, int articleId) async {
    try {
      getLogger().i('🌐 从服务端获取Markdown内容，serviceId: $serviceId');
      
      final response = await UserApi.getArticleApi({
        'service_article_id': serviceId,
      });

      if (response['code'] == 0) {
        final data = response['data'];
        final markdownContent = data['markdown_content'] ?? '';
        
        getLogger().i('✅ 服务端Markdown内容获取成功，长度: ${markdownContent.length}');
        
        // 更新本地状态
        _markdownContent.value = markdownContent;
        
        // 保存到数据库
        if (markdownContent.isNotEmpty) {
          await _saveMarkdownToDatabase(articleId, markdownContent);
        }
      } else {
        throw Exception(response['msg'] ?? '获取文章失败');
      }
    } catch (e) {
      getLogger().e('❌ 从服务端获取Markdown内容失败: $e');
      BotToast.showText(text: '加载Markdown内容失败: $e');
      _markdownContent.value = '';
    }
  }

  /// 保存Markdown内容到数据库
  Future<void> _saveMarkdownToDatabase(int articleId, String markdownContent) async {
    try {
      getLogger().i('💾 保存Markdown内容到数据库，文章ID: $articleId');
      
      // 获取文章记录
      final article = await ArticleService.instance.getArticleById(articleId);
      if (article != null) {
        // 更新markdown字段
        article.markdown = markdownContent;
        article.updatedAt = DateTime.now();
        
        // 保存到数据库
        await ArticleService.instance.saveArticle(article);
        
        getLogger().i('✅ Markdown内容保存成功: ${article.title}');
        
        // 刷新控制器中的文章数据
        await articleController.refreshCurrentArticle();
      } else {
        getLogger().e('❌ 未找到ID为 $articleId 的文章记录');
      }
    } catch (e) {
      getLogger().e('❌ 保存Markdown内容到数据库失败: $e');
    }
  }

  // 接收快照路径的回调方法
  void _onSnapshotCreated(String path) {
    setState(() {
      snapshotPath = path;
    });

    BotToast.showText(text: '快照已保存，路径: ${path.split('/').last}');
    
    // 自动上传快照文件到服务端
    uploadSnapshotToServer(path,articleController.currentArticle!.serviceId);
  }



  // 手动重新上传快照（可选功能）
  Future<void> _retryUploadSnapshot() async {
    if (snapshotPath.isNotEmpty) {
      await uploadSnapshotToServer(snapshotPath,articleController.currentArticle!.serviceId);
    } else {
      BotToast.showText(text: '没有可上传的快照文件');
    }
  }

  // 生成快照的方法
  void generateSnapshot() {
    // 获取当前选中的tab索引
    final currentIndex = tabController.index;
    
    if (currentIndex == 1) { // 网页标签页的索引为1
      // 当前在网页tab，调用ArticleWebWidget的生成快照方法
      final webWidgetState = _webWidgetKey.currentState;
      if (webWidgetState != null) {
        // 调用公共方法createSnapshot
        (webWidgetState as dynamic).createSnapshot();
      } else {
        BotToast.showText(text: '网页未加载完成，请稍后再试');
      }
    } else {
      BotToast.showText(text: '请切换到网页标签页生成快照');
    }
  }

  // 构建快照视图
  Widget _buildSnapshotView() {
    print('=== 构建快照视图 ===');
    print('当前snapshotPath: "$snapshotPath"');
    print('snapshotPath是否为空: ${snapshotPath.isEmpty}');
    print('=== ===');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '快照信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isUploading)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '上传中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (snapshotPath.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '暂无快照',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '请先在网页标签页生成快照',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSnapshotIcon(),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_getSnapshotType()}已生成',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '文件名: ${snapshotPath.split('/').last}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '文件类型: ${_getFileExtension().toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '完整路径: $snapshotPath',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (isUploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_upload, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              '正在上传到服务器...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            BotToast.showText(text: '快照文件: ${snapshotPath.split('/').last}');
                          },
                          icon: const Icon(Icons.info),
                          label: const Text('文件信息'),
                        ),
                        ElevatedButton.icon(
                          onPressed: downloadSnapshot,
                          icon: const Icon(Icons.download),
                          label: const Text('下载快照'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isUploading ? null : _retryUploadSnapshot,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('重新上传'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_isImageFile())
                          ElevatedButton.icon(
                            onPressed: () {
                              _showImagePreview();
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('预览图片'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 获取快照图标
  IconData _getSnapshotIcon() {
    final extension = _getFileExtension();
    switch (extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'mht':
      case 'webarchive':
        return Icons.archive;
      default:
        return Icons.file_present;
    }
  }

  // 获取快照类型描述
  String _getSnapshotType() {
    final extension = _getFileExtension();
    switch (extension) {
      case 'png':
        return '截图快照';
      case 'mht':
        return 'MHT快照';
      case 'webarchive':
        return 'WebArchive快照';
      default:
        return '文件快照';
    }
  }

  // 获取文件扩展名
  String _getFileExtension() {
    if (snapshotPath.isEmpty) return '';
    return snapshotPath.split('.').last.toLowerCase();
  }

  // 判断是否是图片文件
  bool _isImageFile() {
    final extension = _getFileExtension();
    return ['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(extension);
  }

  // 显示图片预览
  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '快照预览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  maxWidth: 300,
                ),
                child: Image.file(
                  File(snapshotPath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red),
                        Text('无法加载图片'),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 下载快照到用户可访问的目录
  Future<void> downloadSnapshot() async {
    if (snapshotPath.isEmpty) {
      BotToast.showText(text: '没有可下载的快照');
      return;
    }

    try {
      // 显示下载开始提示
      BotToast.showText(text: '开始下载快照...');

      // 检查并请求存储权限
      bool hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        BotToast.showText(text: '需要存储权限才能下载文件');
        return;
      }

      // 获取源文件
      final File sourceFile = File(snapshotPath);
      if (!await sourceFile.exists()) {
        BotToast.showText(text: '快照文件不存在');
        return;
      }

      // 获取下载目录
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // Android: 使用公共下载目录
        downloadDir = Directory('/storage/emulated/0/Download');
        // 如果公共下载目录不存在，使用外部存储目录
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: 使用应用文档目录
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        BotToast.showText(text: '无法获取下载目录');
        return;
      }

      // 确保下载目录存在
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 生成目标文件名
      final String fileName = snapshotPath.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = fileName.split('.').last;
      final String downloadFileName = 'inkwell_snapshot_$timestamp.$fileExtension';
      final String downloadPath = '${downloadDir.path}/$downloadFileName';

      // 复制文件到下载目录
      final File targetFile = File(downloadPath);
      await sourceFile.copy(downloadPath);

      print('快照已下载到: $downloadPath');
      
      // 显示下载成功提示
      BotToast.showText(
        text: '快照下载成功\n保存位置: ${Platform.isAndroid ? "Download" : "Documents"}/$downloadFileName',
      );

      // 显示详细的下载信息对话框
      _showDownloadSuccessDialog(downloadPath, downloadFileName);

    } catch (e) {
      print('下载快照失败: $e');
      BotToast.showText(text: '下载失败: $e');
    }
  }

  // 检查并请求存储权限
  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isIOS) {
      // iOS不需要额外的存储权限
      return true;
    }

    // Android权限检查
    if (Platform.isAndroid) {
      // 对于Android 13 (API 33) 及以上版本，访问公共目录不需要存储权限
      // 但我们仍然可以检查并请求权限以兼容更低版本
      try {
        PermissionStatus status = await Permission.storage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        if (status.isDenied) {
          // 请求权限
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          }
        }
        
        if (status.isPermanentlyDenied) {
          // 如果权限被永久拒绝，显示对话框指导用户
          _showPermissionDeniedDialog();
          return false;
        }
        
        // 即使权限被拒绝，在较新的Android版本上仍然可以访问公共目录
        // 所以我们返回true让下载继续尝试
        return true;
        
      } catch (e) {
        print('权限检查失败: $e');
        // 如果权限检查失败，仍然尝试下载
        return true;
      }
    }

    return true;
  }

  // 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('需要存储权限'),
        content: const Text(
          '为了将快照保存到下载文件夹，需要授予存储权限。\n\n'
          '您可以在设置中手动开启权限，或者选择继续下载（文件将保存到应用目录）。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('打开设置'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 继续下载到应用目录
              _downloadToAppDirectory();
            },
            child: const Text('继续下载'),
          ),
        ],
      ),
    );
  }

  // 下载到应用目录（备用方案）
  Future<void> _downloadToAppDirectory() async {
    try {
      final File sourceFile = File(snapshotPath);
      if (!await sourceFile.exists()) {
        BotToast.showText(text: '快照文件不存在');
        return;
      }

      // 使用应用外部存储目录
      final Directory? appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        BotToast.showText(text: '无法获取存储目录');
        return;
      }

      // 创建下载子目录
      final Directory downloadDir = Directory('${appDir.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 生成目标文件名
      final String fileName = snapshotPath.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = fileName.split('.').last;
      final String downloadFileName = 'inkwell_snapshot_$timestamp.$fileExtension';
      final String downloadPath = '${downloadDir.path}/$downloadFileName';

      // 复制文件
      await sourceFile.copy(downloadPath);

      print('快照已下载到应用目录: $downloadPath');
      
      BotToast.showText(
        text: '快照已保存到应用目录\n$downloadFileName',
      );

      _showDownloadSuccessDialog(downloadPath, downloadFileName);

    } catch (e) {
      print('下载到应用目录失败: $e');
      BotToast.showText(text: '下载失败: $e');
    }
  }

  // 显示下载成功对话框
  void _showDownloadSuccessDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.download_done,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('下载成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文件名: $fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '保存位置: ${Platform.isAndroid ? "Download" : "Documents"} 文件夹',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '完整路径: $filePath',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    // 清理文章控制器
    articleController.clearCurrentArticle();
    // 注意：由于我们使用了Get.put，控制器会在其他地方被自动管理
    // 如果需要立即销毁，可以使用 Get.delete<ArticleController>();
    super.dispose();
  }

  /// 获取当前文章数据（便捷方法）
  String get currentArticleUrl => articleController.articleUrl;
  
  /// 获取当前文章标题（便捷方法）
  String get currentArticleTitle => articleController.articleTitle;

  Widget _buildBottomBarItem(BuildContext context, {required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 24.0,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      splashRadius: 24.0,
    );
  }
}

