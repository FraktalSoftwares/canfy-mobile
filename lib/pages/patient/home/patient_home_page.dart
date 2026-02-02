import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/order_status_tag.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final PatientService _patientService = PatientService();

  // Dados do paciente
  String _patientName = 'Usuário';
  String? _patientAvatar;

  // Dados das consultas e pedidos
  List<Map<String, dynamic>> _upcomingConsultations = [];
  List<Map<String, dynamic>> _recentOrders = [];

  // Estados de loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar dados do paciente
      final patientResult = await _patientService.getCurrentPatient();
      if (patientResult['success'] == true) {
        final data = patientResult['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          setState(() {
            _patientName = profile['nome_completo'] as String? ?? 'Usuário';
            _patientAvatar = profile['foto_perfil_url'] as String?;
          });
        }
      }

      // Buscar pedidos recentes
      final ordersResult = await _patientService.getRecentOrders(limit: 5);
      if (ordersResult['success'] == true && ordersResult['data'] != null) {
        final orders = ordersResult['data'] as List;
        setState(() {
          _recentOrders = orders.map((order) {
            // Formatar valor
            final valorTotal = order['valor_total'];
            String priceText = 'R\$ 0,00';
            if (valorTotal != null) {
              try {
                final valor = double.tryParse(valorTotal.toString()) ?? 0.0;
                priceText =
                    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
              } catch (e) {
                priceText = 'R\$ 0,00';
              }
            }

            // Mapear status
            final status = order['status'] as String? ?? 'pendente';
            String statusText = 'Pendente';
            if (status == 'em_analise') {
              statusText = 'Em análise';
            } else if (status == 'aprovado') {
              statusText = 'Aprovado';
            } else if (status == 'em_separacao') {
              statusText = 'Em separação';
            } else if (status == 'enviado') {
              statusText = 'Enviado';
            } else if (status == 'entregue') {
              statusText = 'Entregue';
            } else if (status == 'cancelado') {
              statusText = 'Cancelado';
            } else if (status == 'recusado') {
              statusText = 'Recusado';
            }

            return {
              'id': order['id'],
              'status': statusText,
              'productName': order['productName'] ?? 'Produto',
              'price': priceText,
            };
          }).toList();
        });
      }

      // Buscar apenas consultas futuras (upcoming) para a Home
      final consultationsResult = await _patientService.getConsultations();
      if (consultationsResult['success'] == true &&
          consultationsResult['data'] != null) {
        final data = consultationsResult['data'] as Map<String, dynamic>;
        final upcoming = data['upcoming'] as List? ?? [];
        final upcomingList = <Map<String, dynamic>>[];
        const limit = 5;

        for (final e in upcoming) {
          if (upcomingList.length >= limit) break;
          if (e is Map<String, dynamic>) {
            upcomingList.add(e);
          } else if (e is Map) {
            upcomingList.add(Map<String, dynamic>.from(e));
          }
        }

        if (mounted) {
          setState(() {
            _upcomingConsultations = upcomingList;
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Mostrar erro ao usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasConsultations = _upcomingConsultations.isNotEmpty;
    final hasOrders = _recentOrders.isNotEmpty;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: PatientAppBar(
          title: 'Home',
          showLeading: false,
          avatarTappable: false,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Home',
        showLeading: false,
        avatarUrl: _patientAvatar,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00994B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Welcome message
              Text(
                'Boas Vindas, ${_patientName.split(' ').first}!',
                style: AppTextStyles.truculenta(
                  fontSize: 32,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF3F3F3D),
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
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24),
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
                ..._upcomingConsultations.map(
                    (consultation) => _buildConsultationCard(consultation)),
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
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24),
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
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 0, // Home tab is active
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
                '${consultation['date'] ?? '--'} • ${consultation['time'] ?? '--'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            // Doctor info (mesmas chaves que getConsultations: doctorName, specialty/doctorSpecialty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person,
                          color: Colors.grey, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation['doctorName'] as String? ?? 'Médico',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Text(
                          (consultation['specialty'] ??
                                  consultation['doctorSpecialty']) as String? ??
                              'Especialidade',
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
                    child: const Icon(Icons.chevron_right,
                        color: Color(0xFF00994B)),
                  ),
                  onPressed: () {
                    context
                        .push('/patient/consultations/${consultation['id']}');
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
    return GestureDetector(
      onTap: () {
        context.push('/patient/orders/${order['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderStatusTag(status: order['status'] as String),
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
                    child: const Icon(Icons.chevron_right,
                        color: Color(0xFF00994B)),
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
