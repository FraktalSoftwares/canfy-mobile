import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientBasicDataPage extends StatefulWidget {
  const PatientBasicDataPage({super.key});

  @override
  State<PatientBasicDataPage> createState() => _PatientBasicDataPageState();
}

class _PatientBasicDataPageState extends State<PatientBasicDataPage> {
  final TextEditingController _emailController = TextEditingController(text: 'pedro.henrique@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '********');
  final TextEditingController _cpfController = TextEditingController(text: '123.456.789-00');
  final TextEditingController _sexController = TextEditingController(text: 'Masculino');
  final TextEditingController _birthDateController = TextEditingController(text: '28/01/1990');
  final TextEditingController _motherNameController = TextEditingController(text: 'Maria do Socorro Silva');
  final TextEditingController _susCardController = TextEditingController(text: '0000000000');
  final TextEditingController _phoneController = TextEditingController(text: '(99) 99999-9999');
  final TextEditingController _regionController = TextEditingController(text: 'Rua das Orquídeas, 99,\nSão Paulo/SP - Floresta');

  final List<Map<String, String>> _documents = [
    {'name': 'CNH.pdf'},
    {'name': 'comprovante_de_residencia.pdf'},
    {'name': 'autorização_da_anvisa.pdf'},
  ];

  Widget _buildFieldRow(String label, Widget value) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE6E6E3),
            width: 1,
          ),
        ),
      ),
      child: Row(
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
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String documentName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF33CC80),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
            angle: 1.5708,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Transform.rotate(
                angle: 4.7124,
                child: const Icon(Icons.edit, color: Colors.black, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                documentName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00994B),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: 1.5708,
            child: IconButton(
              icon: Transform.rotate(
                angle: 4.7124,
                child: const Icon(Icons.delete_outline, color: Colors.black),
              ),
              onPressed: () {
                // Remover documento
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE6F8EF),
                shape: const CircleBorder(),
              ),
            ),
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
            angle: 1.5708,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/account');
            }
          },
        ),
        title: const Text(
          'Meus dados',
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
            const Text(
              'Dados básicos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto de perfil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
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
                            border: Border.all(
                              color: const Color(0xFFF8F8F8),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pedro Henrique',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campos editáveis
                  _buildFieldRow(
                    'E-mail',
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Senha',
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldRow(
                    'CPF',
                    TextField(
                      controller: _cpfController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Sexo',
                    TextField(
                      controller: _sexController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Data de nascimento',
                    TextField(
                      controller: _birthDateController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Nome da mãe',
                    TextField(
                      controller: _motherNameController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Cartão do SUS',
                    TextField(
                      controller: _susCardController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldRow(
                    'Telefone',
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Região',
                    TextField(
                      controller: _regionController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Links
                  GestureDetector(
                    onTap: () {
                      // Navegar para alterar senha
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE6E6E3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Alterar senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF00994B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      // Mostrar modal de confirmação para excluir conta
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
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
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._documents.map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDocumentCard(doc['name']!),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botões
            OutlinedButton.icon(
              onPressed: () {
                // Sair da conta
              },
              icon: const Icon(Icons.exit_to_app, size: 16),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                side: const BorderSide(color: Color(0xFF7C7C79)),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Salvar dados
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Salvar dados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00994B),
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





