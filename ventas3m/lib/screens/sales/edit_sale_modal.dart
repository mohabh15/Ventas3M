import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/payment_method.dart';
import '../../models/sale.dart';
import '../../providers/products_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sales_provider.dart';
import '../../services/product_stock_service.dart';
import '../../services/sale_validation_service.dart';

class EditSaleModal extends StatefulWidget {
  final Sale sale;

  const EditSaleModal({super.key, required this.sale});

  @override
  State<EditSaleModal> createState() => _EditSaleModalState();
}

class _EditSaleModalState extends State<EditSaleModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  ProductStock? _selectedStock;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double _unitPrice = 0.0;
  double _totalAmount = 0.0;
  double _profit = 0.0;
  bool _isCalculating = false;
  String? _stockError;
  List<ProductStock> _availableStocks = [];

  final ProductStockService _stockService = ProductStockService();
  final SaleValidationService _validationService = SaleValidationService();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);

    // Inicializar valores con la venta existente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeValues();
      }
    });
  }

  void _initializeValues() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    // Buscar el producto de la venta
    _selectedProduct = productsProvider.products.firstWhere(
      (product) => product.id == widget.sale.productId,
      orElse: () => Product(
        id: widget.sale.productId,
        name: 'Producto no encontrado',
        description: '',
        basePrice: 0,
        category: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        projectId: '',
      ),
    );

    // Inicializar controladores con valores existentes
    _quantityController.text = widget.sale.quantity.toString();
    _unitPriceController.text = widget.sale.unitPrice.toStringAsFixed(2);
    _customerController.text = widget.sale.customerName;
    _notesController.text = widget.sale.notes;
    _selectedPaymentMethod = widget.sale.paymentMethod;
    _unitPrice = widget.sale.unitPrice;
    _totalAmount = widget.sale.totalAmount;
    _profit = widget.sale.profit;

    // Cargar stocks disponibles para el producto
    _loadAvailableStocks();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final unitPrice = double.tryParse(_unitPriceController.text) ?? _selectedProduct!.basePrice;
      setState(() {
        _unitPrice = unitPrice;
        _totalAmount = _unitPrice * quantity;
        _profit = _calculateProfit(_unitPrice, quantity);
      });
    }
  }

  double _calculateProfit(double unitPrice, int quantity) {
    // Calcular ganancia basada en el precio base del producto (precio de compra)
    return (unitPrice - (_selectedProduct?.basePrice ?? 0)) * quantity;
  }

  Future<void> _loadAvailableStocks() async {
    if (_selectedProduct == null) return;

    setState(() {
      _isCalculating = true;
      _availableStocks = [];
      _selectedStock = null;
      _stockError = null;
    });

    try {
      final stocks = await _stockService.getStockByProduct(_selectedProduct!.id);
      final availableStocks = stocks.where((stock) => stock.quantity > 0).toList();

      setState(() {
        _availableStocks = availableStocks;
        // Intentar seleccionar el stock original si aún está disponible
        if (widget.sale.stockId != null) {
          try {
            _selectedStock = availableStocks.firstWhere(
              (stock) => stock.id == widget.sale.stockId,
            );
          } catch (e) {
            // Si no se encuentra, seleccionar el primero disponible
            if (availableStocks.isNotEmpty) {
              _selectedStock = availableStocks.first;
            }
          }
        } else if (availableStocks.isNotEmpty) {
          _selectedStock = availableStocks.first;
        }
      });
    } catch (e) {
      setState(() {
        _stockError = 'Error al cargar stocks: $e';
      });
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  Future<void> _validateStock() async {
    if (_selectedProduct == null || _selectedStock == null || _quantityController.text.isEmpty) return;

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;

    setState(() {
      _isCalculating = true;
      _stockError = null;
    });

    try {
      // Para edición, considerar el stock ya usado en la venta original
      final originalQuantity = widget.sale.quantity;
      final additionalQuantity = quantity - originalQuantity;

      if (additionalQuantity > 0 && quantity > _selectedStock!.quantity) {
        setState(() {
          _stockError = 'Stock insuficiente en el lote seleccionado. Disponible: ${_selectedStock!.quantity}';
        });
      }
    } catch (e) {
      setState(() {
        _stockError = 'Error al validar stock: $e';
      });
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Editar Venta',
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

                // Selector de Producto (solo lectura para edición)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producto',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              _selectedProduct?.name ?? 'Cargando...',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Stock específico
                if (_availableStocks.isNotEmpty) ...[
                  DropdownButtonFormField<ProductStock>(
                    initialValue: _selectedStock,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Stock',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.inventory, color: theme.colorScheme.primary),
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    items: _availableStocks.map((stock) {
                      return DropdownMenuItem(
                        value: stock,
                        child: Text(
                          'Cant: ${stock.quantity} - Resp: ${stock.responsibleId.length > 8 ? '${stock.responsibleId.substring(0, 8)}...' : stock.responsibleId} - \$${stock.price.toStringAsFixed(2)}',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (stock) {
                      setState(() {
                        _selectedStock = stock;
                        _stockError = null;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione un stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Cantidad y Precio Unitario
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.format_list_numbered, color: theme.colorScheme.primary),
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Cantidad inválida';
                          }
                          if (_stockError != null) {
                            return _stockError;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _calculateTotal();
                          if (value.isNotEmpty == true && _selectedStock != null) {
                            _validateStock();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitPriceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Precio de Venta',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _calculateTotal();
                        },
                      ),
                    ),
                  ],
                ),

                if (_stockError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: isDark ? 0.9 : 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _stockError!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Método de Pago
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Método de Pago',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.payment, color: theme.colorScheme.primary),
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  items: PaymentMethod.values.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(
                        method.displayName,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (method) {
                    if (method != null) {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Cliente
                TextFormField(
                  controller: _customerController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    hintText: 'Nombre del cliente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre del cliente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notas
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Notas/Observaciones',
                    hintText: 'Información adicional de la venta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.note, color: theme.colorScheme.primary),
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Resumen de Totales
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '\$${_totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ganancia:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '\$${_profit.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _profit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de Acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    Consumer4<ProductsProvider, SettingsProvider, AuthProvider, SalesProvider>(
                      builder: (context, productsProvider, settingsProvider, authProvider, salesProvider, child) {
                        return ElevatedButton.icon(
                          onPressed: _isCalculating ? null : () => _submitForm(salesProvider),
                          icon: _isCalculating
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.white : theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save),
                          label: const Text('Actualizar Venta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: isDark ? 3 : 4,
                            shadowColor: isDark ? Colors.black26 : theme.shadowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _adjustStockForSaleUpdate(Sale originalSale, Sale updatedSale) async {
    // Si no hay stockId en la venta original, no hay nada que ajustar
    if (originalSale.stockId == null) return;

    final stockService = ProductStockService();

    // Caso 1: El stock cambió
    if (originalSale.stockId != updatedSale.stockId) {
      // Devolver la cantidad al stock original
      if (originalSale.stockId != null) {
        await stockService.increaseStockQuantity(originalSale.stockId!, originalSale.quantity);
      }
      // Reducir del nuevo stock
      if (updatedSale.stockId != null) {
        await stockService.reduceStockQuantity(updatedSale.stockId!, updatedSale.quantity);
      }
    }
    // Caso 2: Solo cambió la cantidad en el mismo stock
    else if (originalSale.stockId == updatedSale.stockId && originalSale.quantity != updatedSale.quantity) {
      final quantityDifference = updatedSale.quantity - originalSale.quantity;
      if (quantityDifference > 0) {
        // Aumentó la cantidad, reducir más del stock
        await stockService.reduceStockQuantity(updatedSale.stockId!, quantityDifference);
      } else if (quantityDifference < 0) {
        // Disminuyó la cantidad, devolver al stock
        await stockService.increaseStockQuantity(updatedSale.stockId!, quantityDifference.abs());
      }
    }
  }

  void _submitForm(SalesProvider salesProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) return;

    final quantity = int.parse(_quantityController.text);

    // Validar stock si hay cambios
    if (_selectedStock != null) {
      final originalQuantity = widget.sale.quantity;
      final additionalQuantity = quantity - originalQuantity;

      if (additionalQuantity > 0 && quantity > _selectedStock!.quantity) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock insuficiente en el lote seleccionado. Disponible: ${_selectedStock!.quantity}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
    }

    // Crear venta actualizada
    final updatedSale = widget.sale.copyWith(
      unitPrice: _unitPrice,
      customerName: _customerController.text,
      quantity: quantity,
      totalAmount: _totalAmount,
      profit: _profit,
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text,
      stockId: _selectedStock?.id,
      updatedAt: DateTime.now(),
    );

    // Validar venta antes de guardar
    final validationResult = _validationService.validateSale(updatedSale);
    if (!validationResult.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errores de validación:\n${validationResult.errors.map((e) => e.message).join('\n')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    try {
      // Ajustar stock basado en los cambios
      await _adjustStockForSaleUpdate(widget.sale, updatedSale);

      final success = await salesProvider.updateSale(updatedSale);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop({
            'success': true,
            'sale': updatedSale,
            'message': 'Venta actualizada exitosamente',
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar venta: ${salesProvider.error ?? 'Error desconocido'}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar venta: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}