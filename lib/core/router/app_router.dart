import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trip_setup/presentation/pages/trip_type_page.dart';
import '../../features/trip_setup/presentation/pages/trip_params_page.dart';
import '../../features/trip_setup/presentation/pages/trip_conditions_page.dart';
import '../../features/packing_list/presentation/pages/generated_list_page.dart';
import '../../features/packing_list/presentation/pages/edit_list_page.dart';
import '../../features/packing_list/presentation/pages/save_list_page.dart';
import '../../features/packing_mode/presentation/pages/packing_mode_page.dart';
import '../../features/packing_mode/presentation/pages/completion_page.dart';
import '../../features/templates/presentation/pages/templates_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../services/auth_service.dart';

// Route names
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/';
  static const String tripType = '/trip-type';
  static const String tripParams = '/trip-params';
  static const String tripConditions = '/trip-conditions';
  static const String generatedList = '/generated-list';
  static const String editList = '/edit-list';
  static const String saveList = '/save-list';
  static const String packingMode = '/packing-mode';
  static const String completion = '/completion';
  static const String templates = '/templates';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);
  final isLoggedIn = authState.valueOrNull != null;

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final isOnboarding = currentPath == AppRoutes.onboarding;
      final isLogin = currentPath == AppRoutes.login;

      // Still loading
      if (authState.isLoading) {
        return null;
      }

      // Show onboarding if not completed
      if (!onboardingCompleted && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      // Show login if not logged in (and onboarding completed)
      if (onboardingCompleted && !isLoggedIn && !isLogin && !isOnboarding) {
        return AppRoutes.login;
      }

      // Redirect from login to home if already logged in
      if (isLoggedIn && isLogin) {
        return AppRoutes.home;
      }

      // Redirect from onboarding to login if already completed
      if (onboardingCompleted && isOnboarding) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      return null;
    },
    routes: [
      // Onboarding (outside shell)
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Login (outside shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Shell with bottom navigation for main screens
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(
            currentLocation: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),

          // Templates
          GoRoute(
            path: AppRoutes.templates,
            name: 'templates',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TemplatesPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),

      // Trip Setup Flow (outside shell - full screen)
      GoRoute(
        path: AppRoutes.tripType,
        name: 'tripType',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TripTypePage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.tripParams,
        name: 'tripParams',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TripParamsPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.tripConditions,
        name: 'tripConditions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TripConditionsPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // Packing List Flow (outside shell - full screen)
      GoRoute(
        path: AppRoutes.generatedList,
        name: 'generatedList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const GeneratedListPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.editList,
        name: 'editList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditListPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.saveList,
        name: 'saveList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SaveListPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // Packing Mode Flow (outside shell - full screen)
      GoRoute(
        path: AppRoutes.packingMode,
        name: 'packingMode',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PackingModePage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.completion,
        name: 'completion',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CompletionPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // Profile (outside shell - modal style)
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfilePage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
  );
});

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}
