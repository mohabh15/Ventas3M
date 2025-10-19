import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class NotificationPermissionDialog extends StatefulWidget {
  const NotificationPermissionDialog({super.key});

  @override
  State<NotificationPermissionDialog> createState() => _NotificationPermissionDialogState();

  // Método estático para mostrar el diálogo
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }
}

class _NotificationPermissionDialogState extends State<NotificationPermissionDialog> {
  bool _isLoading = false;
  String _currentStatus = 'notDetermined';

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissionStatus();
  }

  Future<void> _checkCurrentPermissionStatus() async {
    try {
      final notificationService = NotificationService();
      final settings = await notificationService.getNotificationSettings();

      setState(() {
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          _currentStatus = 'granted';
        } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
          _currentStatus = 'denied';
        } else {
          _currentStatus = 'notDetermined';
        }
      });
    } catch (e) {
      setState(() {
        _currentStatus = 'notDetermined';
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = NotificationService();
      final settings = await notificationService.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (mounted) {
          Navigator.of(context).pop(true);
          _showSuccessMessage();
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop(false);
          _showDeniedMessage();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        _showErrorMessage();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Permisos de notificaciones habilitados!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permisos de notificaciones denegados. Puedes habilitarlos más tarde en Configuración.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Error al solicitar permisos de notificaciones.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).pop();
    // Aquí podrías navegar a la pantalla de configuración
    // o abrir la configuración del sistema
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Permisos de Notificaciones',
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

              // Icono principal
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título y explicación
              Text(
                'Mantente informado',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Recibe notificaciones importantes sobre tu negocio:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Lista de beneficios
              _buildBenefitItem(
                context,
                Icons.shopping_cart,
                'Nuevas ventas realizadas',
                'Sé el primero en saber cuando se registra una nueva venta',
              ),
              const SizedBox(height: 12),

              _buildBenefitItem(
                context,
                Icons.payment,
                'Pagos recibidos',
                'Notificaciones cuando recibas pagos de tus clientes',
              ),
              const SizedBox(height: 12),

              _buildBenefitItem(
                context,
                Icons.inventory,
                'Actualizaciones de inventario',
                'Alertas sobre productos con stock bajo',
              ),
              const SizedBox(height: 12),

              _buildBenefitItem(
                context,
                Icons.event,
                'Recordatorios importantes',
                'No te pierdas eventos, reuniones o fechas importantes',
              ),
              const SizedBox(height: 24),

              // Estado actual de permisos
              if (_currentStatus == 'denied') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: isDark ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: isDark ? 0.5 : 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Permisos denegados',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para habilitar las notificaciones, ve a Configuración > Aplicación > Permisos de notificaciones',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStatus != 'denied') ...[
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      child: const Text('Ahora no'),
                    ),
                    const SizedBox(width: 16),
                  ],

                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : (_currentStatus == 'denied' ? _openSettings : _requestPermission),
                    icon: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? Colors.white : theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(_currentStatus == 'denied' ? Icons.settings : Icons.notifications_active),
                    label: Text(_currentStatus == 'denied' ? 'Abrir Configuración' : 'Habilitar Notificaciones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: isDark ? 3 : 4,
                      shadowColor: isDark ? Colors.black26 : theme.shadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String description) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}