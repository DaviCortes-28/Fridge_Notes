# FridgeNotes 🧊

Geladeira digital compartilhada — projeto acadêmico em Flutter + Firebase
(Curso Técnico em Informática, Programação para Dispositivos Móveis).

Este pacote já contém **todas as 14 prioridades** do documento do
projeto implementadas em código. O que falta é só o que só você pode
fazer: criar o projeto real no Firebase Console e testar no seu
computador (este ambiente onde o código foi gerado não tem Flutter/Dart
instalado nem acesso à internet, então nada aqui foi rodado de verdade).

Leia este README do início ao fim antes de rodar — a ordem importa.

---

## 1. Colocando o projeto para rodar

```bash
flutter --version   # confirme que o Flutter está instalado
flutter create fridge_notes
cd fridge_notes
```

Agora substitua, dentro do projeto que o `flutter create` gerou:
- a pasta `lib/` inteira pela `lib/` deste pacote;
- o `pubspec.yaml` pelo deste pacote (ou copie a seção `dependencies`
  para dentro do seu, se preferir manter outras coisas que o
  `flutter create` já configurou);
- copie também `firestore.rules` e `firestore.indexes.json` para a
  raiz do seu projeto (vamos usá-los no passo 3).

```bash
flutter pub get
```

**Não rode `flutter run` ainda** — o app vai travar na inicialização,
porque `lib/firebase_options.dart` está com credenciais vazias de
propósito (eu nunca invento API keys). Siga o passo 2 primeiro.

---

## 2. Configurando o Firebase (Prioridade 2)

### 2.1 Criar o projeto no Firebase Console
1. Acesse https://console.firebase.google.com
2. "Adicionar projeto" → dê um nome (ex: `fridgenotes`) → siga o assistente.

### 2.2 Ativar o Authentication
1. No menu lateral: **Build → Authentication → Get started**.
2. Na aba "Sign-in method", ative o provedor **E-mail/senha**.

### 2.3 Criar o Firestore Database
1. No menu lateral: **Build → Firestore Database → Create database**.
2. Escolha o modo de produção (as regras de segurança já estão prontas
   no arquivo `firestore.rules`) e a região mais próxima de você.

### 2.4 Conectar o app Flutter ao projeto Firebase
Na raiz do seu projeto Flutter, com o Firebase CLI instalado
(`npm install -g firebase-tools` se ainda não tiver):

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

O comando vai perguntar qual projeto Firebase usar (o que você criou
no passo 2.1) e para quais plataformas gerar configuração (Android/iOS/Web
— escolha o que for testar). Ele **substitui automaticamente** o
arquivo `lib/firebase_options.dart` pelas credenciais reais do seu
projeto. Depois disso o app já pode ser executado.

### 2.5 Publicar as regras de segurança e os índices
```bash
firebase init firestore   # aponte para o mesmo projeto; pode manter os nomes de arquivo padrão
firebase deploy --only firestore:rules,firestore:indexes
```
Isso publica o conteúdo de `firestore.rules` e `firestore.indexes.json`
deste pacote. Sem isso, o Firestore fica com as regras padrão (que
normalmente bloqueiam tudo), e algumas consultas com filtro vão
falhar pedindo um índice — se isso acontecer, o próprio erro no
console do Flutter traz um link para criar o índice em 1 clique como
alternativa.

Agora sim:
```bash
flutter run
```

---

## 3. O que foi implementado, prioridade por prioridade

**Prioridade 1 — Estrutura**: pastas `models/`, `screens/`, `services/`,
`widgets/`, `theme/`, conforme o documento.

**Prioridade 2 — Firebase**: `Firebase.initializeApp` no `main.dart`,
usando `firebase_options.dart` (gerado por você no passo 2.4).

**Prioridade 3 — Autenticação**: `AuthService` (login, cadastro, logout,
mensagens de erro amigáveis). `AuthGate` decide sozinho entre tela de
Login e Home com base no estado de autenticação (persistência de sessão
automática — é assim que o Firebase Authentication funciona por padrão).
Ao cadastrar, cria `users/{userId}` no Firestore.

**Prioridade 4 — Firestore**: estrutura `fridges/{fridgeId}/postIts/{postItId}/comments/{commentId}`
— uma coleção com subcoleção dentro de subcoleção (mais do que o mínimo pedido).

**Prioridade 5 — Geladeiras compartilhadas**: `CreateFridgeScreen`,
`JoinFridgeScreen`. Código de convite de 6 caracteres gerado
aleatoriamente. Lista de membros disponível pelo ícone de grupo na
`FridgeScreen`.

**Prioridade 6 — CRUD de post-its**: criar (`CreatePostItScreen`), ler
(mural em `FridgeScreen`), editar e excluir (`EditPostItScreen`,
restrito ao autor/dono), concluir/reabrir.

**Prioridade 7 — Interação multiusuário**: comentários em tempo real
(`StreamBuilder` + Firestore `snapshots()`) dentro de `EditPostItScreen`.

**Prioridade 8 — Consultas e filtros**: `FirestoreService.watchPendingPostIts`
(`where('completed', isEqualTo: false)`) e `watchMyPostIts`
(`where('authorId', isEqualTo: uid)`) — consultas reais ao Firestore,
selecionáveis pelos chips no topo da `FridgeScreen`.

**Prioridade 9 — Shared Preferences**: `PreferencesService` centraliza
última geladeira aberta, tema, som ligado/desligado e primeira execução.

**Prioridade 10 — Interface gráfica**: post-its coloridos e levemente
rotacionados (parecendo colados de verdade), ímã decorativo, empty
states, loading indicators, confirmação antes de excluir.

**Prioridade 11 — Customização**: 4 temas de geladeira (Clássica, Retrô,
Gamer, Minimalista) em `FridgeSettingsScreen` (só o dono edita); cor,
categoria e ícone do ímã por post-it.

**Prioridade 12 — SFX**: `SoundService`, com liga/desliga salvo via
Shared Preferences. **Os arquivos de áudio não estão incluídos** — veja
`assets/sounds/README.txt`. Sem eles, o app funciona normalmente e
simplesmente não toca som nenhum (nada quebra).

**Prioridade 13 — Animações**: post-its "aparecendo" com escala+fade
(`AnimatedPopIn`), fade de abertura ao entrar numa geladeira.

**Prioridade 14 — Extras**: post-it "atrasado" é destacado visualmente
(ícone/cor de status muda quando passa da data), filtro rápido "Meus
post-its", código de convite com botão de copiar.

---

## 4. Roteiro de apresentação individual (item 21 do documento)

Ordem sugerida para demonstrar tudo:
1. Cadastro → 2. Logout → 3. Login → 4. Criar geladeira (mostrar o
código gerado) → 5. Logout → 6. Criar 2º usuário e fazer login → 7.
Entrar na geladeira com o código → 8. Criar um post-it → 9. Trocar de
usuário (login com o 1º) e ver o post-it do outro → 10. Comentar → 11.
Trocar de volta e ver o comentário aparecer → 12. Filtro "Pendentes" →
13. Filtro "Meus post-its" → 14. Personalizar tema da geladeira → 15.
Fechar e reabrir o app (mostrar que a sessão e as preferências
persistiram).

## 5. Checklist de aceitação (item 22)

Praticamente tudo já está implementado em código; os itens abaixo só
ficam realmente "prontos" depois que você configurar o Firebase (passo 2):

- [x] Estrutura Flutter
- [ ] Firebase conectado — depende do passo 2.4 (`flutterfire configure`)
- [x] Authentication, cadastro, login, logout (código pronto)
- [x] Shared Preferences (última geladeira, tema, som, 1ª execução)
- [x] Firestore: 1+ coleção, 1+ subcoleção (na verdade 2 níveis de subcoleção)
- [x] Criar/entrar em geladeira, sistema de membros
- [x] CRUD completo de post-it + concluir
- [x] Comentários / interação real entre usuários
- [x] 2+ consultas/filtros reais no Firestore
- [x] Interface com loading/empty states/confirmação de exclusão
- [x] Customização (tema da geladeira, cor/categoria/ímã do post-it)
- [x] SFX (opcional, precisa dos arquivos de áudio — ver seção 3)
- [ ] Regras de segurança publicadas — depende do passo 2.5

## 6. Limitações conhecidas / decisões simples de propósito

- Excluir um post-it não apaga automaticamente a subcoleção de
  comentários dele (o Firestore não faz isso sozinho; resolver isso
  direito exigiria Cloud Functions, fora do escopo do projeto).
- As regras do Firestore permitem que qualquer membro conclua o
  post-it de outra pessoa (faz sentido no conceito do app — "eu
  compro quando chegar em casa" é uma ação de outro usuário sobre o
  item de alguém). Editar título/descrição fica restrito ao autor
  pela interface.
- Sem os arquivos de áudio reais, a Prioridade 12 fica "pronta em
  código" mas muda de silenciosa — isso é intencional (som nunca pode
  quebrar o app).
