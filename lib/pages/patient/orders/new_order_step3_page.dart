import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';

class NewOrderStep3Page extends StatefulWidget {
  const NewOrderStep3Page({super.key});

  @override
  State<NewOrderStep3Page> createState() => _NewOrderStep3PageState();
}

class _NewOrderStep3PageState extends State<NewOrderStep3Page> {
  String? rgFile;
  String? addressProofFile;
  String? anvisaFile;

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF00BB5A),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF00BB5A),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF00BB5A),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 52,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String? fileName,
    required VoidCallback onUpload,
    required VoidCallback? onReplace,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F3F3D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Formatos aceitos: PDF, PNG, JPG',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 16),
          if (fileName == null)
            GestureDetector(
              onTap: onUpload,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF33CC80),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Transform.rotate(
                      angle: 1.5708, // 90 graus
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Transform.rotate(
                          angle: -1.5708, // -90 graus para compensar
                          child: const Icon(
                            Icons.cloud_upload,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Clique para adicionar o arquivo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00994B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF33CC80),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: 1.5708, // 90 graus
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F8EF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Transform.rotate(
                            angle: -1.5708, // -90 graus para compensar
                            child: const Icon(
                              Icons.insert_drive_file,
                              size: 32,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00994B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onReplace,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00994B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Trocar documento',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00994B),
                      ),
                    ),
                  ),
                ),
              ],
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
              context.go('/patient/orders/new/step2');
            }
          },
        ),
        title: const Text(
          'Upload de documentos',
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
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Novo pedido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Etapa 3 - Upload de documentos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Valor: R\$ 325,00',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Prescription already attached notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: 1.5708, // 90 graus
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA987F5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Transform.rotate(
                        angle: -1.5708, // -90 graus para compensar
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sua receita médica já foi anexada automaticamente a este pedido. Não é necessário enviar novamente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4E3390),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              title: 'RG ou CNH',
              fileName: rgFile,
              onUpload: () {
                setState(() {
                  rgFile = 'carteira.pdf';
                });
              },
              onReplace: rgFile != null
                  ? () {
                      setState(() {
                        rgFile = null;
                      });
                    }
                  : null,
            ),
            _buildDocumentUploadCard(
              title: 'Comprovante de residência',
              fileName: addressProofFile,
              onUpload: () {
                setState(() {
                  addressProofFile = 'comprovante.pdf';
                });
              },
              onReplace: addressProofFile != null
                  ? () {
                      setState(() {
                        addressProofFile = null;
                      });
                    }
                  : null,
            ),
            _buildDocumentUploadCard(
              title: 'Autorização da Anvisa',
              fileName: anvisaFile,
              onUpload: () {
                setState(() {
                  anvisaFile = 'anvisa.pdf';
                });
              },
              onReplace: anvisaFile != null
                  ? () {
                      setState(() {
                        anvisaFile = null;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (rgFile != null &&
                        addressProofFile != null &&
                        anvisaFile != null)
                    ? () {
                        context.push('/patient/orders/new/step4');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 1, // Pedidos tab is active
      ),
    );
  }
}
