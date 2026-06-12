import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5838D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 14),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gladskin",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      "Admin Panel",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// NAVIGATION
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _navItem(
                  index: 0,
                  icon: Icons.people_alt_outlined,
                  title: "Customers",
                ),

                _navItem(
                  index: 1,
                  icon: Icons.local_offer_outlined,
                  title: "Coupons",
                ),

                _navItem(
                  index: 2,
                  icon: Icons.campaign_outlined,
                  title: "Influencers",
                ),

                  _navItem(

    index: 3,

    icon: Icons.payments_outlined,

    title: "Reward Withdrawals",

  ),


                  _navItem(

    index: 4,

    icon: Icons.notifications_outlined,

    title: "Notifications",

  ),
              ],
            ),
          ),

          /// FOOTER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFB5838D),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          "Gladskin Team",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: "Logout",
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onItemSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF6ECEE)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFFB5838D)
                    : Colors.grey.shade700,
              ),

              const SizedBox(width: 14),

              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFB5838D)
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}