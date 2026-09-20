import 'package:flutter/material.dart';
import 'package:vietnam_handbook/app.dart';
import 'package:vietnam_handbook/app_router.dart';
import 'package:vietnam_handbook/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(VietnamHandbookApp(router: createRouter()));
}
