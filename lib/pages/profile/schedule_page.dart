import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';
import '../../widgets/schedule/schedule_agenda_calendar.dart';

/// Tela de Agenda do médico conforme Figma (node 2533-12864).
/// Inclui: dias da semana, recorrência, horários para a data selecionada,
/// intervalo entre atendimentos, calendário (node 2538-14465) e Modo férias.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final MedicoService _medicoService = MedicoService();

  String? _medicoId;
  bool _isLoading = true;
  String? _loadError;
  bool _isSaving = false;

  final Set<String> _selectedDays = {};
  String? _selectedRecurrence;
  final Set<String> _selectedTimes = {};
  String? _selectedInterval;
  bool _modoFerias = false;

  DateTime _displayedMonth;
  DateTime? _selectedDate;

  static const List<String> _weekDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _recurrences = [
    'Nunca repetir',
    'Repetir todos os dias',
    'Repetir semanalmente',
    'Repetir mensalmente',
  ];

  static const List<String> _intervals = [
    '5 minutos',
    '10 minutos',
    '15 minutos',
    '20 minutos',
    '25 minutos',
    '30 minutos',
  ];

  static List<String> get _timeSlots {
    final slots = <String>[];
    for (int h = 8; h <= 17; h++) {
      for (int m = 0; m < 60; m += 20) {
        if (h == 17 && m > 0) break;
        slots.add('${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}');
      }
    }
    return slots;
  }

  _SchedulePageState()
      : _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month),
        _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final result = await _medicoService.getMedicoByCurrentUser();
    if (!mounted) return;
    if (result['success'] != true || result['data'] == null) {
      setState(() {
        _isLoading = false;
        _loadError = result['message'] as String? ?? 'Médico não encontrado';
      });
      return;
    }
    final medico = result['data'] as Map<String, dynamic>;
    _medicoId = medico['id'] as String?;
    if (_medicoId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Médico não encontrado';
      });
      return;
    }
    final dias = medico['disponibilidade_dias'] as String?;
    if (dias != null && dias.isNotEmpty) {
      _selectedDays.addAll(
          dias.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    _selectedRecurrence = medico['disponibilidade_recorrencia'] as String?;
    final horarios = medico['disponibilidade_horarios'] as String?;
    if (horarios != null && horarios.isNotEmpty) {
      _selectedTimes.addAll(
          horarios.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    _selectedInterval = medico['disponibilidade_intervalo'] as String?;
    _modoFerias = medico['autoriza_compartilhamento_dados'] == true;
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _confirmar() async {
    if (_medicoId == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final result = await _medicoService.updateMedicoDisponibilidade(
        _medicoId!,
        disponibilidadeDias:
            _selectedDays.isEmpty ? null : _selectedDays.join(','),
        disponibilidadeRecorrencia: _selectedRecurrence,
        disponibilidadeHorarios:
            _selectedTimes.isEmpty ? null : _selectedTimes.join(','),
        disponibilidadeIntervalo: _selectedInterval,
        autorizaCompartilhamentoDados: _modoFerias,
      );
      if (!mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['message'] as String? ?? 'Erro ao salvar agenda'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda salva com sucesso'),
          backgroundColor: AppColors.canfyGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.neutral000,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator(color: AppColors.canfyGreen)),
        bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.neutral000,
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.neutral800),
            ),
          ),
        ),
        bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral000,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agenda',
              style: AppTextStyles.truculenta(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Selecione os dias da semana em que deseja atender.',
              _buildDaySelection(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Selecione a recorrência:',
              _buildRecurrenceSelection(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Horários disponíveis para $_selectedDateLabel',
              _buildTimeSlotsSection(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Defina o intervalo entre atendimentos (opcional)',
              _buildIntervalSection(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neutral050,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ScheduleAgendaCalendar(
                    displayedMonth: _displayedMonth,
                    selectedDate: _selectedDate,
                    onMonthChanged: (m) => setState(() => _displayedMonth = m),
                    onDaySelected: (d) =>
                        setState(() => _selectedDate = d),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Modo férias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral800,
                        ),
                      ),
                      Switch(
                        value: _modoFerias,
                        onChanged: (value) =>
                            setState(() => _modoFerias = value),
                        activeColor: AppColors.canfyGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.canfyGreen,
                  foregroundColor: AppColors.neutral000,
                  minimumSize: const Size(double.infinity, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.neutral000,
                        ),
                      )
                    : const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
    );
  }

  String get _selectedDateLabel {
    if (_selectedDate == null) {
      final d = DateTime.now();
      final str = DateFormat('dd \'de\' MMMM', 'pt_BR').format(d);
      return str[0].toUpperCase() + str.substring(1);
    }
    final str = DateFormat('dd \'de\' MMMM', 'pt_BR').format(_selectedDate!);
    return str[0].toUpperCase() + str.substring(1);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.neutral000,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF33CC80),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
          }
        },
      ),
      title: const Text(
        'Agenda',
        style: TextStyle(
          color: AppColors.neutral900,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: const [DoctorAppBarAvatar()],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutral050,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDaySelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _weekDays.map((day) {
        final isSelected = _selectedDays.contains(day);
        return _buildChip(
          label: day,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecurrenceSelection() {
    return Column(
      children: _recurrences.map((recurrence) {
        return RadioListTile<String>(
          title: Text(
            recurrence,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral800,
            ),
          ),
          value: recurrence,
          groupValue: _selectedRecurrence,
          onChanged: (value) => setState(() => _selectedRecurrence = value),
          activeColor: AppColors.canfyGreen,
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTimes.contains(time);
            return _buildChip(
              label: time,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTimes.remove(time);
                  } else {
                    _selectedTimes.add(time);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // TODO: Adicionar horário específico (dialog ou navegação)
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppColors.canfyGreen, size: 20),
              SizedBox(width: 4),
              Text(
                'Adicionar um horário específico',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.canfyGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _intervals.map((interval) {
            final isSelected = _selectedInterval == interval;
            return _buildChip(
              label: interval,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedInterval = isSelected ? null : interval;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // TODO: Adicionar intervalo específico
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppColors.canfyGreen, size: 20),
              SizedBox(width: 4),
              Text(
                'Adicionar um intervalo específico',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.canfyGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canfyGreen : AppColors.neutral000,
          border: Border.all(
            color: isSelected ? AppColors.canfyGreen : AppColors.neutral200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.neutral000 : AppColors.neutral800,
          ),
        ),
      ),
    );
  }
}
