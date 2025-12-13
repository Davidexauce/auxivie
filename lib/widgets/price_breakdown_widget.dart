import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../theme/app_theme.dart';

/// Widget pour afficher la répartition des prix avec les frais de plateforme
class PriceBreakdownWidget extends StatelessWidget {
  final double basePrice;
  final String? label;

  const PriceBreakdownWidget({
    super.key,
    required this.basePrice,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    final settings = settingsViewModel.settings;

    if (settings == null) {
      return const SizedBox.shrink();
    }

    final fee = settings.calculateFeeAmount(basePrice);
    final total = settings.calculateTotal(basePrice);
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            _PriceRow(
              label: 'Prix de base',
              amount: basePrice,
              formatter: formatter,
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Frais de service (${settings.platformFee}%)',
              amount: fee,
              formatter: formatter,
            ),
            const Divider(height: 24),
            _PriceRow(
              label: 'Total',
              amount: total,
              formatter: formatter,
              isBold: true,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final NumberFormat formatter;
  final bool isBold;
  final Color? color;

  const _PriceRow({
    required this.label,
    required this.amount,
    required this.formatter,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

