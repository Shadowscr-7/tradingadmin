import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TradingTradeSection extends StatefulWidget {
  const TradingTradeSection({super.key});

  @override
  State<TradingTradeSection> createState() => _TradingTradeSectionState();
}

class _TradingTradeSectionState extends State<TradingTradeSection> {
  String _selectedSymbol = 'EURUSD';
  double _amount = 1000.0;
  bool _isBuySelected = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 200.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 200.ms),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva Operación',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Selector de par
            Animate(
              effects: [
                FadeEffect(delay: 300.ms),
                SlideEffect(begin: const Offset(-0.3, 0), delay: 300.ms),
              ],
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 70,
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
                      Text(
                        'Par: ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _selectedSymbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '1.0842',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones Buy/Sell
            Animate(
              effects: [
                FadeEffect(delay: 400.ms),
                SlideEffect(begin: const Offset(0, 0.3), delay: 400.ms),
              ],
              child: Row(
                children: [
                  Expanded(
                    child: _buildTradeButton(
                      'COMPRAR',
                      Colors.green,
                      _isBuySelected,
                      () => setState(() => _isBuySelected = true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTradeButton(
                      'VENDER',
                      Colors.red,
                      !_isBuySelected,
                      () => setState(() => _isBuySelected = false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Monto
            Animate(
              effects: [
                FadeEffect(delay: 500.ms),
                SlideEffect(begin: const Offset(0, 0.3), delay: 500.ms),
              ],
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monto',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de confirmar operación
            Animate(
              effects: [
                FadeEffect(delay: 600.ms),
                SlideEffect(begin: const Offset(0, 0.3), delay: 600.ms),
              ],
              child: Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF),
                          const Color(0xFF00E5FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Confirmar Operación',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeButton(
    String text,
    Color color,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(colors: [color, color.withOpacity(0.7)])
                      : null,
              color: isSelected ? null : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(isSelected ? 0.8 : 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmar Operación',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Par: $_selectedSymbol',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                'Tipo: ${_isBuySelected ? 'COMPRA' : 'VENTA'}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                'Monto: \$${_amount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executeTrading();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBuySelected ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Ejecutar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _executeTrading() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Operación ejecutada exitosamente'),
        backgroundColor: _isBuySelected ? Colors.green : Colors.red,
      ),
    );
  }
}
