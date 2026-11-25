import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prestamo.dart';

class PrestamoCard extends StatelessWidget {
  final Prestamo prestamo;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  const PrestamoCard({
    super.key,
    required this.prestamo,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final dateFmt = DateFormat('dd/MM/yyyy');
    final vencido = prestamo.estaVencido;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: vencido ? Colors.red.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: vencido
            ? BorderSide(color: Colors.red.shade400, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prestamo.cliente,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (vencido)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Vencido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (prestamo.pagado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Cobrado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('DNI: ${prestamo.dni}'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                Text('Monto: ${currency.format(prestamo.monto)}'),
                Text('Interés: ${prestamo.interes.toStringAsFixed(2)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total a cobrar: ${currency.format(prestamo.totalACobrar)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vence: ${dateFmt.format(prestamo.fechaVencimiento)}',
              style: TextStyle(
                color: vencido ? Colors.red.shade800 : null,
                fontWeight: vencido ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
                if (!prestamo.pagado)
                  TextButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Pagado'),
                  ),
                TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Anular'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
