import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // 1. Приватный статический экземпляр
  // Используем 'final', так как он инициализируется один раз
  static final FirebaseAuth _authInstance = FirebaseAuth.instance;

  // 2. Публичный статический геттер для доступа
  // Везде, где вам нужен Auth, вы вызываете FirebaseService.auth
  static FirebaseAuth get auth => _authInstance;

  // 3. (Опционально) Пример получения текущего UID
  static String? get currentMasterUid {
    return _authInstance.currentUser?.uid;
  }
}
