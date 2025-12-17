import 'package:intl/intl.dart';

/// Utilitários para formatação de datas
class DateFormatter {
  /// Formata data e hora no formato brasileiro: DD/MM/YY • HH:MM
  static String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yy', 'pt_BR');
    final timeFormat = DateFormat('HH:mm', 'pt_BR');
    return '${dateFormat.format(dateTime)} • ${timeFormat.format(dateTime)}';
  }

  /// Formata apenas a data no formato brasileiro: DD/MM/YY
  static String formatDate(DateTime date) {
    final dateFormat = DateFormat('dd/MM/yy', 'pt_BR');
    return dateFormat.format(date);
  }

  /// Formata apenas a hora: HH:MM
  static String formatTime(DateTime dateTime) {
    final timeFormat = DateFormat('HH:mm', 'pt_BR');
    return timeFormat.format(dateTime);
  }

  /// Formata data completa: DD de MMMM de YYYY
  static String formatFullDate(DateTime date) {
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
    return dateFormat.format(date);
  }
}





