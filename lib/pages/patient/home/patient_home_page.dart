import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  // Mock data - será substituído por dados reais do backend
  final List<Map<String, dynamic>> _upcomingConsultations = [
    {
      'id': '1',
      'date': '01/09/25',
      'time': '09:30',
      'doctorName': 'Dr Luiz Carlos Souza',
      'specialty': 'Clinico geral',
      'avatar': null,
    },
    {
      'id': '2',
      'date': '02/09/25',
      'time': '12:30',
      'doctorName': 'Dra. Renata Campos',
      'specialty': 'Neurologista',
      'avatar': null,
    },
    {
      'id': '3',
      'date': '05/09/25',
      'time': '14:00',
      'doctorName': 'Dr Ricardo Santos',
      'specialty': 'Clinico geral',
      'avatar': null,
    },
  ];

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': '1',
      'status': 'Em análise',
      'productName': 'Óleo Canabidiol 20mg/ml',
      'price': 'R\$ 250,00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hasConsultations = _upcomingConsultations.isNotEmpty;
    final hasOrders = _recentOrders.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF212121)),
          onPressed: () {
            // Menu drawer
          },
        ),
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
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
            const SizedBox(height: 16),
            // Welcome message
            const Text(
              'Boas Vindas, Pedro!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.normal,
                color: Color(0xFF3F3F3D),
                fontFamily: 'Truculenta',
              ),
            ),
            const SizedBox(height: 40),
            // Próximas consultas section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximas consultas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                    fontFamily: 'Truculenta',
                  ),
                ),
                if (hasConsultations)
                  IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00994B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                    onPressed: () {
                      context.push('/patient/consultations/new/step1');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasConsultations)
              _buildEmptyConsultationsState()
            else
              ..._upcomingConsultations.map((consultation) => _buildConsultationCard(consultation)),
            const SizedBox(height: 32),
            // Últimos pedidos section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimos pedidos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                    fontFamily: 'Truculenta',
                  ),
                ),
                if (hasOrders)
                  IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00994B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                    onPressed: () {
                      context.push('/patient/orders/new/step1');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasOrders)
              _buildEmptyOrdersState()
            else
              ..._recentOrders.map((order) => _buildOrderCard(order)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // Home tab is active
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3F3F3D),
          unselectedItemColor: const Color(0xFF3F3F3D),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          onTap: (index) {
            if (index == 0) {
              // Current page, do nothing
            } else if (index == 1) {
              context.go('/patient/orders');
            } else if (index == 2) {
              context.go('/patient/consultations');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_mall),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Consultas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
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
            // Date and time
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${consultation['date']} • ${consultation['time']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            // Doctor info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey, size: 32),
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
                          consultation['specialty'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF00994B)),
                  ),
                  onPressed: () {
                    context.push('/patient/consultations/${consultation['id']}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    Color statusTextColor;

    switch (order['status']) {
      case 'Em análise':
        statusColor = const Color(0xFFF9E68C);
        statusTextColor = const Color(0xFF654C01);
        break;
      default:
        statusColor = const Color(0xFFF9E68C);
        statusTextColor = const Color(0xFF654C01);
    }

    return GestureDetector(
      onTap: () {
        context.push('/patient/orders/${order['id']}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                order['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusTextColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Product info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['price'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF00994B)),
                  ),
                  onPressed: () {
                    context.push('/patient/orders/${order['id']}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyConsultationsState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: ElevatedButton(
        onPressed: () {
          context.push('/patient/consultations/new/step1');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE6F8EF),
          foregroundColor: const Color(0xFF00994B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.calendar_today, size: 16),
            SizedBox(width: 8),
            Text(
              'Agende sua primeira consulta',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: ElevatedButton(
        onPressed: () {
          context.push('/patient/orders/new/step1');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE6F8EF),
          foregroundColor: const Color(0xFF00994B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.local_mall, size: 16),
            SizedBox(width: 8),
            Text(
              'Você ainda não fez pedidos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





