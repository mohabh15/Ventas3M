import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../models/product.dart';
import '../../models/sale_status.dart';
import '../../models/payment_method.dart';

class SaleDetailsModal extends StatelessWidget {
  final Sale sale;
  final Product? product;
  final String? createdByName;

  const SaleDetailsModal({
    super.key,
    required this.sale,
    this.product,
    this.createdByName,
  });

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
                    'Detalles de la Venta',
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
              const SizedBox(height: 16),

              // Información de la venta
              _buildInfoRow(context, 'ID de Venta', sale.id.substring(0, 8).toUpperCase()),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Fecha', _formatDate(sale.saleDate)),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Estado', sale.status.displayName),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Cliente', sale.customerName),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Producto', product?.name ?? 'Producto no encontrado'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Categoría', product?.category ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Cantidad', '${sale.quantity} ${sale.quantity == 1 ? 'unidad' : 'unidades'}'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Precio Unitario', '\$${sale.unitPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Total', '\$${sale.totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Ganancia', '\$${sale.profit.toStringAsFixed(2)}'),
              if (sale.debt != null && sale.debt! > 0) ...[
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Deuda', '\$${sale.debt!.toStringAsFixed(2)}'),
              ],
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Método de Pago', sale.paymentMethod.displayName),
              if (sale.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Notas', sale.notes),
              ],
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Creado por', createdByName ?? sale.createdBy),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Fecha de Creación', _formatDate(sale.createdAt)),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Última Actualización', _formatDate(sale.updatedAt)),
              const SizedBox(height: 24),

              // Botón de cerrar
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
            '${date.minute.toString().padLeft(2, '0')}';
  }
}