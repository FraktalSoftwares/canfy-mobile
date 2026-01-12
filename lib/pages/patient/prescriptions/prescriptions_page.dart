import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> with SingleTickerProviderStateMixin {
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

  Widget _buildPrescriptionCard(BuildContext context, Map<String, dynamic> prescription) {
    return GestureDetector(
      onTap: () {
        // Show prescription details modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _buildPrescriptionModal(context, prescription),
        );
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
                  'Emissão: ${prescription['emissionDate']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7C79),
                  ),
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
            const SizedBox(height: 16),
            Text(
              prescription['product'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prescrito pelo ${prescription['prescribedBy']}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7C7C79),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Validade',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7C79),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  prescription['validityDate'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionModal(BuildContext context, Map<String, dynamic> prescription) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detalhes da receita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Share prescription
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Emissão:', prescription['emissionDate'] as String),
          _buildDetailRow('Validade:', prescription['validityDate'] as String),
          _buildDetailRow('Produto:', prescription['product'] as String),
          _buildDetailRow('Prescrito por:', prescription['prescribedBy'] as String),
          if (prescription['observations'] != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Observações:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7C7C79),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prescription['observations'] as String,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF212121),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Download prescription
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BB5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Baixar receita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<Map<String, dynamic>> activePrescriptions = [
      {
        'emissionDate': '30/09/2025',
        'validityDate': '01/10/2025',
        'product': 'Óleo Canabidiol 20mg/ml',
        'prescribedBy': 'Dr. Luiz Carlos Souza',
        'observations': 'Tomar 1ml, 2 vezes ao dia (manhã e noite).',
      },
    ];

    final List<Map<String, dynamic>> pastPrescriptions = [
      {
        'emissionDate': '30/08/2025',
        'validityDate': '25/09/2025',
        'product': 'Óleo Canabidiol 20mg/ml',
        'prescribedBy': 'Dr. Luiz Carlos Souza',
      },
      {
        'emissionDate': '30/07/2025',
        'validityDate': '25/08/2025',
        'product': 'Óleo Canabidiol 20mg/ml',
        'prescribedBy': 'Dr. Luiz Carlos Souza',
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
              context.go('/patient/consultations');
            }
          },
        ),
        title: const Text(
          'Receitas',
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
            Tab(text: 'Ativas'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ativas
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...activePrescriptions.map((prescription) => _buildPrescriptionCard(context, prescription)),
              ],
            ),
          ),
          // Histórico
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pastPrescriptions.map((prescription) => _buildPrescriptionCard(context, prescription)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






