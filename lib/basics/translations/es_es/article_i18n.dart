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
  'i18n_article_文章链接不存在': 'El enlace del artículo no existe',
  'i18n_article_无法打开该链接': 'No se puede abrir ese enlace',
  'i18n_article_打开链接失败': 'Error al abrir el enlace: ',
  'i18n_article_返回': 'Volver',
  'i18n_article_浏览器打开': 'Abrir en navegador',
  'i18n_article_更多': 'Más',

  // article_loading_view
  'i18n_article_正在加载文章': 'Cargando artículo...',

  // more_actions_modal
  'i18n_article_功能待开发': 'Función en desarrollo',
  'i18n_article_链接已复制到剪贴板': 'Enlace copiado al portapapeles',
  'i18n_article_复制失败': 'Error al copiar: ',
  'i18n_article_文章信息加载中请稍后重试': 'Información del artículo cargando, inténtelo más tarde',
  'i18n_article_已标记为重要': 'Marcado como importante',
  'i18n_article_已取消重要标记': 'Marca de importante eliminada',
  'i18n_article_操作失败': 'Operación fallida: ',
  'i18n_article_已归档': 'Archivado',
  'i18n_article_已取消归档': 'Desarchivado',
  'i18n_article_请切换到网页标签页进行操作': 'Cambie a la pestaña "Web" para realizar la acción @actionName',
  'i18n_article_确认删除': 'Confirmar eliminación',
  'i18n_article_确定要删除这篇文章吗': '¿Está seguro de que desea eliminar este artículo?',
  'i18n_article_删除后的文章可以在回收站中找到': 'Los artículos eliminados se pueden encontrar en la papelera.',
  'i18n_article_取消': 'Cancelar',
  'i18n_article_删除': 'Eliminar',
  'i18n_article_文章已删除': 'Artículo eliminado',
  'i18n_article_删除失败': 'Error al eliminar: ',
  'i18n_article_复制链接': 'Copiar enlace',
  'i18n_article_刷新解析': 'Actualizar análisis',
  'i18n_article_重新生成快照': 'Regenerar instantánea',
  'i18n_article_AI翻译': 'Traducción IA',
  'i18n_article_标签': 'Etiquetas',
  'i18n_article_移动': 'Mover',
  'i18n_article_取消重要': 'Quitar importante',
  'i18n_article_标为重要': 'Marcar como importante',
  'i18n_article_取消归档': 'Desarchivar',
  'i18n_article_归档': 'Archivar',

  // move_to_category_modal
  'i18n_article_加载分类失败': 'Error al cargar categorías: ',
  'i18n_article_未分类': 'Sin categoría',
  'i18n_article_成功移动到': 'Movido exitosamente a ',
  'i18n_article_未找到文章': 'Artículo no encontrado',
  'i18n_article_移动失败': 'Error al mover: ',
  'i18n_article_设为未分类': 'Establecer como sin categoría',
  'i18n_article_移动到分组': 'Mover al grupo',

  // tag_edit_modal
  'i18n_article_暂无标签': 'Sin etiquetas',
  'i18n_article_编辑标签': 'Editar etiquetas',
  'i18n_article_完成': 'Completado',
  'i18n_article_搜索或创建标签': 'Buscar o crear etiqueta',
  'i18n_article_创建': 'Crear',

  // translate_modal
  'i18n_article_AI翻译不足': 'Cuota de traducción IA insuficiente',
  'i18n_article_AI翻译额度已用完提示': 'El sistema ofrece 3 traducciones IA gratuitas a nuevos usuarios. Su cuota de traducción IA se ha agotado. Recargue para continuar usando servicios de traducción de alta calidad.',
  'i18n_article_以后再说': 'Más tarde',
  'i18n_article_前往充值': 'Recargar',
  'i18n_article_选择要翻译的目标语言': 'Seleccionar idioma de destino para traducción',
  'i18n_article_已可用': 'Disponible',
  'i18n_article_翻译完成': 'Traducción completada',
  'i18n_article_正在翻译中': 'Tiempo estimado 20s a 2min, traduciendo...',
  'i18n_article_翻译失败': 'Error en la traducción',
  'i18n_article_待翻译': 'Pendiente de traducción',
  'i18n_article_查看': 'Ver',
  'i18n_article_翻译': 'Traducir',
  'i18n_article_重新翻译': 'Retraducir',
  'i18n_article_重试': 'Reintentar',
  'i18n_article_原文': 'Texto original',
  'i18n_article_英语': 'Inglés',
  'i18n_article_日语': 'Japonés',
  'i18n_article_韩语': 'Coreano',
  'i18n_article_法语': 'Francés',
  'i18n_article_德语': 'Alemán',
  'i18n_article_西班牙语': 'Español',
  'i18n_article_俄语': 'Ruso',
  'i18n_article_阿拉伯语': 'Árabe',
  'i18n_article_葡萄牙语': 'Portugués',
  'i18n_article_意大利语': 'Italiano',
  'i18n_article_荷兰语': 'Holandés',
  'i18n_article_泰语': 'Tailandés',
  'i18n_article_越南语': 'Vietnamita',
  'i18n_article_简体中文': 'Chino simplificado',
  'i18n_article_繁体中文': 'Chino tradicional',

  // article_page
  'i18n_article_快照更新成功': 'Instantánea actualizada exitosamente',
  'i18n_article_快照更新失败': 'Error al actualizar instantánea: ',
  'i18n_article_图文更新成功': 'Markdown actualizado exitosamente',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown generándose, verifique más tarde',
  'i18n_article_Markdown获取失败': 'Error al obtener Markdown: ',
  'i18n_article_Markdown更新失败': 'Error al actualizar Markdown: ',
  'i18n_article_加载失败': 'Error al cargar',
  'i18n_article_图文': 'Texto',
  'i18n_article_网页': 'Web',
  'i18n_article_快照': 'Instantánea',
  'i18n_article_未知页面类型': 'Tipo de página desconocido',
  'i18n_article_内容加载中': 'Cargando contenido...',
  'i18n_article_快照已保存路径': 'Instantánea guardada, ruta: ',
  'i18n_article_网页未加载完成请稍后再试': 'Página web no completamente cargada, inténtelo más tarde',
  'i18n_article_请切换到网页标签页生成快照': 'Cambie a la pestaña de página web para generar instantánea',

  // article_web_widget
  'i18n_article_网页加载失败': 'Error al cargar página web',
  'i18n_article_重新加载': 'Recargar',
  'i18n_article_保存快照失败': 'Error al guardar instantánea',
  'i18n_article_保存快照到数据库失败': 'Error al guardar instantánea en base de datos',
  'i18n_article_重新加载失败提示': 'Error al recargar\\n\\nInténtelo más tarde o reinicie la aplicación.\\n\\nDetalles del error: ',
  'i18n_article_重新加载时发生错误提示': 'Error al recargar\\n\\nReinicie la aplicación e inténtelo de nuevo.\\n\\nDetalles del error: ',
  'i18n_article_网站访问被限制提示': 'Acceso al sitio restringido (403)\\n\\nEste sitio ha detectado patrones de acceso inusuales.\\n\\nSugerencias:\\n• Reintentar más tarde\\n• Acceder directamente con navegador\\n• Verificar entorno de red',
  'i18n_article_重试失败提示': 'Error al reintentar\\n\\nInténtelo manualmente más tarde o use un navegador para acceder.',

  // article_markdown_widget
  'i18n_article_无法创建高亮文章信息缺失': 'No se puede crear resaltado: falta información del artículo',
  'i18n_article_高亮已添加': 'Resaltado añadido',
  'i18n_article_高亮添加失败': 'Error al añadir resaltado',
  'i18n_article_无法创建笔记文章信息缺失': 'No se puede crear nota: falta información del artículo',
  'i18n_article_笔记已添加': 'Nota añadida',
  'i18n_article_笔记添加失败': 'Error al añadir nota',
  'i18n_article_无法复制内容为空': 'No se puede copiar: contenido vacío',
  'i18n_article_已复制': 'Copiado: ',
  'i18n_article_复制失败请重试': 'Error al copiar, inténtelo de nuevo',
  'i18n_article_正在删除标注': 'Eliminando anotación...',
  'i18n_article_删除失败无法从页面中移除标注': 'Error al eliminar: no se puede quitar anotación de la página',
  'i18n_article_标注已删除': 'Anotación eliminada',
  'i18n_article_删除异常建议刷新页面': 'Error de eliminación, se recomienda actualizar la página',

  // article_markdown/components
  'i18n_article_选中文字': 'Texto seleccionado',
  'i18n_article_笔记内容': 'Contenido de la nota',
  'i18n_article_记录你的想法感悟或灵感': 'Registre sus pensamientos, reflexiones o inspiraciones...',
  'i18n_article_内容超出字符限制提示': 'El contenido excede el límite de @maxCharacters caracteres, acórtelo',
  'i18n_article_添加笔记': 'Añadir nota',
  'i18n_article_删除标注': 'Eliminar anotación',
  'i18n_article_此操作无法撤销': 'Esta acción no se puede deshacer',
  'i18n_article_确定要删除以下标注吗': '¿Está seguro de que desea eliminar la siguiente anotación?',
  'i18n_article_标注内容': 'Contenido de la anotación',
  'i18n_article_复制': 'Copiar',
  'i18n_article_高亮': 'Resaltar',
  'i18n_article_笔记': 'Nota',

  // article_controller
  'i18n_article_文章信息获取失败': 'Error al obtener información del artículo',
  'i18n_article_您的翻译额度已用完': 'Su cuota de traducción se ha agotado',
  'i18n_article_翻译请求失败': 'Error en solicitud de traducción',
  'i18n_article_翻译请求失败请重试': 'Error en solicitud de traducción, inténtelo de nuevo',
  'i18n_article_未知标题': 'Título desconocido',

  // snapshot_utils
  'i18n_article_WebView未初始化': 'WebView no inicializado',
  'i18n_article_开始生成快照': 'Iniciando generación de instantánea...',
  'i18n_article_快照保存成功': 'Instantánea guardada exitosamente',
  'i18n_article_生成快照失败': 'Error al generar instantánea: ',

  // article_mhtml_widget
  'i18n_article_快照加载失败': 'Error al cargar instantánea',
  'i18n_article_加载错误文件路径': 'Error de carga: @description\nRuta del archivo: @path',
  'i18n_article_HTTP错误': 'Error HTTP: @statusCode\n@reasonPhrase',
  'i18n_article_快照文件不存在': 'Archivo de instantánea no encontrado\nRuta: @path',
  'i18n_article_快照文件为空': 'Archivo de instantánea vacío\nRuta: @path',
  'i18n_article_初始化失败': 'Error de inicialización: ',

  'i18n_article_标注记录不存在': 'El registro de anotación no existe',
  'i18n_article_颜色已更新': 'Color actualizado',
  'i18n_article_颜色更新失败': 'Error al actualizar color',
  'i18n_article_原文引用': 'Cita del texto original',
  'i18n_article_查看笔记': 'Ver nota',
  'i18n_article_该标注没有笔记内容': 'Esta anotación no tiene contenido de nota',
  'i18n_article_查看笔记失败': 'Error al ver nota',
  'i18n_article_笔记详情': 'Detalles de la nota',
  'i18n_article_标注颜色': 'Color de anotación',

  /// v1.3.0
  'i18n_article_阅读主题': 'Tema de lectura',
  
  // read_theme_widget
  'i18n_article_阅读设置': 'Configuración de lectura',
  'i18n_article_字体大小': 'Tamaño de fuente',
  'i18n_article_减小': 'Disminuir',
  'i18n_article_增大': 'Aumentar',
  'i18n_article_预览效果': 'Efecto de vista previa',
  'i18n_article_重置为默认大小': 'Restablecer al tamaño predeterminado',
  'i18n_article_字体大小已重置': 'El tamaño de fuente se ha restablecido',
}; 