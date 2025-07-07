import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../basics/logger.dart';

class AppStoreHelper {
  static const String _appId = '6747252007'; // 请替换为实际的应用ID
  static const String _packageName = 'com.guanshangyun.clipora'; // 实际的包名

  /// 跳转到应用商店评价页面
  static Future<void> openAppStoreRating() async {
    try {
      if (Platform.isIOS) {
        await _openIOSAppStore();
      } else if (Platform.isAndroid) {
        await _openAndroidAppStore();
      }
    } catch (e) {
      getLogger().e('打开应用商店失败: $e');
      rethrow;
    }
  }

  /// 跳转到应用商店进行更新
  static Future<void> openAppStoreForUpdate() async {
    try {
      if (Platform.isIOS) {
        await _openIOSAppStoreForUpdate();
      } else if (Platform.isAndroid) {
        await _openAndroidAppStore();
      }
    } catch (e) {
      getLogger().e('打开应用商店更新失败: $e');
      rethrow;
    }
  }

  /// iOS App Store 评价
  static Future<void> _openIOSAppStore() async {
    final url = 'https://apps.apple.com/app/id$_appId?action=write-review';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      getLogger().i('跳转到iOS App Store评价页面');
    } else {
      throw Exception('无法打开iOS App Store');
    }
  }

  /// iOS App Store 更新
  static Future<void> _openIOSAppStoreForUpdate() async {
    final url = 'https://apps.apple.com/app/id$_appId';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      getLogger().i('跳转到iOS App Store更新页面');
    } else {
      throw Exception('无法打开iOS App Store');
    }
  }

  /// Android 应用商店评价
  static Future<void> _openAndroidAppStore() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    String manufacturer = androidInfo.manufacturer.toLowerCase();
    String brand = androidInfo.brand.toLowerCase();
    
    getLogger().i('设备信息 - 品牌: $brand, 制造商: $manufacturer, 型号: ${androidInfo.model}');
    
    // 1. 优先尝试通用market://协议（最兼容的方式）
    if (await _tryUniversalMarket()) {
      return;
    }
    
    // 2. 按品牌优先级尝试打开对应的应用商店
    List<AppStoreInfo> storeList = _getAppStoreList(manufacturer, brand);
    
    bool opened = false;
    for (AppStoreInfo store in storeList) {
      if (await _tryOpenStore(store)) {
        opened = true;
        getLogger().i('成功打开${store.name}');
        break;
      }
    }
    
    if (!opened) {
      // 3. 最后尝试Google Play
      await _openGooglePlay();
    }
  }
  
  /// 尝试通用market协议（最兼容的方式）
  static Future<bool> _tryUniversalMarket() async {
    try {
      getLogger().i('尝试通用market://协议');
      final uri = Uri.parse('market://details?id=$_packageName');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      getLogger().i('通用market://协议成功');
      return true;
    } catch (e) {
      getLogger().w('通用market://协议失败: $e');
      return false;
    }
  }

  /// 获取应用商店列表（按品牌优先级排序）
  static List<AppStoreInfo> _getAppStoreList(String manufacturer, String brand) {
    List<AppStoreInfo> storeList = [];
    
    // 根据设备品牌添加对应的应用商店
    if (brand.contains('huawei') || manufacturer.contains('huawei')) {
      storeList.add(_huaweiAppGallery);
    } else if (brand.contains('xiaomi') || manufacturer.contains('xiaomi')) {
      storeList.add(_xiaomiAppStore);
    } else if (brand.contains('oppo') || manufacturer.contains('oppo')) {
      storeList.add(_oppoAppStore);
    } else if (brand.contains('vivo') || manufacturer.contains('vivo')) {
      storeList.add(_vivoAppStore);
    } else if (brand.contains('meizu') || manufacturer.contains('meizu')) {
      storeList.add(_meizuAppStore);
    } else if (brand.contains('realme') || manufacturer.contains('realme')) {
      storeList.add(_realmeAppStore);
    } else if (brand.contains('oneplus') || manufacturer.contains('oneplus')) {
      storeList.add(_oneplusAppStore);
    }
    
    // 添加通用应用商店
    storeList.addAll([
      _tencentMyApp,
      _baiduMobile,
      _qihooMarket,
      _wandoujiaMarket,
      _coolapkMarket,
    ]);
    
    return storeList;
  }

  /// 尝试打开指定应用商店
  static Future<bool> _tryOpenStore(AppStoreInfo store) async {
    try {
      // 首先尝试打开应用商店的深度链接（应用）
      getLogger().i('尝试打开${store.name}应用: ${store.deepLink}');
      final deepLinkUri = Uri.parse(store.deepLink);
      
      // 使用platformDefault模式，让系统决定如何打开
      try {
        await launchUrl(
          deepLinkUri, 
          mode: LaunchMode.externalApplication,
        );
        getLogger().i('成功通过深度链接打开${store.name}');
        return true;
      } catch (e) {
        getLogger().w('深度链接失败: $e，尝试其他方式');
      }
      
      // 如果深度链接失败，不要立即跳转到网页
      // 让上层函数继续尝试其他应用商店
      return false;
    } catch (e) {
      getLogger().w('打开${store.name}失败: $e');
      return false;
    }
  }

  /// Google Play 商店
  static Future<void> _openGooglePlay() async {
    final playStoreUrl = 'market://details?id=$_packageName';
    final webUrl = 'https://play.google.com/store/apps/details?id=$_packageName';
    
    getLogger().i('尝试打开Google Play应用');
    try {
      final uri = Uri.parse(playStoreUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      getLogger().i('成功打开Google Play应用');
      return;
    } catch (e) {
      getLogger().w('打开Google Play应用失败: $e');
    }
    
    // 如果所有应用商店都无法打开，最后才尝试网页版Google Play
    getLogger().i('所有应用商店都无法打开，尝试Google Play网页版');
    try {
      final webUri = Uri.parse(webUrl);
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      getLogger().i('打开Google Play网页版成功');
    } catch (e) {
      getLogger().e('打开Google Play网页版也失败: $e');
      throw Exception('无法打开任何应用商店，请手动前往应用商店评价');
    }
  }

  // 各大应用商店信息
  static final AppStoreInfo _huaweiAppGallery = AppStoreInfo(
    name: '华为应用市场',
    deepLink: 'appmarket://details?id=$_packageName',
    webLink: 'https://appgallery.huawei.com/app/$_packageName',
  );

  static final AppStoreInfo _xiaomiAppStore = AppStoreInfo(
    name: '小米应用商店',
    deepLink: 'mimarket://details?id=$_packageName',
    webLink: 'https://app.mi.com/details?id=$_packageName',
  );

  static final AppStoreInfo _oppoAppStore = AppStoreInfo(
    name: 'OPPO软件商店',
    deepLink: 'oppomarket://details?packagename=$_packageName',
    webLink: 'https://store.oppo.com/app/en?name=$_packageName',
  );

  static final AppStoreInfo _vivoAppStore = AppStoreInfo(
    name: 'vivo应用商店',
    deepLink: 'vivomarket://details?id=$_packageName',
    webLink: 'https://app.vivo.com.cn/detail/$_packageName',
  );

  static final AppStoreInfo _meizuAppStore = AppStoreInfo(
    name: '魅族应用商店',
    deepLink: 'mzmarket://details?package_name=$_packageName',
    webLink: 'https://app.meizu.com/apps/public/detail?package_name=$_packageName',
  );

  static final AppStoreInfo _realmeAppStore = AppStoreInfo(
    name: 'realme应用商店',
    deepLink: 'realmemarket://details?id=$_packageName',
    webLink: '',
  );

  static final AppStoreInfo _oneplusAppStore = AppStoreInfo(
    name: 'OnePlus应用商店',
    deepLink: 'oneplusmarket://details?id=$_packageName',
    webLink: '',
  );

  static final AppStoreInfo _tencentMyApp = AppStoreInfo(
    name: '腾讯应用宝',
    deepLink: 'market://details?id=$_packageName', // 使用标准market协议
    webLink: 'https://android.myapp.com/myapp/detail.htm?apkName=$_packageName',
  );

  static final AppStoreInfo _baiduMobile = AppStoreInfo(
    name: '百度手机助手',
    deepLink: 'market://details?id=$_packageName', // 使用标准market协议
    webLink: 'https://mobile.baidu.com/item?docid=$_packageName',
  );

  static final AppStoreInfo _qihooMarket = AppStoreInfo(
    name: '360手机助手',
    deepLink: 'market://details?id=$_packageName', // 使用标准market协议
    webLink: 'https://zhushou.360.cn/detail/index/soft_id/$_packageName',
  );

  static final AppStoreInfo _wandoujiaMarket = AppStoreInfo(
    name: '豌豆荚',
    deepLink: 'market://details?id=$_packageName', // 使用标准market协议
    webLink: 'https://www.wandoujia.com/apps/$_packageName',
  );

  static final AppStoreInfo _coolapkMarket = AppStoreInfo(
    name: '酷安',
    deepLink: 'coolmarket://details?id=$_packageName', // 酷安的正确scheme
    webLink: 'https://www.coolapk.com/apk/$_packageName',
  );
}

/// 应用商店信息类
class AppStoreInfo {
  final String name;
  final String deepLink;
  final String webLink;

  const AppStoreInfo({
    required this.name,
    required this.deepLink,
    required this.webLink,
  });
} 