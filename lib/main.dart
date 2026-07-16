import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/aop/app_bloc_observer.dart';
import 'core/database/hive_config.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await HiveConfig.initialise();
  await setupServiceLocator();
  runApp(const ArrowConMangoApp());
}
