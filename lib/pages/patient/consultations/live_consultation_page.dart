import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveConsultationPage extends StatefulWidget {
  final String consultationId;
  const LiveConsultationPage({super.key, required this.consultationId});

  @override
  State<LiveConsultationPage> createState() => _LiveConsultationPageState();
}

class _LiveConsultationPageState extends State<LiveConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': 'Olá, Matheus! Vi que relatou sintomas de insônia e estresse. Pode me contar um pouco mais sobre como isso tem afetado o seu dia a dia?',
      'sender': 'doctor',
      'time': '10h05',
    },
    {
      'text': 'Oi, doutora. Tenho dormido muito mal há alguns dias, acordo várias vezes à noite e passo o dia cansado e irritado.',
      'sender': 'patient',
      'time': '15h35',
      'read': true,
    },
    {
      'text': 'Entendi. Você tem percebido se esses sintomas estão ligados a alguma situação específica ou mudança na sua rotina?',
      'sender': 'doctor',
      'time': '15h35',
    },
    {
      'text': 'Acho que sim, tenho trabalhado demais e não consigo relaxar antes de dormir. Minha mente não para.',
      'sender': 'patient',
      'time': '15h35',
      'read': true,
    },
    {
      'text': 'Certo, obrigada por compartilhar. Vamos pensar em estratégias para melhorar seu sono e reduzir o estresse.',
      'sender': 'doctor',
      'time': '15h35',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['sender'] == 'doctor';
    final isRead = message['read'] == true;

    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDoctor ? const Color(0xFFF7F7F5) : const Color(0xFFE6F8EF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: isDoctor ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Text(
                  message['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C7C79),
                  ),
                ),
                if (!isDoctor && isRead) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check, size: 16, color: Color(0xFF7C7C79)),
                ],
              ],
            ),
          ],
        ),
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
              context.go('/patient/consultations');
            }
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar_pictures.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dr Luiz Carlos Souza',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Digitando...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Consulta iniciada às 10h00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Status tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA6BBF9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Em andamento',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF102D57),
                ),
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF212121)),
                  onPressed: () {
                    // Attach file
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF7048C3)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BB5A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        messages.add({
                          'text': _messageController.text,
                          'sender': 'patient',
                          'time': DateTime.now().toString().substring(11, 16),
                          'read': false,
                        });
                        _messageController.clear();
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD6D6D3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Atendimento Encerrado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C333A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/patient/consultations/finish/${widget.consultationId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BB5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Finalizar atendimento',
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
      ),
    );
  }
}





