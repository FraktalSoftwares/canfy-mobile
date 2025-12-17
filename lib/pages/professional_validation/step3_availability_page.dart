import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class Step3AvailabilityPage extends StatefulWidget {
  const Step3AvailabilityPage({super.key});

  @override
  State<Step3AvailabilityPage> createState() => _Step3AvailabilityPageState();
}

class _Step3AvailabilityPageState extends State<Step3AvailabilityPage> {
  // Dias da semana selecionados
  final Set<String> _selectedDays = {'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Sexta-feira'};
  
  // Recorrência selecionada
  String? _selectedRecurrence;
  
  // Horários selecionados
  final Set<String> _selectedTimes = {'10h00'};
  
  // Intervalo selecionado
  String? _selectedInterval;
  
  // Checkbox de autorização
  bool _agreeDataSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
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
        child: SingleChildScrollView(
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0EE), // neutral-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Etapa 3 - Disponibilidade de atendimento',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F3F3D), // neutral-800
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF), // green-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Valor: R\$ 89,90',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF007A3B), // green-900
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
                icon: const Icon(Icons.add, size: 16, color: AppTheme.canfyGreen),
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
                icon: const Icon(Icons.add, size: 16, color: AppTheme.canfyGreen),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          color: const Color(0xFF7C7C79), // neutral-600
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
                  onPressed: _agreeDataSharing
                      ? () {
                          context.go('/professional-validation/status');
                        }
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
                  child: Text(
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
    final days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDayButton(days[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(days[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDayButton(days[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(days[3])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDayButton(days[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildDayButton(days[5])),
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
            color: isSelected ? AppTheme.canfyGreen : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            day,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF3F3F3D), // neutral-800
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
            color: isSelected ? AppTheme.canfyGreen : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            time,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF3F3F3D), // neutral-800
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
            color: isSelected ? AppTheme.canfyGreen : const Color(0xFFB8B8B5), // neutral-400
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            interval,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF3F3F3D), // neutral-800
            ),
          ),
        ),
      ),
    );
  }
}





