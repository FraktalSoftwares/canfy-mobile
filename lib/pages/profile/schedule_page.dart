import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Set<String> _selectedDays = {};
  String? _selectedRecurrence;
  final Set<String> _selectedTimes = {};
  String? _selectedInterval;
  bool _shareData = false;

  final List<String> _weekDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  final List<String> _recurrences = [
    'Semanal',
    'Quinzenal',
    'Mensal',
    'Personalizado',
  ];

  final List<String> _timeSlots = [
    '08h00',
    '09h00',
    '10h00',
    '11h00',
    '14h00',
    '15h00',
    '16h00',
    '17h00',
  ];

  final List<String> _intervals = [
    '15 minutos',
    '30 minutos',
    '45 minutos',
    '1 hora',
  ];

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
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Agenda',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agenda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Seleção de dias da semana
            _buildSection(
              'Selecione os dias da semana em que deseja atender.',
              _buildDaySelection(),
            ),
            const SizedBox(height: 16),
            // Seleção de recorrência
            _buildSection(
              'Selecione a recorrência:',
              _buildRecurrenceSelection(),
            ),
            const SizedBox(height: 16),
            // Horários disponíveis
            _buildSection(
              'Horários disponíveis para 08 de setembro',
              _buildTimeSlots(),
            ),
            const SizedBox(height: 16),
            // Intervalo entre atendimentos
            _buildSection(
              'Defina o intervalo entre atendimentos (opcional)',
              _buildIntervalSelection(),
            ),
            const SizedBox(height: 16),
            // Calendário e compartilhamento
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Calendário placeholder
                  Container(
                    height: 388,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Calendário'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Compartilhar dados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      Switch(
                        value: _shareData,
                        onChanged: (value) => setState(() => _shareData = value),
                        activeColor: const Color(0xFF00994B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Salvar agenda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00994B),
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Salvar agenda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
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
              color: Color(0xFF3F3F3D),
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
        return InkWell(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00994B) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF00994B) : const Color(0xFFE6E6E3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF3F3F3D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecurrenceSelection() {
    return Column(
      children: _recurrences.map((recurrence) {
        return RadioListTile<String>(
          title: Text(recurrence),
          value: recurrence,
          groupValue: _selectedRecurrence,
          onChanged: (value) => setState(() => _selectedRecurrence = value),
          activeColor: const Color(0xFF00994B),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTimes.contains(time);
        return InkWell(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00994B) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF00994B) : const Color(0xFFE6E6E3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF3F3F3D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntervalSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _intervals.map((interval) {
        final isSelected = _selectedInterval == interval;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedInterval = isSelected ? null : interval;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00994B) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF00994B) : const Color(0xFFE6E6E3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              interval,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF3F3F3D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

