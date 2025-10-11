import 'package:flutter/material.dart';
import '../../models/product.dart';

class EditStockModal extends StatefulWidget {
  final ProductStock stock;

  const EditStockModal({
    super.key,
    required this.stock,
  });

  @override
  State<EditStockModal> createState() => _EditStockModalState();
}

class _EditStockModalState extends State<EditStockModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _responsibleController;
  late final TextEditingController _providerController;
  late final TextEditingController _priceController;
  late DateTime _selectedDate;

  // Datos de ejemplo para responsables y proveedores
  final List<String> _responsibles = [
    'Ana García',
    'Carlos López',
    'María Rodríguez',
    'José Martín',
    'Laura Sánchez',
    'David González',
  ];

  final List<String> _providers = [
    'TechSolutions S.A.',
    'ElectroImport',
    'GadgetsPro',
    'MobileTech',
    'AudioMax',
    'GameZone',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.stock.quantity.toString());
    _responsibleController = TextEditingController(text: widget.stock.responsibleId);
    _providerController = TextEditingController(text: widget.stock.providerId);
    _priceController = TextEditingController(text: widget.stock.price.toStringAsFixed(2));
    _selectedDate = widget.stock.purchaseDate;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _responsibleController.dispose();
    _providerController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editar Stock',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.stock.id.substring(0, 8).toUpperCase()}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cantidad
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    hintText: 'Ingrese la cantidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.inventory, color: theme.colorScheme.primary),
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
                      return 'Por favor ingrese la cantidad';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Cantidad inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Responsable
                DropdownButtonFormField<String>(
                  value: _responsibleController.text.isEmpty ? null : _responsibleController.text,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Responsable',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
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
                  items: _responsibles.map((String responsible) {
                    return DropdownMenuItem<String>(
                      value: responsible,
                      child: Text(responsible),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _responsibleController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un responsable';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Proveedor
                DropdownButtonFormField<String>(
                  value: _providerController.text.isEmpty ? null : _providerController.text,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Proveedor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.business, color: theme.colorScheme.primary),
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
                  items: _providers.map((String provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _providerController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un proveedor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Precio
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Precio de Compra',
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
                      return 'Por favor ingrese el precio';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Precio inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fecha de compra
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Compra',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate.year}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: _handleUpdateStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Actualizar Stock',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleUpdateStock() {
    if (_formKey.currentState!.validate()) {
      final updatedStock = widget.stock.copyWith(
        quantity: int.parse(_quantityController.text),
        responsibleId: _responsibleController.text,
        providerId: _providerController.text,
        price: double.parse(_priceController.text),
        purchaseDate: _selectedDate,
        updatedAt: DateTime.now(),
      );
      Navigator.of(context).pop(updatedStock);
    }
  }
}