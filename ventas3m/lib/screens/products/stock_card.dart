import 'package:flutter/material.dart';
import '../../models/product.dart';

class StockCard extends StatelessWidget {
  final ProductStock stock;

  const StockCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ícono de cantidad
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Información del stock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cantidad y precio
                  Row(
                    children: [
                      Text(
                        'Cantidad: ${stock.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${stock.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Responsable
                  Text(
                    'Responsable: ${stock.responsibleId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  // Proveedor
                  Text(
                    'Proveedor: ${stock.providerId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  // Fecha de compra
                  Text(
                    'Fecha: ${_formatDate(stock.purchaseDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Estado del stock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStockStatusColor(stock.quantity, isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStockStatusText(stock.quantity),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  Color _getStockStatusColor(int quantity, bool isDark) {
    if (quantity == 0) {
      return isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336);
    } else if (quantity <= 5) {
      return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    } else {
      return isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);
    }
  }

  String _getStockStatusText(int quantity) {
    if (quantity == 0) {
      return 'Agotado';
    } else if (quantity <= 5) {
      return 'Bajo Stock';
    } else {
      return 'Disponible';
    }
  }
}