import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/utils/responsive_utils.dart';
import '../settings/settings_screen.dart';
import '../sales/sales_screen.dart';
import '../products/products_screen.dart';
import '../management/management_screen.dart';

// Modelos de datos para métricas de ventas
class SalesMetrics {
  final double totalVentas;
  final double ventasHoy;
  final double ventasSemana;
  final double ventasMes;
  final int totalProductos;
  final int productosActivos;
  final double promedioVenta;
  final double tendencia;

  const SalesMetrics({
    required this.totalVentas,
    required this.ventasHoy,
    required this.ventasSemana,
    required this.ventasMes,
    required this.totalProductos,
    required this.productosActivos,
    required this.promedioVenta,
    required this.tendencia,
  });
}

class TopProduct {
  final String nombre;
  final String imagen;
  final double ventas;
  final int cantidad;
  final double crecimiento;

  const TopProduct({
    required this.nombre,
    required this.imagen,
    required this.ventas,
    required this.cantidad,
    required this.crecimiento,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isRefreshing = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Datos simulados - en producción vendrían de un servicio
  late SalesMetrics _metrics;
  late List<TopProduct> _topProducts;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  @override
  void dispose() {
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
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));

    // Datos simulados
    _metrics = const SalesMetrics(
      totalVentas: 125750.50,
      ventasHoy: 8750.25,
      ventasSemana: 45250.75,
      ventasMes: 125750.50,
      totalProductos: 156,
      productosActivos: 142,
      promedioVenta: 285.50,
      tendencia: 12.5,
    );

    _topProducts = [
      const TopProduct(
        nombre: 'Producto Premium A',
        imagen: 'https://via.placeholder.com/60',
        ventas: 15420.50,
        cantidad: 45,
        crecimiento: 18.5,
      ),
      const TopProduct(
        nombre: 'Producto Estándar B',
        imagen: 'https://via.placeholder.com/60',
        ventas: 12850.25,
        cantidad: 38,
        crecimiento: -3.2,
      ),
      const TopProduct(
        nombre: 'Producto Básico C',
        imagen: 'https://via.placeholder.com/60',
        ventas: 9650.75,
        cantidad: 52,
        crecimiento: 8.7,
      ),
    ];

    setState(() {
      _isLoading = false;
    });

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    await _loadDashboardData();

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildModernAppBar(theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppDarkGradients.backgroundGradient
              : AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            displacement: 80,
            edgeOffset: 20,
            child: _isLoading
                ? _buildLoadingState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderSection(),
                            const SizedBox(height: 24),
                            _buildMetricsGrid(),
                            const SizedBox(height: 24),
                            _buildSalesChartSection(),
                            const SizedBox(height: 24),
                            _buildTopProductsSection(),
                            const SizedBox(height: 24),
                            _buildQuickActionsSection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Dashboard de Ventas',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark
              ? AppDarkGradients.primaryGradient
              : AppGradients.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      actions: [
        _buildNotificationButton(),
        const SizedBox(width: 8),
        _buildProfileButton(),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          // Acción para notificaciones
        },
        icon: const Icon(Icons.notifications_outlined),
        tooltip: 'Ver notificaciones - Actualmente tienes 3 notificaciones nuevas',
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        icon: const Icon(Icons.settings_outlined),
        tooltip: 'Configuración',
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido de vuelta!',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).vertical / 4),
                  Text(
                    'Aquí está el resumen de tu negocio',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, isMobile ? 20 : 24),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile || isTablet) ...[
              SizedBox(width: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
                constraints: BoxConstraints(
                  minWidth: ResponsiveUtils.getResponsiveTouchTargetSize(context),
                  minHeight: ResponsiveUtils.getResponsiveTouchTargetSize(context),
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.salesGradient,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context, size: isMobile ? 20 : 24),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).vertical / 8),
                    Text(
                      '${_metrics.tendencia.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, isMobile ? 14 : 16),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (_isRefreshing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Actualizando datos...',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final crossAxisCount = ResponsiveLayoutManager.getGridCrossAxisCount(context, 'dashboard');
    final childAspectRatio = ResponsiveUtils.getResponsiveGridChildAspectRatio(context);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2,
      mainAxisSpacing: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MetricCard(
          title: 'Ventas del Día',
          value: '\$${_metrics.ventasHoy.toStringAsFixed(2)}',
          subtitle: 'Ventas registradas hoy',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.salesGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.today,
              color: Colors.white,
              size: 20,
            ),
          ),
          valueColor: AppColors.sales,
          showTrend: true,
          trendValue: 8.5,
          onTap: () => _navigateToSales(),
        ),
        MetricCard(
          title: 'Ventas de la Semana',
          value: '\$${_metrics.ventasSemana.toStringAsFixed(2)}',
          subtitle: 'Esta semana',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.productsGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.date_range,
              color: Colors.white,
              size: 20,
            ),
          ),
          valueColor: AppColors.products,
          showTrend: true,
          trendValue: _metrics.tendencia,
          onTap: () => _navigateToSales(),
        ),
        MetricCard(
          title: 'Productos Activos',
          value: '${_metrics.productosActivos}',
          subtitle: 'de ${_metrics.totalProductos} totales',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.successGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 20,
            ),
          ),
          valueColor: AppColors.secondary,
          showTrend: true,
          trendValue: 5.2,
          onTap: () => _navigateToProducts(),
        ),
        MetricCard(
          title: 'Promedio por Venta',
          value: '\$${_metrics.promedioVenta.toStringAsFixed(2)}',
          subtitle: 'Por transacción',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.warningGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 20,
            ),
          ),
          valueColor: AppColors.tertiary,
          showTrend: true,
          trendValue: -2.1,
          onTap: () => _navigateToAnalytics(),
        ),
      ],
    );
  }

  Widget _buildSalesChartSection() {
    return AppCard(
      variant: AppCardVariant.gradient,
      gradient: AppGradients.salesGradient,
      elevation: AppCardElevation.level2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Gráfico de Ventas',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Últimos 30 días',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '📊 Gráfico de ventas\n(Integración pendiente con librería de gráficos)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _navigateToProducts(),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._topProducts.map((product) => _buildTopProductCard(product)),
      ],
    );
  }

  Widget _buildTopProductCard(TopProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        variant: AppCardVariant.filled,
        elevation: AppCardElevation.level1,
        padding: const EdgeInsets.all(16),
        child: Semantics(
          label: 'Producto ${product.nombre}, ventas de ${product.ventas.toStringAsFixed(2)} dólares con ${product.cantidad} unidades vendidas',
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(product.imagen),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.cantidad} unidades vendidas',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.ventas.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sales,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product.crecimiento >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: product.crecimiento >= 0
                            ? AppColors.secondary
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.crecimiento >= 0 ? '+' : ''}${product.crecimiento.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.crecimiento >= 0
                              ? AppColors.secondary
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).vertical),
        if (isMobile)
          Column(
            children: [
              _buildQuickActionCard(
                'Nueva Venta',
                Icons.point_of_sale,
                AppColors.sales,
                () => _navigateToSales(),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
              _buildQuickActionCard(
                'Productos',
                Icons.inventory_2,
                AppColors.products,
                () => _navigateToProducts(),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
              _buildQuickActionCard(
                'Gestión',
                Icons.business,
                AppColors.tertiary,
                () => _navigateToManagement(),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Nueva Venta',
                  Icons.point_of_sale,
                  AppColors.sales,
                  () => _navigateToSales(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
              Expanded(
                child: _buildQuickActionCard(
                  'Productos',
                  Icons.inventory_2,
                  AppColors.products,
                  () => _navigateToProducts(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
              Expanded(
                child: _buildQuickActionCard(
                  'Gestión',
                  Icons.business,
                  AppColors.tertiary,
                  () => _navigateToManagement(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return AppCard(
      variant: AppCardVariant.gradient,
      gradient: LinearGradient(
        colors: [color, color.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      elevation: AppCardElevation.level1,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveContentPadding(context).horizontal / 2),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Semantics(
        label: 'Acción rápida: $title',
        button: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, size: isMobile ? 28 : 32),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveContentPadding(context).vertical / 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, isMobile ? 12 : 14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToSales(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Venta',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header skeleton
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        // Metrics grid skeleton
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ),
        const SizedBox(height: 24),
        // Chart skeleton
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        // Products skeleton
        ...List.generate(3, (index) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        )),
      ],
    );
  }

  void _navigateToSales() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SalesScreen()),
    );
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductsScreen()),
    );
  }

  void _navigateToManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManagementScreen()),
    );
  }

  void _navigateToAnalytics() {
    // Navegación a pantalla de análisis
  }
}