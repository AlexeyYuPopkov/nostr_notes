import 'package:flutter/material.dart';

/// [T] - must be hashable to store in Map as key, and comparable to find the best match for current scroll offset.
final class SectionScrollVm<T> {
  final double appBarHeight;
  final ScrollController scrollController;
  final ValueNotifier<T?> currentItemNotifier = ValueNotifier(null);

  final _contentOffsets = <T, double>{};
  ScrollController? _innerController;

  SectionScrollVm({
    required this.scrollController,
    this.appBarHeight = kToolbarHeight,
  }) {
    scrollController.addListener(_onScroll);
  }

  /// Добавляет дополнительный контроллер скролла (например, inner controller
  /// от [NestedScrollView]), чтобы учитывать суммарный scroll offset.
  void setInnerScrollController(ScrollController controller) {
    _innerController?.removeListener(_onScroll);
    _innerController = controller;
    controller.addListener(_onScroll);
  }

  double get _totalScrollOffset {
    final innerOffset = _innerController != null
        ? _safeOffset(_innerController!)
        : 0.0;
    return _safeOffset(scrollController) + innerOffset;
  }

  double _safeOffset(ScrollController c) =>
      c.positions.length == 1 ? c.offset : 0.0;

  /// Записывает позицию секции в координатах контента скролла.
  /// Вызывается через postFrameCallback при каждом rebuild секции.
  void registerSection(T item, BuildContext ctx) {
    if (!ctx.mounted) return;
    final renderObj = ctx.findRenderObject();
    if (renderObj is! RenderBox || !renderObj.attached) return;
    final globalY = renderObj.localToGlobal(Offset.zero).dy;
    _contentOffsets[item] = globalY - appBarHeight + _totalScrollOffset;
  }

  void _onScroll() {
    final totalOffset = _totalScrollOffset;
    T? best;
    double? bestOffset;
    for (final entry in _contentOffsets.entries) {
      // Секция выше appBar когда её contentOffset < суммарного scrollOffset
      if (entry.value < totalOffset) {
        if (bestOffset == null || entry.value > bestOffset) {
          bestOffset = entry.value;
          best = entry.key;
        }
      }
    }

    if (currentItemNotifier.value != best) {
      currentItemNotifier.value = best;
    }
  }

  void clearSections() {
    _contentOffsets.clear();
    currentItemNotifier.value = null;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
    _innerController?.removeListener(_onScroll);
    _innerController = null;
    currentItemNotifier.dispose();
  }
}
