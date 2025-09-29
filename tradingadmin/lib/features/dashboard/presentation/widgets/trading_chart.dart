import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TradingChart extends StatefulWidget {
  const TradingChart({super.key});

  @override
  State<TradingChart> createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  String selectedTimeframe = '1D';
  bool showCandlesticks = true;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 400.ms),
      ],
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 400,
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
        blur: 15,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartHeader(theme),
              const SizedBox(height: 24),
              Expanded(child: _buildChart(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BTC/USD',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Row(
              children: [
                Text(
                  '\$42,847.32',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+2.4%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildTimeframeButton('1H', theme),
            _buildTimeframeButton('1D', theme),
            _buildTimeframeButton('1W', theme),
            _buildTimeframeButton('1M', theme),
            const SizedBox(width: 16),
            _buildToggleButton(theme),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeframeButton(String timeframe, ThemeData theme) {
    final isSelected = selectedTimeframe == timeframe;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              selectedTimeframe = timeframe;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              timeframe,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            showCandlesticks = !showCandlesticks;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(
            showCandlesticks ? Icons.candlestick_chart : Icons.show_chart,
            color: Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            minX: 0,
            maxX: 10,
            minY: 0,
            maxY: 50000,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: 10000,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${(value / 1000).toStringAsFixed(0)}K',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 2,
                  getTitlesWidget: (value, meta) {
                    final hours = [
                      '00:00',
                      '04:00',
                      '08:00',
                      '12:00',
                      '16:00',
                      '20:00',
                    ];
                    if (value.toInt() < hours.length && value.toInt() >= 0) {
                      return Text(
                        hours[value.toInt()],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10000,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.white.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: _generateSpots(),
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.3),
                      theme.colorScheme.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              LineChartBarData(
                spots: _generateSecondarySpots(),
                isCurved: true,
                color: const Color(0xFF00E5FF),
                barWidth: 2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBorder: BorderSide(color: Colors.transparent),
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '\$${spot.y.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
          duration: Duration(
            milliseconds: (2000 * _chartController.value).toInt(),
          ),
        );
      },
    );
  }

  List<FlSpot> _generateSpots() {
    return [
      const FlSpot(0, 41000),
      const FlSpot(1, 41500),
      const FlSpot(2, 42000),
      const FlSpot(3, 41800),
      const FlSpot(4, 42200),
      const FlSpot(5, 42847),
      const FlSpot(6, 42500),
      const FlSpot(7, 43000),
      const FlSpot(8, 42800),
      const FlSpot(9, 43200),
      const FlSpot(10, 42847),
    ];
  }

  List<FlSpot> _generateSecondarySpots() {
    return [
      const FlSpot(0, 40500),
      const FlSpot(1, 41000),
      const FlSpot(2, 41700),
      const FlSpot(3, 41300),
      const FlSpot(4, 41900),
      const FlSpot(5, 42400),
      const FlSpot(6, 42100),
      const FlSpot(7, 42600),
      const FlSpot(8, 42300),
      const FlSpot(9, 42800),
      const FlSpot(10, 42400),
    ];
  }
}
