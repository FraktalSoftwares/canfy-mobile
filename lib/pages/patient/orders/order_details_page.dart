import 'package:flutter/material.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/order_status_tag.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../services/api/patient_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Mapeia o status do pedido para as etapas da timeline
  Map<String, bool> _getTimelineSteps(String? status) {
    final statusLower = (status ?? '').toLowerCase();

    return {
      'Validando documentos': statusLower == 'em_analise' ||
          statusLower == 'aprovado' ||
          statusLower == 'em_separacao' ||
          statusLower == 'enviado' ||
          statusLower == 'entregue',
      'Liberando importação': statusLower == 'aprovado' ||
          statusLower == 'em_separacao' ||
          statusLower == 'enviado' ||
          statusLower == 'entregue',
      'Importação liberada': statusLower == 'em_separacao' ||
          statusLower == 'enviado' ||
          statusLower == 'entregue',
      'Pedido na Anvisa': statusLower == 'enviado' || statusLower == 'entregue',
      'Pedido liberado pela Anvisa': statusLower == 'entregue',
      'Pedido entregue': statusLower == 'entregue',
    };
  }

  /// Nome amigável do tipo de documento para exibição na tela de detalhes.
  String _getDocumentDisplayName(Map<String, dynamic> doc) {
    final tipo = doc['tipo']?.toString().toLowerCase();
    final nomeArquivo = doc['nome_arquivo']?.toString() ?? '';
    switch (tipo) {
      case 'identidade':
        return 'RG/CNH';
      case 'comprovante_residencia':
        return 'Comprovante de residência';
      case 'autorizacao_anvisa':
        return 'Autorização Anvisa';
      case 'laudo_medico':
        return 'Laudo médico';
      case 'exame':
        return 'Exame';
      case 'outro':
        return nomeArquivo.isNotEmpty ? nomeArquivo : 'Documento';
      default:
        return nomeArquivo.isNotEmpty ? nomeArquivo : 'Documento';
    }
  }

  /// Calcula a data estimada de entrega (10-12 dias após o pedido)
  /// Aceita String (ISO) ou valor dinâmico retornado pelo Supabase (timestamptz).
  String _getEstimatedDelivery(dynamic dataPedido) {
    if (dataPedido == null) return 'Data não disponível';

    try {
      final DateTime date;
      if (dataPedido is String) {
        date = DateTime.parse(dataPedido);
      } else if (dataPedido is DateTime) {
        date = dataPedido;
      } else {
        date = DateTime.parse(dataPedido.toString());
      }

      final dataInicio = date.add(const Duration(days: 10));
      final dataFim = date.add(const Duration(days: 12));

      final meses = [
        'janeiro',
        'fevereiro',
        'março',
        'abril',
        'maio',
        'junho',
        'julho',
        'agosto',
        'setembro',
        'outubro',
        'novembro',
        'dezembro'
      ];

      if (dataInicio.month == dataFim.month) {
        return 'Chega entre ${dataInicio.day} e ${dataFim.day} de ${meses[dataInicio.month - 1]}';
      } else {
        return 'Chega entre ${dataInicio.day} de ${meses[dataInicio.month - 1]} e ${dataFim.day} de ${meses[dataFim.month - 1]}';
      }
    } catch (e) {
      return 'Data não disponível';
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientService = PatientService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Detalhes do pedido',
        fallbackRoute: '/patient/orders',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: patientService.getOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00994B),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data?['message'] ??
                        'Erro ao carregar detalhes do pedido',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7C7C79),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Recarregar
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsPage(orderId: orderId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00994B),
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final result = snapshot.data!;
          if (!result['success'] || result['data'] == null) {
            return Center(
              child: Text(
                result['message'] ?? 'Pedido não encontrado',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7C7C79),
                ),
              ),
            );
          }

          final orderData = result['data'] as Map<String, dynamic>;
          final statusRaw = orderData['status_raw']?.toString();
          final timelineSteps = _getTimelineSteps(statusRaw);
          final documentos = orderData['documentos'] is List
              ? orderData['documentos'] as List<dynamic>
              : <dynamic>[];
          final receita = orderData['receita'] is Map<String, dynamic>
              ? orderData['receita'] as Map<String, dynamic>?
              : null;

          return SingleChildScrollView(
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
                          Text(
                            '${orderData['numero_pedido'] ?? '#N/A'} • ${orderData['data_pedido'] ?? '--'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7C7C79),
                            ),
                          ),
                          OrderStatusTag(
                            status:
                                orderData['status'] as String? ?? 'Em análise',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        orderData['primeiro_produto_nome'] as String? ??
                            'Produto não especificado',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Canal de aquisição: ${orderData['canal_aquisicao'] ?? 'associação'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        orderData['valor_total'] as String? ?? 'R\$ 0,00',
                        style: const TextStyle(
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
                      Text(
                        _getEstimatedDelivery(orderData['data_pedido_raw']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTimelineStep(
                        isCompleted:
                            timelineSteps['Validando documentos'] ?? false,
                        title: 'Validando documentos',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted:
                            timelineSteps['Liberando importação'] ?? false,
                        title: 'Liberando importação',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted:
                            timelineSteps['Importação liberada'] ?? false,
                        title: 'Importação liberada',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted: timelineSteps['Pedido na Anvisa'] ?? false,
                        title: 'Pedido na Anvisa',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted:
                            timelineSteps['Pedido liberado pela Anvisa'] ??
                                false,
                        title: 'Pedido liberado pela Anvisa',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted: timelineSteps['Pedido entregue'] ?? false,
                        title: 'Pedido entregue',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                // Tracking code removido - não há campo no banco de dados ainda
                if (receita != null) ...[
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
                          fileName: receita['numero_receita']?.toString() ??
                              'Receita médica',
                          onView: () {
                            final url = receita['documento_url']?.toString();
                            if (url != null && url.isNotEmpty) {
                              launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('URL da receita não disponível')),
                              );
                            }
                          },
                          onDownload: () {
                            final url = receita['documento_url']?.toString();
                            if (url != null && url.isNotEmpty) {
                              launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('URL da receita não disponível')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                if (documentos.isNotEmpty) ...[
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
                        ...documentos.map((doc) {
                          final docMap = doc is Map<String, dynamic>
                              ? doc
                              : <String, dynamic>{};
                          final fileName = _getDocumentDisplayName(docMap);
                          final fileUrl =
                              docMap['arquivo_url']?.toString() ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildDocumentCard(
                              fileName: fileName,
                              onView: () {
                                if (fileUrl.isNotEmpty) {
                                  launchUrl(Uri.parse(fileUrl),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'URL do documento não disponível')),
                                  );
                                }
                              },
                              onDownload: () {
                                if (fileUrl.isNotEmpty) {
                                  launchUrl(Uri.parse(fileUrl),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'URL do documento não disponível')),
                                  );
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 1, // Pedidos tab is active
      ),
    );
  }
}
