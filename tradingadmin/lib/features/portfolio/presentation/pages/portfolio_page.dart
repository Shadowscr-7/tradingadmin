import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/modern_app_bar.dart';
import '../../../dashboard/presentation/widgets/modern_side_panel.dart';
import '../widgets/portfolio_summary_section.dart';
import '../widgets/portfolio_assets_section.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            const Color(0xFF0f0f23),
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        drawer: const ModernSidePanel(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ModernAppBar(
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Balance total
                PortfolioSummarySection(),

                const SizedBox(height: 20),

                // Assets
                Expanded(child: PortfolioAssetsSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
