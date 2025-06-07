import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import 'article_web_widget.dart';
import '../../api/user_api.dart';


class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with TickerProviderStateMixin,ArticlePageBLoC {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文章阅读'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: generateSnapshot,
            icon: const Icon(Icons.save_alt),
            tooltip: '生成快照',
          ),
        ],
      ),
      body: SafeArea(
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
              child: TabBarView(
                // controller: tabController, // 使用自定义的TabController
                // physics: const NeverScrollableScrollPhysics(), // 禁用默认滑动切换
                controller: tabController, // 使用自定义的TabController
                physics: const BouncingScrollPhysics(),
                // clipBehavior: Clip.none, // 避免裁剪问题
                children: tabWidget,
              ),
            ),
          ],
        ),
      ),
    
    );
  }


}

mixin ArticlePageBLoC on State<ArticlePage> {

  late TabController tabController;
   List<SegmentTab> tabs = [];
  List<Widget> tabWidget = [];
  
  // 用于存储ArticleWebWidget的GlobalKey，以便调用其方法
  final GlobalKey<State<ArticleWebWidget>> _webWidgetKey = GlobalKey<State<ArticleWebWidget>>();

  String snapshotPath = "";
  bool isUploading = false; // 添加上传状态标识


   @override
  void initState() {

   tabController = TabController(
     length: 4,
     vsync: this as TickerProvider,
     animationDuration: const Duration(milliseconds: 350), // 优化切换动画时长
   );

    tabs.add(const SegmentTab(label: '网页', color: Color(0xFF00BCF6)));
    tabWidget.add(ArticleWebWidget(
      key: _webWidgetKey,
      onSnapshotCreated: _onSnapshotCreated,
    ));

    tabs.add(const SegmentTab(label: '图文', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    tabs.add(const SegmentTab(label: '快照', color: Color(0xFF00BCF6)));
    // 注意：不要在这里创建Widget，而是使用一个Builder来确保状态更新时重新构建
    tabWidget.add(Builder(
      builder: (context) => _buildSnapshotView(),
    )); 

    tabs.add(const SegmentTab(label: '快照图', color: Color(0xFF00BCF6)));
    tabWidget.add(Container()); 

    super.initState();
  }

  // 接收快照路径的回调方法
  void _onSnapshotCreated(String path) {
    print('=== 快照生成回调被触发 ===');
    print('接收到的路径: $path');
    print('当前snapshotPath: $snapshotPath');
    
    setState(() {
      snapshotPath = path;
    });
    
    print('更新后的snapshotPath: $snapshotPath');
    print('=== 快照路径更新完成 ===');
    
    BotToast.showText(text: '快照已保存，路径: ${path.split('/').last}');
    
    // 自动上传快照文件到服务端
    _uploadSnapshotToServer(path);
  }

  // 上传快照文件到服务端
  Future<void> _uploadSnapshotToServer(String filePath) async {
    if (filePath.isEmpty) {
      print('上传失败：文件路径为空');
      return;
    }

    try {
      setState(() {
        isUploading = true;
      });

      // 显示上传开始提示
      BotToast.showText(text: '开始上传快照到服务器...');

      // 检查文件是否存在
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('快照文件不存在');
      }

      // 准备上传参数
      final fileName = filePath.split('/').last;
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      print('开始上传文件: $fileName');
      print('文件大小: ${await file.length()} bytes');

      // 调用上传接口
      final response = await UserApi.uploadMhtmlApi(formData);

      print('上传响应: $response');

      // 检查响应结果
      if (response['code'] == 0 || response['code'] == 200) {
        print('文件上传成功');
        BotToast.showText(
          text: '快照上传成功！',
        );
        
        // 可以在这里处理服务器返回的数据，比如保存文件ID等
        if (response['data'] != null) {
          print('服务器返回数据: ${response['data']}');
        }
      } else {
        throw Exception(response['message'] ?? '上传失败');
      }

    } catch (e) {
      print('上传快照失败: $e');
      BotToast.showText(
        text: '快照上传失败: ${e.toString()}',
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // 手动重新上传快照（可选功能）
  Future<void> _retryUploadSnapshot() async {
    if (snapshotPath.isNotEmpty) {
      await _uploadSnapshotToServer(snapshotPath);
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

}

