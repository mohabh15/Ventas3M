import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/modern_forms.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de perfil moderna completamente rediseñada
class ProfileScreen extends StatefulWidget {
 const ProfileScreen({super.key});

 @override
 State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
 // Controladores para formularios
 late TextEditingController _nameController;
 late TextEditingController _emailController;
 late TextEditingController _phoneController;
 late TextEditingController _currentPasswordController;
 late TextEditingController _newPasswordController;
 late TextEditingController _confirmPasswordController;

 // Estados de la interfaz
 bool _isChangingPassword = false;
 bool _isLoading = false;

 // Estados de edición de secciones
 bool _isEditingPersonalInfo = false;
 bool _isEditingContactInfo = false;

 // Animaciones
 late AnimationController _fadeController;
 late AnimationController _slideController;
 late AnimationController _scaleController;

 // Avatar
 File? _selectedAvatar;
 bool _isUploadingAvatar = false;

 // Configuración de notificaciones
 bool _emailNotifications = true;
 bool _pushNotifications = true;
 bool _smsNotifications = false;
 bool _marketingEmails = false;

 // Configuración de privacidad
 bool _profileVisible = true;
 bool _showActivityStatus = true;
 bool _allowDataCollection = false;

 @override
 void initState() {
   super.initState();
   _initializeControllers();
   _initializeAnimations();
   _loadUserData();
 }

 @override
 void dispose() {
   _disposeControllers();
   _disposeAnimations();
   super.dispose();
 }

 void _initializeControllers() {
   _nameController = TextEditingController();
   _emailController = TextEditingController();
   _phoneController = TextEditingController();
   _currentPasswordController = TextEditingController();
   _newPasswordController = TextEditingController();
   _confirmPasswordController = TextEditingController();
 }

 void _disposeControllers() {
   _nameController.dispose();
   _emailController.dispose();
   _phoneController.dispose();
   _currentPasswordController.dispose();
   _newPasswordController.dispose();
   _confirmPasswordController.dispose();
 }

 void _initializeAnimations() {
   _fadeController = AnimationController(
     duration: const Duration(milliseconds: 300),
     vsync: this,
   );

   _slideController = AnimationController(
     duration: const Duration(milliseconds: 400),
     vsync: this,
   );

   _scaleController = AnimationController(
     duration: const Duration(milliseconds: 200),
     vsync: this,
   );

   _fadeController.forward();
   _slideController.forward();
 }

 void _disposeAnimations() {
   _fadeController.dispose();
   _slideController.dispose();
   _scaleController.dispose();
 }

 void _loadUserData() {
   final authProvider = context.read<AuthProvider>();
   final user = authProvider.currentUser;

   if (user != null) {
     _nameController.text = user.name;
     _emailController.text = user.email;
     _phoneController.text = user.phone ?? '';
   }
 }

 Future<void> _pickAvatar() async {
   try {
     final picker = ImagePicker();
     final pickedFile = await picker.pickImage(
       source: ImageSource.gallery,
       maxWidth: 512,
       maxHeight: 512,
       imageQuality: 85,
     );

     if (pickedFile != null) {
       setState(() {
         _selectedAvatar = File(pickedFile.path);
       });

       // Aquí iría la lógica para subir la imagen
       await _uploadAvatar();
     }
   } catch (e) {
     _showErrorSnackBar('Error al seleccionar imagen: $e');
   }
 }

 Future<void> _uploadAvatar() async {
   if (_selectedAvatar == null) return;

   setState(() {
     _isUploadingAvatar = true;
   });

   try {
     // Simulación de subida
     await Future.delayed(const Duration(seconds: 2));

     // Aquí iría la lógica real de subida con Firebase Storage o similar
     _showSuccessSnackBar('Avatar actualizado correctamente');
   } catch (e) {
     _showErrorSnackBar('Error al subir avatar: $e');
   } finally {
     setState(() {
       _isUploadingAvatar = false;
     });
   }
 }

 Future<void> _saveProfileChanges() async {
   if (!_validateProfileForm()) return;

   setState(() {
     _isLoading = true;
   });

   try {
     final authProvider = context.read<AuthProvider>();
     final success = await authProvider.updateProfile(
       name: _nameController.text.trim(),
       phone: _phoneController.text.trim(),
     );

     if (success) {
       setState(() {
         _isEditingPersonalInfo = false;
       });
       _showSuccessSnackBar('Perfil actualizado correctamente');
     } else {
       _showErrorSnackBar('Error al actualizar perfil');
     }
   } catch (e) {
     _showErrorSnackBar('Error al actualizar perfil: $e');
   } finally {
     setState(() {
       _isLoading = false;
     });
   }
 }

 Future<void> _changePassword() async {
   if (!_validatePasswordForm()) return;

   setState(() {
     _isLoading = true;
   });

   try {
     // Aquí iría la lógica para cambiar contraseña
     await Future.delayed(const Duration(seconds: 1));

     setState(() {
       _isChangingPassword = false;
       _currentPasswordController.clear();
       _newPasswordController.clear();
       _confirmPasswordController.clear();
     });

     _showSuccessSnackBar('Contraseña cambiada correctamente');
   } catch (e) {
     _showErrorSnackBar('Error al cambiar contraseña: $e');
   } finally {
     setState(() {
       _isLoading = false;
     });
   }
 }

 bool _validateProfileForm() {
   if (_nameController.text.trim().isEmpty) {
     _showErrorSnackBar('El nombre es obligatorio');
     return false;
   }

   if (_phoneController.text.trim().isNotEmpty &&
       _phoneController.text.trim().length < 10) {
     _showErrorSnackBar('El teléfono debe tener al menos 10 dígitos');
     return false;
   }

   return true;
 }

 bool _validatePasswordForm() {
   if (_currentPasswordController.text.isEmpty) {
     _showErrorSnackBar('La contraseña actual es obligatoria');
     return false;
   }

   if (_newPasswordController.text.length < 8) {
     _showErrorSnackBar('La nueva contraseña debe tener al menos 8 caracteres');
     return false;
   }

   if (_newPasswordController.text != _confirmPasswordController.text) {
     _showErrorSnackBar('Las contraseñas no coinciden');
     return false;
   }

   return true;
 }


 void _showSuccessSnackBar(String message) {
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text(message),
       backgroundColor: AppColors.secondary,
       behavior: SnackBarBehavior.floating,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
     ),
   );
 }

 void _showErrorSnackBar(String message) {
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text(message),
       backgroundColor: AppColors.error,
       behavior: SnackBarBehavior.floating,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
     ),
   );
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: _buildAppBar(),
     body: _buildBody(),
     floatingActionButton: _buildFloatingActionButton(),
   );
 }

 PreferredSizeWidget _buildAppBar() {
   return AppBar(
     title: Text(
       'Perfil',
       style: TextStyle(
         fontFamily: 'Lufga',
         fontSize: 20,
         fontWeight: FontWeight.w600,
         color: AppColors.textPrimary,
       ),
     ),
     backgroundColor: AppColors.surface,
     elevation: 0,
     actions: [
       IconButton(
         onPressed: () => _showMoreOptions(),
         icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
         tooltip: 'Más opciones',
       ),
     ],
     systemOverlayStyle: SystemUiOverlayStyle.dark,
   );
 }

 Widget _buildBody() {
   return FadeTransition(
     opacity: _fadeController,
     child: SlideTransition(
       position: Tween<Offset>(
         begin: const Offset(0, 0.1),
         end: Offset.zero,
       ).animate(CurvedAnimation(
         parent: _slideController,
         curve: Curves.easeOut,
       )),
       child: RefreshIndicator(
         onRefresh: () async => _loadUserData(),
         child: SingleChildScrollView(
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _isLoading ? _buildProfileSkeleton() : _buildProfileHeader(),
               const SizedBox(height: 24),
               _isLoading ? _buildStatsSkeleton() : _buildQuickStats(),
               const SizedBox(height: 24),
               _buildPersonalInfoSection(),
               const SizedBox(height: 16),
               _buildContactInfoSection(),
               const SizedBox(height: 16),
               _buildAccountSettingsSection(),
               const SizedBox(height: 16),
               _buildSecuritySection(),
               const SizedBox(height: 16),
               _buildAdvancedSecuritySection(),
               const SizedBox(height: 16),
               _buildPrivacySection(),
               const SizedBox(height: 16),
               _buildNotificationSettingsSection(),
               const SizedBox(height: 16),
               _buildAppPreferencesSection(),
               const SizedBox(height: 16),
               _buildBillingSection(),
               const SizedBox(height: 16),
               _buildAdvancedSection(),
               const SizedBox(height: 32),
             ],
           ),
         ),
       ),
     ),
   );
 }

 Widget _buildProfileSkeleton() {
   return AppCard(
     variant: AppCardVariant.gradient,
     elevation: AppCardElevation.level2,
     borderRadius: 20,
     gradient: LinearGradient(
       colors: [
         AppColors.primary.withValues(alpha: 0.1),
         AppColors.secondary.withValues(alpha: 0.1),
       ],
       begin: Alignment.topLeft,
       end: Alignment.bottomRight,
     ),
     child: Padding(
       padding: const EdgeInsets.all(20),
       child: Column(
         children: [
           // Avatar skeleton
           Container(
             width: 100,
             height: 100,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: AppColors.surface,
             ),
           ),
           const SizedBox(height: 16),
           // Name skeleton
           Container(
             height: 24,
             width: 150,
             decoration: BoxDecoration(
               color: AppColors.surface,
               borderRadius: BorderRadius.circular(4),
             ),
           ),
           const SizedBox(height: 8),
           // Email skeleton
           Container(
             height: 16,
             width: 200,
             decoration: BoxDecoration(
               color: AppColors.surface,
               borderRadius: BorderRadius.circular(4),
             ),
           ),
           const SizedBox(height: 12),
           // Status skeleton
           Container(
             height: 24,
             width: 100,
             decoration: BoxDecoration(
               color: AppColors.surface,
               borderRadius: BorderRadius.circular(12),
             ),
           ),
           const SizedBox(height: 12),
           // Last login skeleton
           Container(
             height: 12,
             width: 180,
             decoration: BoxDecoration(
               color: AppColors.surface,
               borderRadius: BorderRadius.circular(4),
             ),
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildStatsSkeleton() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Title skeleton
       Container(
         height: 20,
         width: 100,
         decoration: BoxDecoration(
           color: AppColors.surface,
           borderRadius: BorderRadius.circular(4),
         ),
       ),
       const SizedBox(height: 12),
       // Stats cards skeleton
       Row(
         children: List.generate(3, (index) {
           return Expanded(
             child: Container(
               height: 80,
               margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
               decoration: BoxDecoration(
                 color: AppColors.cardBackground,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
               ),
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Icon and title row
                     Row(
                       children: [
                         Container(
                           width: 16,
                           height: 16,
                           decoration: BoxDecoration(
                             color: AppColors.surface,
                             borderRadius: BorderRadius.circular(2),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Container(
                           height: 12,
                           width: 60,
                           decoration: BoxDecoration(
                             color: AppColors.surface,
                             borderRadius: BorderRadius.circular(4),
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     // Value skeleton
                     Container(
                       height: 28,
                       width: 80,
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         borderRadius: BorderRadius.circular(4),
                       ),
                     ),
                     const SizedBox(height: 4),
                     // Subtitle skeleton
                     Container(
                       height: 12,
                       width: 100,
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         borderRadius: BorderRadius.circular(4),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           );
         }),
       ),
     ],
   );
 }


 Widget _buildProfileHeader() {
   return Consumer<AuthProvider>(
     builder: (context, authProvider, child) {
       final user = authProvider.currentUser;

       return AppCard(
         variant: AppCardVariant.gradient,
         elevation: AppCardElevation.level2,
         borderRadius: 20,
         gradient: LinearGradient(
           colors: [
             AppColors.primary.withValues(alpha: 0.1),
             AppColors.secondary.withValues(alpha: 0.1),
           ],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
         child: Padding(
           padding: const EdgeInsets.all(20),
           child: Column(
             children: [
               Stack(
                 children: [
                   Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(
                         color: AppColors.surface,
                         width: 4,
                       ),
                       boxShadow: [
                         BoxShadow(
                           color: AppColors.shadow.withValues(alpha: 0.2),
                           blurRadius: 12,
                           offset: const Offset(0, 4),
                         ),
                       ],
                     ),
                     child: CircleAvatar(
                       radius: 50,
                       backgroundColor: AppColors.surface,
                       backgroundImage: _selectedAvatar != null
                           ? FileImage(_selectedAvatar!)
                           : (user?.photoUrl != null
                               ? NetworkImage(user!.photoUrl!)
                               : null),
                       child: (_selectedAvatar == null && user?.photoUrl == null)
                           ? Icon(
                               Icons.person,
                               size: 50,
                               color: AppColors.textDisabled,
                             )
                           : null,
                     ),
                   ),
                   Positioned(
                     bottom: 0,
                     right: 0,
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         shape: BoxShape.circle,
                         border: Border.all(color: AppColors.border),
                       ),
                       child: InkWell(
                         onTap: _isUploadingAvatar ? null : _pickAvatar,
                         borderRadius: BorderRadius.circular(20),
                         child: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: AppColors.primary,
                             shape: BoxShape.circle,
                           ),
                           child: _isUploadingAvatar
                               ? const SizedBox(
                                   width: 16,
                                   height: 16,
                                   child: CircularProgressIndicator(
                                     strokeWidth: 2,
                                     valueColor: AlwaysStoppedAnimation<Color>(
                                       AppColors.textOnPrimary,
                                     ),
                                   ),
                                 )
                               : Icon(
                                   Icons.camera_alt,
                                   size: 16,
                                   color: AppColors.textOnPrimary,
                                 ),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               Text(
                 user?.name ?? 'Usuario',
                 style: TextStyle(
                   fontFamily: 'Lufga',
                   fontSize: 24,
                   fontWeight: FontWeight.w700,
                   color: AppColors.textPrimary,
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 user?.email ?? '',
                 style: TextStyle(
                   fontFamily: 'Lufga',
                   fontSize: 14,
                   fontWeight: FontWeight.w400,
                   color: AppColors.textSecondary,
                 ),
               ),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: (user?.isEmailVerified ?? false)
                       ? AppColors.secondary.withValues(alpha: 0.1)
                       : AppColors.tertiary.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: (user?.isEmailVerified ?? false)
                         ? AppColors.secondary.withValues(alpha: 0.3)
                         : AppColors.tertiary.withValues(alpha: 0.3),
                   ),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(
                       (user?.isEmailVerified ?? false)
                           ? Icons.verified
                           : Icons.pending,
                       size: 16,
                       color: (user?.isEmailVerified ?? false)
                           ? AppColors.secondary
                           : AppColors.tertiary,
                     ),
                     const SizedBox(width: 6),
                     Text(
                       (user?.isEmailVerified ?? false)
                           ? 'Verificado'
                           : 'Pendiente',
                       style: TextStyle(
                         fontFamily: 'Lufga',
                         fontSize: 12,
                         fontWeight: FontWeight.w600,
                         color: (user?.isEmailVerified ?? false)
                             ? AppColors.secondary
                             : AppColors.tertiary,
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 12),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     Icons.access_time,
                     size: 16,
                     color: AppColors.textDisabled,
                   ),
                   const SizedBox(width: 6),
                   Text(
                     'Último acceso: ${_formatLastLogin(user?.lastLoginAt)}',
                     style: TextStyle(
                       fontFamily: 'Lufga',
                       fontSize: 12,
                       fontWeight: FontWeight.w400,
                       color: AppColors.textDisabled,
                     ),
                   ),
                 ],
               ),
             ],
           ),
         ),
       );
     },
   );
 }

 Widget _buildQuickStats() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         'Estadísticas',
         style: TextStyle(
           fontFamily: 'Lufga',
           fontSize: 18,
           fontWeight: FontWeight.w600,
           color: AppColors.textPrimary,
         ),
       ),
       const SizedBox(height: 12),
       Row(
         children: [
           Expanded(
             child: MetricCard(
               title: 'Ventas',
               value: '156',
               subtitle: '+12% este mes',
               icon: Icon(Icons.point_of_sale, color: AppColors.primary),
               showTrend: true,
               trendValue: 12.5,
               onTap: () {},
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: MetricCard(
               title: 'Productos',
               value: '48',
               subtitle: 'En inventario',
               icon: Icon(Icons.inventory, color: AppColors.secondary),
               onTap: () {},
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: MetricCard(
               title: 'Clientes',
               value: '89',
               subtitle: '+5 nuevos',
               icon: Icon(Icons.people, color: AppColors.tertiary),
               showTrend: true,
               trendValue: 5.9,
               onTap: () {},
             ),
           ),
         ],
       ),
     ],
   );
 }

 Widget _buildPersonalInfoSection() {
   return _buildSectionCard(
     title: 'Información Personal',
     icon: Icons.person_outline,
     isEditing: _isEditingPersonalInfo,
     onEdit: () => setState(() => _isEditingPersonalInfo = !_isEditingPersonalInfo),
     onSave: _saveProfileChanges,
     isLoading: _isLoading,
     child: Column(
       children: [
         AppTextField(
           label: 'Nombre completo',
           controller: _nameController,
           enabled: _isEditingPersonalInfo,
           type: AppTextFieldType.text,
           leadingIcon: const Icon(Icons.person),
           validator: (value) {
             if (value?.isEmpty ?? true) return 'El nombre es obligatorio';
             return null;
           },
         ),
         const SizedBox(height: 16),
         AppTextField(
           label: 'Correo electrónico',
           controller: _emailController,
           enabled: false,
           type: AppTextFieldType.email,
           leadingIcon: const Icon(Icons.email),
           trailingIcon: Consumer<AuthProvider>(
             builder: (context, authProvider, child) {
               final user = authProvider.currentUser;
               return (user?.isEmailVerified ?? false)
                   ? Icon(Icons.verified, color: AppColors.secondary)
                   : IconButton(
                       onPressed: () {},
                       icon: Icon(Icons.send, color: AppColors.primary),
                       tooltip: 'Reenviar verificación',
                     );
             },
           ),
         ),
         const SizedBox(height: 16),
         AppTextField(
           label: 'Teléfono',
           controller: _phoneController,
           enabled: _isEditingPersonalInfo,
           type: AppTextFieldType.phone,
           leadingIcon: const Icon(Icons.phone),
           validator: (value) {
             if (value != null && value.isNotEmpty && value.length < 10) {
               return 'El teléfono debe tener al menos 10 dígitos';
             }
             return null;
           },
         ),
       ],
     ),
   );
 }

 Widget _buildAccountSettingsSection() {
   return _buildSectionCard(
     title: 'Configuración de Cuenta',
     icon: Icons.settings_outlined,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Idioma',
           subtitle: 'Español (España)',
           icon: Icons.language,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Región',
           subtitle: 'Europa/Madrid',
           icon: Icons.location_on,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Moneda',
           subtitle: 'EUR (€)',
           icon: Icons.euro,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Zona horaria',
           subtitle: 'UTC+2:00',
           icon: Icons.schedule,
           onTap: () {},
         ),
       ],
     ),
   );
 }

 Widget _buildSecuritySection() {
   return _buildSectionCard(
     title: 'Seguridad',
     icon: Icons.security,
     isEditing: _isChangingPassword,
     onEdit: () => setState(() => _isChangingPassword = !_isChangingPassword),
     onSave: _changePassword,
     isLoading: _isLoading,
     child: Column(
       children: [
         if (!_isChangingPassword) ...[
           _buildSettingsTile(
             title: 'Contraseña',
             subtitle: 'Última actualización: hace 30 días',
             icon: Icons.lock,
             onTap: () => setState(() => _isChangingPassword = true),
           ),
           _buildSettingsTile(
             title: 'Autenticación de dos factores',
             subtitle: 'No configurada',
             icon: Icons.shield,
             trailing: Switch(
               value: false,
               onChanged: (value) {},
               activeTrackColor: AppColors.primary,
             ),
           ),
           _buildSettingsTile(
             title: 'Sesiones activas',
             subtitle: '2 dispositivos',
             icon: Icons.devices,
             onTap: () {},
           ),
         ] else ...[
           AppTextField(
             label: 'Contraseña actual',
             controller: _currentPasswordController,
             type: AppTextFieldType.password,
             leadingIcon: const Icon(Icons.lock_outline),
           ),
           const SizedBox(height: 16),
           AppTextField(
             label: 'Nueva contraseña',
             controller: _newPasswordController,
             type: AppTextFieldType.password,
             leadingIcon: const Icon(Icons.lock),
             validator: (value) {
               if (value != null && value.length < 8) {
                 return 'Debe tener al menos 8 caracteres';
               }
               return null;
             },
           ),
           const SizedBox(height: 16),
           AppTextField(
             label: 'Confirmar contraseña',
             controller: _confirmPasswordController,
             type: AppTextFieldType.password,
             leadingIcon: const Icon(Icons.lock),
             validator: (value) {
               if (value != _newPasswordController.text) {
                 return 'Las contraseñas no coinciden';
               }
               return null;
             },
           ),
         ],
       ],
     ),
   );
 }

 Widget _buildPrivacySection() {
   return _buildSectionCard(
     title: 'Privacidad',
     icon: Icons.privacy_tip,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Perfil público',
           subtitle: 'Otros usuarios pueden ver tu perfil',
           icon: Icons.visibility,
           trailing: Switch(
             value: _profileVisible,
             onChanged: (value) => setState(() => _profileVisible = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'Estado de actividad',
           subtitle: 'Mostrar cuándo estuviste activo por última vez',
           icon: Icons.access_time,
           trailing: Switch(
             value: _showActivityStatus,
             onChanged: (value) => setState(() => _showActivityStatus = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'Recopilación de datos',
           subtitle: 'Ayúdanos a mejorar la aplicación',
           icon: Icons.analytics,
           trailing: Switch(
             value: _allowDataCollection,
             onChanged: (value) => setState(() => _allowDataCollection = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildNotificationSettingsSection() {
   return _buildSectionCard(
     title: 'Notificaciones',
     icon: Icons.notifications,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Notificaciones por email',
           subtitle: 'Recibir actualizaciones por correo',
           icon: Icons.email,
           trailing: Switch(
             value: _emailNotifications,
             onChanged: (value) => setState(() => _emailNotifications = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'Notificaciones push',
           subtitle: 'Recibir notificaciones en la aplicación',
           icon: Icons.notifications_active,
           trailing: Switch(
             value: _pushNotifications,
             onChanged: (value) => setState(() => _pushNotifications = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'SMS',
           subtitle: 'Notificaciones importantes por SMS',
           icon: Icons.sms,
           trailing: Switch(
             value: _smsNotifications,
             onChanged: (value) => setState(() => _smsNotifications = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'Emails de marketing',
           subtitle: 'Ofertas y promociones',
           icon: Icons.campaign,
           trailing: Switch(
             value: _marketingEmails,
             onChanged: (value) => setState(() => _marketingEmails = value),
             activeTrackColor: AppColors.primary,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildContactInfoSection() {
   return _buildSectionCard(
     title: 'Información de Contacto',
     icon: Icons.contact_mail,
     isEditing: _isEditingContactInfo,
     onEdit: () => setState(() => _isEditingContactInfo = !_isEditingContactInfo),
     onSave: () async {
       setState(() => _isLoading = true);
       await Future.delayed(const Duration(seconds: 1));
       setState(() {
         _isEditingContactInfo = false;
         _isLoading = false;
       });
       _showSuccessSnackBar('Información de contacto actualizada');
     },
     isLoading: _isLoading,
     child: Column(
       children: [
         AppTextField(
           label: 'Dirección',
           hint: 'Calle, número, piso...',
           enabled: _isEditingContactInfo,
           leadingIcon: const Icon(Icons.location_on),
         ),
         const SizedBox(height: 16),
         AppTextField(
           label: 'Ciudad',
           enabled: _isEditingContactInfo,
           leadingIcon: const Icon(Icons.location_city),
         ),
         const SizedBox(height: 16),
         AppTextField(
           label: 'Código postal',
           enabled: _isEditingContactInfo,
           type: AppTextFieldType.number,
           leadingIcon: const Icon(Icons.local_post_office),
         ),
         const SizedBox(height: 16),
         AppTextField(
           label: 'País',
           hint: 'España',
           enabled: _isEditingContactInfo,
           leadingIcon: const Icon(Icons.flag),
         ),
       ],
     ),
   );
 }

 Widget _buildAdvancedSecuritySection() {
   return _buildSectionCard(
     title: 'Seguridad Avanzada',
     icon: Icons.security,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Autenticación biométrica',
           subtitle: 'Huella dactilar / Reconocimiento facial',
           icon: Icons.fingerprint,
           trailing: Switch(
             value: true,
             onChanged: (value) {},
             activeTrackColor: AppColors.primary,
           ),
         ),
         _buildSettingsTile(
           title: 'Clave de recuperación',
           subtitle: 'Generar clave para recuperar cuenta',
           icon: Icons.key,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Dispositivos autorizados',
           subtitle: 'Gestionar dispositivos conectados',
           icon: Icons.devices,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Actividad reciente',
           subtitle: 'Últimas acciones en tu cuenta',
           icon: Icons.access_time,
           onTap: () {},
         ),
       ],
     ),
   );
 }

 Widget _buildAppPreferencesSection() {
   return _buildSectionCard(
     title: 'Preferencias de Aplicación',
     icon: Icons.settings_applications,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Tema',
           subtitle: 'Modo oscuro / Modo claro',
           icon: Icons.palette,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Idioma de la aplicación',
           subtitle: 'Español',
           icon: Icons.language,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Unidades de medida',
           subtitle: 'Métrico / Imperial',
           icon: Icons.straighten,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Formato de fecha',
           subtitle: 'DD/MM/YYYY',
           icon: Icons.calendar_today,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Configuración de accesibilidad',
           subtitle: 'Tamaño de texto, contraste, etc.',
           icon: Icons.accessibility,
           onTap: () {},
         ),
       ],
     ),
   );
 }

 Widget _buildBillingSection() {
   return _buildSectionCard(
     title: 'Datos de Facturación',
     icon: Icons.receipt_long,
     child: Column(
       children: [
         Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: AppColors.surface,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: AppColors.border),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Icon(Icons.info_outline, color: AppColors.textSecondary),
                   const SizedBox(width: 8),
                   Text(
                     'Información de facturación',
                     style: TextStyle(
                       fontFamily: 'Lufga',
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: AppColors.textPrimary,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 8),
               Text(
                 'Configura tus datos de facturación para generar recibos e informes automáticamente.',
                 style: TextStyle(
                   fontFamily: 'Lufga',
                   fontSize: 12,
                   fontWeight: FontWeight.w400,
                   color: AppColors.textSecondary,
                 ),
               ),
               const SizedBox(height: 16),
               AppButton(
                 text: 'Configurar datos de facturación',
                 variant: AppButtonVariant.outline,
                 size: AppButtonSize.medium,
                 onPressed: () {},
                 leadingIcon: const Icon(Icons.add),
               ),
             ],
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildAdvancedSection() {
   return _buildSectionCard(
     title: 'Avanzado',
     icon: Icons.tune,
     child: Column(
       children: [
         _buildSettingsTile(
           title: 'Exportar datos',
           subtitle: 'Descargar toda tu información personal',
           icon: Icons.download,
           onTap: () async {
             setState(() => _isLoading = true);
             await Future.delayed(const Duration(seconds: 2));
             setState(() => _isLoading = false);
             _showSuccessSnackBar('Datos exportados correctamente');
           },
         ),
         _buildSettingsTile(
           title: 'Backup automático',
           subtitle: 'Configurar copias de seguridad automáticas',
           icon: Icons.backup,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Historial de actividad',
           subtitle: 'Ver todas tus acciones recientes',
           icon: Icons.history,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Accesos directos',
           subtitle: 'Configurar atajos de teclado',
           icon: Icons.keyboard,
           onTap: () {},
         ),
         _buildSettingsTile(
           title: 'Sincronización automática',
           subtitle: 'Mantener datos sincronizados',
           icon: Icons.sync,
           trailing: Switch(
             value: true,
             onChanged: (value) {},
             activeTrackColor: AppColors.primary,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildSectionCard({
   required String title,
   required IconData icon,
   required Widget child,
   bool isEditing = false,
   VoidCallback? onEdit,
   VoidCallback? onSave,
   bool isLoading = false,
 }) {
   return AppCard(
     variant: AppCardVariant.filled,
     elevation: AppCardElevation.level1,
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           children: [
             Icon(icon, color: AppColors.primary),
             const SizedBox(width: 8),
             Text(
               title,
               style: TextStyle(
                 fontFamily: 'Lufga',
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: AppColors.textPrimary,
               ),
             ),
             const Spacer(),
             if (onEdit != null) ...[
               if (!isEditing) ...[
                 IconButton(
                   onPressed: onEdit,
                   icon: Icon(Icons.edit, color: AppColors.primary),
                   tooltip: 'Editar',
                 ),
               ] else ...[
                 if (isLoading) ...[
                   const SizedBox(
                     width: 20,
                     height: 20,
                     child: CircularProgressIndicator(
                       strokeWidth: 2,
                       valueColor: AlwaysStoppedAnimation<Color>(
                         AppColors.primary,
                       ),
                     ),
                   ),
                 ] else ...[
                   IconButton(
                     onPressed: onSave,
                     icon: Icon(Icons.check, color: AppColors.secondary),
                     tooltip: 'Guardar',
                   ),
                   IconButton(
                     onPressed: onEdit,
                     icon: Icon(Icons.close, color: AppColors.error),
                     tooltip: 'Cancelar',
                   ),
                 ],
               ],
             ],
           ],
         ),
         const SizedBox(height: 16),
         child,
       ],
     ),
   );
 }

 Widget _buildSettingsTile({
   required String title,
   required String subtitle,
   required IconData icon,
   Widget? trailing,
   VoidCallback? onTap,
 }) {
   return ListTile(
     contentPadding: EdgeInsets.zero,
     leading: Container(
       padding: const EdgeInsets.all(8),
       decoration: BoxDecoration(
         color: AppColors.primary.withValues(alpha: 0.1),
         borderRadius: BorderRadius.circular(8),
       ),
       child: Icon(icon, color: AppColors.primary, size: 20),
     ),
     title: Text(
       title,
       style: TextStyle(
         fontFamily: 'Lufga',
         fontSize: 14,
         fontWeight: FontWeight.w600,
         color: AppColors.textPrimary,
       ),
     ),
     subtitle: Text(
       subtitle,
       style: TextStyle(
         fontFamily: 'Lufga',
         fontSize: 12,
         fontWeight: FontWeight.w400,
         color: AppColors.textSecondary,
       ),
     ),
     trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDisabled) : null),
     onTap: onTap,
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   );
 }

 Widget _buildFloatingActionButton() {
   return ScaleTransition(
     scale: _scaleController,
     child: FloatingActionButton.extended(
       onPressed: () {},
       backgroundColor: AppColors.primary,
       foregroundColor: AppColors.textOnPrimary,
       icon: const Icon(Icons.help_outline),
       label: const Text('Ayuda'),
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
     ),
   );
 }

 void _showMoreOptions() {
   showModalBottomSheet(
     context: context,
     backgroundColor: AppColors.surface,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
     ),
     builder: (context) => Container(
       padding: const EdgeInsets.all(16),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(
             width: 40,
             height: 4,
             decoration: BoxDecoration(
               color: AppColors.border,
               borderRadius: BorderRadius.circular(2),
             ),
           ),
           const SizedBox(height: 16),
           _buildModalAction(
             icon: Icons.share,
             title: 'Compartir perfil',
             onTap: () {},
           ),
           _buildModalAction(
             icon: Icons.qr_code,
             title: 'Código QR',
             onTap: () {},
           ),
           _buildModalAction(
             icon: Icons.block,
             title: 'Bloquear usuarios',
             onTap: () {},
           ),
           _buildModalAction(
             icon: Icons.report,
             title: 'Reportar problema',
             onTap: () {},
           ),
           const SizedBox(height: 16),
         ],
       ),
     ),
   );
 }

 Widget _buildModalAction({
   required IconData icon,
   required String title,
   required VoidCallback onTap,
 }) {
   return InkWell(
     onTap: onTap,
     borderRadius: BorderRadius.circular(12),
     child: Padding(
       padding: const EdgeInsets.symmetric(vertical: 12),
       child: Row(
         children: [
           Icon(icon, color: AppColors.textSecondary),
           const SizedBox(width: 12),
           Text(
             title,
             style: TextStyle(
               fontFamily: 'Lufga',
               fontSize: 16,
               fontWeight: FontWeight.w500,
               color: AppColors.textPrimary,
             ),
           ),
         ],
       ),
     ),
   );
 }

 String _formatLastLogin(DateTime? date) {
   if (date == null) return 'Nunca';

   final now = DateTime.now();
   final difference = now.difference(date);

   if (difference.inDays == 0) {
     if (difference.inHours == 0) {
       return 'hace ${difference.inMinutes} minutos';
     }
     return 'hace ${difference.inHours} horas';
   } else if (difference.inDays == 1) {
     return 'ayer';
   } else if (difference.inDays < 7) {
     return 'hace ${difference.inDays} días';
   } else {
     return 'hace ${difference.inDays ~/ 7} semanas';
   }
 }
}