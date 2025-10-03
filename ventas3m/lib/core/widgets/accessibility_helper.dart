import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../models/sale.dart';

/// Utilidades para mejorar la accesibilidad en la aplicación
class AccessibilityHelper {
  /// Configura atajos de teclado globales para accesibilidad
  static Map<LogicalKeySet, Intent> getGlobalAccessibilityShortcuts() {
    return {
      // Ctrl/Cmd + K: Enfocar barra de búsqueda
      LogicalKeySet(Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
          const _FocusSearchIntent(),

      // Ctrl/Cmd + H: Mostrar ayuda de accesibilidad
      LogicalKeySet(Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
          const _ShowAccessibilityHelpIntent(),

      // Escape: Cerrar modales y diálogos
      LogicalKeySet(LogicalKeyboardKey.escape):
          const _CloseModalIntent(),

      // Ctrl/Cmd + +: Aumentar tamaño de texto
      LogicalKeySet(Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control, LogicalKeyboardKey.equal):
          const _IncreaseTextSizeIntent(),

      // Ctrl/Cmd + -: Disminuir tamaño de texto
      LogicalKeySet(Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control, LogicalKeyboardKey.minus):
          const _DecreaseTextSizeIntent(),
    };
  }

  /// Genera descripción automática para productos
  static String generateProductDescription(Product product) {
    final buffer = StringBuffer();

    buffer.write(product.name);

    if (product.description.isNotEmpty) {
      buffer.write('. ${product.description}');
    }

    buffer.write('. Precio: ${product.price} pesos');

    if (product.originalPrice != null) {
      buffer.write('. Precio anterior: ${product.originalPrice} pesos');
    }

    if (product.rating > 0) {
      buffer.write('. Calificación: ${product.rating} estrellas');
      if (product.reviewCount > 0) {
        buffer.write(' con ${product.reviewCount} reseñas');
      }
    }

    buffer.write('. Estado: ');
    if (product.inStock) {
      buffer.write('Disponible');
      if (product.stockCount > 0) {
        buffer.write(', quedan ${product.stockCount} unidades');
      }
    } else {
      buffer.write('Agotado');
    }

    if (product.tags.isNotEmpty) {
      buffer.write('. Categorías: ${product.tags.join(', ')}');
    }

    return buffer.toString();
  }

  /// Genera descripción automática para elementos del carrito
  static String generateCartItemDescription(CartItem item) {
    final buffer = StringBuffer();

    buffer.write('${item.product.name}. ');
    buffer.write('Cantidad: ${item.quantity}. ');
    buffer.write('Precio unitario: ${item.unitPrice} pesos. ');

    if (item.hasDiscount) {
      buffer.write('Descuento aplicado: ${item.discount} pesos. ');
    }

    buffer.write('Subtotal: ${item.subtotal} pesos');

    if (item.notes != null && item.notes!.isNotEmpty) {
      buffer.write('. Nota: ${item.notes}');
    }

    return buffer.toString();
  }

  /// Genera descripción automática para ventas
  static String generateSaleDescription(Sale sale) {
    final buffer = StringBuffer();

    buffer.write('Venta número ${sale.invoiceNumber ?? sale.id}. ');
    buffer.write('Total: ${sale.total} pesos. ');
    buffer.write('Estado: ${sale.status.displayName}. ');
    buffer.write('Fecha: ${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}. ');

    if (sale.hasCustomer && sale.customer != null) {
      buffer.write('Cliente: ${sale.customer!.name}. ');
    }

    buffer.write('Método de pago: ${sale.paymentMethod.type.displayName}. ');
    buffer.write('Productos: ${sale.totalItems} artículos');

    if (sale.hasDiscount) {
      buffer.write('. Descuento aplicado: ${sale.discount} pesos');
    }

    return buffer.toString();
  }
}

/// Intenciones para acciones de accesibilidad
class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ShowAccessibilityHelpIntent extends Intent {
  const _ShowAccessibilityHelpIntent();
}

class _CloseModalIntent extends Intent {
  const _CloseModalIntent();
}

class _IncreaseTextSizeIntent extends Intent {
  const _IncreaseTextSizeIntent();
}

class _DecreaseTextSizeIntent extends Intent {
  const _DecreaseTextSizeIntent();
}

/// Widget para indicador visual de foco mejorado
class FocusIndicator extends StatelessWidget {
  final Widget child;
  final bool showAlways;
  final Color? focusColor;
  final double borderWidth;

  const FocusIndicator({
    super.key,
    required this.child,
    this.showAlways = false,
    this.focusColor,
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          FocusManager.instance.primaryFocus?.parent ?? ValueNotifier(null),
        ]),
        builder: (context, child) {
          final hasFocus = Focus.of(context).hasFocus;

          return Container(
            decoration: BoxDecoration(
              border: hasFocus || showAlways
                  ? Border.all(
                      color: focusColor ?? Theme.of(context).colorScheme.primary,
                      width: borderWidth,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

/// Widget para área de texto accesible
class AccessibleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;

  const AccessibleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Widget para botón accesible
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String label;
  final String? hint;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.label,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
    );
  }
}

/// Widget para mostrar ayuda de accesibilidad
class AccessibilityHelpDialog extends StatelessWidget {
  const AccessibilityHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ayuda de Accesibilidad'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpItem(
              'Ctrl/Cmd + K',
              'Enfocar barra de búsqueda',
            ),
            _buildHelpItem(
              'Tab',
              'Navegar entre elementos',
            ),
            _buildHelpItem(
              'Enter/Espacio',
              'Activar botones y elementos',
            ),
            _buildHelpItem(
              'Escape',
              'Cerrar modales y diálogos',
            ),
            _buildHelpItem(
              'Ctrl/Cmd + +',
              'Aumentar tamaño de texto',
            ),
            _buildHelpItem(
              'Ctrl/Cmd + -',
              'Disminuir tamaño de texto',
            ),
            const SizedBox(height: 16),
            const Text(
              'Características de accesibilidad:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Navegación completa por teclado'),
            _buildFeatureItem('Soporte para lectores de pantalla'),
            _buildFeatureItem('Indicadores de foco visibles'),
            _buildFeatureItem('Contrastes óptimos'),
            _buildFeatureItem('Descripciones semánticas'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildHelpItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }
}

/// Extensión para widgets con accesibilidad mejorada
extension AccessibilityExtensions on Widget {
  /// Agrega propiedades de accesibilidad básicas
  Widget withAccessibility({
    String? label,
    String? hint,
    String? value,
    bool? enabled,
    bool? selected,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      enabled: enabled ?? true,
      selected: selected,
      child: this,
    );
  }

  /// Marca el widget como botón accesible
  Widget asAccessibleButton({
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      child: this,
    );
  }

  /// Marca el widget como área de texto accesible
  Widget asAccessibleTextField({
    required String label,
    String? hint,
    String? value,
    bool enabled = true,
  }) {
    return Semantics(
      textField: true,
      enabled: enabled,
      label: label,
      hint: hint,
      value: value,
      child: this,
    );
  }
}