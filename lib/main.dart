import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/hive_config.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.initialise();
  await setupServiceLocator();
  runApp(const ArrowConMangoApp());
}
