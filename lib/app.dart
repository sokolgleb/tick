import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'routing/router.dart';

class TickApp extends StatelessWidget {
  const TickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tick',
      theme: TickTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
