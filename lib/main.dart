import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'firebase_options.dart';
import 'services/gorouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(PathUrlStrategy());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GladskinAdminApp());
}

class GladskinAdminApp extends StatelessWidget {
  const GladskinAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gladskin Admin',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB5838D),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F4F4),
      ),

      routerConfig: appRouter,
    );
  }
}