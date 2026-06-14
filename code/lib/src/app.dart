import 'package:flutter/material.dart';

import 'pages/home_shell_page.dart';
import 'theme/app_theme.dart';

class FunBoxApp extends StatelessWidget {
  const FunBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeShellPage(),
    );
  }
}
