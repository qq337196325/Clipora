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