import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/order_status_tag.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../services/api/patient_service.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _patientAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadPatientProfile();
  }

  Future<void> _loadPatientProfile() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final profile = data['profile'] as Map<String, dynamic>?;
        if (profile != null && mounted) {
          setState(() {
            _patientAvatarUrl = profile['foto_perfil_url'] as String?;
          });
        }
      }
    } catch (e) {
      // Silently fail - avatar will show default icon
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _patientService.getAllOrders();

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erro ao carregar pedidos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar pedidos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
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
                '${order['number']} • ${order['date']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              OrderStatusTag(status: order['status'] as String),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              context.push('/patient/orders/${order['id']}');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['product'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Canal de aquisição: ${order['channel']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                    ],
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
          ),
          const SizedBox(height: 16),
          Text(
            order['value'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Histórico de pedidos',
        fallbackRoute: '/patient/home',
        avatarUrl: _patientAvatarUrl,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00994B),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFF7C7C79),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7C7C79),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00994B),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Color(0xFF7C7C79),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum pedido encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7C7C79),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/patient/orders/new/step1');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00994B),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Fazer primeiro pedido'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      color: const Color(0xFF00994B),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pedidos',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 1.5708, // 90 graus
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00994B),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Transform.rotate(
                                      angle:
                                          -1.5708, // -90 graus para compensar
                                      child: IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.white),
                                        onPressed: () {
                                          context.push(
                                              '/patient/orders/new/step1');
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ..._orders.map(
                                (order) => _buildOrderCard(context, order)),
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 1, // Pedidos tab is active
      ),
    );
  }
}
