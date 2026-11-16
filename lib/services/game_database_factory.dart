// Base de données du stockage local des parties : IndexedDB dans le
// navigateur, en mémoire ailleurs (tests sur la VM Dart).
export 'game_database_factory_memory.dart' if (dart.library.js_interop) 'game_database_factory_web.dart';
