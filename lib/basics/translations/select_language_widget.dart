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


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_controller.dart';

class SelectLanguageWidget extends StatelessWidget {
  const SelectLanguageWidget({super.key});

  /// 显示语言选择底部弹窗
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SelectLanguageWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部横杠
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'i18n_language_selector_title'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      Text(
                        'i18n_language_selector_subtitle'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 语言列表
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languageController.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final language = languageController.supportedLanguages[index];
                  
                  return Obx(() {
                    final isSelected = languageController.isCurrentLanguage(
                      language.languageCode,
                      language.countryCode,
                    );
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                            ? const Color(0xFF667eea)
                            : const Color(0xFFE5E5E7),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected 
                          ? const Color(0xFF667eea).withOpacity(0.1)
                          : Colors.white,
                        boxShadow: isSelected 
                          ? [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (!isSelected) {
                              languageController.changeLanguage(
                                language.languageCode,
                                language.countryCode,
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // 国旗表情
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                      ? const Color(0xFF667eea).withOpacity(0.1)
                                      : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected 
                                        ? const Color(0xFF667eea).withOpacity(0.3)
                                        : const Color(0xFFE9ECEF),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      language.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // 语言信息
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getLanguageDisplayName(language),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected 
                                            ? const Color(0xFF667eea)
                                            : const Color(0xFF1D1D1F),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getLanguageDescription(language),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected 
                                            ? const Color(0xFF667eea).withOpacity(0.7)
                                            : const Color(0xFF8E8E93),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 选中标识
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF667eea),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE5E5E7),
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
          
          // 底部说明
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE9ECEF),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF667eea),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'i18n_language_selector_tip'.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取语言显示名称
  String _getLanguageDisplayName(LanguageModel language) {
    final key = 'i18n_language_name_${language.languageCode}_${language.countryCode.toLowerCase()}';
    return key.tr;
  }

  /// 获取语言描述
  String _getLanguageDescription(LanguageModel language) {
    final key = 'i18n_language_desc_${language.languageCode}_${language.countryCode.toLowerCase()}';
    return key.tr;
  }
}
