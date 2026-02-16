class LocalStorageService {
  static final Map<String, Object?> _memory = {};

  T? read<T>(String key) {
    return _memory[key] as T?;
  }

  Future<void> write(String key, Object? value) async {
    _memory[key] = value;
  }

  static void clear() {
    _memory.clear();
  }
}
