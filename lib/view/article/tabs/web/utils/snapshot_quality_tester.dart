import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../basics/logger.dart';


/// 快照质量测试工具
/// 用于验证生成的快照是否与原网页样式一致
class SnapshotQualityTester {
  
  /// 测试快照质量
  static Future<SnapshotQualityReport> testSnapshotQuality({
    required String snapshotPath,
    required String originalUrl,
    InAppWebViewController? webViewController,
  }) async {
    final report = SnapshotQualityReport();
    
    try {
      getLogger().i('🔍 开始测试快照质量...');
      
      // 1. 基础文件检查
      await _testBasicFileIntegrity(snapshotPath, report);
      
      // 2. 如果有WebView控制器，进行页面内容检查
      if (webViewController != null) {
        await _testPageContentIntegrity(webViewController, report);
      }
      
      // 3. 生成质量报告
      _generateQualityScore(report);
      
      getLogger().i('✅ 快照质量测试完成，得分: ${report.qualityScore}/100');
      
    } catch (e) {
      getLogger().e('❌ 快照质量测试失败: $e');
      report.addIssue('测试过程异常', '测试过程中发生错误: $e', IssueSeverity.high);
    }
    
    return report;
  }
  
  /// 测试基础文件完整性
  static Future<void> _testBasicFileIntegrity(String snapshotPath, SnapshotQualityReport report) async {
    try {
      final file = File(snapshotPath);
      
      // 检查文件是否存在
      if (!file.existsSync()) {
        report.addIssue('文件不存在', '快照文件不存在: $snapshotPath', IssueSeverity.high);
        return;
      }
      
      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        report.addIssue('文件为空', '快照文件大小为0', IssueSeverity.high);
        return;
      }
      
      if (fileSize < 1024) { // 小于1KB
        report.addIssue('文件过小', '快照文件可能不完整，大小: ${fileSize}字节', IssueSeverity.medium);
      } else if (fileSize > 50 * 1024 * 1024) { // 大于50MB
        report.addIssue('文件过大', '快照文件过大，可能包含过多资源: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB', IssueSeverity.low);
      } else {
        report.addSuccess('文件大小正常', '快照文件大小: ${(fileSize / 1024).toStringAsFixed(2)}KB');
      }
      
      // 检查文件扩展名
      final extension = snapshotPath.split('.').last.toLowerCase();
      if (Platform.isAndroid && extension != 'mht') {
        report.addIssue('文件格式', 'Android平台应使用.mht格式', IssueSeverity.low);
      } else if ((Platform.isIOS || Platform.isMacOS) && extension != 'webarchive') {
        report.addIssue('文件格式', 'iOS/macOS平台应使用.webarchive格式', IssueSeverity.low);
      } else {
        report.addSuccess('文件格式正确', '使用了正确的平台格式: .$extension');
      }
      
    } catch (e) {
      report.addIssue('文件检查异常', '检查文件时发生错误: $e', IssueSeverity.high);
    }
  }
  
  /// 测试页面内容完整性
  static Future<void> _testPageContentIntegrity(InAppWebViewController controller, SnapshotQualityReport report) async {
    try {
      // 检查页面基本元素
      final hasTitle = await controller.evaluateJavascript(source: '''
        document.title && document.title.trim().length > 0;
      ''');
      
      if (hasTitle == true) {
        report.addSuccess('页面标题', '页面包含有效标题');
      } else {
        report.addIssue('页面标题', '页面缺少标题或标题为空', IssueSeverity.medium);
      }
      
      // 检查页面内容
      final hasContent = await controller.evaluateJavascript(source: '''
        document.body && document.body.textContent && document.body.textContent.trim().length > 100;
      ''');
      
      if (hasContent == true) {
        report.addSuccess('页面内容', '页面包含充足的文本内容');
      } else {
        report.addIssue('页面内容', '页面内容过少或为空', IssueSeverity.high);
      }
      
      // 检查图片加载情况
      final imageStats = await controller.evaluateJavascript(source: '''
        (function() {
          const images = document.querySelectorAll('img');
          let total = images.length;
          let loaded = 0;
          let failed = 0;
          
          images.forEach(img => {
            if (img.complete) {
              if (img.naturalHeight > 0) {
                loaded++;
              } else {
                failed++;
              }
            }
          });
          
          return { total: total, loaded: loaded, failed: failed };
        })();
      ''');
      
      if (imageStats != null && imageStats is Map) {
        final total = imageStats['total'] ?? 0;
        final loaded = imageStats['loaded'] ?? 0;
        final failed = imageStats['failed'] ?? 0;
        
        if (total == 0) {
          report.addSuccess('图片加载', '页面无图片');
        } else if (failed == 0) {
          report.addSuccess('图片加载', '所有图片($total张)加载成功');
        } else if (failed < total * 0.2) { // 失败率小于20%
          report.addIssue('图片加载', '部分图片加载失败: $failed/$total', IssueSeverity.low);
        } else {
          report.addIssue('图片加载', '大量图片加载失败: $failed/$total', IssueSeverity.medium);
        }
      }
      
      // 检查样式应用情况
      final styleCheck = await controller.evaluateJavascript(source: '''
        (function() {
          const body = document.body;
          const computedStyle = window.getComputedStyle(body);
          
          return {
            hasBackgroundColor: computedStyle.backgroundColor !== 'rgba(0, 0, 0, 0)',
            hasFont: computedStyle.fontFamily !== '',
            hasFontSize: computedStyle.fontSize !== '',
            hasTextColor: computedStyle.color !== 'rgba(0, 0, 0, 0)'
          };
        })();
      ''');
      
      if (styleCheck != null && styleCheck is Map) {
        final hasBackgroundColor = styleCheck['hasBackgroundColor'] ?? false;
        final hasFont = styleCheck['hasFont'] ?? false;
        final hasFontSize = styleCheck['hasFontSize'] ?? false;
        final hasTextColor = styleCheck['hasTextColor'] ?? false;
        
        if (hasBackgroundColor && hasFont && hasFontSize && hasTextColor) {
          report.addSuccess('样式应用', '基础样式正确应用');
        } else {
          final missing = <String>[];
          if (!hasBackgroundColor) missing.add('背景色');
          if (!hasFont) missing.add('字体');
          if (!hasFontSize) missing.add('字体大小');
          if (!hasTextColor) missing.add('文字颜色');
          
          report.addIssue('样式应用', '部分样式缺失: ${missing.join(', ')}', IssueSeverity.medium);
        }
      }
      
      // 检查响应式布局
      final layoutCheck = await controller.evaluateJavascript(source: '''
        (function() {
          const body = document.body;
          const html = document.documentElement;
          
          return {
            bodyWidth: body.offsetWidth,
            htmlWidth: html.offsetWidth,
            viewportWidth: window.innerWidth,
            hasHorizontalScroll: body.scrollWidth > window.innerWidth
          };
        })();
      ''');
      
      if (layoutCheck != null && layoutCheck is Map) {
        final hasHorizontalScroll = layoutCheck['hasHorizontalScroll'] ?? false;
        
        if (!hasHorizontalScroll) {
          report.addSuccess('响应式布局', '页面适配移动端，无水平滚动');
        } else {
          report.addIssue('响应式布局', '页面存在水平滚动，可能影响阅读体验', IssueSeverity.low);
        }
      }
      
    } catch (e) {
      report.addIssue('内容检查异常', '检查页面内容时发生错误: $e', IssueSeverity.medium);
    }
  }
  
  /// 生成质量评分
  static void _generateQualityScore(SnapshotQualityReport report) {
    int score = 100;
    
    // 根据问题严重程度扣分
    for (final issue in report.issues) {
      switch (issue.severity) {
        case IssueSeverity.high:
          score -= 30;
          break;
        case IssueSeverity.medium:
          score -= 15;
          break;
        case IssueSeverity.low:
          score -= 5;
          break;
      }
    }
    
    // 确保分数不低于0
    report.qualityScore = score < 0 ? 0 : score;
    
    // 设置质量等级
    if (score >= 90) {
      report.qualityLevel = QualityLevel.excellent;
    } else if (score >= 75) {
      report.qualityLevel = QualityLevel.good;
    } else if (score >= 60) {
      report.qualityLevel = QualityLevel.fair;
    } else {
      report.qualityLevel = QualityLevel.poor;
    }
  }
}

/// 快照质量报告
class SnapshotQualityReport {
  final List<QualityIssue> issues = [];
  final List<QualitySuccess> successes = [];
  int qualityScore = 0;
  QualityLevel qualityLevel = QualityLevel.poor;
  
  void addIssue(String title, String description, IssueSeverity severity) {
    issues.add(QualityIssue(title, description, severity));
  }
  
  void addSuccess(String title, String description) {
    successes.add(QualitySuccess(title, description));
  }
  
  /// 获取格式化的报告
  String getFormattedReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 快照质量报告');
    buffer.writeln('═══════════════════');
    buffer.writeln('🎯 质量评分: $qualityScore/100 (${_getQualityLevelText()})');
    buffer.writeln();
    
    if (successes.isNotEmpty) {
      buffer.writeln('✅ 成功项目:');
      for (final success in successes) {
        buffer.writeln('  • ${success.title}: ${success.description}');
      }
      buffer.writeln();
    }
    
    if (issues.isNotEmpty) {
      buffer.writeln('⚠️ 发现问题:');
      for (final issue in issues) {
        final icon = _getSeverityIcon(issue.severity);
        buffer.writeln('  $icon ${issue.title}: ${issue.description}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('📝 建议:');
    buffer.writeln(_getRecommendations());
    
    return buffer.toString();
  }
  
  String _getQualityLevelText() {
    switch (qualityLevel) {
      case QualityLevel.excellent:
        return '优秀';
      case QualityLevel.good:
        return '良好';
      case QualityLevel.fair:
        return '一般';
      case QualityLevel.poor:
        return '较差';
    }
  }
  
  String _getSeverityIcon(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.high:
        return '🔴';
      case IssueSeverity.medium:
        return '🟡';
      case IssueSeverity.low:
        return '🟢';
    }
  }
  
  String _getRecommendations() {
    if (qualityScore >= 90) {
      return '快照质量优秀，可以正常使用。';
    } else if (qualityScore >= 75) {
      return '快照质量良好，建议检查并修复中等严重程度的问题。';
    } else if (qualityScore >= 60) {
      return '快照质量一般，建议重新生成快照或检查网络连接。';
    } else {
      return '快照质量较差，强烈建议重新生成快照，并检查原网页是否正常加载。';
    }
  }
}

/// 质量问题
class QualityIssue {
  final String title;
  final String description;
  final IssueSeverity severity;
  
  QualityIssue(this.title, this.description, this.severity);
}

/// 质量成功项
class QualitySuccess {
  final String title;
  final String description;
  
  QualitySuccess(this.title, this.description);
}

/// 问题严重程度
enum IssueSeverity {
  high,    // 高：严重影响使用
  medium,  // 中：影响体验
  low      // 低：轻微问题
}

/// 质量等级
enum QualityLevel {
  excellent, // 优秀 (90-100)
  good,      // 良好 (75-89)
  fair,      // 一般 (60-74)
  poor       // 较差 (0-59)
}