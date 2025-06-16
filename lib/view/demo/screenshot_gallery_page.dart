import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 截图查看页面
/// 显示所有保存的网页截图，支持预览和删除功能
class ScreenshotGalleryPage extends StatefulWidget {
  const ScreenshotGalleryPage({super.key});

  @override
  State<ScreenshotGalleryPage> createState() => _ScreenshotGalleryPageState();
}

class _ScreenshotGalleryPageState extends State<ScreenshotGalleryPage> {
  List<File> screenshots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  /// 加载所有截图文件
  Future<void> _loadScreenshots() async {
    try {
      print("开始加载截图文件...");
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory('${directory.path}/screenshots');
      
      print("截图目录路径: ${screenshotDir.path}");
      print("截图目录是否存在: ${await screenshotDir.exists()}");
      
      if (await screenshotDir.exists()) {
        print("开始扫描截图文件...");
        final entities = screenshotDir.listSync();
        print("目录中文件总数: ${entities.length}");
        
        final files = entities
            .where((file) => file.path.endsWith('.png'))
            .map((file) => File(file.path))
            .toList();
        
        print("PNG文件数量: ${files.length}");
        
        // 打印所有找到的文件
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;
          print("文件 $i: ${file.path}");
          print("  - 存在: $exists");
          print("  - 大小: $size bytes");
        }
        
        // 按修改时间排序，最新的在前面
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        setState(() {
          screenshots = files;
          isLoading = false;
        });
        
        print("最终加载的截图数量: ${screenshots.length}");
      } else {
        print("截图目录不存在");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("加载截图失败详细错误: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载截图失败: $e')),
      );
    }
  }

  /// 删除截图文件
  Future<void> _deleteScreenshot(File file) async {
    try {
      await file.delete();
      _loadScreenshots(); // 重新加载列表
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  /// 显示截图预览对话框
  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部工具栏
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getFileDisplayName(imageFile),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // 图片内容
                Flexible(
                  child: InteractiveViewer(
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // 底部操作栏
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('删除', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmDelete(imageFile);
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.info, color: Colors.white),
                        label: const Text('详情', style: TextStyle(color: Colors.white)),
                        onPressed: () => _showImageInfo(imageFile),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 确认删除对话框
  void _confirmDelete(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除 "${_getFileDisplayName(file)}" 吗？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteScreenshot(file);
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示图片信息
  void _showImageInfo(File file) {
    final stat = file.statSync();
    final size = (stat.size / 1024).toStringAsFixed(2);
    final modified = DateFormat('yyyy-MM-dd HH:mm:ss').format(stat.modified);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('图片详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('文件名: ${_getFileDisplayName(file)}'),
              const SizedBox(height: 8),
              Text('大小: ${size} KB'),
              const SizedBox(height: 8),
              Text('创建时间: $modified'),
              const SizedBox(height: 8),
              Text('路径: ${file.path}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// 获取文件显示名称
  String _getFileDisplayName(File file) {
    return file.path.split('/').last;
  }

  /// 格式化文件修改时间
  String _formatFileTime(File file) {
    final modified = file.lastModifiedSync();
    return DateFormat('MM-dd HH:mm').format(modified);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '网页截图',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadScreenshots();
            },
            tooltip: "刷新",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : screenshots.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无截图',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '在网页浏览器中点击截图按钮保存网页图片',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: screenshots.length,
                    itemBuilder: (context, index) {
                      final file = screenshots[index];
                      return Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: () => _showImagePreview(file),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getFileDisplayName(file),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatFileTime(file),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 