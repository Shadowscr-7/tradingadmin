import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class PortfolioAssetsSection extends StatelessWidget {
  const PortfolioAssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 400.ms),
      ],
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        linearGradient: LinearGradient(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tus Inversiones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    return Animate(
                      effects: [
                        FadeEffect(delay: (500 + index * 100).ms),
                        SlideEffect(
                          begin: const Offset(0.3, 0),
                          delay: (500 + index * 100).ms,
                        ),
                      ],
                      child: _buildAssetItem(
                        asset['symbol'],
                        asset['percentage'],
                        asset['value'],
                        asset['change'],
                        asset['changeColor'],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _assets = [
    {
      'symbol': 'EUR/USD',
      'percentage': '45%',
      'value': '\$5,646.52',
      'change': '+2.3%',
      'changeColor': Colors.green,
    },
    {
      'symbol': 'GBP/USD',
      'percentage': '25%',
      'value': '\$3,136.96',
      'change': '-0.8%',
      'changeColor': Colors.red,
    },
    {
      'symbol': 'USD/JPY',
      'percentage': '20%',
      'value': '\$2,509.57',
      'change': '+1.5%',
      'changeColor': Colors.green,
    },
    {
      'symbol': 'AUD/USD',
      'percentage': '10%',
      'value': '\$1,254.78',
      'change': '+3.2%',
      'changeColor': Colors.green,
    },
  ];

  Widget _buildAssetItem(
    String symbol,
    String percentage,
    String value,
    String change,
    Color changeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: changeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
