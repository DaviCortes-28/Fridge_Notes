import 'package:flutter/material.dart';

/// Efeito de "porta de geladeira abrindo", usado como transição de entrada
/// da [FridgeScreen]. A porta gira em torno da dobradiça esquerda (efeito
/// 3D simples com Matrix4 + perspectiva) e revela o mural de post-its
/// que fica atrás dela.
class FridgeDoorTransition extends StatefulWidget {
  final Widget child;
  final List<Color> doorGradient;
  final Color handleColor;

  const FridgeDoorTransition({
    super.key,
    required this.child,
    required this.doorGradient,
    required this.handleColor,
  });

  @override
  State<FridgeDoorTransition> createState() => _FridgeDoorTransitionState();
}

class _FridgeDoorTransitionState extends State<FridgeDoorTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    // Pequena pausa "porta fechada" antes de começar a abrir — dá tempo
    // do usuário registrar que chegou numa geladeira antes dela abrir.
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            if (_progress.value >= 0.999) return const SizedBox.shrink();
            final angle = _progress.value * -1.35; // ~-77 graus, abre bastante
            final opacity = 1 - (_progress.value * 0.4); // some escurecendo um pouco
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0).toDouble(),
              child: Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0016)
                  ..rotateY(angle),
                child: _DoorFace(gradient: widget.doorGradient, handleColor: widget.handleColor),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DoorFace extends StatelessWidget {
  final List<Color> gradient;
  final Color handleColor;

  const _DoorFace({required this.gradient, required this.handleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(6, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Linha sutil sugerindo a borda/dobradiça da porta.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 6, color: Colors.black.withOpacity(0.15)),
          ),
          Center(
            child: Icon(Icons.kitchen, size: 64, color: Colors.white.withOpacity(0.18)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 22),
              width: 12,
              height: 130,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 2))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
