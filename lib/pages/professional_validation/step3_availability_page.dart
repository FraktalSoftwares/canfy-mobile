import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/medico_service.dart';

class Step3AvailabilityPage extends StatefulWidget {
  const Step3AvailabilityPage({super.key});

  @override
  State<Step3AvailabilityPage> createState() => _Step3AvailabilityPageState();
}

class _Step3AvailabilityPageState extends State<Step3AvailabilityPage> {
  final MedicoService _medicoService = MedicoService();

  String? _medicoId;
  bool _isLoading = true;
  String? _loadError;
  bool _isSaving = false;

  // Dias da semana selecionados
  final Set<String> _selectedDays = {};

  // Recorrência selecionada
  String? _selectedRecurrence;

  // Horários selecionados
  final Set<String> _selectedTimes = {};

  // Intervalo selecionado
  String? _selectedInterval;

  // Checkbox de autorização
  bool _agreeDataSharing = false;

  static const List<String> _daysOrder = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

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
    final medicoResult = await _medicoService.getMedicoByCurrentUser();
    if (!mounted) return;
    if (medicoResult['success'] != true || medicoResult['data'] == null) {
      setState(() {
        _isLoading = false;
        _loadError =
            medicoResult['message'] as String? ?? 'Médico não encontrado';
      });
      return;
    }
    final medico = medicoResult['data'] as Map<String, dynamic>;
    _medicoId = medico['id'] as String?;
    if (_medicoId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Médico não encontrado';
      });
      return;
    }
    // Restaurar dados salvos
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
    _agreeDataSharing = medico['autoriza_compartilhamento_dados'] == true;
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveAndNext() async {
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
        autorizaCompartilhamentoDados: _agreeDataSharing,
      );
      await Future.delayed(Duration.zero);
      if (!mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ??
                'Erro ao salvar disponibilidade'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!mounted) return;
      context.go('/professional-validation/status');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF33CC80),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/professional-validation/step2-documents');
            }
          },
        ),
        title: Text(
          'Disponibilidade de atendimento',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.canfyGreen))
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _loadData,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barra de progresso
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A), // green-700
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A), // green-700
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A), // green-700
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Título e badges
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Validação profissional',
                              style: AppTextStyles.truculenta(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFF0F0EE), // neutral-100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Etapa 3 - Disponibilidade de atendimento',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(
                                          0xFF3F3F3D), // neutral-800
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F8EF), // green-100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Valor: R\$ 89,90',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color(0xFF007A3B), // green-900
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Seção: Dias da semana
                        Text(
                          'Selecione os dias da semana em que deseja atender.',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDayButtons(),
                        const SizedBox(height: 32),
                        // Seção: Recorrência
                        Text(
                          'Selecione a recorrência:',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecurrenceOptions(),
                        const SizedBox(height: 32),
                        // Seção: Horários disponíveis
                        Text(
                          'Horários disponíveis para 08 de setembro',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimeSlots(),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Adicionar horário específico
                          },
                          icon: const Icon(Icons.add,
                              size: 16, color: AppTheme.canfyGreen),
                          label: Text(
                            'Adicionar um horário específico',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              color: AppTheme.canfyGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Seção: Intervalo entre atendimentos
                        Text(
                          'Defina o intervalo entre atendimentos (opcional)',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildIntervalButtons(),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Adicionar intervalo específico
                          },
                          icon: const Icon(Icons.add,
                              size: 16, color: AppTheme.canfyGreen),
                          label: Text(
                            'Adicionar um intervalo específico',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              color: AppTheme.canfyGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Calendário (simplificado)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F5), // neutral-050
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {},
                                  ),
                                  Text(
                                    'Setembro - 2025',
                                    style: AppTextStyles.arimo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.canfyGreen,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Grid de dias (simplificado - apenas exemplo)
                              Text(
                                '8',
                                style: AppTextStyles.arimo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.canfyGreen,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Center(
                                  child: Text(
                                    '8',
                                    style: AppTextStyles.arimo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeDataSharing,
                              onChanged: (value) {
                                setState(() {
                                  _agreeDataSharing = value ?? false;
                                });
                              },
                              activeColor: AppTheme.canfyGreen,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'Autorizo o compartilhamento de dados com médicos e associações, quando necessário para meu tratamento.',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12,
                                    color:
                                        const Color(0xFF7C7C79), // neutral-600
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Botão Confirmar
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: ElevatedButton(
                            onPressed: _agreeDataSharing && !_isSaving
                                ? _saveAndNext
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.canfyGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE0E0E0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Confirmar e enviar documentação',
                                    style: AppTextStyles.arimo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDayButtons() {
    // Figma: Segunda a Sábado (sem Domingo)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDayButton(_daysOrder[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(_daysOrder[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDayButton(_daysOrder[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(_daysOrder[3])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDayButton(_daysOrder[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(_daysOrder[5])),
          ],
        ),
      ],
    );
  }

  Widget _buildDayButton(String day) {
    final isSelected = _selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(day);
          } else {
            _selectedDays.add(day);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.canfyGreen : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.canfyGreen
                : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            day,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF3F3F3D), // neutral-800
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceOptions() {
    final options = [
      'Nunca repetir',
      'Repetir todos os dias',
      'Repetir semanalmente',
      'Repetir mensalmente',
    ];

    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(
            option,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF404040),
            ),
          ),
          value: option,
          groupValue: _selectedRecurrence,
          onChanged: (value) {
            setState(() {
              _selectedRecurrence = value;
            });
          },
          activeColor: AppTheme.canfyGreen,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots() {
    final times = [
      ['10h00', '10h20'],
      ['10h40', '11h00'],
      ['11h20', '11h40'],
      ['12h00', '12h20'],
      ['12h40', '13h00'],
      ['13h20', '13h40'],
      ['14h00', '14h20'],
      ['14h40', '15h00'],
      ['15h20', '15h40'],
      ['16h00', '16h20'],
    ];

    return Column(
      children: times.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildTimeButton(row[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeButton(row[1])),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeButton(String time) {
    final isSelected = _selectedTimes.contains(time);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTimes.remove(time);
          } else {
            _selectedTimes.add(time);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.canfyGreen : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.canfyGreen
                : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            time,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF3F3F3D), // neutral-800
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalButtons() {
    final intervals = [
      ['5 minutos', '10 minutos'],
      ['15 minutos', '20 minutos'],
      ['25 minutos', '30 minutos'],
    ];

    return Column(
      children: intervals.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildIntervalButton(row[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildIntervalButton(row[1])),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntervalButton(String interval) {
    final isSelected = _selectedInterval == interval;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInterval = isSelected ? null : interval;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.canfyGreen : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.canfyGreen
                : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            interval,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF3F3F3D), // neutral-800
            ),
          ),
        ),
      ),
    );
  }
}
