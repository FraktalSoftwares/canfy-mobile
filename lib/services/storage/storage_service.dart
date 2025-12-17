import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para armazenamento local
class StorageService {
  static SharedPreferences? _prefs;

  /// Inicializa o serviço de armazenamento
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Salva uma string
  static Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  /// Obtém uma string
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Salva um boolean
  static Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  /// Obtém um boolean
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Salva um int
  static Future<bool> setInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }

  /// Obtém um int
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Remove uma chave
  static Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  /// Limpa todo o armazenamento
  static Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
}





