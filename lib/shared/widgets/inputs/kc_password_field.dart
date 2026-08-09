import 'package:flutter/material.dart';
import 'kc_text_field.dart';

class KcPasswordField extends StatefulWidget {
  const KcPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.validator,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  State<KcPasswordField> createState() => _KcPasswordFieldState();
}

class _KcPasswordFieldState extends State<KcPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return KcTextField(
      controller: widget.controller,
      label: widget.label,
      obscureText: _obscure,
      validator: widget.validator,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
