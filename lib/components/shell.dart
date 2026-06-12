import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gladskin_backend/components/sidebar.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({
    super.key,
    required this.child,
  });

  int _getSelectedIndex(BuildContext context) {
    final location =
        GoRouterState.of(context)
            .matchedLocation;

    if (location.startsWith('/customers')) {
      return 0;
    }

    if (location.startsWith('/coupons')) {
      return 1;
    }

    if (location.startsWith('/influencers')) {
      return 2;
    }

    if (location.startsWith('/reward-withdrawals')) {
      return 3;
    }

    if (location.startsWith('/notifications')) {
      return 4;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        _getSelectedIndex(context);

    return Scaffold(
      body: Row(
        children: [

          /// SIDEBAR
          AdminSidebar(
            selectedIndex:
                selectedIndex,

            onItemSelected: (
              index,
            ) {

              switch (index) {

                case 0:
                  context.go(
                    '/customers',
                  );
                  break;

                case 1:
                  context.go(
                    '/coupons',
                  );
                  break;

                case 2:
                  context.go(
                    '/influencers',
                  );
                  break;

                case 3:
                  context.go(
                    '/reward-withdrawals',
                  );
                  break;

                case 4:
                  context.go(
                    '/notifications',
                  );
                  break;
              }
            },

            onLogout: () async {

              await FirebaseAuth
                  .instance
                  .signOut();
            },
          ),

          /// PAGE CONTENT
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}