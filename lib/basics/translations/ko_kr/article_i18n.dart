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
  'i18n_article_文章链接不存在': '기사 링크가 존재하지 않습니다',
  'i18n_article_无法打开该链接': '해당 링크를 열 수 없습니다',
  'i18n_article_打开链接失败': '링크 열기 실패: ',
  'i18n_article_返回': '뒤로',
  'i18n_article_浏览器打开': '브라우저에서 열기',
  'i18n_article_更多': '더보기',

  // article_loading_view
  'i18n_article_正在加载文章': '기사 로딩 중...',

  // more_actions_modal
  'i18n_article_功能待开发': '기능 개발 중입니다',
  'i18n_article_链接已复制到剪贴板': '링크가 클립보드에 복사되었습니다',
  'i18n_article_复制失败': '복사 실패: ',
  'i18n_article_文章信息加载中请稍后重试': '기사 정보 로딩 중입니다. 잠시 후 다시 시도해주세요',
  'i18n_article_已标记为重要': '중요로 표시되었습니다',
  'i18n_article_已取消重要标记': '중요 표시가 해제되었습니다',
  'i18n_article_操作失败': '작업 실패: ',
  'i18n_article_已归档': '보관되었습니다',
  'i18n_article_已取消归档': '보관이 해제되었습니다',
  'i18n_article_请切换到网页标签页进行操作': '"웹" 탭으로 전환하여 @actionName 작업을 수행해주세요',
  'i18n_article_确认删除': '삭제 확인',
  'i18n_article_确定要删除这篇文章吗': '이 기사를 삭제하시겠습니까?',
  'i18n_article_删除后的文章可以在回收站中找到': '삭제된 기사는 휴지통에서 찾을 수 있습니다.',
  'i18n_article_取消': '취소',
  'i18n_article_删除': '삭제',
  'i18n_article_文章已删除': '기사가 삭제되었습니다',
  'i18n_article_删除失败': '삭제 실패: ',
  'i18n_article_复制链接': '링크 복사',
  'i18n_article_刷新解析': '파싱 새로고침',
  'i18n_article_重新生成快照': '스냅샷 재생성',
  'i18n_article_AI翻译': 'AI 번역',
  'i18n_article_标签': '태그',
  'i18n_article_移动': '이동',
  'i18n_article_取消重要': '중요 해제',
  'i18n_article_标为重要': '중요로 표시',
  'i18n_article_取消归档': '보관 해제',
  'i18n_article_归档': '보관',

  // move_to_category_modal
  'i18n_article_加载分类失败': '카테고리 로딩 실패: ',
  'i18n_article_未分类': '미분류',
  'i18n_article_成功移动到': '성공적으로 이동했습니다: ',
  'i18n_article_未找到文章': '기사를 찾을 수 없습니다',
  'i18n_article_移动失败': '이동 실패: ',
  'i18n_article_设为未分类': '미분류로 설정',
  'i18n_article_移动到分组': '그룹으로 이동',

  // tag_edit_modal
  'i18n_article_暂无标签': '태그가 없습니다',
  'i18n_article_编辑标签': '태그 편집',
  'i18n_article_完成': '완료',
  'i18n_article_搜索或创建标签': '태그 검색 또는 생성',
  'i18n_article_创建': '생성',

  // translate_modal
  'i18n_article_AI翻译不足': 'AI 번역 할당량 부족',
  'i18n_article_AI翻译额度已用完提示': '시스템에서 신규 사용자에게 3회의 무료 AI 번역을 제공합니다. AI 번역 할당량이 모두 사용되었습니다. 충전 후 고품질 번역 서비스를 계속 이용하실 수 있습니다.',
  'i18n_article_以后再说': '나중에',
  'i18n_article_前往充值': '충전하기',
  'i18n_article_选择要翻译的目标语言': '번역할 대상 언어 선택',
  'i18n_article_已可用': '사용 가능',
  'i18n_article_翻译完成': '번역 완료',
  'i18n_article_正在翻译中': '예상 시간 20초~2분, 번역 중...',
  'i18n_article_翻译失败': '번역 실패',
  'i18n_article_待翻译': '번역 대기',
  'i18n_article_查看': '보기',
  'i18n_article_翻译': '번역',
  'i18n_article_重新翻译': '재번역',
  'i18n_article_重试': '재시도',
  'i18n_article_原文': '원문',
  'i18n_article_英语': '영어',
  'i18n_article_日语': '일본어',
  'i18n_article_韩语': '한국어',
  'i18n_article_法语': '프랑스어',
  'i18n_article_德语': '독일어',
  'i18n_article_西班牙语': '스페인어',
  'i18n_article_俄语': '러시아어',
  'i18n_article_阿拉伯语': '아랍어',
  'i18n_article_葡萄牙语': '포르투갈어',
  'i18n_article_意大利语': '이탈리아어',
  'i18n_article_荷兰语': '네덜란드어',
  'i18n_article_泰语': '태국어',
  'i18n_article_越南语': '베트남어',
  'i18n_article_简体中文': '간체 중국어',
  'i18n_article_繁体中文': '번체 중국어',

  // article_page
  'i18n_article_快照更新成功': '스냅샷 업데이트 성공',
  'i18n_article_快照更新失败': '스냅샷 업데이트 실패: ',
  'i18n_article_图文更新成功': 'Markdown 업데이트 성공',
  'i18n_article_Markdown生成中请稍后查看': 'Markdown 생성 중, 잠시 후 확인해주세요',
  'i18n_article_Markdown获取失败': 'Markdown 가져오기 실패: ',
  'i18n_article_Markdown更新失败': 'Markdown 업데이트 실패: ',
  'i18n_article_加载失败': '로딩 실패',
  'i18n_article_图文': '텍스트',
  'i18n_article_网页': '웹',
  'i18n_article_快照': '스냅샷',
  'i18n_article_未知页面类型': '알 수 없는 페이지 유형',
  'i18n_article_内容加载中': '콘텐츠 로딩 중...',
  'i18n_article_快照已保存路径': '스냅샷이 저장되었습니다, 경로: ',
  'i18n_article_网页未加载完成请稍后再试': '웹페이지 로딩이 완료되지 않았습니다. 잠시 후 다시 시도해주세요',
  'i18n_article_请切换到网页标签页生成快照': '웹페이지 탭으로 전환하여 스냅샷을 생성해주세요',

  // article_web_widget
  'i18n_article_网页加载失败': '웹페이지 로딩 실패',
  'i18n_article_重新加载': '새로고침',
  'i18n_article_保存快照失败': '스냅샷 저장 실패',
  'i18n_article_保存快照到数据库失败': '스냅샷 데이터베이스 저장 실패',
  'i18n_article_重新加载失败提示': '새로고침 실패\\n\\n잠시 후 다시 시도하거나 앱을 재시작해주세요.\\n\\n오류 세부사항: ',
  'i18n_article_重新加载时发生错误提示': '새로고침 중 오류 발생\\n\\n앱을 재시작한 후 다시 시도해주세요.\\n\\n오류 세부사항: ',
  'i18n_article_网站访问被限制提示': '사이트 접근이 제한되었습니다 (403)\\n\\n이 사이트에서 비정상적인 접근 패턴을 감지했습니다.\\n\\n제안사항:\\n• 나중에 재시도\\n• 브라우저로 직접 접근\\n• 네트워크 환경 확인',
  'i18n_article_重试失败提示': '재시도 실패\\n\\n나중에 수동으로 재시도하거나 브라우저로 접근해주세요.',

  // article_markdown_widget
  'i18n_article_无法创建高亮文章信息缺失': '하이라이트를 생성할 수 없습니다: 기사 정보가 누락되었습니다',
  'i18n_article_高亮已添加': '하이라이트가 추가되었습니다',
  'i18n_article_高亮添加失败': '하이라이트 추가 실패',
  'i18n_article_无法创建笔记文章信息缺失': '노트를 생성할 수 없습니다: 기사 정보가 누락되었습니다',
  'i18n_article_笔记已添加': '노트가 추가되었습니다',
  'i18n_article_笔记添加失败': '노트 추가 실패',
  'i18n_article_无法复制内容为空': '복사할 수 없습니다: 내용이 비어있습니다',
  'i18n_article_已复制': '복사되었습니다: ',
  'i18n_article_复制失败请重试': '복사 실패, 다시 시도해주세요',
  'i18n_article_正在删除标注': '주석 삭제 중...',
  'i18n_article_删除失败无法从页面中移除标注': '삭제 실패: 페이지에서 주석을 제거할 수 없습니다',
  'i18n_article_标注已删除': '주석이 삭제되었습니다',
  'i18n_article_删除异常建议刷新页面': '삭제 오류, 페이지를 새로고침하는 것을 권장합니다',

  // article_markdown/components
  'i18n_article_选中文字': '선택된 텍스트',
  'i18n_article_笔记内容': '노트 내용',
  'i18n_article_记录你的想法感悟或灵感': '당신의 생각, 감상, 영감을 기록하세요...',
  'i18n_article_内容超出字符限制提示': '내용이 @maxCharacters자 제한을 초과했습니다. 적절히 줄여주세요',
  'i18n_article_添加笔记': '노트 추가',
  'i18n_article_删除标注': '주석 삭제',
  'i18n_article_此操作无法撤销': '이 작업은 되돌릴 수 없습니다',
  'i18n_article_确定要删除以下标注吗': '다음 주석을 삭제하시겠습니까?',
  'i18n_article_标注内容': '주석 내용',
  'i18n_article_复制': '복사',
  'i18n_article_高亮': '하이라이트',
  'i18n_article_笔记': '노트',

  // article_controller
  'i18n_article_文章信息获取失败': '기사 정보 가져오기 실패',
  'i18n_article_您的翻译额度已用完': '번역 할당량이 모두 사용되었습니다',
  'i18n_article_翻译请求失败': '번역 요청 실패',
  'i18n_article_翻译请求失败请重试': '번역 요청 실패, 다시 시도해주세요',
  'i18n_article_未知标题': '알 수 없는 제목',

  // snapshot_utils
  'i18n_article_WebView未初始化': 'WebView가 초기화되지 않았습니다',
  'i18n_article_开始生成快照': '스냅샷 생성 시작...',
  'i18n_article_快照保存成功': '스냅샷 저장 성공',
  'i18n_article_生成快照失败': '스냅샷 생성 실패: ',

  // article_mhtml_widget
  'i18n_article_快照加载失败': '스냅샷 로딩 실패',
  'i18n_article_加载错误文件路径': '로딩 오류: @description\n파일 경로: @path',
  'i18n_article_HTTP错误': 'HTTP 오류: @statusCode\n@reasonPhrase',
  'i18n_article_快照文件不存在': '스냅샷 파일이 존재하지 않습니다\n경로: @path',
  'i18n_article_快照文件为空': '스냅샷 파일이 비어있습니다\n경로: @path',
  'i18n_article_初始化失败': '초기화 실패: ',

  'i18n_article_标注记录不存在': '주석 기록이 존재하지 않습니다',
  'i18n_article_颜色已更新': '색상이 업데이트되었습니다',
  'i18n_article_颜色更新失败': '색상 업데이트 실패',
  'i18n_article_原文引用': '원문 인용',
  'i18n_article_查看笔记': '노트 보기',
  'i18n_article_该标注没有笔记内容': '이 주석에는 노트 내용이 없습니다',
  'i18n_article_查看笔记失败': '노트 보기 실패',
  'i18n_article_笔记详情': '노트 세부사항',
  'i18n_article_标注颜色': '주석 색상',

  /// v1.3.0
  'i18n_article_阅读主题': '읽기 테마',
  
  // read_theme_widget
  'i18n_article_阅读设置': '읽기 설정',
  'i18n_article_字体大小': '글꼴 크기',
  'i18n_article_减小': '축소',
  'i18n_article_增大': '확대',
  'i18n_article_预览效果': '미리보기 효과',
  'i18n_article_重置为默认大小': '기본 크기로 재설정',
  'i18n_article_字体大小已重置': '글꼴 크기가 재설정되었습니다',
}; 