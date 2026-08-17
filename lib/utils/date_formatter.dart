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

  /// Faz o parse de um timestamp de consulta (ex.: data_consulta, vindo do
  /// Postgres como timestamptz/UTC) e converte para o horário local do
  /// dispositivo. Usar sempre este helper para exibir data/hora de consulta
  /// — parsear sem `.toLocal()` mostra o horário UTC (ex.: +3h em
  /// America/Sao_Paulo), que foi a causa do bug de horário incorreto.
  static DateTime? parseConsulta(dynamic raw) {
    if (raw == null) return null;
    final dt = DateTime.tryParse(raw.toString());
    return dt?.toLocal();
  }

  /// Formata data e hora de uma consulta a partir do valor bruto do banco.
  static String formatConsultaDateTime(dynamic raw) {
    final dt = parseConsulta(raw);
    return dt != null ? formatDateTime(dt) : '--';
  }

  /// Formata apenas a data de uma consulta a partir do valor bruto do banco.
  static String formatConsultaDate(dynamic raw) {
    final dt = parseConsulta(raw);
    return dt != null ? formatDate(dt) : '--';
  }

  /// Formata apenas a hora de uma consulta a partir do valor bruto do banco.
  static String formatConsultaTime(dynamic raw) {
    final dt = parseConsulta(raw);
    return dt != null ? formatTime(dt) : '--';
  }
}






