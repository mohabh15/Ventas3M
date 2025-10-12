import 'package:go_router/go_router.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/add_edit_expense_modal.dart';
import '../screens/banking/team_balance_screen.dart';
import '../screens/debt/debt_management_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../widgets/auth_wrapper.dart';
import '../models/expense.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String sales = '/sales';
  static const String products = '/products';
  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String teamBalance = '/team-balance';
  static const String debtManagement = '/debt-management';
  static const String calendar = '/calendar';

  static GoRouter get router => GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AuthWrapper(),
          ),
          GoRoute(
            path: login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: register,
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => ProfileScreen(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: sales,
            builder: (context, state) => const SalesScreen(),
          ),
          GoRoute(
            path: products,
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: expenses,
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: addExpense,
            builder: (context, state) => const AddEditExpenseModal(),
          ),
          GoRoute(
            path: editExpense,
            builder: (context, state) => AddEditExpenseModal(
              expense: state.extra as Expense?,
            ),
          ),
          GoRoute(
            path: teamBalance,
            builder: (context, state) => const TeamBalanceScreen(),
          ),
          GoRoute(
            path: debtManagement,
            builder: (context, state) => const DebtManagementScreen(),
          ),
          GoRoute(
            path: calendar,
            builder: (context, state) => CalendarScreen(initialDate: state.extra as DateTime?),
          ),
        ],
      );
}