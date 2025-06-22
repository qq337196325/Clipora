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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredTags = _allTags
        .where((tag) =>
            tag.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    final showCreateButton = _searchText.isNotEmpty &&
        !_allTags.any(
            (tag) => tag.name.toLowerCase() == _searchText.toLowerCase());

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                  child: _buildSearchBar(context, isDarkMode)),
              _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildTagList(
                      context, filteredTags, showCreateButton, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const Text('编辑标签',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: _saveTags,
            child: Text('完成',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: '搜索或创建标签',
          prefixIcon:
              const Icon(Icons.search, color: Colors.grey, size: 22),
          filled: true,
          fillColor: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  SliverList _buildTagList(BuildContext context, List<TagDb> filteredTags,
      bool showCreateButton, bool isDarkMode) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (showCreateButton && index == 0) {
            return _buildCreateTagItem(context);
          }
          final tagIndex = index - (showCreateButton ? 1 : 0);
          if (tagIndex < filteredTags.length) {
            final tag = filteredTags[tagIndex];
            final isSelected = _selectedTagIds.contains(tag.id);
            return _buildTagItem(context, tag, isSelected);
          }
          return null;
        },
        childCount: filteredTags.length + (showCreateButton ? 1 : 0),
      ),
    );
  }

  Widget _buildTagItem(BuildContext context, TagDb tag, bool isSelected) {
    return ListTile(
      title: Text('# ${tag.name}', style: const TextStyle(fontSize: 16)),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedTagIds.add(tag.id);
            } else {
              _selectedTagIds.remove(tag.id);
            }
          });
        },
      ),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTagIds.remove(tag.id);
          } else {
            _selectedTagIds.add(tag.id);
          }
        });
      },
    );
  }

  Widget _buildCreateTagItem(BuildContext context) {
    return ListTile(
      title: Text('# $_searchText', style: const TextStyle(fontSize: 16)),
      trailing: Text(
        '点击创建',
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600),
      ),
      onTap: _createTag,
    );
  }
} 