import 'package:audioplayers/audioplayers.dart';

import 'preferences_service.dart';

/// Efeitos sonoros opcionais (PRIORIDADE 12).
///
/// Regras importantes do projeto:
/// - Os sons NUNCA podem impedir o app de funcionar.
/// - A preferência de som (ligado/desligado) é salva com Shared Preferences.
///
/// Por isso todo `play*` aqui é protegido por try/catch: se o arquivo de
/// áudio ainda não foi adicionado em assets/sounds/ (veja o README), o
/// app simplesmente não toca nada, sem travar nem mostrar erro ao usuário.
class SoundService {
  SoundService._internal();
  static final SoundService instance = SoundService._internal();
  factory SoundService() => instance;

  final AudioPlayer _player = AudioPlayer();
  final PreferencesService _prefs = PreferencesService();

  Future<void> _play(String fileName) async {
    try {
      final enabled = await _prefs.getSoundEnabled();
      if (!enabled) return;
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Silenciosamente ignorado: som é opcional (ver docstring acima).
    }
  }

  Future<void> playDoorOpen() => _play('door_open.mp3');
  Future<void> playDoorClose() => _play('door_close.mp3');
  Future<void> playPaper() => _play('paper.mp3');
  Future<void> playMagnet() => _play('magnet.mp3');
  Future<void> playConfirm() => _play('confirm.mp3');
  Future<void> playNotification() => _play('notification.mp3');
}
