import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class StatsCardsSection extends StatelessWidget {
  const StatsCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(spacing: 16, runSpacing: 16, children: _buildStatsCards(theme));
  }

  List<Widget> _buildStatsCards(ThemeData theme) {
    final statsData = [
      {
        'title': 'Balance Total',
        'value': '\$124,859.32',
        'change': '+12.5%',
        'changeColor': Colors.green,
        'icon': Icons.account_balance_wallet_rounded,
        'color': theme.colorScheme.primary,
        'delay': 0,
      },
      {
        'title': 'Ganancias Hoy',
        'value': '\$2,847.21',
        'change': '+8.2%',
        'changeColor': Colors.green,
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF00E5FF),
        'delay': 100,
      },
      {
        'title': 'Trades Activos',
        'value': '24',
        'change': '+3',
        'changeColor': Colors.orange,
        'icon': Icons.swap_horiz_rounded,
        'color': Colors.orange,
        'delay': 200,
      },
      {
        'title': 'ROI Mensual',
        'value': '18.4%',
        'change': '+2.1%',
        'changeColor': Colors.green,
        'icon': Icons.analytics_rounded,
        'color': Colors.purple,
        'delay': 300,
      },
    ];

    return statsData.map((stat) {
      return SizedBox(
        width: 280,
        height: 140,
        child: _buildStatsCard(
          theme,
          stat['title'] as String,
          stat['value'] as String,
          stat['change'] as String,
          stat['changeColor'] as Color,
          stat['icon'] as IconData,
          stat['color'] as Color,
          stat['delay'] as int,
        ),
      );
    }).toList();
  }

  Widget _buildStatsCard(
    ThemeData theme,
    String title,
    String value,
    String change,
    Color changeColor,
    IconData icon,
    Color iconColor,
    int delay,
  ) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: delay)),
        SlideEffect(
          begin: const Offset(0, 0.3),
          delay: Duration(milliseconds: delay),
        ),
        ScaleEffect(
          begin: const Offset(0.8, 0.8),
          delay: Duration(milliseconds: delay),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Acción al tocar la tarjeta
          },
          child: GlassmorphicContainer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 20,
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
            blur: 15,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          change,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
