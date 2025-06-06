import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:inkwell/api/share_service.dart';

/// 分享接收页面
class ShareReceivePage extends StatefulWidget {
  const ShareReceivePage({super.key});

  @override
  State<ShareReceivePage> createState() => _ShareReceivePageState();
}

class _ShareReceivePageState extends State<ShareReceivePage> {
  final ShareService _shareService = ShareService.instance;
  SharedContent? _currentSharedContent;

  @override
  void initState() {
    super.initState();
    _listenToShareContent();
    // ShareService会在初始化时自动检查初始分享内容
  }

  /// 监听分享内容
  void _listenToShareContent() {
    _shareService.sharedContentStream.listen((SharedContent content) {
      debugPrint('分享接收页面收到内容: $content');
      setState(() {
        _currentSharedContent = content;
      });
      BotToast.showText(text: '接收到分享内容: ${content.title}');
    });
  }

  /// 处理分享内容
  void _handleShare() {
    if (_currentSharedContent == null) {
      BotToast.showText(text: '没有可处理的分享内容');
      return;
    }

    switch (_currentSharedContent!.type) {
      case ShareContentType.text:
        _handleTextShare(_currentSharedContent!.text!);
        break;
      case ShareContentType.url:
        _handleUrlShare(_currentSharedContent!.url!);
        break;
      case ShareContentType.image:
        _handleImageShare(_currentSharedContent!.imagePath!);
        break;
      case ShareContentType.file:
        _handleFileShare(_currentSharedContent!.filePath!);
        break;
    }
  }

  /// 处理文本分享
  void _handleTextShare(String text) {
    // 这里可以将文本保存到应用的笔记或收藏中
    BotToast.showText(text: '已收藏文本: ${text.substring(0, text.length > 20 ? 20 : text.length)}...');
    _clearCurrentShare();
  }

  /// 处理URL分享
  void _handleUrlShare(String url) {
    // 这里可以将URL保存到应用的链接收藏中
    BotToast.showText(text: '已收藏链接: $url');
    _clearCurrentShare();
  }

  /// 处理图片分享
  void _handleImageShare(String imagePath) {
    // 这里可以将图片保存到应用的图片收藏中
    BotToast.showText(text: '已收藏图片: $imagePath');
    _clearCurrentShare();
  }

  /// 处理文件分享
  void _handleFileShare(String filePath) {
    // 这里可以将文件保存到应用的文件收藏中
    BotToast.showText(text: '已收藏文件: $filePath');
    _clearCurrentShare();
  }

  /// 清除当前分享内容
  void _clearCurrentShare() {
    setState(() {
      _currentSharedContent = null;
    });
    _shareService.clearSharedContent();
  }

  /// 测试分享功能
  void _testShare() {
    _shareService.handleManualShare(
      '这是一个测试分享的文本内容',
      ShareContentType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享接收'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分享状态',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentSharedContent == null
                        ? '暂无分享内容'
                        : '已接收: ${_currentSharedContent!.title}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _currentSharedContent == null 
                          ? Colors.grey[500] 
                          : Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 分享内容详情
            if (_currentSharedContent != null) ...[
              Text(
                '分享内容详情',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForType(_currentSharedContent!.type),
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTypeLabel(_currentSharedContent!.type),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getContentPreview(_currentSharedContent!),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleShare,
                      icon: const Icon(Icons.favorite),
                      label: const Text('收藏到应用'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearCurrentShare,
                      icon: const Icon(Icons.clear),
                      label: const Text('忽略'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const Spacer(),
            
            // 测试按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testShare,
                icon: const Icon(Icons.share),
                label: const Text('测试分享功能'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 说明文字
            Text(
              '使用说明：\n'
              '1. 在其他应用中选择分享内容\n'
              '2. 选择"Inkwell"应用\n'
              '3. 应用将自动打开并显示分享内容\n'
              '4. 点击"收藏到应用"保存内容',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取类型对应的图标
  IconData _getIconForType(ShareContentType type) {
    switch (type) {
      case ShareContentType.text:
        return Icons.text_fields;
      case ShareContentType.url:
        return Icons.link;
      case ShareContentType.image:
        return Icons.image;
      case ShareContentType.file:
        return Icons.attach_file;
    }
  }

  /// 获取类型标签
  String _getTypeLabel(ShareContentType type) {
    switch (type) {
      case ShareContentType.text:
        return '文本';
      case ShareContentType.url:
        return '链接';
      case ShareContentType.image:
        return '图片';
      case ShareContentType.file:
        return '文件';
    }
  }

  /// 获取内容预览
  String _getContentPreview(SharedContent content) {
    switch (content.type) {
      case ShareContentType.text:
        return content.text ?? '';
      case ShareContentType.url:
        return content.url ?? '';
      case ShareContentType.image:
        return content.imagePath ?? '';
      case ShareContentType.file:
        return content.filePath ?? '';
    }
  }
} 