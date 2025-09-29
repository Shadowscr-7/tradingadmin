import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Importar los componentes modulares
import '../widgets/modern_app_bar.dart';
import '../widgets/modern_side_panel.dart';
import '../widgets/stats_cards_section.dart';
import '../widgets/trading_chart.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recent_transactions_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: const ModernSidePanel(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: ModernAppBar(
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.surface,
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildDashboardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome section
          _buildWelcomeSection(),
          const SizedBox(height: 32),

          // Stats cards section
          const StatsCardsSection(),
          const SizedBox(height: 32),

          // Main content row (chart and quick actions)
          _buildMainContentRow(),
          const SizedBox(height: 32),

          // Recent transactions section
          const RecentTransactionsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 100.ms),
        SlideEffect(begin: const Offset(0, -0.3), delay: 100.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido de vuelta!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí tienes un resumen de tu actividad de trading',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1200;

        if (isWide) {
          // Layout horizontal para pantallas anchas
          return Row(
            children: [
              Expanded(flex: 2, child: const TradingChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: const QuickActionsSection()),
            ],
          );
        } else {
          // Layout vertical para pantallas más pequeñas
          return Column(
            children: [
              const TradingChart(),
              const SizedBox(height: 24),
              const QuickActionsSection(),
            ],
          );
        }
      },
    );
  }
}
