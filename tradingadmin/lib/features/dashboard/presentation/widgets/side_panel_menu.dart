import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SidePanelMenu extends StatelessWidget {
  const SidePanelMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuItems = [
      {
        'icon': Icons.dashboard_rounded,
        'title': 'Dashboard',
        'subtitle': 'Vista general',
        'color': theme.colorScheme.primary,
        'route': '/dashboard',
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'title': 'Portfolio',
        'subtitle': 'Mis inversiones',
        'color': const Color(0xFF00E5FF),
        'route': '/portfolio',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Trading',
        'subtitle': 'Operar en vivo',
        'color': Colors.green,
        'route': '/trading',
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'title': 'Operaciones',
        'subtitle': 'Historial',
        'color': Colors.orange,
        'route': '/trading',
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Análisis',
        'subtitle': 'Reportes y métricas',
        'color': Colors.purple,
        'route': '/dashboard',
      },
      {
        'icon': Icons.settings_rounded,
        'title': 'Configuración',
        'subtitle': 'Preferencias',
        'color': Colors.grey,
        'route': '/profile',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Animate(
              effects: [
                FadeEffect(delay: Duration(milliseconds: 300 + (100 * index))),
                SlideEffect(
                  begin: const Offset(0.3, 0),
                  delay: Duration(milliseconds: 300 + (100 * index)),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item['route'] as String);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (item['color'] as Color).withOpacity(
                                  0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  item['subtitle'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.4),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
