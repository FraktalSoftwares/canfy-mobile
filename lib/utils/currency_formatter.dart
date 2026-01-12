import 'package:intl/intl.dart';

/// Utilitários para formatação de moeda
class CurrencyFormatter {
  /// Formata valor em Real brasileiro: R$ 1.234,56
  static String formatBRL(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Formata valor sem símbolo: 1.234,56
  static String formatWithoutSymbol(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value).trim();
  }
}






