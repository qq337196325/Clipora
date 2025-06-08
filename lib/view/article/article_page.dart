import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          articleController.hasArticle 
            ? articleController.articleTitle 
            : '文章阅读',
        )),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 显示加载状态
          Obx(() {
            if (articleController.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            onPressed: generateSnapshot,
            icon: const Icon(Icons.save_alt),
            tooltip: '生成快照',
          ),
        ],
      ),
      body: Obx(() {
        // 显示错误信息
        if (articleController.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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

        // 显示加载状态
        if (articleController.isLoading) {
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

        // 显示主要内容
        return SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                child:  SegmentedTabControl(
                  controller: tabController, // 使用自定义的TabController
                  barDecoration: BoxDecoration(
                    color: Color(0xFFF3F2F1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  tabTextColor: Color(0xFF161514),
                  selectedTabTextColor: Color(0xFFF3F2F1),
                  squeezeIntensity: 4,
                  height: 28,
                  tabPadding: EdgeInsets.symmetric(horizontal: 8),
                  tabs: tabs,
                )
              ),
              Expanded(
                child:TabBarView(
                  physics: const NeverScrollableScrollPhysics(), // 禁用默认滑动切换
                  controller: tabController, // 使用自定义的TabController
                  // physics: const BouncingScrollPhysics(),
                  // clipBehavior: Clip.none, // 避免裁剪问题
                  children: tabWidget,
                ),
              ),
            ],
          ),
        );
      }),
    
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

   @override
  void initState() {

   tabController = TabController(
     length: 4,
     vsync: this as TickerProvider,
     animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
   );

    tabs.add(const SegmentTab(label: '图文', color: Color(0xFF00BCF6)));
    // 使用Builder来确保响应式更新
  tabWidget.add(Builder(
      builder: (context) => Obx(() => ArticleMarkdownWidget(
        markdownContent: _markdownContent.value,
        article: articleController.currentArticle, // 添加article参数
      )),
    ));

    

    tabs.add(const SegmentTab(label: '网页', color: Color(0xFF00BCF6)));
    // 修改为传递markdown内容而不是serviceId
    tabWidget.add(Builder(
      builder: (context) => Obx(() => ArticleWebWidget(
        key: _webWidgetKey,
        onSnapshotCreated: _onSnapshotCreated,
        url: articleController.articleUrl.isNotEmpty 
          ? articleController.articleUrl 
          : null,
        articleId: widget.id,  // 传入文章ID
      )),
    ));
  

    tabs.add(const SegmentTab(label: '快照', color: Color(0xFF00BCF6)));
    // 注意：不要在这里创建Widget，而是使用一个Builder来确保状态更新时重新构建 
    tabWidget.add(Builder(
      builder: (context) => Obx(() => ArticleMhtmlWidget(
        mhtmlPath: articleController.hasArticle 
          ? articleController.currentArticle!.mhtmlPath 
          : '', // 如果没有快照路径，传递空字符串
        title: articleController.hasArticle 
          ? articleController.currentArticle!.title 
          : null,
      )),
    ));

    tabs.add(const SegmentTab(label: '快照图', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    super.initState();
    
    // 加载文章数据
    _loadArticleData();
  }

  /// 加载文章数据
  Future<void> _loadArticleData() async {
    await articleController.loadArticleById(widget.id);
    
    // 文章数据加载完成后，检查并加载markdown内容
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
    
    if (currentIndex == 0) {
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

}

