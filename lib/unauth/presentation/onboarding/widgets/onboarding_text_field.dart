import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

final class OnboardingTextFormField extends FormField<String> {
  OnboardingTextFormField({
    super.key,
    required super.initialValue,
    required super.validator,
    required TextEditingController controller,
    required String hint,
  }) : super(
          builder: (FormFieldState<String> state) => OnboardingTextField(
            controller: controller,
            hint: hint,
            errorText: state.errorText,
            validator: validator,
            onChanged: (value) {
              state.didChange(value);
            },
          ),
        );
}

final class OnboardingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
          ),
          textAlign: TextAlign.center,
          onTapOutside: (e) => FocusScope.of(context).unfocus(),
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
