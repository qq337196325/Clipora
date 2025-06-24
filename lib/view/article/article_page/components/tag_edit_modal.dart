import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/db/tag/tag_db.dart';
import '/services/tag_service.dart';

class TagEditModal extends StatefulWidget {
  final int articleId;
  const TagEditModal({super.key, required this.articleId});

  @override
  State<TagEditModal> createState() => _TagEditModalState();
}

class _TagEditModalState extends State<TagEditModal> {
  final _tagService = TagService();
  final _searchController = TextEditingController();
  late final StreamSubscription<List<TagDb>> _tagsSubscription;

  List<TagDb> _allTags = [];
  String _searchText = '';
  final Set<int> _selectedTagIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialTags();
    _tagsSubscription = _tagService.watchAllTags().listen((tags) {
      if (mounted) {
        setState(() {
          _allTags = tags;
        });
      }
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchText = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tagsSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadInitialTags() async {
    final articleTags = await _tagService.getTagsForArticle(widget.articleId);
    if (mounted) {
      setState(() {
        _selectedTagIds.addAll(articleTags.map((t) => t.id));
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTags() async {
    await _tagService.updateArticleTags(widget.articleId, _selectedTagIds);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createTag() async {
    if (_searchText.trim().isEmpty) return;
    await _tagService.createTag(_searchText.trim());
    _searchController.clear();
  }

  List<Widget> _buildTagList(BuildContext context) {
    final filteredTags = _allTags
        .where((tag) =>
            tag.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    final showCreateButton = _searchText.isNotEmpty &&
        !_allTags.any(
            (tag) => tag.name.toLowerCase() == _searchText.toLowerCase());

    final List<Widget> widgets = [];

    // Add create tag option if needed
    if (showCreateButton) {
      widgets.add(_buildCreateTagItem(context));
    }

    // Add existing tags
    for (final tag in filteredTags) {
      final isSelected = _selectedTagIds.contains(tag.id);
      widgets.add(_buildTagItem(context, tag, isSelected));
    }

    if (widgets.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              '暂无标签',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ];
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Header
            _buildHeader(context, theme),
            // Search Bar
            _buildSearchBar(context, theme),
            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildTagList(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '编辑标签',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _saveTags,
                child: Text(
                  '完成',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // IconButton(
              //   icon: Icon(
              //     Icons.close,
              //     color: theme.iconTheme.color?.withOpacity(0.7),
              //   ),
              //   onPressed: () => Navigator.of(context).pop(),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '搜索或创建标签',
            hintStyle: TextStyle(
              color: theme.hintColor.withOpacity(0.7),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary.withOpacity(0.7),
              size: 24,
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTagItem(BuildContext context, TagDb tag, bool isSelected) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final selectedBackgroundColor = selectedColor.withOpacity(0.1);

    return Material(
      color: isSelected ? selectedBackgroundColor : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedTagIds.remove(tag.id);
            } else {
              _selectedTagIds.add(tag.id);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#',
                  style: TextStyle(
                    color: selectedColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  tag.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? selectedColor : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: selectedColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTagItem(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Material(
      color: primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: _createTag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _searchText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '创建',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 