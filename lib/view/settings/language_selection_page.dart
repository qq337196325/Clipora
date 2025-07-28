// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../basics/translations/language_controller.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => ListView.builder(
        itemCount: languageController.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = languageController.supportedLanguages[index];
          final isSelected = languageController.isCurrentLanguage(
            language.languageCode,
            language.countryCode,
          );
          
          return ListTile(
            leading: Text(
              language.flag,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              language.languageName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            trailing: isSelected 
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                )
              : null,
            onTap: () {
              if (!isSelected) {
                languageController.changeLanguage(
                  language.languageCode,
                  language.countryCode,
                );
                Get.back();
              }
            },
          );
        },
      )),
    );
  }
} 