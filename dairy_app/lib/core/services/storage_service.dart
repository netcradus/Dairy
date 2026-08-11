/// Abstract Storage Service interface for Phase 1 architecture
abstract class StorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> remove(String key);
  Future<void> clear();
}

/// InMemory implementation of StorageService
class InMemoryStorageService implements StorageService {
  final Map<String, dynamic> _memory = {};

  @override
  Future<void> setString(String key, String value) async {
    _memory[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _memory[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return (_memory[key] as bool?) ?? defaultValue;
  }

  @override
  Future<void> remove(String key) async {
    _memory.remove(key);
  }

  @override
  Future<void> clear() async {
    _memory.clear();
  }
}
