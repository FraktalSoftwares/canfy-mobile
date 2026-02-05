import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'financial_filters_modal.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinancialHistoryPage extends StatelessWidget {
  const FinancialHistoryPage({super.key});

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
    final List<Map<String, dynamic>> transfers = [
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
      {
        'status': 'recebido',
        'consultation': 'Consulta #12345 • 01/07/25',
        'amount': 'R\$89,90',
        'paidDate': 'Pago em 05/07/25',
      },
    ];

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
              context.go('/financial');
            }
          },
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Histórico de repasses',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 1.5708,
                  child: IconButton(
                    icon: Transform.rotate(
                      angle: 4.7124,
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FinancialFiltersModal(),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00994B),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...transfers.map((transfer) => _buildTransferCard(transfer)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.headset_mic, size: 16),
                label: const Text(
                  'Entrar em contato com o suporte',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00994B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: const BorderSide(color: Color(0xFF00994B)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 2),
    );
  }
}
