import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/resumen.dart';

class ResumenCard extends StatelessWidget {
  final Resumen? resumen;

  const ResumenCard({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final theme = Theme.of(context);

    if (resumen == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen de cartera',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (resumen!.cantidadVencidos > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${resumen!.cantidadVencidos} vencido(s)',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Capital',
                    value: currency.format(resumen!.capitalPrestado),
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Por cobrar',
                    value: currency.format(resumen!.totalPorCobrar),
                    highlight: true,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Ganancia',
                    value: currency.format(resumen!.gananciaEsperada),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MetricTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
