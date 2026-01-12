import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  Widget _buildTimelineStep({
    required bool isCompleted,
    required String title,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isCompleted ? const Color(0xFF00994B) : Colors.transparent,
                shape: BoxShape.circle,
                border: isCompleted
                    ? null
                    : Border.all(
                        color: const Color(0xFF9A9A97),
                        width: 1.5,
                      ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? const Color(0xFF00994B)
                      : const Color(0xFF9A9A97),
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 1,
              height: 32,
              color: isCompleted
                  ? const Color(0xFF00994B)
                  : const Color(0xFF9A9A97),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String fileName,
    required VoidCallback onView,
    required VoidCallback onDownload,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF33CC80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
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
                child: IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.black),
                  onPressed: onView,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00994B),
              ),
            ),
          ),
          Transform.rotate(
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
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.black),
                  onPressed: onDownload,
                ),
              ),
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
              context.go('/patient/orders');
            }
          },
        ),
        title: const Text(
          'Detalhes do pedido',
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
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalhes do pedido',
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
                      angle: -1.5708, // -90 graus para compensar
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Order summary card
            Container(
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
                        '#12345 • 01/09/25',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E68C),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Em análise',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF654C01),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Óleo Canabidiol 20mg/ml',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Canal de aquisição: associação',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'R\$ 325,00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Delivery estimate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chega entre 10 e 12 de setembro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTimelineStep(
                    isCompleted: true,
                    title: 'Validando documentos',
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    isCompleted: true,
                    title: 'Liberando importação',
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    isCompleted: true,
                    title: 'Importação liberada',
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    isCompleted: true,
                    title: 'Pedido na Anvisa',
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    isCompleted: false,
                    title: 'Pedido liberado pela Anvisa',
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    isCompleted: false,
                    title: 'Pedido entregue',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tracking code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Código de rastreio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '0019050 0954014 48160 6906 8093503 1433737 0000010 000093 50314 33',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00994B),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.black),
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Prescription card
            Container(
              padding: const EdgeInsets.all(24),
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
                        'Receita vínculada',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: 3.1416, // 180 graus
                          child: const Icon(Icons.chevron_left,
                              color: Colors.black),
                        ),
                        onPressed: () {
                          // Expand/collapse
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Visualize a receita usada neste pedido.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentCard(
                    fileName: 'Receita médica',
                    onView: () {
                      // View prescription
                    },
                    onDownload: () {
                      // Download prescription
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Documents card
            Container(
              padding: const EdgeInsets.all(24),
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
                        'Documentos enviados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: 3.1416, // 180 graus
                          child: const Icon(Icons.chevron_left,
                              color: Colors.black),
                        ),
                        onPressed: () {
                          // Expand/collapse
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentCard(
                    fileName: 'Receita_médica.pdf',
                    onView: () {
                      // View document
                    },
                    onDownload: () {
                      // Download document
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentCard(
                    fileName: 'Laudo médico.pdf',
                    onView: () {
                      // View document
                    },
                    onDownload: () {
                      // Download document
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        constraints: const BoxConstraints(
          minHeight: 110,
        ),
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
          currentIndex: 1, // Pedidos tab is active
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
              context.go('/patient/home');
            } else if (index == 1) {
              // Current page, do nothing
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
}
