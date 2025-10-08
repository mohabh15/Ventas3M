import 'package:flutter/material.dart';
import '../../models/debt.dart';
import '../../services/formatting_service.dart';

class DebtDetailsModal extends StatelessWidget {
  final Debt debt;

  const DebtDetailsModal({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark;

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
                    'Detalles de Deuda',
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
                  _buildDetailRow(context, 'Descripción', debt.description),
                  _buildDetailRow(context, 'Monto', FormattingService.formatCurrency(debt.amount)),
                  _buildDetailRow(context, 'Fecha', FormattingService.formatDate(debt.date)),
                  _buildDetailRow(context, 'Deudor', debt.effectiveDebtor),
                  _buildDetailRow(context, 'Acreedor', debt.creditor),
                ],
              ),

              const SizedBox(height: 16),

              // Estado y tipo
              _buildInfoSection(
                context,
                'Estado y Tipo',
                [
                  _buildStatusRow(context, 'Tipo de Deuda', debt.debtType.displayName),
                  _buildStatusRow(context, 'Estado', debt.status.displayName, statusColor: _getStatusColor(debt.status)),
                ],
              ),

              const SizedBox(height: 16),

              // Información del sistema
              _buildInfoSection(
                context,
                'Información del Sistema',
                [
                  _buildDetailRow(context, 'ID', debt.id),
                  _buildDetailRow(context, 'Proyecto ID', debt.projectId),
                  _buildDetailRow(context, 'Creado por', debt.createdBy),
                  _buildDetailRow(context, 'Fecha de Creación', FormattingService.formatDateTime(debt.createdAt)),
                  _buildDetailRow(context, 'Última Actualización', FormattingService.formatDateTime(debt.updatedAt)),
                ],
              ),

              if (debt.hasRelatedTransaction) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  context,
                  'Transacción Relacionada',
                  [
                    _buildDetailRow(context, 'ID de Transacción', debt.relatedTransactionId!),
                  ],
                ),
              ],

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

  Widget _buildStatusRow(BuildContext context, String label, String value, {Color? statusColor}) {
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (statusColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (statusColor ?? theme.colorScheme.primary).withValues(alpha: 0.3)),
              ),
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.pending:
        return Colors.orange;
      case DebtStatus.paid:
        return Colors.green;
      case DebtStatus.cancelled:
        return Colors.red;
      case DebtStatus.overdue:
        return Colors.red[700]!;
    }
  }
}