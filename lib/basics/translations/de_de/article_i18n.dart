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



const Map<String, String> articleI18n = {
  // article bottom bar
  'i18n_article_文章链接不存在': 'Artikel-Link existiert nicht',
  'i18n_article_无法打开该链接': 'Dieser Link kann nicht geöffnet werden',
  'i18n_article_打开链接失败': 'Fehler beim Öffnen des Links: ',
  'i18n_article_返回': 'Zurück',
  'i18n_article_浏览器打开': 'Im Browser öffnen',
  'i18n_article_更多': 'Mehr',

  // article_loading_view
  'i18n_article_正在加载文章': 'Artikel wird geladen...',

  // more_actions_modal
  'i18n_article_功能待开发': 'Funktion in Entwicklung',
  'i18n_article_链接已复制到剪贴板': 'Link in die Zwischenablage kopiert',
  'i18n_article_复制失败': 'Kopieren fehlgeschlagen: ',
  'i18n_article_文章信息加载中请稍后重试': 'Artikel-Informationen werden geladen, bitte versuchen Sie es später erneut',
  'i18n_article_已标记为重要': 'Als wichtig markiert',
  'i18n_article_已取消重要标记': 'Wichtig-Markierung entfernt',
  'i18n_article_操作失败': 'Operation fehlgeschlagen: ',
  'i18n_article_已归档': 'Archiviert',
  'i18n_article_已取消归档': 'Archivierung aufgehoben',
  'i18n_article_请切换到网页标签页进行操作': 'Bitte wechseln Sie zum "Web"-Tab, um die @actionName-Aktion durchzuführen',
  'i18n_article_确认删除': 'Löschung bestätigen',
  'i18n_article_确定要删除这篇文章吗': 'Sind Sie sicher, dass Sie diesen Artikel löschen möchten?',
  'i18n_article_删除后的文章可以在回收站中找到': 'Gelöschte Artikel können im Papierkorb gefunden werden.',
  'i18n_article_取消': 'Abbrechen',
  'i18n_article_删除': 'Löschen',
  'i18n_article_文章已删除': 'Artikel gelöscht',
  'i18n_article_删除失败': 'Löschung fehlgeschlagen: ',
  'i18n_article_复制链接': 'Link kopieren',
  'i18n_article_刷新解析': 'Analyse aktualisieren',
  'i18n_article_重新生成快照': 'Snapshot neu generieren',
  'i18n_article_AI翻译': 'KI-Übersetzung',
  'i18n_article_标签': 'Tags',
  'i18n_article_移动': 'Verschieben',
  'i18n_article_取消重要': 'Wichtig entfernen',
  'i18n_article_标为重要': 'Als wichtig markieren',
  'i18n_article_取消归档': 'Archivierung aufheben',
  'i18n_article_归档': 'Archivieren',

  // move_to_category_modal
  'i18n_article_加载分类失败': 'Laden der Kategorien fehlgeschlagen: ',
  'i18n_article_未分类': 'Unkategorisiert',
  'i18n_article_成功移动到': 'Erfolgreich verschoben nach ',
  'i18n_article_未找到文章': 'Artikel nicht gefunden',
  'i18n_article_移动失败': 'Verschieben fehlgeschlagen: ',
  'i18n_article_设为未分类': 'Als unkategorisiert festlegen',
  'i18n_article_移动到分组': 'In Gruppe verschieben',

  // tag_edit_modal
  'i18n_article_暂无标签': 'Keine Tags',
  'i18n_article_编辑标签': 'Tags bearbeiten',
  'i18n_article_完成': 'Fertig',
  'i18n_article_搜索或创建标签': 'Tag suchen oder erstellen',
  'i18n_article_创建': 'Erstellen',

  // translate_modal
  'i18n_article_AI翻译不足': 'KI-Übersetzungskontingent unzureichend',
  'i18n_article_AI翻译额度已用完提示': 'Das System bietet neuen Benutzern 3 kostenlose KI-Übersetzungen. Ihr KI-Übersetzungskontingent ist aufgebraucht. Laden Sie auf, um weiterhin hochwertige Übersetzungsdienste zu nutzen.',
  'i18n_article_以后再说': 'Später',
  'i18n_article_前往充值': 'Aufladen',
  'i18n_article_选择要翻译的目标语言': 'Zielsprache für Übersetzung auswählen',
  'i18n_article_已可用': 'Verfügbar',
  'i18n_article_翻译完成': 'Übersetzung abgeschlossen',
  'i18n_article_正在翻译中': 'Geschätzte Zeit 20s bis 2min, Übersetzung läuft...',
  'i18n_article_翻译失败': 'Übersetzung fehlgeschlagen',
  'i18n_article_待翻译': 'Wartet auf Übersetzung',
  'i18n_article_查看': 'Anzeigen',
  'i18n_article_翻译': 'Übersetzen',
  'i18n_article_重新翻译': 'Neu übersetzen',
  'i18n_article_重试': 'Erneut versuchen',
  'i18n_article_原文': 'Originaltext',
  'i18n_article_英语': 'Englisch',
  'i18n_article_日语': 'Japanisch',
  'i18n_article_韩语': 'Koreanisch',
  'i18n_article_法语': 'Französisch',
  'i18n_article_德语': 'Deutsch',
  'i18n_article_西班牙语': 'Spanisch',
  'i18n_article_俄语': 'Russisch',
  'i18n_article_阿拉伯语': 'Arabisch',
  'i18n_article_葡萄牙语': 'Portugiesisch',
  'i18n_article_意大利语': 'Italienisch',
  'i18n_article_荷兰语': 'Niederländisch',
  'i18n_article_泰语': 'Thailändisch',
  'i18n_article_越南语': 'Vietnamesisch',
  'i18n_article_简体中文': 'Vereinfachtes Chinesisch',
  'i18n_article_繁体中文': 'Traditionelles Chinesisch',

  // article_page
  'i18n_article_快照更新成功': 'Snapshot erfolgreich aktualisiert',
  'i18n_article_快照更新失败': 'Snapshot-Aktualisierung fehlgeschlagen: ',
  'i18n_article_图文更新成功': 'Markdown erfolgreich aktualisiert',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown wird generiert, bitte später überprüfen',
  'i18n_article_Markdown获取失败': 'Markdown-Abruf fehlgeschlagen: ',
  'i18n_article_Markdown更新失败': 'Markdown-Aktualisierung fehlgeschlagen: ',
  'i18n_article_加载失败': 'Laden fehlgeschlagen',
  'i18n_article_图文': 'Text',
  'i18n_article_网页': 'Web',
  'i18n_article_快照': 'Snapshot',
  'i18n_article_未知页面类型': 'Unbekannter Seitentyp',
  'i18n_article_内容加载中': 'Inhalt wird geladen...',
  'i18n_article_快照已保存路径': 'Snapshot gespeichert, Pfad: ',
  'i18n_article_网页未加载完成请稍后再试': 'Webseite nicht vollständig geladen, bitte versuchen Sie es später erneut',
  'i18n_article_请切换到网页标签页生成快照': 'Bitte wechseln Sie zum Webseiten-Tab, um einen Snapshot zu generieren',

  // article_web_widget
  'i18n_article_网页加载失败': 'Webseiten-Laden fehlgeschlagen',
  'i18n_article_重新加载': 'Neu laden',
  'i18n_article_保存快照失败': 'Snapshot-Speicherung fehlgeschlagen',
  'i18n_article_保存快照到数据库失败': 'Snapshot-Speicherung in Datenbank fehlgeschlagen',
  'i18n_article_重新加载失败提示': 'Neu laden fehlgeschlagen\\n\\nBitte versuchen Sie es später erneut oder starten Sie die App neu.\\n\\nFehlerdetails: ',
  'i18n_article_重新加载时发生错误提示': 'Fehler beim Neu laden\\n\\nBitte starten Sie die App neu und versuchen Sie es erneut.\\n\\nFehlerdetails: ',
  'i18n_article_网站访问被限制提示': 'Website-Zugriff eingeschränkt (403)\\n\\nDiese Website hat ungewöhnliche Zugriffsmuster erkannt.\\n\\nVorschläge:\\n• Später erneut versuchen\\n• Direkt mit Browser zugreifen\\n• Netzwerkumgebung überprüfen',
  'i18n_article_重试失败提示': 'Erneuter Versuch fehlgeschlagen\\n\\nBitte versuchen Sie es später manuell erneut oder verwenden Sie einen Browser zum Zugriff.',

  // article_markdown_widget
  'i18n_article_无法创建高亮文章信息缺失': 'Hervorhebung kann nicht erstellt werden: Artikel-Informationen fehlen',
  'i18n_article_高亮已添加': 'Hervorhebung hinzugefügt',
  'i18n_article_高亮添加失败': 'Hervorhebung hinzufügen fehlgeschlagen',
  'i18n_article_无法创建笔记文章信息缺失': 'Notiz kann nicht erstellt werden: Artikel-Informationen fehlen',
  'i18n_article_笔记已添加': 'Notiz hinzugefügt',
  'i18n_article_笔记添加失败': 'Notiz hinzufügen fehlgeschlagen',
  'i18n_article_无法复制内容为空': 'Kopieren nicht möglich: Inhalt ist leer',
  'i18n_article_已复制': 'Kopiert: ',
  'i18n_article_复制失败请重试': 'Kopieren fehlgeschlagen, bitte erneut versuchen',
  'i18n_article_正在删除标注': 'Annotation wird gelöscht...',
  'i18n_article_删除失败无法从页面中移除标注': 'Löschung fehlgeschlagen: Annotation kann nicht von der Seite entfernt werden',
  'i18n_article_标注已删除': 'Annotation gelöscht',
  'i18n_article_删除异常建议刷新页面': 'Löschfehler, Seite aktualisieren empfohlen',

  // article_markdown/components
  'i18n_article_选中文字': 'Ausgewählter Text',
  'i18n_article_笔记内容': 'Notizinhalt',
  'i18n_article_记录你的想法感悟或灵感': 'Notieren Sie Ihre Gedanken, Erkenntnisse oder Inspirationen...',
  'i18n_article_内容超出字符限制提示': 'Inhalt überschreitet die @maxCharacters-Zeichen-Grenze, bitte kürzen',
  'i18n_article_添加笔记': 'Notiz hinzufügen',
  'i18n_article_删除标注': 'Annotation löschen',
  'i18n_article_此操作无法撤销': 'Diese Aktion kann nicht rückgängig gemacht werden',
  'i18n_article_确定要删除以下标注吗': 'Sind Sie sicher, dass Sie die folgende Annotation löschen möchten?',
  'i18n_article_标注内容': 'Annotationsinhalt',
  'i18n_article_复制': 'Kopieren',
  'i18n_article_高亮': 'Hervorheben',
  'i18n_article_笔记': 'Notiz',

  // article_controller
  'i18n_article_文章信息获取失败': 'Artikel-Informationen abrufen fehlgeschlagen',
  'i18n_article_您的翻译额度已用完': 'Ihr Übersetzungskontingent ist aufgebraucht',
  'i18n_article_翻译请求失败': 'Übersetzungsanfrage fehlgeschlagen',
  'i18n_article_翻译请求失败请重试': 'Übersetzungsanfrage fehlgeschlagen, bitte erneut versuchen',
  'i18n_article_未知标题': 'Unbekannter Titel',

  // snapshot_utils
  'i18n_article_WebView未初始化': 'WebView nicht initialisiert',
  'i18n_article_开始生成快照': 'Snapshot-Generierung beginnt...',
  'i18n_article_快照保存成功': 'Snapshot erfolgreich gespeichert',
  'i18n_article_生成快照失败': 'Snapshot-Generierung fehlgeschlagen: ',

  // article_mhtml_widget
  'i18n_article_快照加载失败': 'Snapshot-Laden fehlgeschlagen',
  'i18n_article_加载错误文件路径': 'Ladefehler: @description\nDateipfad: @path',
  'i18n_article_HTTP错误': 'HTTP-Fehler: @statusCode\n@reasonPhrase',
  'i18n_article_快照文件不存在': 'Snapshot-Datei nicht gefunden\nPfad: @path',
  'i18n_article_快照文件为空': 'Snapshot-Datei ist leer\nPfad: @path',
  'i18n_article_初始化失败': 'Initialisierung fehlgeschlagen: ',

  'i18n_article_标注记录不存在': 'Annotationsdatensatz existiert nicht',
  'i18n_article_颜色已更新': 'Farbe aktualisiert',
  'i18n_article_颜色更新失败': 'Farbaktualisierung fehlgeschlagen',
  'i18n_article_原文引用': 'Originaltext-Zitat',
  'i18n_article_查看笔记': 'Notiz anzeigen',
  'i18n_article_该标注没有笔记内容': 'Diese Annotation hat keinen Notizinhalt',
  'i18n_article_查看笔记失败': 'Notiz anzeigen fehlgeschlagen',
  'i18n_article_笔记详情': 'Notizdetails',
  'i18n_article_标注颜色': 'Annotationsfarbe',

  /// v1.3.0
  'i18n_article_阅读主题': 'Lesethema',
  
  // read_theme_widget
  'i18n_article_阅读设置': 'Leseeinstellungen',
  'i18n_article_字体大小': 'Schriftgröße',
  'i18n_article_减小': 'Verkleinern',
  'i18n_article_增大': 'Vergrößern',
  'i18n_article_预览效果': 'Vorschau-Effekt',
  'i18n_article_重置为默认大小': 'Auf Standardgröße zurücksetzen',
  'i18n_article_字体大小已重置': 'Schriftgröße wurde zurückgesetzt',
}; 