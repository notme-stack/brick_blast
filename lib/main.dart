import 'package:flutter/material.dart';

import 'app.dart';
import 'capabilities/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const BrickBlastApp());
}
