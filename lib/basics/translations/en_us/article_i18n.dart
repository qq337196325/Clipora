// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/



const Map<String, String> articleI18n = {
  // article bottom bar
  'i18n_article_文章链接不存在': 'Article link does not exist',
  'i18n_article_无法打开该链接': 'Could not open the link',
  'i18n_article_打开链接失败': 'Failed to open link: ',
  'i18n_article_返回': 'Back',
  'i18n_article_浏览器打开': 'Open in browser',
  'i18n_article_更多': 'More',

  // article_loading_view
  'i18n_article_正在加载文章': 'Loading article...',

  // more_actions_modal
  'i18n_article_功能待开发': 'Function is under development',
  'i18n_article_链接已复制到剪贴板': 'Link copied to clipboard',
  'i18n_article_复制失败': 'Failed to copy: ',
  'i18n_article_文章信息加载中请稍后重试': 'Article information is loading, please try again later',
  'i18n_article_已标记为重要': 'Marked as important',
  'i18n_article_已取消重要标记': 'Unmarked as important',
  'i18n_article_操作失败': 'Operation failed: ',
  'i18n_article_已归档': 'Archived',
  'i18n_article_已取消归档': 'Unarchived',
  'i18n_article_请切换到网页标签页进行操作': 'Please switch to the "Web" tab to perform the @actionName action',
  'i18n_article_确认删除': 'Confirm Deletion',
  'i18n_article_确定要删除这篇文章吗': 'Are you sure you want to delete this article?',
  'i18n_article_删除后的文章可以在回收站中找到': 'Deleted articles can be found in the trash.',
  'i18n_article_取消': 'Cancel',
  'i18n_article_删除': 'Delete',
  'i18n_article_文章已删除': 'Article deleted',
  'i18n_article_删除失败': 'Failed to delete: ',
  'i18n_article_复制链接': 'Copy Link',
  'i18n_article_刷新解析': 'Refresh Parse',
  'i18n_article_重新生成快照': 'Re-generate Snapshot',
  'i18n_article_AI翻译': 'AI Translate',
  'i18n_article_标签': 'Tags',
  'i18n_article_移动': 'Move',
  'i18n_article_取消重要': 'Unmark',
  'i18n_article_标为重要': 'Mark as Important',
  'i18n_article_取消归档': 'Unarchive',
  'i18n_article_归档': 'Archive',

  // move_to_category_modal
  'i18n_article_加载分类失败': 'Failed to load categories: ',
  'i18n_article_未分类': 'Uncategorized',
  'i18n_article_成功移动到': 'Successfully moved to ',
  'i18n_article_未找到文章': 'Article not found',
  'i18n_article_移动失败': 'Failed to move: ',
  'i18n_article_设为未分类': 'Set as Uncategorized',
  'i18n_article_移动到分组': 'Move to Group',

  // tag_edit_modal
  'i18n_article_暂无标签': 'No tags yet',
  'i18n_article_编辑标签': 'Edit Tags',
  'i18n_article_完成': 'Done',
  'i18n_article_搜索或创建标签': 'Search or create a tag',
  'i18n_article_创建': 'Create',

  // translate_modal
  'i18n_article_AI翻译不足': 'Insufficient AI Translation Quota',
  'i18n_article_AI翻译额度已用完提示': 'New users receive 3 free AI translations. Your AI translation quota has been exhausted. Please recharge to continue using high-quality translation services.',
  'i18n_article_以后再说': 'Later',
  'i18n_article_前往充值': 'Recharge',
  'i18n_article_选择要翻译的目标语言': 'Select target language for translation',
  'i18n_article_已可用': 'Available',
  'i18n_article_翻译完成': 'Translation complete',
  'i18n_article_正在翻译中': 'Translating, estimated 20s to 2min...',
  'i18n_article_翻译失败': 'Translation failed',
  'i18n_article_待翻译': 'Untranslated',
  'i18n_article_查看': 'View',
  'i18n_article_翻译': 'Translate',
  'i18n_article_重新翻译': 'Retranslate',
  'i18n_article_重试': 'Retry',
  'i18n_article_原文': 'Original',
  'i18n_article_英语': 'English',
  'i18n_article_日语': 'Japanese',
  'i18n_article_韩语': 'Korean',
  'i18n_article_法语': 'French',
  'i18n_article_德语': 'German',
  'i18n_article_西班牙语': 'Spanish',
  'i18n_article_俄语': 'Russian',
  'i18n_article_阿拉伯语': 'Arabic',
  'i18n_article_葡萄牙语': 'Portuguese',
  'i18n_article_意大利语': 'Italian',
  'i18n_article_荷兰语': 'Dutch',
  'i18n_article_泰语': 'Thai',
  'i18n_article_越南语': 'Vietnamese',
  'i18n_article_简体中文': 'Simplified Chinese',
  'i18n_article_繁体中文': 'Traditional Chinese',

  // article_page
  'i18n_article_快照更新成功': 'Snapshot updated successfully',
  'i18n_article_快照更新失败': 'Snapshot update failed: ',
  'i18n_article_图文更新成功': 'Markdown updated successfully',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown is generating, please check later',
  'i18n_article_Markdown获取失败': 'Failed to get Markdown: ',
  'i18n_article_Markdown更新失败': 'Markdown update failed: ',
  'i18n_article_加载失败': 'Failed to load',
  // 'i18n_article_重试': 'Retry', // Duplicated key
  'i18n_article_图文': 'Text',
  'i18n_article_网页': 'Web',
  'i18n_article_快照': 'Snapshot',
  'i18n_article_未知页面类型': 'Unknown page type',
  'i18n_article_内容加载中': 'Content loading...',
  'i18n_article_快照已保存路径': 'Snapshot saved, path: ',
  'i18n_article_网页未加载完成请稍后再试': 'Web page not fully loaded, please try again later',
  'i18n_article_请切换到网页标签页生成快照': 'Please switch to the web page tab to generate a snapshot',

  // article_web_widget
  'i18n_article_网页加载失败': 'Web Page Load Failed',
  'i18n_article_重新加载': 'Reload',
  'i18n_article_保存快照失败': 'Failed to save snapshot',
  'i18n_article_保存快照到数据库失败': 'Failed to save snapshot to database',
  'i18n_article_重新加载失败提示': 'Reload failed\\n\\nPlease try again later or restart the app.\\n\\nError details: ',
  'i18n_article_重新加载时发生错误提示': 'An error occurred while reloading\\n\\nPlease restart the app and try again.\\n\\nError details: ',
  'i18n_article_网站访问被限制提示': 'Site Access Restricted (403)\\n\\nThis site has detected unusual access patterns.\\n\\nSuggestions:\\n• Retry later\\n• Access directly with a browser\\n• Check your network environment',
  'i18n_article_重试失败提示': 'Retry failed\\n\\nPlease try again manually later or use a browser to access.',

  // article_markdown_widget
  'i18n_article_无法创建高亮文章信息缺失': 'Cannot create highlight: article information is missing',
  'i18n_article_高亮已添加': 'Highlight added',
  'i18n_article_高亮添加失败': 'Failed to add highlight',
  'i18n_article_无法创建笔记文章信息缺失': 'Cannot create note: article information is missing',
  'i18n_article_笔记已添加': 'Note added',
  'i18n_article_笔记添加失败': 'Failed to add note',
  'i18n_article_无法复制内容为空': 'Cannot copy: content is empty',
  'i18n_article_已复制': 'Copied: ',
  'i18n_article_复制失败请重试': 'Copy failed, please try again',
  'i18n_article_正在删除标注': 'Deleting highlight...',
  'i18n_article_删除失败无法从页面中移除标注': 'Delete failed: cannot remove highlight from the page',
  'i18n_article_标注已删除': 'Highlight deleted',
  'i18n_article_删除异常建议刷新页面': 'Deletion error, please refresh the page',

  // article_markdown/components
  'i18n_article_选中文字': 'Selected Text',
  'i18n_article_笔记内容': 'Note Content',
  'i18n_article_记录你的想法感悟或灵感': 'Record your thoughts, insights, or inspiration...',
  'i18n_article_内容超出字符限制提示': 'Content exceeds the @maxCharacters character limit, please shorten it.',
  'i18n_article_添加笔记': 'Add Note',
  'i18n_article_删除标注': 'Delete Highlight',
  'i18n_article_此操作无法撤销': 'This action cannot be undone',
  'i18n_article_确定要删除以下标注吗': 'Are you sure you want to delete the following highlight?',
  'i18n_article_标注内容': 'Highlight Content',
  'i18n_article_复制': 'Copy',
  'i18n_article_高亮': 'Highlight',
  'i18n_article_笔记': 'Note',

  // article_controller
  'i18n_article_文章信息获取失败': 'Failed to get article information',
  'i18n_article_您的翻译额度已用完': 'Your translation quota has been used up',
  'i18n_article_翻译请求失败': 'Translation request failed',
  'i18n_article_翻译请求失败请重试': 'Translation request failed, please try again',
  'i18n_article_未知标题': 'Unknown Title',

  // snapshot_utils
  'i18n_article_WebView未初始化': 'WebView not initialized',
  'i18n_article_开始生成快照': 'Starting to generate snapshot...',
  'i18n_article_快照保存成功': 'Snapshot saved successfully',
  'i18n_article_生成快照失败': 'Failed to generate snapshot: ',

  // article_mhtml_widget
  'i18n_article_快照加载失败': 'Snapshot Load Failed',
  'i18n_article_加载错误文件路径': 'Load error: @description\nFile path: @path',
  'i18n_article_HTTP错误': 'HTTP error: @statusCode\n@reasonPhrase',
  'i18n_article_快照文件不存在': 'Snapshot file not found\nPath: @path',
  'i18n_article_快照文件为空': 'Snapshot file is empty\nPath: @path',
  'i18n_article_初始化失败': 'Initialization failed: ',

  'i18n_article_标注记录不存在': 'Annotation record does not exist',
  'i18n_article_颜色已更新': 'Color updated',
  'i18n_article_颜色更新失败': 'Color update failed',
  'i18n_article_原文引用': 'Original text quote',
  'i18n_article_查看笔记': 'View note',
  'i18n_article_该标注没有笔记内容': 'This annotation has no note content',
  'i18n_article_查看笔记失败': 'Failed to view note',
  'i18n_article_笔记详情': 'Note details',
  'i18n_article_标注颜色': 'Annotation color',

  /// v1.3.0
  'i18n_article_阅读主题': 'Reading Theme',
  
  // read_theme_widget
  'i18n_article_阅读设置': 'Reading Settings',
  'i18n_article_字体大小': 'Font Size',
  'i18n_article_减小': 'Decrease',
  'i18n_article_增大': 'Increase',
  'i18n_article_预览效果': 'Preview Effect',
  'i18n_article_重置为默认大小': 'Reset to Default Size',
  'i18n_article_字体大小已重置': 'Font size has been reset',
};