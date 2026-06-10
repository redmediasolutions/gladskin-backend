import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/components/shell.dart';
import 'package:gladskin_backend/screens/coupons/coupons_create.dart';
import 'package:gladskin_backend/screens/coupons/coupons_list.dart';
import 'package:gladskin_backend/screens/coupons/influencers/influencers_create.dart';
import 'package:gladskin_backend/screens/coupons/influencers/influencers_list.dart';
import 'package:gladskin_backend/screens/customer_rewards_screen.dart';
import 'package:gladskin_backend/screens/customers_screen.dart';
import 'package:gladskin_backend/screens/login_screen.dart';
import 'package:gladskin_backend/screens/reward_withdrawlsscreen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,

  initialLocation: '/customers',

  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  /// AUTH CHECK
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final isLoginPage =
        state.matchedLocation == '/login';

    /// NOT LOGGED IN
    if (user == null && !isLoginPage) {
      return '/login';
    }

    /// ALREADY LOGGED IN
    if (user != null && isLoginPage) {
      return '/customers';
    }

    return null;
  },

  routes: [
    /// LOGIN
    GoRoute(
      path: '/login',

      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: LoginScreen(),
        );
      },
    ),

    /// SHELL
    ShellRoute(
      builder: (context, state, child) {
        return AdminShell(child: child);
      },

      routes: [
        /// CUSTOMERS
        GoRoute(
          path: '/customers',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: CustomersScreen(),
            );
          },
        ),

        /// CUSTOMER REWARDS
        GoRoute(
          path:
              '/customers/:userId/rewards',

          pageBuilder: (
            context,
            state,
          ) {
            final userId =
                state.pathParameters[
                    'userId']!;

            final customerName =
                state.uri.queryParameters[
                        'name'] ??
                    'Customer';

            return NoTransitionPage(
              child:
                  CustomerRewardsScreen(
                userId: userId,
                customerName:
                    customerName,
              ),
            );
          },
        ),

        /// COUPONS
        GoRoute(
          path: '/coupons',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: CouponsList(),
            );
          },
        ),

        /// CREATE COUPON
        GoRoute(
          path: '/coupons/create',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child:
                  CreateCouponScreen(),
            );
          },
        ),

        GoRoute(

  path: '/reward-withdrawals',

  builder: (context, state) =>

      const RewardWithdrawalsPage(),

),

        /// INFLUENCERS
        GoRoute(
          path: '/influencers',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child:
                  Influencerscreens(),
            );
          },
        ),

        /// CREATE INFLUENCER
        GoRoute(
          path:
              '/influencers/create',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child:
                  CreateInfluencerScreen(),
            );
          },
        ),
      ],
    ),
  ],
);

/// REFRESH LISTENER
class GoRouterRefreshStream
    extends ChangeNotifier {
  GoRouterRefreshStream(
    Stream<dynamic> stream,
  ) {
    notifyListeners();

    _subscription = stream
        .asBroadcastStream()
        .listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic>
      _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}