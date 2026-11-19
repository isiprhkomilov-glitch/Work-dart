import 'package:flutter/material.dart';

import 'core/di/locator.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка зависимостей через пакет get_it.
  await configureDependencies();

  runApp(const NetworkApp());
}
