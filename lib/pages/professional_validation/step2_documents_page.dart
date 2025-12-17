import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class Step2DocumentsPage extends StatefulWidget {
  const Step2DocumentsPage({super.key});

  @override
  State<Step2DocumentsPage> createState() => _Step2DocumentsPageState();
}

class _Step2DocumentsPageState extends State<Step2DocumentsPage> {
  // Estado para controlar quais documentos foram enviados
  final Map<String, bool> _uploadedDocuments = {
    'rg_ou_cnh': true, // RG já enviado (exemplo)
    'comprovante_de_residencia': false,
    'comprovante_do_crm_cro': false,
    'diploma': false,
    'certificado_complementar': false,
    'outros_documentos': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/professional-validation/step1-professional-data');
            }
          },
        ),
        title: Text(
          'Envio de documentos',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de progresso
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BB5A), // green-700
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BB5A), // green-700
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D3), // neutral-300
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Título e badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validação profissional',
                    style: AppTextStyles.truculenta(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0EE), // neutral-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Etapa 2 - Envio de documentos',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F3F3D), // neutral-800
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF), // green-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Valor: R\$ 89,90',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF007A3B), // green-900
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Cards de documentos
              _buildDocumentCard(
                key: const ValueKey('rg_ou_cnh'),
                title: 'RG ou CNH',
                isUploaded: _uploadedDocuments['rg_ou_cnh']!,
                fileName: 'carteira.pdf',
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                key: const ValueKey('comprovante_de_residencia'),
                title: 'Comprovante de residência',
                isUploaded: _uploadedDocuments['comprovante_de_residencia']!,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                key: const ValueKey('comprovante_do_crm_cro'),
                title: 'Comprovante do CRM/CRO',
                isUploaded: _uploadedDocuments['comprovante_do_crm_cro']!,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                key: const ValueKey('diploma'),
                title: 'Diploma',
                isUploaded: _uploadedDocuments['diploma']!,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                key: const ValueKey('certificado_complementar'),
                title: 'Certificado complementar',
                subtitle: '(opcional)',
                isUploaded: _uploadedDocuments['certificado_complementar']!,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                key: const ValueKey('outros_documentos'),
                title: 'Outros documentos',
                subtitle: '(opcional)',
                isUploaded: _uploadedDocuments['outros_documentos']!,
              ),
              const SizedBox(height: 24),
              // Botão Próximo
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/professional-validation/step3-availability');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.canfyGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Próximo',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    Key? key,
    required String title,
    String? subtitle,
    required bool isUploaded,
    String? fileName,
  }) {
    final documentKey = key?.toString().replaceAll("'", '').split('(').last.split(')').first ?? 
                        title.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_');
    
    return Container(
      key: key,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5), // neutral-050
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          RichText(
            text: TextSpan(
              style: AppTextStyles.arimo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3F3F3D), // neutral-800
              ),
              children: [
                TextSpan(text: title),
                if (subtitle != null)
                  TextSpan(
                    text: ' $subtitle',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F3F3D),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Subtítulo formatos
          Text(
            'Formatos aceitos: PDF, PNG, JPG',
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: const Color(0xFF7C7C79), // neutral-600
            ),
          ),
          const SizedBox(height: 16),
          // Área de upload
          if (isUploaded && fileName != null)
            // Documento já enviado
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF33CC80), // green-500
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(18.138),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF), // green-100
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.insert_drive_file,
                          size: 32,
                          color: AppTheme.canfyGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        fileName,
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.canfyGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Botões Trocar/Remover
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          // Trocar documento
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.canfyGreen,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Trocar documento',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            color: AppTheme.canfyGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _uploadedDocuments[documentKey] = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5E5E5B), // neutral-700
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Remover documento',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            color: const Color(0xFF5E5E5B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            // Área para adicionar documento
            GestureDetector(
              onTap: () {
                // Abrir seletor de arquivo
                setState(() {
                  _uploadedDocuments[documentKey] = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF33CC80), // green-500
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(18.138),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8EF), // green-100
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        size: 32,
                        color: AppTheme.canfyGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Clique para adicionar o arquivo',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.canfyGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

