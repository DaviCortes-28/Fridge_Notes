import 'package:flutter/material.dart';

/// Pequeno wrapper de animação (PRIORIDADE 13), usado para dar um efeito
/// simples de "aparecendo" a widgets como post-its e cards — sem exagerar
/// e sem prejudicar o desempenho.
class AnimatedPopIn extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedPopIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1).toDouble(),
          child: Transform.scale(scale: 0.85 + (0.15 * value), child: child),
        );
      },
      child: child,
    );
  }
}
