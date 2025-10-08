import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/payment_method.dart';
import '../../models/expense_recurrence_type.dart';
import '../../services/formatting_service.dart';

class ExpenseDetailsModal extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsModal({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalles del Gasto',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Información principal
              _buildInfoSection(
                context,
                'Información Principal',
                [
                  _buildDetailRow(context, 'Descripción', expense.description),
                  _buildDetailRow(context, 'Monto', FormattingService.formatCurrency(expense.amount)),
                  _buildDetailRow(context, 'Fecha', FormattingService.formatDate(expense.date)),
                  _buildDetailRow(context, 'Categoría', expense.category),
                  _buildDetailRow(context, 'Método de Pago', expense.paymentMethod.displayName),
                ],
              ),

              const SizedBox(height: 16),

              // Información adicional
              if (expense.hasProject || expense.hasProvider || expense.isRecurring || expense.hasNotes || expense.hasReceipt) ...[
                _buildInfoSection(
                  context,
                  'Información Adicional',
                  [
                    if (expense.hasProject) _buildDetailRow(context, 'Proyecto', 'Proyecto relacionado'),
                    if (expense.hasProvider) _buildDetailRow(context, 'Proveedor', 'Proveedor relacionado'),
                    if (expense.isRecurring) _buildDetailRow(context, 'Recurrente', expense.recurrenceType?.displayName ?? 'Sí'),
                    if (expense.hasNotes) _buildDetailRow(context, 'Notas', expense.notes!),
                    if (expense.hasReceipt) _buildDetailRow(context, 'Recibo', 'Imagen disponible'),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Información del sistema
              _buildInfoSection(
                context,
                'Información del Sistema',
                [
                  _buildDetailRow(context, 'ID', expense.id),
                  _buildDetailRow(context, 'Creado por', expense.createdBy),
                  _buildDetailRow(context, 'Fecha de Creación', FormattingService.formatDateTime(expense.createdAt)),
                  _buildDetailRow(context, 'Última Actualización', FormattingService.formatDateTime(expense.updatedAt)),
                ],
              ),

              const SizedBox(height: 24),

              // Botón de cerrar
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}