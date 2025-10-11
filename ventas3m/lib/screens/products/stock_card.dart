import 'package:flutter/material.dart';
import '../../models/product.dart';

class StockCard extends StatefulWidget {
  final ProductStock stock;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockCard({
    super.key,
    required this.stock,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.stock.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Deslizar derecha: eliminar
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed) {
            widget.onDelete();
          }
          return confirmed;
        } else if (direction == DismissDirection.endToStart) {
          // Deslizar izquierda: editar
          widget.onEdit();
          return false; // No dismiss, solo mostrar modal
        }
        return false;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
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
                            'Cantidad: ${widget.stock.quantity}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${widget.stock.price.toStringAsFixed(2)}',
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
                        'Responsable: ${widget.stock.responsibleId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),

                      // Proveedor
                      Text(
                        'Proveedor: ${widget.stock.providerId}',
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
                    color: _getStockStatusColor(widget.stock.quantity, isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStockStatusText(widget.stock.quantity),
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
        ),
      ),
    );
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

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Stock'),
          content: Text('¿Estás seguro de que quieres eliminar este stock? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}