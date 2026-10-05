import 'package:flutter/material.dart';

/// Tema centralizado do app (Material, usado em todas as telas).
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF4FC3F7);
  static const Color accentColor = Color(0xFFFFF176);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Temas visuais de geladeira disponíveis para customização
/// (PRIORIDADE 11). O identificador (`id`) é o que fica salvo no campo
/// `theme` do documento da geladeira no Firestore.
enum FridgeTheme {
  classic('classic', 'Clássica', Icons.kitchen, Color(0xFFECEFF1), Color(0xFFB0BEC5)),
  retro('retro', 'Retrô', Icons.tv, Color(0xFFFFE0B2), Color(0xFFFFB74D)),
  gamer('gamer', 'Gamer', Icons.sports_esports, Color(0xFF212121), Color(0xFF7C4DFF)),
  minimalist('minimalist', 'Minimalista', Icons.crop_square, Color(0xFFFFFFFF), Color(0xFFE0E0E0));

  final String id;
  final String label;
  final IconData icon;
  final Color background;
  final Color accent;

  const FridgeTheme(this.id, this.label, this.icon, this.background, this.accent);

  static FridgeTheme fromId(String id) {
    return FridgeTheme.values.firstWhere(
      (t) => t.id == id,
      orElse: () => FridgeTheme.classic,
    );
  }
}
