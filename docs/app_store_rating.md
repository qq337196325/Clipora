# 应用商店评价功能说明

## 功能概述

这个功能实现了跨平台的应用商店评价跳转，支持iOS App Store和Android各大应用商店。

## 核心特性

### iOS支持
- 自动跳转到App Store评价页面
- 支持itms-apps://和https://两种方式

### Android支持
根据设备品牌自动选择合适的应用商店：

**手机品牌应用商店（优先级最高）**
- 华为：华为应用市场
- 小米：小米应用商店
- OPPO：OPPO软件商店
- vivo：vivo应用商店
- 魅族：魅族应用商店
- realme：realme应用商店
- OnePlus：OnePlus应用商店

**通用应用商店（降级选择）**
- 腾讯应用宝
- 百度手机助手
- 360手机助手
- 豌豆荚
- 酷安
- Google Play（最后选择）

## 配置步骤

### 1. 更新应用ID和包名

在`lib/basics/app_store_helper.dart`文件中：

```dart
class AppStoreHelper {
  static const String _appId = 'your_app_id'; // 请替换为实际的iOS应用ID
  static const String _packageName = 'com.guanshangyun.clipora'; // Android包名
  
  // ...
}
```

**iOS应用ID获取方法：**
1. 登录[App Store Connect](https://appstoreconnect.apple.com/)
2. 选择你的应用
3. 在应用信息页面找到"Apple ID"
4. 将这个数字ID替换到代码中

### 2. 权限配置已完成

**Android权限（AndroidManifest.xml）**
- ✅ INTERNET权限
- ✅ 应用商店查询权限
- ✅ 各大应用商店包名查询权限

**iOS权限（Info.plist）**
- ✅ LSApplicationQueriesSchemes配置
- ✅ itms-apps和https协议支持

### 3. 依赖包已添加

```yaml
dependencies:
  url_launcher: ^6.3.1      # 打开外部链接
  device_info_plus: ^10.1.2 # 获取设备信息
```

## 使用方法

### 基础调用
```dart
import 'package:your_app/basics/app_store_helper.dart';

// 直接跳转到应用商店
await AppStoreHelper.openAppStoreRating();
```

### 使用评价对话框（推荐）
```dart
import 'package:your_app/view/home/my_page/rating_dialog.dart';

// 显示评价对话框
await RatingDialog.show(context);
```

## 工作原理

### Android应用商店检测流程
1. 获取设备品牌和制造商信息
2. 根据品牌映射到对应的应用商店
3. 按优先级尝试打开应用商店：
   - 深度链接（market://、mimarket://等）
   - 网页链接（如果深度链接失败）
4. 如果所有品牌应用商店都失败，最后尝试Google Play

### iOS处理流程
1. 构造App Store评价链接
2. 尝试使用itms-apps://协议打开
3. 如果失败则使用https://网页版

## 错误处理

功能包含完善的错误处理机制：
- 记录详细的日志信息
- 友好的用户提示
- 优雅的降级处理

## 测试建议

### 开发阶段测试
1. 修改`_appId`为一个已存在的应用ID进行测试
2. 在不同品牌的Android设备上测试
3. 检查日志输出确认检测逻辑正确

### 发布前测试
1. 确保App Store应用已上线并有正确的ID
2. 在各主要Android品牌设备上测试
3. 验证权限配置正确

## 注意事项

1. **iOS应用ID**：必须是已在App Store上线的应用ID
2. **Android包名**：必须与实际发布的包名一致
3. **权限配置**：确保所有权限配置都已正确添加
4. **网络连接**：功能需要网络连接才能正常工作

## 日志信息

功能会记录以下日志信息便于调试：
- 设备品牌和制造商
- 尝试打开的应用商店
- 成功/失败状态
- 错误信息

查看日志：
```dart
import 'package:your_app/basics/logger.dart';

getLogger().i('查看日志信息');
``` 