import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/settings_screen.dart';

/// A centralized drawer widget used across all screens.
/// Prevents code duplication and ensures consistent navigation.
class AppDrawer extends ConsumerWidget {
  final VoidCallback? onDeleteReset;
  final VoidCallback? onFeedback;
  final VoidCallback? onCloudStorage;
  final VoidCallback? onManageCategories;
  final VoidCallback? onManageUpiApps;
  final VoidCallback? onAbout;

  const AppDrawer({
    super.key,
    this.onDeleteReset,
    this.onFeedback,
    this.onCloudStorage,
    this.onManageCategories,
    this.onManageUpiApps,
    this.onAbout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          const SizedBox(height: 8),
          _buildDrawerSection(
            context,
            title: 'Data',
            items: [
              if (onDeleteReset != null)
                _DrawerItem(
                  icon: Icons.delete_forever,
                  label: 'Delete & Reset',
                  onTap: () {
                    Navigator.pop(context);
                    onDeleteReset?.call();
                  },
                  iconColor: colorScheme.error,
                ),
              if (onCloudStorage != null)
                _DrawerItem(
                  icon: Icons.cloud_sync,
                  label: 'Cloud Storage',
                  onTap: () {
                    Navigator.pop(context);
                    onCloudStorage?.call();
                  },
                ),
            ],
          ),
          _buildDrawerSection(
            context,
            title: 'Manage',
            items: [
              if (onManageCategories != null)
                _DrawerItem(
                  icon: Icons.category,
                  label: 'Manage Categories',
                  onTap: () {
                    Navigator.pop(context);
                    onManageCategories?.call();
                  },
                ),
              if (onManageUpiApps != null)
                _DrawerItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Manage UPI Apps',
                  onTap: () {
                    Navigator.pop(context);
                    onManageUpiApps?.call();
                  },
                ),
            ],
          ),
          _buildDrawerSection(
            context,
            title: 'Settings',
            items: [
              _DrawerItem(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              if (onFeedback != null)
                _DrawerItem(
                  icon: Icons.feedback,
                  label: 'Feedback',
                  onTap: () {
                    Navigator.pop(context);
                    onFeedback?.call();
                  },
                ),
              if (onAbout != null)
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    onAbout?.call();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 32,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'MoneyManager',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Manage your finances',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    // Filter out empty sections
    final validItems = items.whereType<_DrawerItem>().toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
