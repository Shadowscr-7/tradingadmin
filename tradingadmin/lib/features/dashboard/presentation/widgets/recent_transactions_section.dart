import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 600.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 600.ms),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transacciones Recientes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // Ver todas las transacciones
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Ver todas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildTransactionsList(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    final transactions = [
      {
        'type': 'buy',
        'asset': 'BTC',
        'amount': '0.25',
        'value': '\$10,750.00',
        'time': '2 min ago',
        'status': 'completed',
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
      },
      {
        'type': 'sell',
        'asset': 'ETH',
        'amount': '1.5',
        'value': '\$3,420.00',
        'time': '15 min ago',
        'status': 'completed',
        'icon': Icons.trending_down_rounded,
        'color': Colors.red,
      },
      {
        'type': 'transfer',
        'asset': 'USDT',
        'amount': '5,000',
        'value': '\$5,000.00',
        'time': '1 hour ago',
        'status': 'pending',
        'icon': Icons.swap_horiz_rounded,
        'color': const Color(0xFF00E5FF),
      },
      {
        'type': 'buy',
        'asset': 'ADA',
        'amount': '2,500',
        'value': '\$1,250.00',
        'time': '3 hours ago',
        'status': 'completed',
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
      },
      {
        'type': 'deposit',
        'asset': 'USD',
        'amount': '10,000',
        'value': '\$10,000.00',
        'time': '1 day ago',
        'status': 'completed',
        'icon': Icons.add_circle_rounded,
        'color': Colors.orange,
      },
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Animate(
          effects: [
            FadeEffect(delay: Duration(milliseconds: 100 * index)),
            SlideEffect(
              begin: const Offset(0.3, 0),
              delay: Duration(milliseconds: 100 * index),
            ),
          ],
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Ver detalles de la transacción
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (transaction['color'] as Color).withOpacity(
                            0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          transaction['icon'] as IconData,
                          color: transaction['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_getTransactionTypeText(transaction['type'] as String)} ${transaction['asset']}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  transaction['value'] as String,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: transaction['color'] as Color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${transaction['amount']} ${transaction['asset']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          transaction['status'] as String,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      transaction['time'] as String,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'buy':
        return 'Compra';
      case 'sell':
        return 'Venta';
      case 'transfer':
        return 'Transferencia';
      case 'deposit':
        return 'Depósito';
      case 'withdraw':
        return 'Retiro';
      default:
        return 'Transacción';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
