import 'package:shared_preferences/shared_preferences.dart';

/// Centraliza todo o uso de Shared Preferences do app (PRIORIDADE 9).
///
/// Importante: aqui só guardamos preferências individuais do
/// dispositivo/usuário local (tema, som, última geladeira aberta,
/// primeira execução). Dados compartilhados entre usuários (post-its,
/// comentários, geladeiras) continuam sempre no Firestore.
class PreferencesService {
  static const _keyLastFridgeId = 'last_fridge_id';
  static const _keyTheme = 'app_theme';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyFirstRun = 'first_run_done';

  Future<void> saveLastFridge(String fridgeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastFridgeId, fridgeId);
  }

  Future<String?> getLastFridge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastFridgeId);
  }

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme);
  }

  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme);
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  /// Sons ligados por padrão, até o usuário desligar manualmente.
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  /// Retorna `true` na primeira vez que o app roda no dispositivo, e já
  /// marca como "não é mais a primeira vez" para as próximas chamadas.
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = !(prefs.getBool(_keyFirstRun) ?? false);
    if (isFirst) {
      await prefs.setBool(_keyFirstRun, true);
    }
    return isFirst;
  }
}
