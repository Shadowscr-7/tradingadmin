import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TradingPositionsSection extends StatelessWidget {
  const TradingPositionsSection({super.key});

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
            'Posiciones Activas',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Resumen de posiciones
          Animate(
            effects: [
              FadeEffect(delay: 300.ms),
              SlideEffect(begin: const Offset(-0.3, 0), delay: 300.ms),
            ],
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 100,
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total P&L',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '+\$2,847.50',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Posiciones',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '3 Activas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lista de posiciones
          Expanded(
            child: ListView.builder(
              itemCount: _positions.length,
              itemBuilder: (context, index) {
                final position = _positions[index];
                return Animate(
                  effects: [
                    FadeEffect(delay: (400 + index * 100).ms),
                    SlideEffect(
                      begin: const Offset(0.3, 0),
                      delay: (400 + index * 100).ms,
                    ),
                  ],
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 120,
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
                          position['isProfit']
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      blur: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  position['symbol'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        position['type'] == 'BUY'
                                            ? Colors.green
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    position['type'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  position['isProfit']
                                      ? '+${position['pnl']}'
                                      : position['pnl'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color:
                                        position['isProfit']
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Volumen',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        position['volume'],
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Precio Entrada',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        position['entryPrice'],
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Precio Actual',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        position['currentPrice'],
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap:
                                        () =>
                                            _closePosition(position['symbol']),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  static const List<Map<String, dynamic>> _positions = [
    {
      'symbol': 'EURUSD',
      'type': 'BUY',
      'volume': '1.00',
      'entryPrice': '1.0835',
      'currentPrice': '1.0842',
      'pnl': '\$70.00',
      'isProfit': true,
    },
    {
      'symbol': 'GBPUSD',
      'type': 'SELL',
      'volume': '0.50',
      'entryPrice': '1.2156',
      'currentPrice': '1.2145',
      'pnl': '\$55.00',
      'isProfit': true,
    },
    {
      'symbol': 'USDJPY',
      'type': 'BUY',
      'volume': '0.75',
      'entryPrice': '149.85',
      'currentPrice': '149.92',
      'pnl': '\$52.50',
      'isProfit': true,
    },
  ];

  void _closePosition(String symbol) {
    // Lógica para cerrar posición
    print('Cerrando posición para $symbol');
  }
}
