import 'package:flutter/material.dart';

import '../common/common.dart';
import '../module/module.dart';
import 'splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ModuleRegistry.register(AntiPatternsModule());
  ModuleRegistry.register(ConceptsModule());
  ModuleRegistry.register(OperatorsModule());
  ModuleRegistry.register(RecipesModule());
  ModuleRegistry.register(QuizModule());
  ModuleRegistry.register(WizardModule());

  for (final module in ModuleRegistry.all) {
    await module.init();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RxLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
