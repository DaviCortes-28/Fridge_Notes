import 'package:flutter/material.dart';

import '../../models/fridge_model.dart';
import '../../models/post_it_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/preferences_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/draggable_post_it.dart';
import '../../widgets/fridge_door_transition.dart';
import '../post_it/create_post_it_screen.dart';
import '../post_it/edit_post_it_screen.dart';
import 'fridge_settings_screen.dart';

/// Filtros disponíveis no mural (PRIORIDADE 8 — consultas/filtros reais
/// no Firestore, não filtragem local de uma lista já carregada).
enum PostItFilter { all, pending, mine }

class FridgeScreen extends StatefulWidget {
  final String fridgeId;

  const FridgeScreen({super.key, required this.fridgeId});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _preferencesService = PreferencesService();
  final _soundService = SoundService();

  PostItFilter _filter = PostItFilter.all;

  @override
  void initState() {
    super.initState();
    // PRIORIDADE 9: lembra qual foi a última geladeira aberta.
    _preferencesService.saveLastFridge(widget.fridgeId);
    // PRIORIDADE 12: som de "abrir a porta" ao entrar (a animação visual
    // da porta propriamente dita fica por conta de FridgeDoorTransition).
    _soundService.playDoorOpen();
  }

  @override
  void dispose() {
    // PRIORIDADE 12: som de "fechar a porta" ao sair da tela da geladeira.
    _soundService.playDoorClose();
    super.dispose();
  }

  Stream<List<PostItModel>> _postItsStream(String uid) {
    switch (_filter) {
      case PostItFilter.all:
        return _firestoreService.watchAllPostIts(widget.fridgeId);
      case PostItFilter.pending:
        return _firestoreService.watchPendingPostIts(widget.fridgeId);
      case PostItFilter.mine:
        return _firestoreService.watchMyPostIts(widget.fridgeId, uid);
    }
  }

  Future<void> _showMembers(FridgeModel fridge) async {
    final users = await _firestoreService.getUsers(fridge.members);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Membros (${users.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...users.map((u) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(u.name.isEmpty ? u.email : u.name),
                    trailing: u.id == fridge.ownerId
                        ? const Chip(label: Text('Dono'), visualDensity: VisualDensity.compact)
                        : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser!.uid;

    return StreamBuilder<FridgeModel?>(
      stream: _firestoreService.watchFridge(widget.fridgeId),
      builder: (context, fridgeSnapshot) {
          if (!fridgeSnapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final fridge = fridgeSnapshot.data;
          if (fridge == null) {
            return const Scaffold(body: Center(child: Text('Esta geladeira não existe mais.')));
          }

          final theme = FridgeTheme.fromId(fridge.theme);
          final isOwner = fridge.ownerId == uid;

          return Scaffold(
            backgroundColor: theme.background,
            appBar: AppBar(
              title: Text(fridge.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.group),
                  tooltip: 'Membros',
                  onPressed: () => _showMembers(fridge),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Personalizar',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FridgeSettingsScreen(fridge: fridge, isOwner: isOwner),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: FridgeDoorTransition(
              doorGradient: [
                theme.accent,
                Color.lerp(theme.accent, Colors.black, 0.28)!,
              ],
              handleColor: Colors.grey[200]!,
              child: _buildShelfBackground(
                theme,
                child: Column(
                  children: [
                    _buildFilterBar(),
                    Expanded(
                      child: StreamBuilder<List<PostItModel>>(
                        stream: _postItsStream(uid),
                        builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Erro ao carregar post-its: ${snapshot.error}'));
                        }
                        final postIts = snapshot.data ?? [];

                        if (postIts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _filter == PostItFilter.all
                                    ? '🧊 Sua geladeira está vazia.\nAdicione seu primeiro lembrete!'
                                    : '🧊 Nenhum post-it encontrado com esse filtro.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          );
                        }

                        // Mural livre: cada post-it é posicionado pela sua
                        // fração salva (posX/posY) dentro da área
                        // disponível, e pode ser arrastado pra qualquer
                        // lugar (ver DraggablePostIt).
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: postIts.map((postIt) {
                                return DraggablePostIt(
                                  key: ValueKey(postIt.id),
                                  postIt: postIt,
                                  canvasSize: canvasSize,
                                  fridgeId: widget.fridgeId,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditPostItScreen(
                                          fridgeId: widget.fridgeId,
                                          postItId: postIt.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreatePostItScreen(fridgeId: widget.fridgeId),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Post-it'),
            ),
          );
        },
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: _filter == PostItFilter.all,
            onSelected: (_) => setState(() => _filter = PostItFilter.all),
          ),
          ChoiceChip(
            label: const Text('Pendentes'),
            selected: _filter == PostItFilter.pending,
            onSelected: (_) => setState(() => _filter = PostItFilter.pending),
          ),
          ChoiceChip(
            label: const Text('Meus post-its'),
            selected: _filter == PostItFilter.mine,
            onSelected: (_) => setState(() => _filter = PostItFilter.mine),
          ),
        ],
      ),
    );
  }

  /// Fundo com "linhas de prateleira" (PRIORIDADE 10/11) — dá um clima de
  /// interior de geladeira em vez de uma tela branca lisa, usando só
  /// Containers simples (sem precisar de nenhuma imagem/asset externo).
  Widget _buildShelfBackground(FridgeTheme theme, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, theme.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const shelfSpacing = 160.0;
                final shelfCount = (constraints.maxHeight / shelfSpacing).ceil();
                return Column(
                  children: List.generate(shelfCount, (i) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.accent.withOpacity(0.18),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          child,
        ],
      ),
    );
  }
}
