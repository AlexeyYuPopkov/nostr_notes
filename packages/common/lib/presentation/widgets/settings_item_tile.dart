import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';

final class SettingsItemTile extends StatelessWidget {
  final Widget title;
  final String subtitle;
  final Widget? trailing;
  final Color? Function(BuildContext)? titleTextColorBuilder;
  final String sectionTitle;
  final ListItemPosition position;
  final VoidCallback? onTap;
  final void Function(BuildContext)? onBuildSectionTitle;

  const SettingsItemTile({
    super.key,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.titleTextColorBuilder,
    this.sectionTitle = '',
    required this.position,
    required this.onTap,
    this.onBuildSectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final insets = switch (position) {
      .first => const EdgeInsets.only(top: Sizes.halfIndent),
      .last => const EdgeInsets.only(bottom: Sizes.halfIndent),
      .single => const EdgeInsets.symmetric(vertical: Sizes.halfIndent),
      .middle => EdgeInsets.zero,
    };

    return RawSettingsItemTile(
      title: CupertinoButton(
        foregroundColor:
            titleTextColorBuilder?.call(context) ?? theme.colorScheme.onSurface,
        padding: const EdgeInsets.all(Sizes.indent2x) + insets,
        minimumSize: .zero,
        onPressed: onTap,
        child: _ButtonContent(
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
      trailing: trailing,
      titleTextColorBuilder: titleTextColorBuilder,
      sectionTitle: sectionTitle,
      position: position,
      onTap: onTap,
      onBuildSectionTitle: onBuildSectionTitle,
    );
  }
}

final class RawSettingsItemTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final Color? Function(BuildContext)? titleTextColorBuilder;
  final String sectionTitle;
  final ListItemPosition position;
  final VoidCallback? onTap;
  final void Function(BuildContext)? onBuildSectionTitle;

  const RawSettingsItemTile({
    super.key,
    required this.title,

    this.trailing,
    this.titleTextColorBuilder,
    this.sectionTitle = '',
    required this.position,
    required this.onTap,
    this.onBuildSectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showSectionTitle = switch (position) {
      .first => true,
      .single => true,
      .middle => false,
      .last => false,
    };

    return Column(
      children: [
        if (showSectionTitle && sectionTitle.isNotEmpty)
          SectionTitle(
            sectionTitle: sectionTitle,
            onChangeDependencies: (ctx) {
              onBuildSectionTitle?.call(ctx);
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: position.getRadius(),
              border: position.getBorder(
                theme.colorScheme.outline,
                thickness: Sizes.thicknessHalf,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                if (position.needsSeparator())
                  Divider(
                    indent: Sizes.indent2x,
                    endIndent: Sizes.indent2x,
                    height: Sizes.thicknessHalf,
                    thickness: Sizes.thicknessHalf,
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ButtonContent extends StatelessWidget {
  final Widget title;
  final String subtitle;
  final Widget? trailing;

  const _ButtonContent({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return subtitle.isEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: title),
              ?trailing,
            ],
          )
        : _ButtonContentWithSubtitle(
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          );
  }
}

final class _ButtonContentWithSubtitle extends StatelessWidget {
  final Widget title;
  final String subtitle;
  final Widget? trailing;

  const _ButtonContentWithSubtitle({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [title, ?trailing],
        ),
        const SizedBox(height: Sizes.halfIndent),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

final class SectionTitle extends StatefulWidget {
  final String sectionTitle;
  final EdgeInsetsGeometry padding;
  final void Function(BuildContext)? onChangeDependencies;
  const SectionTitle({
    super.key,
    required this.sectionTitle,
    this.onChangeDependencies,
    this.padding = const EdgeInsets.all(Sizes.indent2x),
  });

  @override
  State<SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.onChangeDependencies != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          widget.onChangeDependencies?.call(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(widget.sectionTitle, style: theme.textTheme.titleLarge),
      ),
    );
  }
}
