import 'package:flutter/material.dart';

/// Botão padronizado, reutilizável em várias telas do app.
///
/// Diferente dos outros widgets desta pasta, este já é funcional desde
/// a Prioridade 1 — é só um wrapper simples em cima de [ElevatedButton].
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
