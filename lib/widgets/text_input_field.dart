import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  const TextInputField({
    Key? key,
    required this.controller,
    this.keyboardType,
    this.labelText,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
    );
  }
}
