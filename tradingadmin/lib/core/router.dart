import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/trading/presentation/pages/trading_page.dart';
import '../features/portfolio/presentation/pages/portfolio_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  ),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                ),
                child: FadeTransition(
                  opacity: CurveTween(
                    curve: Curves.easeInOut,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  ),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfilePage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  ),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: '/trading',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TradingPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  ),
                  child: child,
                ),
              );
            },
          ),
    ),
    GoRoute(
      path: '/portfolio',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PortfolioPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCubic,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  ),
                  child: child,
                ),
              );
            },
          ),
    ),
    // Agrega aquí más rutas para otros módulos
  ],
);
