import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class RefreshButtonVm extends ChangeNotifier {
  final VoidCallback onRefresh;
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  set isRefreshing(bool value) {
    if (_isRefreshing != value) {
      _isRefreshing = value;
      notifyListeners();
    }
  }

  RefreshButtonVm({required this.onRefresh});

  void refresh() {
    if (!_isRefreshing) {
      _isRefreshing = true;
      onRefresh();
      notifyListeners();
    }
  }

  void stopRefreshing() {
    if (_isRefreshing) {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}

final class RefreshButton extends StatelessWidget {
  final RefreshButtonVm vm;
  final EdgeInsets padding;
  final Alignment alignment;

  const RefreshButton({
    super.key,
    required this.vm,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return CupertinoButton(
          minimumSize: Size.zero,
          alignment: alignment,
          padding: padding,
          onPressed: () => vm.refresh(),
          child: vm.isRefreshing
              ? const Center(child: CircularProgressIndicator.adaptive())
              : Icon(Icons.refresh, color: theme.colorScheme.onSurfaceVariant),
        );
      },
    );
  }
}
