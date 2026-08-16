import 'package:flutter/material.dart';

final class TabbarChoiceChip extends ChoiceChip {
  const TabbarChoiceChip({
    super.key,
    required super.label,
    required super.selected,
    super.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      child: ChoiceChip(
        avatar: avatar,
        label: label,
        selected: selected,
        labelPadding: labelPadding,
        labelStyle: labelStyle,
        onSelected: onSelected,
        pressElevation: pressElevation,
        selectedColor: selectedColor,
        disabledColor: disabledColor,
        tooltip: tooltip,
        side: side,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        color: color,
        backgroundColor: backgroundColor,
        padding: padding,
        visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: elevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        iconTheme: iconTheme,
        selectedShadowColor: selectedShadowColor,
        showCheckmark: showCheckmark,
        checkmarkColor: checkmarkColor,
        avatarBorder: avatarBorder,
        avatarBoxConstraints: avatarBoxConstraints,
        chipAnimationStyle: chipAnimationStyle,
      ),
    );
  }
}
