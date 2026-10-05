import 'package:flutter/material.dart';

import '../../models/fridge_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/animated_pop_in.dart';
import '../../widgets/fridge_widget.dart';
import '../fridge/create_fridge_screen.dart';
import '../fridge/fridge_screen.dart';
import '../fridge/join_fridge_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final uid = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Geladeiras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<FridgeModel>>(
        stream: firestoreService.watchUserFridges(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar geladeiras: ${snapshot.error}'));
          }

          final fridges = snapshot.data ?? [];

          if (fridges.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '🧊 Você ainda não participa de nenhuma geladeira.\n'
                  'Crie uma nova ou entre com um código de convite.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: fridges.length,
            itemBuilder: (context, index) {
              final fridge = fridges[index];
              return AnimatedPopIn(
                child: FridgeWidget(
                  fridge: fridge,
                  isOwner: fridge.ownerId == uid,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FridgeScreen(fridgeId: fridge.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const JoinFridgeScreen()),
              );
            },
            label: const Text('Entrar com código'),
            icon: const Icon(Icons.qr_code),
            backgroundColor: Colors.blueGrey,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateFridgeScreen()),
              );
            },
            label: const Text('Nova geladeira'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
