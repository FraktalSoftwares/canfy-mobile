import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../models/consultation/consultation_model.dart';
import '../../../widgets/consultation/consultation_widgets.dart';

class NewConsultationStep2Page extends StatefulWidget {
  final NewConsultationFormData? formData;

  const NewConsultationStep2Page({super.key, this.formData});

  @override
  State<NewConsultationStep2Page> createState() =>
      _NewConsultationStep2PageState();
}

class _NewConsultationStep2PageState extends State<NewConsultationStep2Page> {
  final PatientService _patientService = PatientService();
  DateTime? _selectedDate;
  String? _selectedTime;
  DateTime _focusedMonth = DateTime.now();

  // Controla se estamos no estágio de calendário ou de horários
  bool _showTimeSelection = false;

  String? _patientAvatar;
  bool _isLoadingAvatar = true;

  // Simular dias disponíveis (em produção, viria da API)
  final Set<int> _availableDays = {
    1,
    2,
    3,
    4,
    5,
    6,
    8,
    10,
    12,
    15,
    16,
    18,
    19,
    20,
    22,
    23,
    24,
    26,
    30
  };

  // Horários disponíveis (10h às 18h com slots de 15 min)
  final List<String> _availableTimes = [
    '10h00',
    '10h15',
    '10h30',
    '10h45',
    '11h00',
    '11h15',
    '11h30',
    '11h45',
    '12h00',
    '12h15',
    '12h30',
    '12h45',
    '13h00',
    '13h15',
    '13h30',
    '13h45',
    '14h00',
    '14h15',
    '14h30',
    '14h45',
    '15h00',
    '15h15',
    '15h30',
    '15h45',
    '16h00',
    '16h15',
    '16h30',
    '16h45',
    '17h00',
    '17h15',
    '17h30',
    '17h45',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientAvatar();
  }

  Future<void> _loadPatientAvatar() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          setState(() {
            _patientAvatar = profile['foto_perfil_url'] as String?;
            _isLoadingAvatar = false;
          });
        } else {
          setState(() {
            _isLoadingAvatar = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAvatar = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  bool _isDayAvailable(int day) {
    return _availableDays.contains(day);
  }

  bool _isDayInPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  String _formatSelectedDate() {
    if (_selectedDate == null) return '';
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    final month = _getMonthName(_selectedDate!.month).toLowerCase();
    return '$day de $month';
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      _showTimeSelection = true;
    });
  }

  void _goBackToCalendar() {
    setState(() {
      _showTimeSelection = false;
      _selectedTime = null;
    });
  }

  void _handleBack() {
    if (_showTimeSelection) {
      _goBackToCalendar();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/patient/consultations');
    }
  }

  void _goToNextStep() {
    if (_showTimeSelection) {
      final updatedFormData =
          (widget.formData ?? NewConsultationFormData()).copyWith(
        selectedDate: _selectedDate,
        selectedTime: _selectedTime,
      );
      context.push(
        '/patient/consultations/new/step3',
        extra: updatedFormData,
      );
    } else {
      setState(() {
        _showTimeSelection = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _showTimeSelection
        ? _selectedDate != null && _selectedTime != null
        : _selectedDate != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ConsultationAppBar(
        onBack: _handleBack,
        avatarWidget: ConsultationAvatar(
          avatarUrl: _patientAvatar,
          isLoading: _isLoadingAvatar,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  const ConsultationStepIndicator(currentStep: 2),
                  const SizedBox(height: 20),

                  // Step header
                  const ConsultationStepHeader(
                    stepNumber: 2,
                    stepTitle: 'Selecione dia e horário',
                    valueText: 'Valor: R\$ 200,00',
                  ),
                  const SizedBox(height: 24),

                  // Conteúdo principal (calendário ou horários)
                  if (_showTimeSelection)
                    _buildTimeSelection()
                  else
                    _buildCalendar(),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ConsultationPrimaryButton(
                text: 'Próximo',
                onPressed: isEnabled ? _goToNextStep : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendário
        ConsultationSectionCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header do mês
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _previousMonth,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.chevron_left,
                          color: AppColors.neutral800,
                          size: 22,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${_getMonthName(_focusedMonth.month)} - ${_focusedMonth.year}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.neutral800,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dias da semana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                    .map((day) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral800,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Dias do mês
              ..._buildCalendarDays(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Legenda
        Row(
          children: [
            _buildLegendItem('Disponível', AppColors.neutral800, false),
            const SizedBox(width: 20),
            _buildLegendItem('Indisponível', AppColors.neutral300, true),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool hasStrike) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: hasStrike ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: hasStrike
                ? Border.all(color: AppColors.neutral300, width: 2)
                : null,
          ),
          child: hasStrike
              ? const Center(
                  child: Icon(
                    Icons.remove,
                    size: 10,
                    color: AppColors.neutral300,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horários disponíveis para ${_formatSelectedDate()}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 16),

        // Grid de horários
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: _availableTimes.length,
          itemBuilder: (context, index) {
            return _buildTimeSlot(_availableTimes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = _selectedTime == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canfyGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.canfyGreen : AppColors.neutral300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.neutral800,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final previousMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final lastDayOfPreviousMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0);

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Adicionar dias do mês anterior
    for (int i = firstWeekday - 1; i >= 0; i--) {
      final day = lastDayOfPreviousMonth.day - i;
      currentRow.add(_buildDayCell(
        day: day,
        isCurrentMonth: false,
        isAvailable: false,
        date: DateTime(previousMonth.year, previousMonth.month, day),
      ));
    }

    // Adicionar dias do mês atual
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isAvailable = _isDayAvailable(day) && !_isDayInPast(date);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;

      currentRow.add(_buildDayCell(
        day: day,
        isCurrentMonth: true,
        isAvailable: isAvailable,
        isSelected: isSelected,
        date: date,
      ));

      if (currentRow.length == 7) {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentRow,
          ),
        ));
        currentRow = [];
      }
    }

    // Adicionar dias do próximo mês para completar a última semana
    if (currentRow.isNotEmpty) {
      int nextMonthDay = 1;
      while (currentRow.length < 7) {
        currentRow.add(_buildDayCell(
          day: nextMonthDay,
          isCurrentMonth: false,
          isAvailable: false,
          date: DateTime(
              _focusedMonth.year, _focusedMonth.month + 1, nextMonthDay),
        ));
        nextMonthDay++;
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: currentRow,
      ));
    }

    return rows;
  }

  Widget _buildDayCell({
    required int day,
    required bool isCurrentMonth,
    required bool isAvailable,
    required DateTime date,
    bool isSelected = false,
  }) {
    final isPast = _isDayInPast(date);
    final showStrikethrough = isCurrentMonth && (!isAvailable || isPast);

    return GestureDetector(
      onTap: isCurrentMonth && isAvailable && !isPast
          ? () => _onDateSelected(date)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canfyPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x4D9067F1),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  isSelected || (isCurrentMonth && isAvailable && !isPast)
                      ? FontWeight.w700
                      : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : !isCurrentMonth
                      ? AppColors.neutral300
                      : AppColors.neutral800,
              decoration: showStrikethrough ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.neutral600,
            ),
          ),
        ),
      ),
    );
  }
}
