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
  // 基础翻译（简化版，包含主要功能）
  'i18n_article_文章链接不存在': 'Link do artigo não existe',
  'i18n_article_无法打开该链接': 'Não é possível abrir este link',
  'i18n_article_打开链接失败': 'Falha ao abrir link: ',
  'i18n_article_返回': 'Voltar',
  'i18n_article_浏览器打开': 'Abrir no navegador',
  'i18n_article_更多': 'Mais',
  'i18n_article_正在加载文章': 'Carregando artigo...',
  'i18n_article_功能待开发': 'Funcionalidade em desenvolvimento',
  'i18n_article_链接已复制到剪贴板': 'Link copiado para a área de transferência',
  'i18n_article_复制失败': 'Falha ao copiar: ',
  'i18n_article_已标记为重要': 'Marcado como importante',
  'i18n_article_已取消重要标记': 'Marca de importante removida',
  'i18n_article_操作失败': 'Operação falhou: ',
  'i18n_article_已归档': 'Arquivado',
  'i18n_article_已取消归档': 'Desarquivado',
  'i18n_article_确认删除': 'Confirmar exclusão',
  'i18n_article_确定要删除这篇文章吗': 'Tem certeza de que deseja excluir este artigo?',
  'i18n_article_取消': 'Cancelar',
  'i18n_article_删除': 'Excluir',
  'i18n_article_文章已删除': 'Artigo excluído',
  'i18n_article_复制链接': 'Copiar link',
  'i18n_article_AI翻译': 'Tradução IA',
  'i18n_article_标签': 'Etiquetas',
  'i18n_article_移动': 'Mover',
  'i18n_article_归档': 'Arquivar',
  'i18n_article_未分类': 'Sem categoria',
  'i18n_article_编辑标签': 'Editar etiquetas',
  'i18n_article_完成': 'Concluído',
  'i18n_article_创建': 'Criar',
  'i18n_article_翻译': 'Traduzir',
  'i18n_article_重试': 'Tentar novamente',
  'i18n_article_原文': 'Texto original',
  'i18n_article_英语': 'Inglês',
  'i18n_article_日语': 'Japonês',
  'i18n_article_韩语': 'Coreano',
  'i18n_article_法语': 'Francês',
  'i18n_article_德语': 'Alemão',
  'i18n_article_西班牙语': 'Espanhol',
  'i18n_article_俄语': 'Russo',
  'i18n_article_阿拉伯语': 'Árabe',
  'i18n_article_葡萄牙语': 'Português',
  'i18n_article_意大利语': 'Italiano',
  'i18n_article_荷兰语': 'Holandês',
  'i18n_article_泰语': 'Tailandês',
  'i18n_article_越南语': 'Vietnamita',
  'i18n_article_简体中文': 'Chinês Simplificado',
  'i18n_article_繁体中文': 'Chinês Tradicional',
  'i18n_article_图文': 'Texto',
  'i18n_article_网页': 'Web',
  'i18n_article_快照': 'Instantâneo',
  'i18n_article_加载失败': 'Falha no carregamento',
  'i18n_article_内容加载中': 'Carregando conteúdo...',
  'i18n_article_重新加载': 'Recarregar',
  'i18n_article_高亮已添加': 'Destaque adicionado',
  'i18n_article_笔记已添加': 'Nota adicionada',
  'i18n_article_已复制': 'Copiado: ',
  'i18n_article_复制': 'Copiar',
  'i18n_article_高亮': 'Destacar',
  'i18n_article_笔记': 'Nota',
  'i18n_article_选中文字': 'Texto selecionado',
  'i18n_article_笔记内容': 'Conteúdo da nota',
  'i18n_article_添加笔记': 'Adicionar nota',
  'i18n_article_删除标注': 'Excluir anotação',
  'i18n_article_此操作无法撤销': 'Esta ação não pode ser desfeita',
  'i18n_article_WebView未初始化': 'WebView não inicializado',
  'i18n_article_快照保存成功': 'Instantâneo salvo com sucesso',
  'i18n_article_快照加载失败': 'Falha no carregamento do instantâneo',
  'i18n_article_初始化失败': 'Falha na inicialização: ',

  'i18n_article_标注记录不存在': 'Registro de anotação não existe',
  'i18n_article_颜色已更新': 'Cor atualizada',
  'i18n_article_颜色更新失败': 'Falha ao atualizar cor',
  'i18n_article_原文引用': 'Citação do texto original',
  'i18n_article_查看笔记': 'Ver nota',
  'i18n_article_该标注没有笔记内容': 'Esta anotação não tem conteúdo de nota',
  'i18n_article_查看笔记失败': 'Falha ao ver nota',
  'i18n_article_笔记详情': 'Detalhes da nota',
  'i18n_article_标注颜色': 'Cor da anotação',

  /// v1.3.0
  'i18n_article_阅读主题': 'Tema de leitura',
  
  // read_theme_widget
  'i18n_article_阅读设置': 'Configurações de leitura',
  'i18n_article_字体大小': 'Tamanho da fonte',
  'i18n_article_减小': 'Diminuir',
  'i18n_article_增大': 'Aumentar',
  'i18n_article_预览效果': 'Efeito de visualização',
  'i18n_article_重置为默认大小': 'Redefinir para tamanho padrão',
  'i18n_article_字体大小已重置': 'Tamanho da fonte foi redefinido',
  
  // AI翻译相关
  'i18n_article_AI翻译不足': 'Créditos de tradução IA insuficientes',
  'i18n_article_AI翻译额度已用完提示': 'Créditos de tradução IA esgotados',
  'i18n_article_您的翻译额度已用完': 'Os seus créditos de tradução esgotaram',
  'i18n_article_前往充值': 'Ir para recarregar',
  'i18n_article_以后再说': 'Mais tarde',
  'i18n_article_翻译失败': 'Tradução falhada',
  'i18n_article_翻译完成': 'Tradução concluída',
  'i18n_article_翻译请求失败': 'Pedido de tradução falhado',
  'i18n_article_翻译请求失败请重试': 'Pedido de tradução falhado, tente novamente',
  'i18n_article_正在翻译中': 'A traduzir',
  'i18n_article_重新翻译': 'Traduzir novamente',
  'i18n_article_选择要翻译的目标语言': 'Selecionar idioma de destino para tradução',
  'i18n_article_待翻译': 'Para traduzir',
  
  // 快照相关
  'i18n_article_开始生成快照': 'Começar a gerar snapshot',
  'i18n_article_生成快照失败': 'Falha na geração de snapshot',
  'i18n_article_快照已保存路径': 'Snapshot guardado no caminho',
  'i18n_article_快照文件不存在': 'Ficheiro de snapshot não existe',
  'i18n_article_快照文件为空': 'Ficheiro de snapshot vazio',
  'i18n_article_快照更新失败': 'Falha na atualização do snapshot',
  'i18n_article_快照更新成功': 'Atualização do snapshot bem-sucedida',
  'i18n_article_保存快照失败': 'Falha ao guardar snapshot',
  'i18n_article_保存快照到数据库失败': 'Falha ao guardar snapshot na base de dados',
  'i18n_article_重新生成快照': 'Regenerar snapshot',
  'i18n_article_请切换到网页标签页生成快照': 'Mude para o separador web para gerar snapshot',
  'i18n_article_请切换到网页标签页进行操作': 'Mude para o separador web para operar',
  
  // Markdown相关
  'i18n_article_Markdown更新失败': 'Falha na atualização do Markdown',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown a ser gerado, verifique mais tarde',
  'i18n_article_Markdown获取失败': 'Falha ao obter Markdown',
  
  // 错误和状态
  'i18n_article_HTTP错误': 'Erro HTTP',
  'i18n_article_网页加载失败': 'Falha no carregamento da página web',
  'i18n_article_网页未加载完成请稍后再试': 'Página web não totalmente carregada, tente mais tarde',
  'i18n_article_网站访问被限制提示': 'Acesso ao website limitado',
  'i18n_article_重新加载失败提示': 'Falha no recarregamento',
  'i18n_article_重新加载时发生错误提示': 'Erro ocorrido durante o recarregamento',
  'i18n_article_重试失败提示': 'Falha na nova tentativa',
  'i18n_article_加载错误文件路径': 'Caminho do ficheiro de erro de carregamento',
  'i18n_article_加载分类失败': 'Falha no carregamento de categorias',
  'i18n_article_刷新解析': 'Atualizar análise',
  
  // 文章操作
  'i18n_article_删除失败': 'Falha na eliminação',
  'i18n_article_删除失败无法从页面中移除标注': 'Falha na eliminação, não é possível remover anotação da página',
  'i18n_article_删除异常建议刷新页面': 'Anomalia na eliminação, recomenda-se atualizar a página',
  'i18n_article_删除后的文章可以在回收站中找到': 'Artigos eliminados podem ser encontrados no lixo',
  'i18n_article_移动到分组': 'Mover para grupo',
  'i18n_article_移动失败': 'Falha na movimentação',
  'i18n_article_成功移动到': 'Movido com sucesso para',
  'i18n_article_取消归档': 'Cancelar arquivo',
  'i18n_article_取消重要': 'Remover importante',
  'i18n_article_标为重要': 'Marcar como importante',
  'i18n_article_设为未分类': 'Definir como não categorizado',
  
  // 标签和内容
  'i18n_article_搜索或创建标签': 'Pesquisar ou criar etiqueta',
  'i18n_article_暂无标签': 'Sem etiquetas',
  'i18n_article_标注内容': 'Conteúdo da anotação',
  'i18n_article_标注已删除': 'Anotação eliminada',
  'i18n_article_正在删除标注': 'A eliminar anotação',
  'i18n_article_确定要删除以下标注吗': 'Tem a certeza de que quer eliminar as seguintes anotações?',
  'i18n_article_高亮添加失败': 'Falha ao adicionar destaque',
  'i18n_article_笔记添加失败': 'Falha ao adicionar nota',
  'i18n_article_记录你的想法感悟或灵感': 'Registe os seus pensamentos, perceções ou inspiração',
  
  // 其他
  'i18n_article_未找到文章': 'Artigo não encontrado',
  'i18n_article_未知标题': 'Título desconhecido',
  'i18n_article_未知页面类型': 'Tipo de página desconhecido',
  'i18n_article_文章信息加载中请稍后重试': 'A carregar informações do artigo, tente mais tarde',
  'i18n_article_文章信息获取失败': 'Falha ao obter informações do artigo',
  'i18n_article_无法创建笔记文章信息缺失': 'Não é possível criar nota, informações do artigo em falta',
  'i18n_article_无法创建高亮文章信息缺失': 'Não é possível criar destaque, informações do artigo em falta',
  'i18n_article_无法复制内容为空': 'Não é possível copiar, conteúdo vazio',
  'i18n_article_复制失败请重试': 'Falha na cópia, tente novamente',
  'i18n_article_图文更新成功': 'Atualização de imagem e texto bem-sucedida',
  'i18n_article_内容超出字符限制提示': 'Conteúdo excede limite de caracteres',
  'i18n_article_已可用': 'Disponível',
  'i18n_article_查看': 'Ver',
}; 