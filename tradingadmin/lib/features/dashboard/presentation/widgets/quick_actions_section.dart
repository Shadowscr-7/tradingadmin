import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 500.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 500.ms),
      ],
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 24,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: 1,
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acciones Rápidas',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    QuickActionCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Trading',
                      subtitle: 'Operar ahora',
                      color: Colors.green,
                      animationDelay: 0,
                      onTap: () => context.go('/trading'),
                    ),
                    QuickActionCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Portfolio',
                      subtitle: 'Ver inversiones',
                      color: const Color(0xFF2196F3),
                      animationDelay: 100,
                      onTap: () => context.go('/portfolio'),
                    ),
                    QuickActionCard(
                      icon: Icons.analytics_rounded,
                      title: 'Análisis',
                      subtitle: 'Reportes',
                      color: Colors.purple,
                      animationDelay: 200,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente: Análisis detallado'),
                          ),
                        );
                      },
                    ),
                    QuickActionCard(
                      icon: Icons.person_rounded,
                      title: 'Perfil',
                      subtitle: 'Configuración',
                      color: Colors.orange,
                      animationDelay: 300,
                      onTap: () => context.go('/profile'),
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
