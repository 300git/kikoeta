import 'package:flutter/material.dart';

import 'data.dart';
import 'pages/work_page.dart';
import 'services/download_service.dart';

/// 作品详情页路由：缩放 + 淡入的展开动画
Route<void> buildWorkRoute(
  AppState app,
  Work w, {
  VoiceDownload? downloadItem,
}) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) =>
        WorkPage(app: app, work: w, downloadItem: downloadItem),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curved),
          alignment: Alignment.center,
          child: child,
        ),
      );
    },
  );
}
