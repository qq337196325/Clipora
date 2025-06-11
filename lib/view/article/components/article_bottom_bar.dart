import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'more_actions_modal.dart';

class ArticleBottomBar extends StatelessWidget {
  final bool isVisible;
  final double bottomBarHeight;
  final VoidCallback onBack;
  final VoidCallback onGenerateSnapshot;
  final VoidCallback onDownloadSnapshot;
  final VoidCallback onReGenerateSnapshot;
  final int articleId;

  const ArticleBottomBar({
    super.key,
    required this.isVisible,
    required this.bottomBarHeight,
    required this.onBack,
    required this.onGenerateSnapshot,
    required this.onDownloadSnapshot,
    required this.onReGenerateSnapshot,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        offset: isVisible ? Offset.zero : const Offset(0, 1.5),
        child: Container(
          height: bottomBarHeight + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildBottomBarItem(
                  context,
                  icon: Icons.arrow_back_ios_new,
                  tooltip: '返回',
                  onPressed: onBack,
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.camera_alt_outlined,
                  tooltip: '生成快照',
                  onPressed: onGenerateSnapshot,
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.download_outlined,
                  tooltip: '下载快照',
                  onPressed: onDownloadSnapshot,
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.share_outlined,
                  tooltip: '分享',
                  onPressed: () {
                    BotToast.showText(text: '分享功能待开发');
                  },
                ),
                _buildBottomBarItem(
                  context,
                  icon: Icons.more_horiz,
                  tooltip: '更多',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return MoreActionsModal(
                          articleId: articleId,
                          onReGenerateSnapshot: onReGenerateSnapshot,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(BuildContext context, {required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 24.0,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      splashRadius: 24.0,
    );
  }
} 