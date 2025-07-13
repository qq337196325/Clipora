import 'package:flutter/material.dart';

/// 应用颜色系统 - 统一管理所有主题颜色
class AppColors {
  // ==================== 主色调 ====================
  
  /// 蓝色系主色调
  static const Color bluePrimary = Color(0xFF42A5F5);
  static const Color bluePrimaryLight = Color(0xFF64B5F6);
  static const Color bluePrimaryDark = Color(0xFF1976D2);
  
  /// 绿色系主色调（护眼）
  static const Color greenPrimary = Color(0xFF81C784);
  static const Color greenPrimaryLight = Color(0xFFA5D6A7);
  static const Color greenPrimaryDark = Color(0xFF66BB6A);
  
  /// 棕色系主色调（纸张感）
  static const Color brownPrimary = Color(0xFF6D4C41);
  static const Color brownPrimaryLight = Color(0xFF8D6E63);
  static const Color brownPrimaryDark = Color(0xFF4E342E);
  
  /// 紫色系主色调（现代感）
  static const Color purplePrimary = Color(0xFF9C27B0);
  static const Color purplePrimaryLight = Color(0xFFBA68C8);
  static const Color purplePrimaryDark = Color(0xFF7B1FA2);

  // ==================== 背景色系 ====================
  
  /// 浅色背景
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightCard = Colors.white;
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  /// 护眼背景
  static const Color readingBackground = Color(0xFFF5F5DC);
  static const Color readingSurface = Color(0xFFFFF8E1);
  static const Color readingCard = Color(0xFFFFFEF7);
  static const Color readingDivider = Color(0xFFE8E6D9);
  
  /// 深色背景
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF212121);
  static const Color darkDivider = Color(0xFF424242);
  
  /// 夜间护眼背景
  static const Color nightReadingBackground = Color(0xFF263238);
  static const Color nightReadingSurface = Color(0xFF2E3C43);
  static const Color nightReadingCard = Color(0xFF37474F);
  static const Color nightReadingDivider = Color(0xFF455A64);

  // ==================== 文本色系 ====================
  
  /// 浅色主题文本
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFFBDBDBD);
  static const Color lightTextDisabled = Color(0xFFE0E0E0);
  
  /// 护眼主题文本
  static const Color readingTextPrimary = Color(0xFF3C3C3C);
  static const Color readingTextSecondary = Color(0xFF5D5D5D);
  static const Color readingTextHint = Color(0xFF9E9E9E);
  static const Color readingTextDisabled = Color(0xFFD0D0D0);
  
  /// 深色主题文本
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextHint = Color(0xFF757575);
  static const Color darkTextDisabled = Color(0xFF424242);
  
  /// 夜间护眼文本
  static const Color nightReadingTextPrimary = Color(0xFFE5E5E7);
  static const Color nightReadingTextSecondary = Color(0xFFB0BEC5);
  static const Color nightReadingTextHint = Color(0xFF78909C);
  static const Color nightReadingTextDisabled = Color(0xFF546E7A);

  // ==================== 状态色系 ====================
  
  /// 成功状态
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  /// 警告状态
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  /// 错误状态
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  /// 信息状态
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ==================== 交互状态色系 ====================
  
  /// 浅色主题交互状态
  static const Color lightHover = Color(0xFFF5F5F5);
  static const Color lightPressed = Color(0xFFEEEEEE);
  static const Color lightSelected = Color(0xFFE3F2FD);
  
  /// 护眼主题交互状态
  static const Color readingHover = Color(0xFFF0F0E8);
  static const Color readingPressed = Color(0xFFE8E6D9);
  static const Color readingSelected = Color(0xFFE8F5E8);
  
  /// 深色主题交互状态
  static const Color darkHover = Color(0xFF2A2A2A);
  static const Color darkPressed = Color(0xFF1A1A1A);
  static const Color darkSelected = Color(0xFF1E3A5F);
  
  /// 夜间护眼交互状态
  static const Color nightReadingHover = Color(0xFF2E3C43);
  static const Color nightReadingPressed = Color(0xFF1E2C33);
  static const Color nightReadingSelected = Color(0xFF1E3A2A);

  // ==================== 阴影色系 ====================
  
  /// 浅色阴影
  static const Color lightShadow = Color(0x1A000000);
  static const Color lightShadowStrong = Color(0x33000000);
  
  /// 深色阴影
  static const Color darkShadow = Color(0x1AFFFFFF);
  static const Color darkShadowStrong = Color(0x33FFFFFF);

  // ==================== 辅助方法 ====================
  
  /// 获取主题对应的背景色
  static Color getBackgroundColor(bool isDark, bool isReading) {
    if (isDark) {
      return isReading ? nightReadingBackground : darkBackground;
    } else {
      return isReading ? readingBackground : lightBackground;
    }
  }
  
  /// 获取主题对应的表面色
  static Color getSurfaceColor(bool isDark, bool isReading) {
    if (isDark) {
      return isReading ? nightReadingSurface : darkSurface;
    } else {
      return isReading ? readingSurface : lightSurface;
    }
  }
  
  /// 获取主题对应的卡片色
  static Color getCardColor(bool isDark, bool isReading) {
    if (isDark) {
      return isReading ? nightReadingCard : darkCard;
    } else {
      return isReading ? readingCard : lightCard;
    }
  }
  
  /// 获取主题对应的主文本色
  static Color getTextPrimaryColor(bool isDark, bool isReading) {
    if (isDark) {
      return isReading ? nightReadingTextPrimary : darkTextPrimary;
    } else {
      return isReading ? readingTextPrimary : lightTextPrimary;
    }
  }
  
  /// 获取主题对应的次文本色
  static Color getTextSecondaryColor(bool isDark, bool isReading) {
    if (isDark) {
      return isReading ? nightReadingTextSecondary : darkTextSecondary;
    } else {
      return isReading ? readingTextSecondary : lightTextSecondary;
    }
  }
} 