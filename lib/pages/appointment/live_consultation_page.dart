import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../services/api/chat_service.dart';

class LiveConsultationPage extends StatefulWidget {
  final String consultationId;
  const LiveConsultationPage({super.key, required this.consultationId});

  @override
  State<LiveConsultationPage> createState() => _LiveConsultationPageState();
}

class _LiveConsultationPageState extends State<LiveConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final _supabase = Supabase.instance.client;

  // Stream subscription para mensagens em tempo real
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  // Estado
  bool _isLoading = true;
  String? _errorMessage;
  bool _isConsultationEnded = false;
  bool _isSending = false;

  // Dados da consulta
  String _patientName = 'Paciente';
  String? _patientAvatar;
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
    if (widget.consultationId.isEmpty) {
      setState(() {
        _errorMessage = 'ID da consulta não informado';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Buscar dados da consulta
      final response = await _supabase.from('consultas').select('''
            id,
            data_consulta,
            status,
            queixa_principal,
            paciente_id,
            pacientes!inner(
              id,
              user_id,
              profiles!inner(
                nome_completo,
                foto_perfil_url
              )
            )
          ''').eq('id', widget.consultationId).single();

      final dataConsulta = response['data_consulta'];
      DateTime? dt;
      if (dataConsulta != null) {
        dt = DateTime.parse(dataConsulta.toString()).toLocal();
      }

      final paciente = response['pacientes'];
      final profile = paciente?['profiles'];

      setState(() {
        _patientName = profile?['nome_completo'] as String? ?? 'Paciente';
        _patientAvatar = profile?['foto_perfil_url'] as String?;
        _consultationStartTime = dt != null
            ? '${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}'
            : '--:--';
        _consultationDate = dt != null
            ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
            : '--';
        _status = (response['status'] as String?)?.toLowerCase() ?? 'agendada';
        _mainComplaint = response['queixa_principal'] as String? ?? '';
        _isConsultationEnded = _status == 'finalizada';
        _isLoading = false;
      });

      // Iniciar stream de mensagens em tempo real
      _startMessagesStream();

      // Marcar mensagens como lidas
      _chatService.markAsRead(widget.consultationId);
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
      remetenteTipo: 'medico',
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

  Future<void> _endConsultation() async {
    // Mostrar confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar consulta?'),
        content: const Text(
            'Ao encerrar, você poderá prescrever produtos para o paciente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.canfyGreen,
            ),
            child:
                const Text('Encerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Atualizar status da consulta
      await _supabase
          .from('consultas')
          .update({'status': 'finalizada'}).eq('id', widget.consultationId);

      setState(() {
        _isConsultationEnded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao encerrar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/appointment');
              }
            },
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
            // Header
            _buildHeader(),
            // Área de mensagens
            Expanded(
              child: _buildMessagesList(),
            ),
            // Área de input ou botão de prescrever
            if (_isConsultationEnded)
              _buildPrescribeButton()
            else
              _buildInputArea(),
          ],
        ),
      ),
    );
  }

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
          // Botão voltar
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/appointment');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.canfyGreen,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar + info do paciente
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.neutral200,
                  backgroundImage: _patientAvatar != null &&
                          _patientAvatar!.startsWith('http')
                      ? NetworkImage(_patientAvatar!)
                      : null,
                  child: _patientAvatar == null
                      ? const Icon(Icons.person, color: AppColors.neutral600)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      if (_mainComplaint.isNotEmpty)
                        Text(
                          'Queixa: $_mainComplaint',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7C7C79),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            'Início: $_consultationStartTime',
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
          // Botão encerrar (se não encerrada)
          if (!_isConsultationEnded)
            GestureDetector(
              onTap: _endConsultation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Encerrar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final hasMessages = _messages.isNotEmpty;
    final itemCount = _messages.length + 1 + (_isConsultationEnded ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        // Mensagem inicial se não houver mensagens
        if (!hasMessages && index == 1) {
          return _buildWelcomeMessage();
        }
        return const SizedBox.shrink();
      },
    );
  }

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
              'Inicie a conversa com o paciente',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_mainComplaint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Queixa principal: $_mainComplaint',
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

  Widget _buildDateTag() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDFC), // roxo claro para médico
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _consultationDate,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF7048C3),
          ),
        ),
      ),
    );
  }

  Widget _buildEndedTag() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0EE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Atendimento Encerrado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3F3F3D),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['sender'] == 'doctor';
    final isRead = message['read'] == true;

    // Cores - invertidas para visão do médico
    // Mensagens do médico (próprias): roxo
    // Mensagens do paciente: cinza
    final bgColor = isDoctor
        ? const Color(0xFFC3A6F9) // roxo - própria mensagem
        : const Color(0xFFF7F7F5); // cinza - mensagem do paciente

    final textColor =
        isDoctor ? const Color(0xFF212121) : const Color(0xFF3F3F3D);

    final timeColor =
        isDoctor ? const Color(0xFF3F3F3D) : const Color(0xFF5E5E5B);

    final borderRadius = isDoctor
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isDoctor ? 71 : 0,
          right: isDoctor ? 0 : 71,
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
            Row(
              mainAxisAlignment:
                  isDoctor ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message['time'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: timeColor,
                  ),
                ),
                if (isDoctor && isRead) ...[
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
          // Botão "+"
          GestureDetector(
            onTap: () {
              // TODO: Anexar arquivo
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00994B),
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
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
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
          ),
          const SizedBox(width: 8),
          // Botão enviar
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00994B),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescribeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: () {
                context.push('/appointment/prescription-products');
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
        ],
      ),
    );
  }
}
