import 'package:flutter/material.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _activePrescriptions = [];
  List<Map<String, dynamic>> _pastPrescriptions = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Parse "DD/MM/YYYY" to DateTime (null if invalid).
  DateTime? _parseDDMMYYYY(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (m < 1 || m > 12) return null;
    final lastDay = DateTime(y, m + 1, 0).day;
    if (d < 1 || d > lastDay) return null;
    return DateTime(y, m, d);
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await _patientService.getPrescriptions(onlyActive: false);
      if (!mounted) return;
      if (result['success'] == true && result['data'] != null) {
        final all = List<Map<String, dynamic>>.from(result['data'] as List);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final active = <Map<String, dynamic>>[];
        final past = <Map<String, dynamic>>[];
        for (final p in all) {
          final validityStr = p['validity'] as String?;
          final validityDate = _parseDDMMYYYY(validityStr);
          if (validityDate != null && !validityDate.isBefore(today)) {
            active.add(p);
          } else {
            past.add(p);
          }
        }
        setState(() {
          _activePrescriptions = active;
          _pastPrescriptions = past;
          _loading = false;
        });
      } else {
        setState(() {
          _activePrescriptions = [];
          _pastPrescriptions = [];
          _loading = false;
          _errorMessage =
              result['message'] as String? ?? 'Erro ao carregar receitas';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _activePrescriptions = [];
          _pastPrescriptions = [];
          _loading = false;
          _errorMessage = 'Erro ao carregar receitas: ${e.toString()}';
        });
      }
    }
  }

  /// Campos da API: issueDate, validity, product, doctor (observations opcional).
  String _getEmissionDate(Map<String, dynamic> p) =>
      p['issueDate'] as String? ?? p['emissionDate'] as String? ?? '--';
  String _getValidityDate(Map<String, dynamic> p) =>
      p['validity'] as String? ?? p['validityDate'] as String? ?? '--';
  String _getProduct(Map<String, dynamic> p) => p['product'] as String? ?? '--';
  String _getPrescribedBy(Map<String, dynamic> p) =>
      p['doctor'] as String? ?? p['prescribedBy'] as String? ?? '--';

  Widget _buildPrescriptionCard(
      BuildContext context, Map<String, dynamic> prescription) {
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
                  'Emissão: ${_getEmissionDate(prescription)}',
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
                      child:
                          const Icon(Icons.chevron_right, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getProduct(prescription),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prescrito pelo ${_getPrescribedBy(prescription)}',
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
                  _getValidityDate(prescription),
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

  Widget _buildPrescriptionModal(
      BuildContext context, Map<String, dynamic> prescription) {
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
          _buildDetailRow('Emissão:', _getEmissionDate(prescription)),
          _buildDetailRow('Validade:', _getValidityDate(prescription)),
          _buildDetailRow('Produto:', _getProduct(prescription)),
          _buildDetailRow('Prescrito por:', _getPrescribedBy(prescription)),
          if (prescription['observations'] != null &&
              (prescription['observations'] as String).isNotEmpty) ...[
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

  Widget _buildTabContent(
    BuildContext context,
    List<Map<String, dynamic>> prescriptions,
    String emptyMessage,
  ) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF7048C3)),
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadPrescriptions,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (prescriptions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPrescriptions,
      color: const Color(0xFF7048C3),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: prescriptions
              .map((prescription) =>
                  _buildPrescriptionCard(context, prescription))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Receitas',
        fallbackRoute: '/patient/consultations',
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
          _buildTabContent(
            context,
            _activePrescriptions,
            'Nenhuma receita ativa no momento.',
          ),
          _buildTabContent(
            context,
            _pastPrescriptions,
            'Nenhuma receita no histórico.',
          ),
        ],
      ),
    );
  }
}
