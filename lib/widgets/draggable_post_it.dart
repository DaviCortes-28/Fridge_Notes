import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../models/post_it_model.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import 'post_it_widget.dart';

/// Post-it posicionado livremente no mural, que pode ser arrastado pra
/// qualquer lugar (PRIORIDADE 14 — extra). A posição é salva como fração
/// (0.0–1.0) da área do mural, para continuar fazendo sentido em
/// qualquer tamanho de tela.
///
/// Importante: usa uma `ValueKey(postIt.id)` no mural (ver FridgeScreen)
/// para o Flutter manter o estado de arraste de cada card entre as
/// atualizações em tempo real vindas do Firestore.
class DraggablePostIt extends StatefulWidget {
  final PostItModel postIt;
  final Size canvasSize;
  final String fridgeId;
  final VoidCallback onTap;
  final double size;

  const DraggablePostIt({
    super.key,
    required this.postIt,
    required this.canvasSize,
    required this.fridgeId,
    required this.onTap,
    this.size = 110,
  });

  @override
  State<DraggablePostIt> createState() => _DraggablePostItState();
}

class _DraggablePostItState extends State<DraggablePostIt>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _soundService = SoundService();

  late final AnimationController _entranceController;

  Offset? _dragPosition; // posição em pixels durante o arraste (null = usa a do servidor)
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Offset get _serverPosition => Offset(
        widget.postIt.posX * widget.canvasSize.width,
        widget.postIt.posY * widget.canvasSize.height,
      );

  double get _maxX =>
      (widget.canvasSize.width - widget.size).clamp(0, double.infinity).toDouble();
  double get _maxY =>
      (widget.canvasSize.height - widget.size).clamp(0, double.infinity).toDouble();

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragging = true;
      _dragPosition = _serverPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final current = _dragPosition ?? _serverPosition;
    final next = current + details.delta;
    setState(() {
      _dragPosition = Offset(
        next.dx.clamp(0, _maxX).toDouble(),
        next.dy.clamp(0, _maxY).toDouble(),
      );
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    final pos = _dragPosition;
    setState(() => _dragging = false);

    if (pos == null || widget.canvasSize.width <= 0 || widget.canvasSize.height <= 0) {
      return;
    }

    final fracX = (pos.dx / widget.canvasSize.width).clamp(0.0, 1.0).toDouble();
    final fracY = (pos.dy / widget.canvasSize.height).clamp(0.0, 1.0).toDouble();

    unawaited(_soundService.playMagnet());
    try {
      await _firestoreService.updatePostItPosition(
        fridgeId: widget.fridgeId,
        postItId: widget.postIt.id,
        posX: fracX,
        posY: fracY,
      );
    } catch (_) {
      // Se falhar (ex: sem internet por um instante), o próximo snapshot
      // do Firestore simplesmente devolve o post-it pra posição salva
      // anteriormente — não precisa travar a UI por causa disso.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = _dragPosition ?? _serverPosition;

    return AnimatedPositioned(
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      left: pos.dx,
      top: pos.dy,
      width: widget.size,
      height: widget.size,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
        child: AnimatedScale(
          scale: _dragging ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: PostItWidget(postIt: widget.postIt, size: widget.size),
            ),
          ),
        ),
      ),
    );
  }
}
