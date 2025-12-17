import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({super.key});

  @override
  State<BasicDataPage> createState() => _BasicDataPageState();
}

class _BasicDataPageState extends State<BasicDataPage> {
  final _emailController = TextEditingController(text: 'robertog@gmail.com');
  final _passwordController = TextEditingController(text: '********');
  final _cpfController = TextEditingController(text: '123.456.789-00');
  final _crmController = TextEditingController(text: '12345-SP');
  final _birthDateController = TextEditingController(text: '29/02/1990');
  final _phoneController = TextEditingController(text: '(99) 99999-9999');
  final _regionController = TextEditingController(
    text: 'Rua das Orquídeas, 99,\nSão Paulo/SP - Floresta',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _crmController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
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
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Dados básicos',
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
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados básicos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Card de dados básicos
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Foto de perfil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF43439D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Roberto Gonçalves',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('E-mail', _emailController),
                  const SizedBox(height: 16),
                  _buildInfoRow('Senha', _passwordController),
                  const SizedBox(height: 16),
                  _buildInfoRow('CPF', _cpfController),
                  const SizedBox(height: 16),
                  _buildInfoRow('CRM+UF', _crmController),
                  const SizedBox(height: 16),
                  _buildInfoRow('Data de nascimento', _birthDateController),
                  const SizedBox(height: 16),
                  _buildInfoRow('Telefone', _phoneController),
                  const SizedBox(height: 16),
                  _buildInfoRow('Região', _regionController, isMultiline: true),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      // Navegar para alterar senha
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Alterar senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF00994B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Mostrar diálogo de exclusão
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Excluir conta e todos os dados na plataforma',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Card de documentos
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documentos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDocumentItem('CNH.pdf'),
                  const SizedBox(height: 16),
                  _buildDocumentItem('comprovante_de_residencia.pdf'),
                  const SizedBox(height: 16),
                  _buildDocumentItem('autorização_da_anvisa.pdf'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botões de ação
            OutlinedButton(
              onPressed: () {
                // Sair da conta
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 49),
                side: const BorderSide(color: Color(0xFF7C7C79)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, size: 16, color: Color(0xFF7C7C79)),
                  SizedBox(width: 8),
                  Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Salvar dados
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00994B),
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Salvar dados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 124,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5E5E5B),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE6E6E3), width: 1),
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: isMultiline ? 2 : 1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        border: Border.all(color: const Color(0xFF33CC80)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F8EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.edit, color: Color(0xFF00994B), size: 20),
          ),
          const SizedBox(width: 16),
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF00994B)),
            onPressed: () {
              // Remover documento
            },
          ),
        ],
      ),
    );
  }
}

