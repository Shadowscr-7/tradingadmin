import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stats = [
      StatItem(
        icon: Icons.trending_up_rounded,
        value: '24',
        label: 'Trades',
        color: const Color(0xFF4CAF50),
      ),
      StatItem(
        icon: Icons.account_balance_wallet_rounded,
        value: '\$12.5K',
        label: 'Portfolio',
        color: const Color(0xFF2196F3),
      ),
      StatItem(
        icon: Icons.show_chart_rounded,
        value: '+15.7%',
        label: 'Ganancia',
        color: const Color(0xFF9C27B0),
      ),
    ];

    return Animate(
      effects: [
        FadeEffect(delay: 200.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 200.ms),
      ],
      child: Container(
        width: double.infinity,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 90,
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
          blur: 20,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  stats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;

                    return Animate(
                      effects: [
                        FadeEffect(
                          delay: Duration(milliseconds: 300 + (index * 100)),
                        ),
                        ScaleEffect(
                          delay: Duration(milliseconds: 300 + (index * 100)),
                        ),
                      ],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: stat.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: stat.color.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(stat.icon, color: stat.color, size: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stat.value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stat.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
