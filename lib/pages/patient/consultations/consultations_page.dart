import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';

class ConsultationsPage extends StatefulWidget {
  const ConsultationsPage({super.key});

  @override
  State<ConsultationsPage> createState() => _ConsultationsPageState();
}

class _ConsultationsPageState extends State<ConsultationsPage> with SingleTickerProviderStateMixin {
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

  Widget _buildConsultationCard(BuildContext context, Map<String, dynamic> consultation) {
    Color statusColor;
    Color statusTextColor;
    String statusText;

    switch (consultation['status']) {
      case 'Agendada':
        statusColor = const Color(0xFFF9E68C);
        statusTextColor = const Color(0xFF654C01);
        statusText = 'Agendada';
        break;
      case 'Em andamento':
        statusColor = const Color(0xFFA6BBF9);
        statusTextColor = const Color(0xFF102D57);
        statusText = 'Em andamento';
        break;
      case 'Finalizada':
        statusColor = const Color(0xFFD6D6D3);
        statusTextColor = const Color(0xFF2C333A);
        statusText = 'Finalizada';
        break;
      default:
        statusColor = const Color(0xFFD6D6D3);
        statusTextColor = const Color(0xFF2C333A);
        statusText = consultation['status'];
    }

    return GestureDetector(
      onTap: () {
        context.push('/patient/consultations/${consultation['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${consultation['id']} • ${consultation['date']} • ${consultation['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7C79),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage(consultation['doctorAvatar'] ?? 'assets/images/avatar_pictures.png'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation['doctorName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Text(
                          consultation['doctorSpecialty'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Transform.rotate(
                  angle: 4.7124, // 270 graus
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Transform.rotate(
                      angle: -4.7124, // -270 graus para compensar
                      child: const Icon(Icons.chevron_right, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            if (consultation['mainComplaint'] != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Principal queixa:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    consultation['mainComplaint'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ],
            if (consultation['isReturn'] == true) ...[
              const SizedBox(height: 8),
              const Text(
                'Consulta de retorno',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<Map<String, dynamic>> upcomingConsultations = [
      {
        'id': '12345',
        'date': '01/09/25',
        'time': '09:30',
        'status': 'Agendada',
        'doctorName': 'Dr Luiz Carlos Souza',
        'doctorSpecialty': 'Clínico geral',
        'doctorAvatar': 'assets/images/avatar_pictures.png',
        'mainComplaint': 'Insônia, Estresse',
      },
      {
        'id': '12346',
        'date': '01/09/25',
        'time': '10:30',
        'status': 'Agendada',
        'doctorName': 'Dra. Renata Campos',
        'doctorSpecialty': 'Neurologista',
        'doctorAvatar': 'assets/images/avatar_pictures.png',
        'mainComplaint': 'Insônia',
      },
      {
        'id': '12347',
        'date': '01/09/25',
        'time': '11:30',
        'status': 'Agendada',
        'doctorName': 'Dr Ricardo Santos',
        'doctorSpecialty': 'Clínico geral',
        'doctorAvatar': 'assets/images/avatar_pictures.png',
        'isReturn': true,
      },
    ];

    final List<Map<String, dynamic>> pastConsultations = [
      {
        'id': '12340',
        'date': '25/08/25',
        'time': '14:00',
        'status': 'Finalizada',
        'doctorName': 'Dr Luiz Carlos Souza',
        'doctorSpecialty': 'Clínico geral',
        'doctorAvatar': 'assets/images/avatar_pictures.png',
        'mainComplaint': 'Ansiedade',
      },
      {
        'id': '12339',
        'date': '20/08/25',
        'time': '10:00',
        'status': 'Finalizada',
        'doctorName': 'Dra. Renata Campos',
        'doctorSpecialty': 'Neurologista',
        'doctorAvatar': 'assets/images/avatar_pictures.png',
        'mainComplaint': 'Dor crônica',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Transform.rotate(
                angle: -1.5708, // -90 graus para compensar
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/home');
            }
          },
        ),
        title: const Text(
          'Consultas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push('/patient/account');
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/avatar_pictures.png'),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7048C3),
          labelColor: const Color(0xFF7048C3),
          unselectedLabelColor: const Color(0xFF7C7C79),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Próximas consultas'),
            Tab(text: 'Histórico de consultas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Próximas consultas
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...upcomingConsultations.map((consultation) => _buildConsultationCard(context, consultation)),
              ],
            ),
          ),
          // Histórico de consultas
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pastConsultations.map((consultation) => _buildConsultationCard(context, consultation)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/patient/consultations/new/step1');
        },
        backgroundColor: const Color(0xFF00BB5A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 2, // Consultas tab is active
      ),
    );
  }
}






