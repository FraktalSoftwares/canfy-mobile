import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveConsultationPage extends StatefulWidget {
  const LiveConsultationPage({super.key});

  @override
  State<LiveConsultationPage> createState() => _LiveConsultationPageState();
}

class _LiveConsultationPageState extends State<LiveConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConsultationEnded = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Olá, Matheus! Vi que relatou sintomas de insônia e estresse. Pode me contar um pouco mais sobre como isso tem afetado o seu dia a dia?',
      'isDoctor': true,
      'time': '10h05',
    },
    {
      'text': 'Oi, doutora. Tenho dormido muito mal há alguns dias, acordo várias vezes à noite e passo o dia cansado e irritado.',
      'isDoctor': false,
      'time': '15h35',
      'isRead': true,
    },
    {
      'text': 'Entendi. Você tem percebido se esses sintomas estão ligados a alguma situação específica ou mudança na sua rotina?',
      'isDoctor': true,
      'time': '15h35',
    },
    {
      'text': 'Acho que sim, tenho trabalhado demais e não consigo relaxar antes de dormir. Minha mente não para.',
      'isDoctor': false,
      'time': '15h35',
      'isRead': true,
    },
    {
      'text': 'Certo, obrigada por compartilhar. Vamos pensar em estratégias para melhorar seu sono e reduzir o estresse.',
      'isDoctor': true,
      'time': '15h35',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr Luiz Carlos Souza',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Clínico Geral',
                    style: TextStyle(
                      color: Color(0xFF7C7C79),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Digitando... • Consulta iniciada às 10h00',
                    style: TextStyle(
                      color: Color(0xFF9A9A97),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDFC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '09 de julho, 2025',
                      style: TextStyle(
                        color: Color(0xFF7048C3),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._messages.map((message) => _buildMessage(message)),
                  if (_isConsultationEnded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0EE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Atendimento Encerrado',
                        style: TextStyle(
                          color: Color(0xFF3F3F3D),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isConsultationEnded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/appointment/prescription-products');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00994B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Prescrever produtos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          else
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF00994B)),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mensagem',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo, color: Color(0xFF00994B)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isDoctor = message['isDoctor'] as bool;
    final text = message['text'] as String;
    final time = message['time'] as String;
    final isRead = message['isRead'] as bool? ?? false;

    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDoctor
              ? const Color(0xFFF7F7F5)
              : const Color(0xFFC3A6F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isDoctor ? 12 : 0),
            bottomRight: Radius.circular(isDoctor ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDoctor ? const Color(0xFF3F3F3D) : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDoctor ? const Color(0xFF5E5E5B) : const Color(0xFF3F3F3D),
                  ),
                ),
                if (!isDoctor && isRead) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, size: 24, color: Color(0xFF3F3F3D)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}





