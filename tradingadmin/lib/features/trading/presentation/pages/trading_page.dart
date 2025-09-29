import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/modern_app_bar.dart';
import '../../../dashboard/presentation/widgets/modern_side_panel.dart';
import '../widgets/trading_tabs_section.dart';
import '../widgets/trading_market_section.dart';
import '../widgets/trading_trade_section.dart';
import '../widgets/trading_positions_section.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

                // Tabs
                TradingTabsSection(tabController: _tabController),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      TradingMarketSection(),
                      TradingTradeSection(),
                      TradingPositionsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
