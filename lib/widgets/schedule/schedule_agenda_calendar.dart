import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

/// Calendário mensal conforme Figma (node 2538-14465).
/// Cabeçalho: setas verde, "Mês - Ano" em verde; linha de dias D S T Q Q S S; grid de dias.
/// Dias do mês em negrito/preto; dias adjacentes em cinza claro.
class ScheduleAgendaCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime>? onDaySelected;

  const ScheduleAgendaCalendar({
    super.key,
    required this.displayedMonth,
    this.selectedDate,
    required this.onMonthChanged,
    this.onDaySelected,
  });

  static const List<String> _weekdayLabels = [
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];

  static String _formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM - yyyy', 'pt_BR');
    final str = formatter.format(date);
    return str[0].toUpperCase() + str.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final prevMonthDays = DateTime(year, month, 0).day;

    const double cellSize = 36.0;
    const int totalCells = 42;

    final List<Widget> dayCells = [];
    int prevDay = prevMonthDays - startWeekday + 1;
    for (int i = 0; i < totalCells; i++) {
      if (i < startWeekday) {
        final d = prevDay + i;
        final prevM = month == 1 ? 12 : month - 1;
        final prevY = month == 1 ? year - 1 : year;
        dayCells.add(_buildDayCell(
          day: d,
          isCurrentMonth: false,
          isSelected: false,
          size: cellSize,
          onTap: () => onDaySelected?.call(DateTime(prevY, prevM, d)),
        ));
      } else if (i < startWeekday + daysInMonth) {
        final d = i - startWeekday + 1;
        final cellDate = DateTime(year, month, d);
        final isSelected = selectedDate != null &&
            selectedDate!.year == year &&
            selectedDate!.month == month &&
            selectedDate!.day == d;
        dayCells.add(_buildDayCell(
          day: d,
          isCurrentMonth: true,
          isSelected: isSelected,
          size: cellSize,
          onTap: () => onDaySelected?.call(cellDate),
        ));
      } else {
        final d = i - startWeekday - daysInMonth + 1;
        final nextM = month == 12 ? 1 : month + 1;
        final nextY = month == 12 ? year + 1 : year;
        dayCells.add(_buildDayCell(
          day: d,
          isCurrentMonth: false,
          isSelected: false,
          size: cellSize,
          onTap: () => onDaySelected?.call(DateTime(nextY, nextM, d)),
        ));
      }
    }

    final List<Widget> weekRows = [];
    for (int r = 0; r < 6; r++) {
      weekRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayCells.sublist(r * 7, (r + 1) * 7),
      ));
      if (r < 5) weekRows.add(const SizedBox(height: 8));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral000,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    onMonthChanged(month == 1
                        ? DateTime(year - 1, 12)
                        : DateTime(year, month - 1));
                  },
                  color: AppColors.canfyGreen,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Text(
                  _formatMonthYear(displayedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.canfyGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    onMonthChanged(month == 12
                        ? DateTime(year + 1, 1)
                        : DateTime(year, month + 1));
                  },
                  color: AppColors.canfyGreen,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdayLabels
                .map((label) => SizedBox(
                      width: 32,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: weekRows,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isCurrentMonth,
    required bool isSelected,
    required double size,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentMonth ? FontWeight.w700 : FontWeight.w400,
                color: isCurrentMonth
                    ? AppColors.neutral900
                    : AppColors.neutral600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
