import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  final String _selectedMonth = 'Setembro';

  final List<Map<String, dynamic>> _transfers = [
    {
      'status': 'atrasado',
      'consultation': 'Consulta #12345 • 01/09/25',
      'amount': 'R\$89,90',
    },
    {
      'status': 'aReceber',
      'consultation': 'Consulta #12345 • 01/08/25',
      'amount': 'R\$89,90',
    },
    {
      'status': 'recebido',
      'consultation': 'Consulta #12345 • 01/07/25',
      'amount': 'R\$89,90',
      'paidDate': 'Pago em 05/07/25',
    },
  ];

  Widget _buildStatusTag(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'atrasado':
        backgroundColor = const Color(0xFFF8B8B5);
        textColor = const Color(0xFF551611);
        text = 'Atrasado';
        break;
      case 'recebido':
        backgroundColor = const Color(0xFF66DDA2);
        textColor = const Color(0xFF174F38);
        text = 'Recebido';
        break;
      default: // aReceber
        backgroundColor = const Color(0xFFA6BBF9);
        textColor = const Color(0xFF102D57);
        text = 'A receber';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTransferCard(Map<String, dynamic> transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7E7F1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusTag(transfer['status']),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C7C79),
                        ),
                        children: [
                          TextSpan(
                              text: transfer['consultation'].split(' • ')[0] +
                                  ' • '),
                          TextSpan(
                            text: transfer['consultation'].split(' • ')[1],
                            style: const TextStyle(color: Color(0xFF212121)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transfer['amount'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: 1.5708, // 90 graus
                child: IconButton(
                  icon: Transform.rotate(
                    angle: 4.7124, // 270 graus
                    child: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE6F8EF),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (transfer['paidDate'] != null) ...[
            const SizedBox(height: 16),
            Text(
              transfer['paidDate'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C7C79),
              ),
            ),
          ],
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Financeiro',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          DoctorAppBarAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e seletor de mês
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financeiro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Transform.rotate(
                      angle: 1.5708,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F8EF),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _selectedMonth,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007A3B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Transform.rotate(
                      angle: 1.5708,
                      child: IconButton(
                        icon: Transform.rotate(
                          angle: 3.1416, // 180 graus
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F8EF),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Cards de resumo
            Column(
              children: [
                // Total a receber
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total a receber',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'R\$3.000,00',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Último e próximo repasse
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '10/09/25',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Último repasse',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'R\$2.300,00',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '10/10/25',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Próximo repasse',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'R\$700,00',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Seção Repasses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Repasses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/financial/history');
                  },
                  child: const Text(
                    'Ver tudo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7048C3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de repasses
            ..._transfers.map((transfer) => _buildTransferCard(transfer)),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 2),
    );
  }
}
