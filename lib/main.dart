import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PateDateApp());
}

class PateDateApp extends StatelessWidget {
  const PateDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PateDate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppScaffold(),
    );
  }
}
