import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';
import 'category_management_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'Z';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.sp24),
          child: Column(
            children: [
              SizedBox(height: AppTheme.sp32),

              // ── Avatar ──
              ScaleIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTheme.displayLarge(context).copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppTheme.sp20),

              // ── Name ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                child: Text(
                  displayName,
                  style: AppTheme.headlineLarge(context),
                ),
              ),

              SizedBox(height: AppTheme.sp4),

              // ── Email ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 450),
                child: Text(email, style: AppTheme.bodyMedium(context)),
              ),

              SizedBox(height: AppTheme.sp48),

              // ── Menu Items ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: _MenuItem(
                  icon: Icons.category_outlined,
                  label: 'Pengaturan Kategori',
                  onTap: () {
                    Navigator.push(
                      context,
                      SmoothPageRoute(page: const CategoryManagementScreen()),
                    );
                  },
                ),
              ),

              SizedBox(height: AppTheme.sp8),

              FadeSlideIn(
                delay: const Duration(milliseconds: 550),
                child: _MenuItem(
                  icon: Icons.dark_mode_outlined,
                  label: 'Tema Gelap',
                  trailing: Switch(
                    value: ref.watch(themeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref
                          .read(themeProvider.notifier)
                          .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeThumbColor: Theme.of(context).colorScheme.surface,
                    activeTrackColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () {
                    final isDark = ref.read(themeProvider) == ThemeMode.dark;
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(
                          !isDark ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
              ),

              SizedBox(height: AppTheme.sp8),

              FadeSlideIn(
                delay: const Duration(milliseconds: 550),
                child: _MenuItem(
                  icon: Icons.info_outline,
                  label: 'Tentang Aplikasi',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ZenFlow',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 ZenFlow',
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'Aplikasi pencatatan keuangan minimalis.',
                          style: AppTheme.bodyMedium(context),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: AppTheme.sp8),

              FadeSlideIn(
                delay: const Duration(milliseconds: 650),
                child: _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  isDestructive: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Keluar?',
                          style: AppTheme.headlineMedium(context),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar dari akun ini?',
                          style: AppTheme.bodyLarge(context),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'BATAL',
                              style: AppTheme.labelSmall(context).copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('KELUAR'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await AuthService().signOut();
                    }
                  },
                ),
              ),

              SizedBox(height: AppTheme.sp48),

              // ── Footer ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 750),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/icon/icon1.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.sp12),
                    Text(
                      'ZENFLOW',
                      style: AppTheme.labelSmall(
                        context,
                      ).copyWith(letterSpacing: 4),
                    ),
                    SizedBox(height: AppTheme.sp4),
                    Text(
                      'v1.0.0',
                      style: AppTheme.bodyMedium(context).copyWith(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.sp20,
          vertical: AppTheme.sp16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: AppTheme.sp12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.titleMedium(context).copyWith(
                  color: isDestructive
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ],
        ),
      ),
    );
  }
}
