import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/router/app_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader(context, 'Аккаунт'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Профиль',
                subtitle: user?.email ?? (user?.isAnonymous == true ? 'Гость' : 'Не авторизован'),
                onTap: () => context.push(AppRoutes.profile),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(context, 'Внешний вид'),
          const SizedBox(height: 12),
          _buildThemeModeSection(context, ref),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader(context, 'Данные'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.cloud_sync,
                title: 'Синхронизация',
                subtitle: user != null ? 'Включена' : 'Войдите для синхронизации',
                trailing: Icon(
                  user != null ? Icons.check_circle : Icons.cancel,
                  color: user != null ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'О приложении'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'Версия',
                subtitle: '1.0.0',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout button
          if (user != null)
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Выйти из аккаунта',
                  onTap: () => _showLogoutDialog(context, ref),
                  isDestructive: true,
                ),
              ],
            ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool enabled = true,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : (enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.4));

    return ListTile(
      enabled: enabled,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary)
              .withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? theme.colorScheme.error.withValues(alpha: enabled ? 1 : 0.4)
              : theme.colorScheme.primary.withValues(alpha: enabled ? 1 : 0.4),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildThemeModeSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeModeProvider);

    return _buildSettingsCard(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тема оформления',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildThemeModeButton(
                    context,
                    ref,
                    icon: Icons.brightness_auto,
                    label: 'Авто',
                    mode: ThemeMode.system,
                    isSelected: currentMode == ThemeMode.system,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeModeButton(
                    context,
                    ref,
                    icon: Icons.light_mode,
                    label: 'Светлая',
                    mode: ThemeMode.light,
                    isSelected: currentMode == ThemeMode.light,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeModeButton(
                    context,
                    ref,
                    icon: Icons.dark_mode,
                    label: 'Темная',
                    mode: ThemeMode.dark,
                    isSelected: currentMode == ThemeMode.dark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeNotifierProvider.notifier).setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Вы уверены, что хотите выйти?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
