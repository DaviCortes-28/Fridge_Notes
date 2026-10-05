import 'package:flutter/material.dart';

import '../models/fridge_model.dart';
import '../theme/app_theme.dart';

/// Card de uma geladeira na Home — desenhado para parecer uma geladeira em
/// miniatura (corpo arredondado + porta + puxador), não uma linha de lista
/// genérica.
class FridgeWidget extends StatelessWidget {
  final FridgeModel fridge;
  final bool isOwner;
  final VoidCallback onTap;

  const FridgeWidget({
    super.key,
    required this.fridge,
    required this.isOwner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FridgeTheme.fromId(fridge.theme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.accent.withOpacity(0.9), theme.accent],
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(theme.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fridge.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fridge.members.length} membro${fridge.members.length == 1 ? '' : 's'} · ${theme.label}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Dono', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                // Puxador da "porta", só decorativo.
                Container(
                  width: 8,
                  height: 48,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
