import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final surfaceColor = isDark ? Colors.grey[800] : Colors.grey[50];
    //final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85, // Máximo 85% de la pantalla
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header del modal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Detalles de Venta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '#VNT-${sale.id.substring(0, 6).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del modal - más compacto y deslizable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica - más compacta
                  _buildCompactSection(context, 'Información General', [
                    _buildCompactRow(context, 'Fecha', _formatDateTime(sale.saleDate)),
                    _buildCompactRow(context, 'Estado', sale.status.displayName, statusColor: _getStatusColor(sale.status)),
                    _buildCompactRow(context, 'Cliente', sale.customerName),
                  ]),

                  // Información del producto - más compacta
                  _buildCompactSection(context, 'Producto', [
                    _buildCompactRow(context, 'Nombre', product?.name ?? 'Producto no encontrado'),
                    _buildCompactRow(context, 'Categoría', product?.category ?? 'N/A'),
                    _buildCompactRow(context, 'Cantidad', '${sale.quantity} ${sale.quantity == 1 ? 'unidad' : 'unidades'}'),
                  ]),

                  // Información financiera - más compacta
                  _buildCompactSection(context, 'Financiera', [
                    _buildCompactRow(context, 'Precio Unit.', '\$${sale.unitPrice.toStringAsFixed(2)}'),
                    _buildCompactRow(context, 'Total', '\$${sale.totalAmount.toStringAsFixed(2)}', isHighlighted: true),
                    _buildCompactRow(context, 'Ganancia', '\$${sale.profit.toStringAsFixed(2)}', profitColor: Colors.green),
                    if (sale.debt != null && sale.debt! > 0)
                      _buildCompactRow(context, 'Deuda', '\$${sale.debt!.toStringAsFixed(2)}', statusColor: Colors.orange),
                  ]),

                  // Método de pago - más compacto
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Método de Pago',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPaymentMethodColor(sale.paymentMethod).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getPaymentMethodColor(sale.paymentMethod).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            sale.paymentMethod.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _getPaymentMethodColor(sale.paymentMethod),
                            ),
                          ),
                        ),
                        if (sale.paymentMethod == PaymentMethod.debt) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Genera deuda por cobrar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Notas (si existen) - más compactas
                  if (sale.notes.isNotEmpty) ...[
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                            ),
                            child: Text(
                              sale.notes,
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Información del sistema - más compacta
                  _buildCompactSection(context, 'Sistema', [
                    _buildCompactRow(context, 'Creado por', createdByName ?? sale.createdBy),
                    _buildCompactRow(context, 'Creado', _formatDateTime(sale.createdAt)),
                    _buildCompactRow(context, 'Actualizado', _formatDateTime(sale.updatedAt)),
                  ]),

                  const SizedBox(height: 12),

                  // Botón de cerrar - más compacto
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Cerrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCompactRow(BuildContext context, String label, String value, {
    Color? statusColor,
    Color? profitColor,
    bool isHighlighted = false
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHighlighted
                  ? (isDark ? Colors.blue[900] : Colors.blue[50])
                  : isDark
                    ? Colors.grey[800]
                    : (statusColor != null
                      ? statusColor.withValues(alpha: 0.1)
                      : Colors.grey[100]),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isHighlighted
                    ? Colors.blue[isDark ? 700 : 200]!
                    : isDark
                      ? Colors.grey[600]!
                      : (statusColor != null
                        ? statusColor.withValues(alpha: 0.3)
                        : Colors.grey[300]!),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  color: statusColor ?? profitColor ?? (isDark ? Colors.grey[200] : Colors.grey[800]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final saleDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (saleDate == today) {
      return 'Hoy, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
    }
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.completed:
        return Colors.green;
      case SaleStatus.pending:
        return Colors.orange;
      case SaleStatus.cancelled:
        return Colors.red;
      case SaleStatus.refunded:
        return Colors.blue;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod paymentMethod) {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.transfer:
        return Colors.purple;
      case PaymentMethod.debt:
        return Colors.orange;
      case PaymentMethod.check:
        return Colors.teal;
      case PaymentMethod.digitalWallet:
        return Colors.indigo;
    }
  }
}