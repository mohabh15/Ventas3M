import 'package:intl/intl.dart';

class FormattingService {
  static const String _locale = 'es_ES';

  // Formateo de números y moneda
  static String formatCurrency(double amount, {String symbol = '€'}) {
    final formatter = NumberFormat.currency(
      locale: _locale,
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatNumber(double number, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern(_locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(number);
  }

  // Formateo de fechas
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', _locale);
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', _locale);
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm', _locale);
    return formatter.format(dateTime);
  }

  static String formatDateLong(DateTime date) {
    final formatter = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', _locale);
    return formatter.format(date);
  }

  // Formateo relativo (hace X días, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) {
          return 'Hace un momento';
        }
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semanas';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months meses';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years años';
    }
  }

  // Validaciones y parsing
  static double? parseCurrency(String value) {
    try {
      // Remover símbolo de moneda y espacios
      String cleanValue = value.replaceAll('€', '').replaceAll(' ', '').trim();
      return double.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDate(String dateString) {
    try {
      final formatter = DateFormat('dd/MM/yyyy', _locale);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Formateo específico para gastos
  static String formatExpenseAmount(double amount) {
    return formatCurrency(amount);
  }

  static String formatExpenseDate(DateTime date) {
    return formatDate(date);
  }

  static String formatExpenseDateTime(DateTime dateTime) {
    return formatDateTime(dateTime);
  }
}