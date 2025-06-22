import '../../../../../basics/logger.dart';
import '../core/simulation_config.dart';

/// 请求头管理器
/// 负责生成和管理真实浏览器的请求头，针对不同网站进行优化
class RequestHeaderManager {
  final SimulationConfig config;
  
  // 常用的真实浏览器请求头
  static const Map<String, List<String>> _browserHeaders = {
    'chrome_120_windows': [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    ],
    'chrome_119_windows': [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    ],
    'firefox_120_windows': [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0',
    ],
    'edge_120_windows': [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0',
    ],
  };

  // 网站特定的反爬虫策略
  static const Map<String, Map<String, dynamic>> _siteSpecificStrategies = {
    'zhihu.com': {
      'requiresAdvancedHeaders': true,
      'blocksAutomation': true,
      'checksFingerprint': true,
      'headerWhitelist': [
        'accept',
        'accept-encoding', 
        'accept-language',
        'cache-control',
        'connection',
        'dnt',
        'host',
        'referer',
        'sec-ch-ua',
        'sec-ch-ua-mobile',
        'sec-ch-ua-platform',
        'sec-fetch-dest',
        'sec-fetch-mode',
        'sec-fetch-site',
        'upgrade-insecure-requests',
        'user-agent',
      ],
    },
    'weibo.com': {
      'requiresAdvancedHeaders': true,
      'blocksAutomation': true,
      'checksFingerprint': true,
    },
    'bilibili.com': {
      'requiresAdvancedHeaders': false,
      'blocksAutomation': true,
      'checksFingerprint': false,
    },
    'toutiao.com': {
      'requiresAdvancedHeaders': true,
      'blocksAutomation': true,
      'checksFingerprint': true,
    },
  };

  RequestHeaderManager(this.config);

  /// 为URL生成优化的请求头
  Map<String, String> generateOptimizedHeaders(String url) {
    final uri = Uri.parse(url);
    final domain = uri.host.toLowerCase();
    
    // 获取网站特定策略
    final strategy = _getSiteStrategy(domain);
    
    // 基础请求头
    final headers = _getBaseHeaders(uri);
    
    // 添加高级安全头
    if (strategy['requiresAdvancedHeaders'] == true) {
      headers.addAll(_getAdvancedSecurityHeaders(uri));
    }
    
    // 添加网站特定头
    headers.addAll(_getSiteSpecificHeaders(domain, uri));
    
    getLogger().d('🌐 为 $domain 生成了 ${headers.length} 个请求头');
    return headers;
  }

  /// 获取网站策略
  Map<String, dynamic> _getSiteStrategy(String domain) {
    for (final site in _siteSpecificStrategies.keys) {
      if (domain.contains(site)) {
        return _siteSpecificStrategies[site]!;
      }
    }
    return {'requiresAdvancedHeaders': false, 'blocksAutomation': false, 'checksFingerprint': false};
  }

  /// 生成基础请求头
  Map<String, String> _getBaseHeaders(Uri uri) {
    final userAgent = _selectRandomUserAgent();
    
    return {
      'User-Agent': userAgent,
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Accept-Encoding': 'gzip, deflate, br',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Cache-Control': 'max-age=0',
    };
  }

  /// 生成高级安全请求头（针对严格的反爬虫网站）
  Map<String, String> _getAdvancedSecurityHeaders(Uri uri) {
    return {
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-ch-ua-platform-version': '"15.0.0"',
      'sec-ch-ua-arch': '"x86"',
      'sec-ch-ua-model': '',
      'sec-ch-ua-bitness': '"64"',
      'sec-ch-ua-wow64': '?0',
      'sec-ch-ua-full-version-list': '"Not_A Brand";v="8.0.0.0", "Chromium";v="120.0.6099.130", "Google Chrome";v="120.0.6099.130"',
    };
  }

  /// 生成网站特定请求头
  Map<String, String> _getSiteSpecificHeaders(String domain, Uri uri) {
    final headers = <String, String>{};
    
    if (domain.contains('zhihu.com')) {
      headers.addAll(_getZhihuHeaders(uri));
    } else if (domain.contains('weibo.com')) {
      headers.addAll(_getWeiboHeaders(uri));
    } else if (domain.contains('bilibili.com')) {
      headers.addAll(_getBilibiliHeaders(uri));
    }
    
    return headers;
  }

  /// 知乎特定请求头
  Map<String, String> _getZhihuHeaders(Uri uri) {
    return {
      'Referer': 'https://www.zhihu.com/',
      'Origin': 'https://www.zhihu.com',
      'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
      'x-requested-with': 'XMLHttpRequest',
      // 注意：这里不包含x-zse-96等加密头，因为它们需要动态生成
    };
  }

  /// 微博特定请求头
  Map<String, String> _getWeiboHeaders(Uri uri) {
    return {
      'Referer': 'https://weibo.com/',
      'Origin': 'https://weibo.com',
    };
  }

  /// B站特定请求头
  Map<String, String> _getBilibiliHeaders(Uri uri) {
    return {
      'Referer': 'https://www.bilibili.com/',
      'Origin': 'https://www.bilibili.com',
    };
  }

  /// 随机选择User-Agent
  String _selectRandomUserAgent() {
    final allUserAgents = _browserHeaders.values.expand((list) => list).toList();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % allUserAgents.length;
    return allUserAgents[randomIndex];
  }

  /// 检查域名是否需要特殊处理
  bool needsSpecialHandling(String domain) {
    return _siteSpecificStrategies.keys.any((site) => domain.contains(site));
  }

  /// 获取域名的反爬虫等级
  String getAntiCrawlerLevel(String domain) {
    final strategy = _getSiteStrategy(domain);
    
    if (strategy['checksFingerprint'] == true) {
      return 'HIGH';
    } else if (strategy['blocksAutomation'] == true) {
      return 'MEDIUM';
    } else {
      return 'LOW';
    }
  }

  /// 生成WebView设置的优化User-Agent
  String generateWebViewUserAgent() {
    // 为WebView使用一个稳定的User-Agent，避免频繁变化引起怀疑
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  }

  /// 验证请求头是否符合网站要求
  bool validateHeaders(String domain, Map<String, String> headers) {
    final strategy = _getSiteStrategy(domain);
    
    if (strategy['headerWhitelist'] != null) {
      final whitelist = List<String>.from(strategy['headerWhitelist']);
      final headerKeys = headers.keys.map((k) => k.toLowerCase()).toSet();
      
      // 检查是否包含必需的请求头
      final requiredHeaders = ['user-agent', 'accept', 'accept-language'];
      for (final required in requiredHeaders) {
        if (!headerKeys.contains(required)) {
          getLogger().w('⚠️ 缺少必需请求头: $required');
          return false;
        }
      }
    }
    
    return true;
  }
} 