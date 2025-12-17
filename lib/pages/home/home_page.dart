import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Text(
            appointment['dateTime'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE6E6E3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paciente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['patient'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                    onPressed: () {
                      context.push('/appointment/pre-consultation');
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F8EF),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Valor da consulta:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  appointment['value'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: 144,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFC3A6F9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Image.asset(
              'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              children: [
                TextSpan(text: 'Canabidiol\n'),
                TextSpan(
                  text: 'Óleo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = [
      {
        'dateTime': '01/09/25 • 09:30',
        'patient': 'Maria Aparecida',
        'value': 'R\$89,00',
      },
      {
        'dateTime': '01/09/25 • 10:30',
        'patient': 'Laura Flores',
        'value': 'R\$89,00',
      },
      {
        'dateTime': '01/09/25 • 10:30',
        'patient': 'Laura Flores',
        'value': 'R\$89,00',
      },
      {
        'dateTime': '01/09/25 • 10:30',
        'patient': 'Laura Flores',
        'value': 'R\$89,00',
      },
      {
        'dateTime': '01/09/25 • 10:30',
        'patient': 'Laura Flores',
        'value': 'R\$89,00',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
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
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            const Text(
              'Boas Vindas, Dr. Luiz Carlos!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.normal,
                color: Color(0xFF3F3F3D),
              ),
            ),
            const SizedBox(height: 16),
            // Card Total a receber
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE7E7F1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total a receber',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
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
                  Transform.rotate(
                    angle: 1.5708,
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: 4.7124,
                        child: const Icon(Icons.chevron_right, color: Colors.black),
                      ),
                      onPressed: () {
                        context.push('/financial');
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE6F8EF),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consultas realizadas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3F3F3D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '32',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Atendimentos\nda semana',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3F3F3D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '6',
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
            const SizedBox(height: 32),
            // Próximos atendimentos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximos atendimentos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/appointment');
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
            // Lista de atendimentos
            ...appointments.map((appointment) => _buildAppointmentCard(context, appointment)),
            const SizedBox(height: 32),
            // Catálogo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catálogo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/catalog');
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
            // Lista horizontal de produtos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildProductCard(),
                  const SizedBox(width: 16),
                  _buildProductCard(),
                  const SizedBox(width: 16),
                  _buildProductCard(),
                  const SizedBox(width: 16),
                  _buildProductCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

