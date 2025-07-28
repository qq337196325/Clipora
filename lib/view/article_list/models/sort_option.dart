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



import 'package:get/get.dart';

/// 排序类型枚举
enum SortType {
  createTime('createTime'),
  modifyTime('modifyTime'),
  name('name');

  const SortType(this.value);

  final String value;

  String get label {
    switch (this) {
      case SortType.createTime:
        return 'i18n_article_list_sort_by_create_time'.tr;
      case SortType.modifyTime:
        return 'i18n_article_list_sort_by_modify_time'.tr;
      case SortType.name:
        return 'i18n_article_list_sort_by_name'.tr;
    }
  }
}

/// 排序选项配置
class SortOption {
  final SortType type;
  final bool isDescending;
  
  const SortOption({
    required this.type,
    this.isDescending = true,
  });
  
  SortOption copyWith({
    SortType? type,
    bool? isDescending,
  }) {
    return SortOption(
      type: type ?? this.type,
      isDescending: isDescending ?? this.isDescending,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SortOption &&
        other.type == type &&
        other.isDescending == isDescending;
  }
  
  @override
  int get hashCode => type.hashCode ^ isDescending.hashCode;
} 