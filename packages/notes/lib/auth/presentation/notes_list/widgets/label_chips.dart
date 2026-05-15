import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';

final class LabelChips extends StatelessWidget {
  final Note note;
  final DateTime updatedAt;
  const LabelChips({super.key, required this.note, required this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final labelTypes = note.labels
        .whereType<Label>()
        .where((e) => e.type != CategoryType.other)
        .toList();

    if (labelTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Text(
            DateFormatter.formatDateTimeOrEmpty(updatedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurfaceVariant,
              // height: lineHeight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Wrap(
              spacing: Sizes.halfIndent,
              runSpacing: Sizes.tinyIndent,
              alignment: .end,
              children: [
                for (final label in labelTypes)
                  Padding(
                    padding: const EdgeInsets.only(right: Sizes.indent),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.all(
                          Radius.circular(Sizes.radius),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: Sizes.indentVariant,
                          right: Sizes.indent,
                          top: Sizes.tinyIndent,
                          bottom: Sizes.halfIndent,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: TextSizes.tiny,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            children: [
                              TextSpan(
                                text: label.symbol,
                                style: TextStyle(fontSize: TextSizes.tiny),
                              ),
                              TextSpan(text: label.type.name),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        //  Text(

                        //   '${label.symbol} ${label.type.name}',
                        //   style: theme.textTheme.titleMedium?.copyWith(
                        //     color: theme.colorScheme.onSecondaryContainer,
                        //   ),
                        // ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
