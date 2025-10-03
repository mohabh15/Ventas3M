import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/modern_forms.dart';
import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controladores de animación para efectos de entrada
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Iniciar animaciones después de un breve retraso
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(_emailController.text, _passwordController.text);

    if (!success && mounted) {
      _showErrorSnackbar(authProvider.errorMessage ?? 'Error al iniciar sesión');
    }
  }

  Future<void> _handleGuestLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginAsGuest();
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();

    if (!success && mounted) {
      _showErrorSnackbar(authProvider.errorMessage ?? 'Error al iniciar sesión con Google');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.textOnPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.02),

                      // Logo moderno centrado
                      _buildLogoSection(),

                      SizedBox(height: size.height * 0.06),

                      // Campos de formulario modernos
                      _buildEmailField(),

                      const SizedBox(height: 16),

                      _buildPasswordField(),

                      const SizedBox(height: 8),

                      // Navegación moderna
                      _buildForgotPasswordLink(),

                      const SizedBox(height: 32),

                      // Botones modernos
                      _buildLoginButton(),

                      const SizedBox(height: 16),

                      _buildGoogleButton(),

                      const SizedBox(height: 24),

                      // Separador moderno
                      _buildSeparator(),

                      const SizedBox(height: 24),

                      _buildGuestButton(),

                      const SizedBox(height: 16),

                      _buildRegisterButton(),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          // Logo con sombra moderna
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.store_rounded,
              size: 48,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ventas 3M',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema de Gestión de Ventas',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Correo electrónico',
      hint: 'Ingresa tu correo electrónico',
      leadingIcon: Icon(Icons.email_outlined, color: AppColors.primary),
      type: AppTextFieldType.email,
      controller: _emailController,
      borderRadius: 16,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu correo electrónico';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingresa un correo electrónico válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Contraseña',
      hint: 'Ingresa tu contraseña',
      leadingIcon: Icon(Icons.lock_outlined, color: AppColors.primary),
      type: AppTextFieldType.password,
      controller: _passwordController,
      borderRadius: 16,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AppButton(
          text: 'Iniciar Sesión',
          onPressed: authProvider.isLoading ? null : _handleLogin,
          variant: AppButtonVariant.gradient,
          size: AppButtonSize.large,
          isLoading: authProvider.isLoading,
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AppButton(
          text: 'Continuar con Google',
          onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.large,
          leadingIcon: Icon(Icons.g_mobiledata_rounded, color: AppColors.primary),
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border.withValues(alpha: 0),
                  AppColors.border.withValues(alpha: 0.5),
                  AppColors.border.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border.withValues(alpha: 0),
                  AppColors.border.withValues(alpha: 0.5),
                  AppColors.border.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AppButton(
          text: 'Entrar como Invitado',
          onPressed: authProvider.isLoading ? null : _handleGuestLogin,
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.large,
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return AppButton(
      text: 'Crear Cuenta',
      onPressed: _navigateToRegister,
      variant: AppButtonVariant.outline,
      size: AppButtonSize.large,
      width: double.infinity,
    );
  }
}