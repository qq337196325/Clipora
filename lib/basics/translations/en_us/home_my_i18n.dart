// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.



const Map<String, String> homeMyI18n = {
  // 我的页面主要内容
  'i18n_my_设置': 'Settings',
  'i18n_my_应用功能': 'App Features',
  'i18n_my_信息': 'Information',
  'i18n_my_退出登录': 'Log Out',
  'i18n_my_注销账号': 'Delete Account',
  
  // AI翻译相关
  'i18n_my_AI翻译请求': 'AI Translation Requests',
  'i18n_my_让阅读更智能翻译更流畅': 'Make reading smarter, translation smoother',
  'i18n_my_购买': 'Purchase',
  'i18n_my_正在获取AI翻译余量': 'Getting AI translation balance...',
  'i18n_my_加载失败请点击重试': 'Loading failed, click to retry',
  'i18n_my_已用': 'Used: @used',
  'i18n_my_剩余': 'Remaining: @remaining / @total',
  
  // 设置项目
  'i18n_my_语言设置': 'Language Settings',
  'i18n_my_当前语言': 'Current: @language',
  'i18n_my_主题设置': 'Theme Settings',
  'i18n_my_当前主题': 'Current: @theme',
  'i18n_my_用户协议': 'User Agreement',
  'i18n_my_了解我们的用户协议': 'Learn about our user agreement',
  'i18n_my_隐私协议': 'Privacy Policy',
  'i18n_my_保护您的隐私权益': 'Protect your privacy rights',
  'i18n_my_关于我们': 'About Us',
  'i18n_my_了解更多应用信息': 'Learn more about the app',
  'i18n_my_使用帮助': 'Usage Help',
  'i18n_my_常见问题与解答': 'FAQ and Answers',
  'help_documentation': 'Help Documentation',
  'i18n_my_评价一下': 'Rate Us',
  'i18n_my_您的评价是我们前进的动力': 'Your rating is our motivation',
  'i18n_my_应用商店测试': 'App Store Test',
  'i18n_my_测试应用商店跳转功能': 'Test App Store redirect function',
  
  // 退出登录对话框
  'i18n_my_确定要退出当前账号吗': 'Are you sure you want to log out of the current account?',
  'i18n_my_取消': 'Cancel',
  'i18n_my_退出': 'Log Out',
  
  // 注销账号对话框
  'i18n_my_确定要注销当前账号吗': 'Are you sure you want to delete the current account? All data will be deleted and cannot be recovered.',
  'i18n_my_注销': 'Delete',

  // 关于我们页面
  'i18n_my_关于我们页面标题': 'About Us',
  'i18n_my_智能剪藏与笔记管理': 'Smart Clipping & Note Management',
  'i18n_my_版本信息': 'Version Information',
  'i18n_my_版本号': 'Version Number',
  'i18n_my_构建号': 'Build Number',
  'i18n_my_备案号': 'Registration Number',
  'i18n_my_应用介绍': 'App Introduction',
  'i18n_my_应用介绍内容': 'Clipora is a smart clipping and note management app designed for modern users. We are committed to helping users efficiently collect, organize, and manage various types of information, making knowledge management simpler and more efficient.',
  'i18n_my_主要功能': 'Main Features:',
  'i18n_my_网页内容快速剪藏': 'Quick web content clipping',
  'i18n_my_智能笔记分类管理': 'Smart note categorization management',
  'i18n_my_全文搜索与标签系统': 'Full-text search and tag system',
  'i18n_my_跨平台同步与分享': 'Cross-platform sync and sharing',
  'i18n_my_联系我们': 'Contact Us',
  'i18n_my_邮箱': 'Email',
  'i18n_my_官网': 'Official Website',
  'i18n_my_感谢您使用Clipora': 'Thank you for using Clipora. If you have any questions or suggestions, feel free to contact us!',
  'i18n_my_邮箱地址已复制到剪贴板': 'Email address copied to clipboard',
  'i18n_my_官网地址已复制到剪贴板': 'Official website address copied to clipboard',
  
  // 应用商店测试页面
  'i18n_my_应用商店测试页面标题': 'App Store Test',
  'i18n_my_设备信息': 'Device Information',
  'i18n_my_设备品牌': 'Device Brand',
  'i18n_my_制造商': 'Manufacturer',
  'i18n_my_型号': 'Model',
  'i18n_my_Android版本': 'Android Version',
  'i18n_my_API级别': 'API Level',
  'i18n_my_设备型号': 'Device Model',
  'i18n_my_系统名称': 'System Name',
  'i18n_my_系统版本': 'System Version',
  'i18n_my_设备名称': 'Device Name',
  'i18n_my_正在获取设备信息': 'Getting device information...',
  'i18n_my_测试通用market协议': 'Test generic market:// protocol',
  'i18n_my_测试完整应用商店流程': 'Test complete App Store process',
  'i18n_my_测试GooglePlay': 'Test Google Play',
  'i18n_my_测试日志': 'Test Log',
  'i18n_my_点击上方按钮开始测试': 'Click the button above to start testing',
  'i18n_my_开始测试通用market协议': 'Start testing generic market:// protocol',
  'i18n_my_成功打开应用商店': '✅ Successfully opened App Store',
  'i18n_my_失败': '❌ Failed: @error',
  'i18n_my_开始测试完整应用商店流程': 'Start testing complete App Store process',
  'i18n_my_开始测试GooglePlay': 'Start testing Google Play',
  'i18n_my_成功打开GooglePlay': '✅ Successfully opened Google Play',
  'i18n_my_GooglePlay失败': '❌ Google Play failed: @error',
  
  // 评价对话框
  'i18n_my_评价一下我们的应用': 'Rate Our App',
  'i18n_my_您的评价是我们前进的动力描述': 'Your rating is our motivation\nDo you like our app?',
  'i18n_my_点击星星直接跳转到应用商店评价': 'Click stars to go directly to App Store rating',
  'i18n_my_稍后再说': 'Later',
  'i18n_my_立即评价': 'Rate Now',
  'i18n_my_将跳转到AppStore进行评价': 'Will redirect to App Store for rating',
  'i18n_my_将根据您的设备自动选择应用商店': 'App Store will be automatically selected based on your device',
  'i18n_my_暂时无法打开应用商店请稍后重试': 'Cannot open App Store at the moment, please try again later',
  'i18n_my_确定': 'Confirm',

  // 0727
  'i18n_my_自动解析': 'Auto Parse',
  'i18n_my_自动解析网页内容并提取文本': 'Automatically parse web content and extract text',
};