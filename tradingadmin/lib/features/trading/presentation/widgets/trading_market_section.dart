import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TradingMarketSection extends StatelessWidget {
  TradingMarketSection({super.key});

  final List<Map<String, dynamic>> _tradingPairs = [
    {'symbol': 'EURUSD', 'price': 1.0842, 'change': 0.0023, 'isUp': true},
    {'symbol': 'GBPUSD', 'price': 1.2635, 'change': -0.0012, 'isUp': false},
    {'symbol': 'USDJPY', 'price': 149.85, 'change': 0.45, 'isUp': true},
    {'symbol': 'AUDUSD', 'price': 0.6423, 'change': 0.0008, 'isUp': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 200.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 200.ms),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pares de Divisas',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _tradingPairs.length,
              itemBuilder: (context, index) {
                final pair = _tradingPairs[index];
                return Animate(
                  effects: [
                    FadeEffect(
                      delay: Duration(milliseconds: 300 + (index * 100)),
                    ),
                    SlideEffect(
                      begin: const Offset(0.3, 0),
                      delay: Duration(milliseconds: 300 + (index * 100)),
                    ),
                  ],
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 80,
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Acción al seleccionar par
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Símbolo del par
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pair['symbol'],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Forex',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Precio
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pair['price'].toString(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Cambio
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (pair['isUp']
                                              ? Colors.green
                                              : Colors.red)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (pair['isUp']
                                                ? Colors.green
                                                : Colors.red)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          pair['isUp']
                                              ? Icons.arrow_upward_rounded
                                              : Icons.arrow_downward_rounded,
                                          color:
                                              pair['isUp']
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${pair['isUp'] ? '+' : ''}${pair['change']}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    pair['isUp']
                                                        ? Colors.green
                                                        : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
