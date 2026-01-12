import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/safe_image_asset.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  const PrescriptionDetailsPage({super.key});

  @override
  State<PrescriptionDetailsPage> createState() => _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final List<Map<String, dynamic>> _prescriptions = [
    {
      'form': 'Óleo',
      'dosage': '20mg/ml',
      'concentration': '20mg/ml de THC',
      'issueDate': '05/09/2025',
      'validity': '04/03/2026 (6 meses)',
      'indications': ['Insônia', 'Ansiedade'],
      'observations': '',
      'instructions': 'Deve ser usado 20mg/ml, sendo 10ml pela manhã e 10ml à noite, após as refeições.',
    },
    {
      'form': 'Óleo',
      'dosage': '20mg/ml',
      'concentration': '20mg/ml de THC',
      'issueDate': '05/09/2025',
      'validity': '04/03/2026 (6 meses)',
      'indications': ['Insônia', 'Ansiedade'],
      'observations': '',
      'instructions': 'Deve ser usado 20mg/ml, sendo 10ml pela manhã e 10ml à noite, após as refeições.',
    },
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
            angle: 1.5708,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/appointment');
            }
          },
        ),
        title: const Text(
          'Prescrição dos produtos',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Card do paciente
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paciente',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7C7C79),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Laura Flores',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: Colors.transparent),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campos de busca/filtro (opcional)
                  const SizedBox(height: 24),
                  // Lista de prescrições
                  ..._prescriptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final prescription = entry.value;
                    return _buildPrescriptionCard(prescription, index);
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 9,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/appointment/finish');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produto 1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  const IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: SafeImageAsset(
                  imagePath: 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                  fit: BoxFit.contain,
                  placeholderIcon: Icons.local_pharmacy,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Formas de uso:', prescription['form'] as String),
                    const SizedBox(height: 4),
                    _buildInfoRow('Dosagem:', prescription['dosage'] as String),
                    const SizedBox(height: 4),
                    _buildInfoRow('Concentração:', prescription['concentration'] as String),
                    const SizedBox(height: 4),
                    _buildInfoRow('Data de emissão:', prescription['issueDate'] as String),
                    const SizedBox(height: 4),
                    _buildInfoRow('Validade:', prescription['validity'] as String),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Indicado para:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (prescription['indications'] as List<String>)
                .map((indication) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        indication,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00994B),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Observações',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 4,
            controller: TextEditingController(text: prescription['observations'] as String),
          ),
          const SizedBox(height: 16),
          const Text(
            'Orientações de uso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prescription['instructions'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7C7C79),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

