import 'package:flutter/material.dart';

enum PinKeyboardType {
  text,
  number,
  phone;

  TextInputType toTextInputType() {
    return switch (this) {
      PinKeyboardType.text => TextInputType.text,
      PinKeyboardType.number => TextInputType.number,
      PinKeyboardType.phone => TextInputType.phone,
    };
  }

  static PinKeyboardType fromName(String? name) {
    if (name == null) return PinKeyboardType.text;
    return PinKeyboardType.values.asNameMap()[name] ?? PinKeyboardType.text;
  }
}
