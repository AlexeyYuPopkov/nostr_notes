import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/services.dart';

final class OnboardingTextFormField extends FormField<String> {
  OnboardingTextFormField({
    super.key,
    super.initialValue,
    required super.validator,
    required TextEditingController controller,
    required String hint,
    bool isEnabled = true,
    TextInputType? keyboardType,
    bool obscureText = false,
    ValueChanged<String>? onSubmitted,
    TapRegionCallback? onTapOutside,
    List<TextInputFormatter>? inputFormatters,
  }) : super(
         builder: (FormFieldState<String> state) => OnboardingTextField(
           controller: controller,
           obscureText: obscureText,
           hint: hint,
           errorText: state.errorText,
           keyboardType: keyboardType,
           validator: validator,
           inputFormatters: inputFormatters,
           isEnabled: isEnabled,
           onSubmitted: onSubmitted,
           onChanged: (value) {
             state.didChange(value);
           },
           onTapOutside: onTapOutside,
         ),
       );
}

final class OnboardingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final bool isEnabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TapRegionCallback? onTapOutside;
  final List<TextInputFormatter>? inputFormatters;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.isEnabled,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: isEnabled,
          decoration: InputDecoration(hintText: hint),
          textAlign: TextAlign.center,
          onTapOutside: onTapOutside ?? (e) => FocusScope.of(context).unfocus(),
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
        ),
        Visibility(
          visible: errorText != null && errorText!.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: Sizes.halfIndent),
            child: Text(
              errorText ?? '',
              style: theme.inputDecorationTheme.errorStyle,
            ),
          ),
        ),
      ],
    );
  }
}
