import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'screens/customers_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'screens/customer_rewards_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GladskinAdminApp());
}

// ✅ _router is global — accessible everywhere in this file
final GoRouter _router = GoRouter(
  initialLocation: '/customers',
  routes: [
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: '/customers/:userId/rewards',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final customerName =
            state.uri.queryParameters['name'] ?? 'Customer';
        return CustomerRewardsScreen(
          userId: userId,
          customerName: customerName,
        );
      },
    ),
  ],
);

class GladskinAdminApp extends StatelessWidget {
  const GladskinAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // ✅ Logged in → show router app with _router (global)
        if (snapshot.hasData) {
          return MaterialApp.router(
            title: 'Gladskin Admin',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFFB5838D),
              useMaterial3: true,
            ),
            routerConfig: _router, // ✅ references the global _router above
          );
        }

        // ❌ Not logged in → show login screen
        return MaterialApp(
          title: 'Gladskin Admin',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFFB5838D),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}