import 'package:flutter/material.dart';
import '../../models/product.dart';

class StockDetailsModal extends StatelessWidget {
  final ProductStock stock;

  const StockDetailsModal({
    super.key,
    required this.stock,
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
                    'Detalles del Stock',
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

              // Información del stock
              _buildInfoRow(context, 'ID del Stock', stock.id.substring(0, 8).toUpperCase()),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Cantidad', stock.quantity.toString()),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Precio de Compra', '\$${stock.price.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Responsable', stock.responsibleId),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Proveedor', stock.providerId),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Fecha de Compra', _formatDate(stock.purchaseDate)),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Fecha de Creación', _formatDate(stock.createdAt)),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Última Actualización', _formatDate(stock.updatedAt)),
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