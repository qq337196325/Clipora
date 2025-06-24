/// 排序类型枚举
enum SortType {
  createTime('createTime', '按创建时间'),
  modifyTime('modifyTime', '按修改时间'),
  name('name', '按名称');

  const SortType(this.value, this.label);
  
  final String value;
  final String label;
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