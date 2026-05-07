import 'package:flutter/material.dart';
import 'package:segundo_parcial/core/router/app_router.dart';
import 'package:segundo_parcial/core/theme/app_theme.dart';

void main() {
  runApp(const ShopFlowApp());
}

class ShopFlowApp extends StatelessWidget {
  const ShopFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}