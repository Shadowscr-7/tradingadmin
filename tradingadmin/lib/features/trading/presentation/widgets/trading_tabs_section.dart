import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TradingTabsSection extends StatelessWidget {
  final TabController tabController;

  const TradingTabsSection({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: 100.ms),
        SlideEffect(begin: const Offset(0, -0.3), delay: 100.ms),
      ],
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 16,
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
          padding: const EdgeInsets.all(8),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6C63FF), const Color(0xFF00E5FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Mercado'),
              Tab(text: 'Operar'),
              Tab(text: 'Posiciones'),
            ],
          ),
        ),
      ),
    );
  }
}
