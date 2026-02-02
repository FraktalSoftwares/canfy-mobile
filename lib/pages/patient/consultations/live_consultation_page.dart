import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../services/api/chat_service.dart';

class LiveConsultationPage extends StatefulWidget {
  final String consultationId;
  const LiveConsultationPage({super.key, required this.consultationId});

  @override
  State<LiveConsultationPage> createState() => _LiveConsultationPageState();
}

class _LiveConsultationPageState extends State<LiveConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PatientService _patientService = PatientService();
  final ChatService _chatService = ChatService();

  // Stream subscription para mensagens em tempo real
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  // Estado
  bool _isLoading = true;
  String? _errorMessage;
  bool _isConsultationEnded = false;
  bool _isSending = false;

  // Dados da consulta (vindos da API)
  String _doctorName = 'Médico';
  String _doctorSpecialty = 'Especialidade';
  String? _doctorAvatar;
  String _consultationStartTime = '--:--';
  String _consultationDate = '--';
  String _status = 'agendada';
  String _mainComplaint = '';

  // Mensagens
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _patientService.getConsultationById(widget.consultationId);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;

        setState(() {
          _doctorName = data['doctorName'] as String? ?? 'Médico';
          _doctorSpecialty =
              data['doctorSpecialty'] as String? ?? 'Especialidade';
          _doctorAvatar = data['doctorAvatar'] as String?;
          _consultationStartTime = data['time'] as String? ?? '--:--';
          _consultationDate = data['date'] as String? ?? '--';
          _status =
              (data['status_raw'] as String?)?.toLowerCase() ?? 'agendada';
          _mainComplaint = data['mainComplaint'] as String? ?? '';
          _isConsultationEnded = _status == 'finalizada';
          _isLoading = false;
        });

        // Iniciar stream de mensagens em tempo real
        _startMessagesStream();

        // Marcar mensagens como lidas
        _chatService.markAsRead(widget.consultationId);
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erro ao carregar consulta';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar consulta: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startMessagesStream() {
    _messagesSubscription?.cancel();
    _messagesSubscription =
        _chatService.messagesStream(widget.consultationId).listen(
      (messages) {
        if (mounted) {
          setState(() {
            _messages = messages.map((msg) {
              return {
                'id': msg['id'],
                'text': msg['mensagem'] ?? '',
                'sender':
                    msg['remetente_tipo'] == 'medico' ? 'doctor' : 'patient',
                'senderId': msg['remetente_id'],
                'time': _formatTime(msg['created_at']),
                'read': msg['lida'] == true,
              };
            }).toList();
          });

          // Scroll para o final
          _scrollToBottom();

          // Marcar como lidas
          _chatService.markAsRead(widget.consultationId);
        }
      },
      onError: (error) {
        debugPrint('Erro no stream de mensagens: $error');
      },
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '--:--';
    try {
      DateTime dt;
      if (timestamp is String) {
        dt = DateTime.parse(timestamp).toLocal();
      } else if (timestamp is DateTime) {
        dt = timestamp.toLocal();
      } else {
        return '--:--';
      }
      return '${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    final result = await _chatService.sendMessage(
      consultaId: widget.consultationId,
      mensagem: text,
      remetenteTipo: 'paciente',
    );

    if (result['success'] == true) {
      _messageController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro ao enviar mensagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.canfyGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.canfyGreen),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.neutral600),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loadConsultationData,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header/Navbar conforme Figma
            _buildHeader(),
            // Área de mensagens
            Expanded(
              child: Stack(
                children: [
                  _buildMessagesList(),
                  // CTA flutuante "Ver resumo da consulta"
                  if (_isConsultationEnded) _buildFloatingCTA(),
                ],
              ),
            ),
            // Input área
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// Header conforme Figma (node 2314:5960)
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFD6D6D3), width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Botão voltar (círculo verde claro com seta)
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8EF), // green-100
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.canfyGreen,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Avatar + info do médico
          Expanded(
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.neutral200,
                  backgroundImage: _doctorAvatar != null &&
                          _doctorAvatar!.startsWith('http')
                      ? NetworkImage(_doctorAvatar!)
                      : const AssetImage('assets/images/avatar_pictures.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 8),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _doctorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        _doctorSpecialty,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!_isConsultationEnded)
                            const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF00994B),
                              ),
                            )
                          else
                            const Text(
                              'Consulta encerrada',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF9A9A97),
                              ),
                            ),
                          Text(
                            'Consulta iniciada às $_consultationStartTime',
                            style: const TextStyle(
                              fontSize: 10,
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
          ),
        ],
      ),
    );
  }

  /// Lista de mensagens conforme Figma
  Widget _buildMessagesList() {
    final hasMessages = _messages.isNotEmpty;
    final itemCount = _messages.length +
        1 +
        (_isConsultationEnded ? 1 : 0); // +1 data tag, +1 ended tag

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Tag de data no início
        if (index == 0) {
          return _buildDateTag();
        }
        // Tag "Atendimento Encerrado" no final
        if (_isConsultationEnded && index == _messages.length + 1) {
          return _buildEndedTag();
        }
        // Mensagens
        if (index - 1 < _messages.length) {
          return _buildMessageBubble(_messages[index - 1]);
        }
        // Mensagem de boas-vindas se não houver mensagens
        if (!hasMessages && index == 1) {
          return _buildWelcomeMessage();
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Mensagem de boas-vindas quando não há mensagens
  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Inicie a conversa com o médico',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_mainComplaint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Queixa: $_mainComplaint',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tag de data centralizada (conforme Figma)
  Widget _buildDateTag() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFB0E8D1), // tagcolors/green/light/fill
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _consultationDate,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF174F38), // tagcolors/green/light/content
          ),
        ),
      ),
    );
  }

  /// Tag "Atendimento Encerrado" (conforme Figma)
  Widget _buildEndedTag() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0EE), // neutral-100
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Atendimento Encerrado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3F3F3D), // neutral-800
          ),
        ),
      ),
    );
  }

  /// Balão de mensagem conforme Figma
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['sender'] == 'doctor';
    final isRead = message['read'] == true;

    // Cores conforme Figma
    final bgColor = isDoctor
        ? const Color(0xFFF7F7F5) // neutral-050
        : const Color(0xFFC3A6F9); // purple-300

    final textColor = isDoctor
        ? const Color(0xFF3F3F3D) // neutral-800
        : const Color(0xFF212121); // neutral-900

    final timeColor = isDoctor
        ? const Color(0xFF5E5E5B) // neutral-700
        : const Color(0xFF3F3F3D); // neutral-800

    // Border radius conforme Figma
    final borderRadius = isDoctor
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          );

    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isDoctor ? 0 : 71,
          right: isDoctor ? 71 : 0,
        ),
        constraints: const BoxConstraints(maxWidth: 287),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] as String? ?? '',
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            // Hora + check (para paciente)
            if (isDoctor)
              Text(
                message['time'] as String? ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: timeColor,
                  height: 1.5,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    message['time'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: timeColor,
                      height: 1.5,
                    ),
                  ),
                  if (isRead) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.done_all,
                      size: 24,
                      color: Color(0xFF3F3F3D),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// CTA flutuante "Ver resumo da consulta" (conforme Figma)
  Widget _buildFloatingCTA() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 8,
      child: Material(
        color:
            const Color(0xFF00BB5A), // buttoncolors/primary/filled/background
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            context
                .push('/patient/consultations/finish/${widget.consultationId}');
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Center(
              child: Text(
                'Ver resumo da consulta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      Color(0xFFE6F8EF), // buttoncolors/primary/filled/content
                  fontFamily: 'Truculenta',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Área de input conforme Figma (node 2314:6970)
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000), // rgba(0,0,0,0.1)
            offset: Offset(2, 0),
            blurRadius: 9,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão "+" verde
          GestureDetector(
            onTap: _isConsultationEnded
                ? null
                : () {
                    // TODO: Anexar arquivo
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isConsultationEnded
                    ? const Color(0xFFD6D6D3)
                    : const Color(0xFF00994B), // green-800
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Campo de texto
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isConsultationEnded,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Mensagem',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB2B2B2),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  // Ícone de enviar dentro do campo
                  GestureDetector(
                    onTap: _isConsultationEnded || _isSending
                        ? null
                        : _sendMessage,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.canfyGreen,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: _isConsultationEnded
                                ? const Color(0xFFD6D6D3)
                                : const Color(0xFF9CA3AF),
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botão de foto verde
          GestureDetector(
            onTap: _isConsultationEnded
                ? null
                : () {
                    // TODO: Enviar foto
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isConsultationEnded
                    ? const Color(0xFFD6D6D3)
                    : const Color(0xFF00994B), // green-800
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.photo_camera, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
