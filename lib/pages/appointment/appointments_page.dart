import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Atendimento',
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atendimento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF00994B),
            labelColor: Colors.black,
            unselectedLabelColor: const Color(0xFF9A9A97),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'Próximas consultas'),
              Tab(text: 'Histórico de consultas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingAppointments(),
                _buildAppointmentHistory(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildUpcomingAppointments() {
    final appointments = [
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '09:30',
        'patient': 'Laura Flores',
        'status': 'Agendada',
        'value': 'R\$100,00',
      },
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '10:30',
        'patient': 'Maria Aparecida',
        'status': 'Agendada',
        'value': 'R\$100,00',
      },
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '09:30',
        'patient': 'Fernando Torres',
        'status': 'Agendada',
        'value': 'R\$100,00',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...appointments.map((appointment) => _buildAppointmentCard(appointment)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAppointmentHistory() {
    final appointments = [
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '09:30',
        'patient': 'Laura Flores',
        'status': 'Concluída',
        'value': 'R\$100,00',
      },
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '10:30',
        'patient': 'Maria Aparecida',
        'status': 'Concluída',
        'value': 'R\$100,00',
      },
      {
        'id': '#12345',
        'date': '01/09/25',
        'time': '09:30',
        'patient': 'Fernando Torres',
        'status': 'Concluída',
        'value': 'R\$100,00',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...appointments.map((appointment) => _buildAppointmentCard(appointment)),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, String> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        border: Border.all(color: const Color(0xFFE7E7F1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appointment['id']} • ${appointment['date']} • ${appointment['time']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF66DDA2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  appointment['status']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF174F38),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paciente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C7C79),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['patient']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF00994B)),
                onPressed: () {
                  if (_tabController.index == 0) {
                    context.go('/appointment/pre-consultation');
                  } else {
                    context.go('/appointment/details');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Valor da consulta:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                appointment['value']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Atendimento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Financeiro',
          ),
        ],
      ),
    );
  }
}






