import 'package:flutter/cupertino.dart';

final class PrymaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const PrymaryButton({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 100.0),
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}
