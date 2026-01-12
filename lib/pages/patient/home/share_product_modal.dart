import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareProductModal extends StatefulWidget {
  const ShareProductModal({super.key});

  @override
  State<ShareProductModal> createState() => _ShareProductModalState();
}

class _ShareProductModalState extends State<ShareProductModal> {
  final TextEditingController _linkController = TextEditingController(
    text: 'https://canfy.com/produto/oleo-canabidiol-20mg',
  );

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Compartilhar produto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF212121)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Social media options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialMediaOption(
                icon: Icons.email,
                label: 'Email',
                onTap: () {
                  // Share via email
                },
              ),
              _buildSocialMediaOption(
                icon: Icons.chat,
                label: 'WhatsApp',
                onTap: () {
                  // Share via WhatsApp
                },
              ),
              _buildSocialMediaOption(
                icon: Icons.camera_alt,
                label: 'Instagram',
                onTap: () {
                  // Share via Instagram
                },
              ),
              _buildSocialMediaOption(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: () {
                  // Share via Facebook
                },
              ),
              _buildSocialMediaOption(
                icon: Icons.close,
                label: 'X',
                onTap: () {
                  // Share via X
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Link field
          TextField(
            controller: _linkController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Link do produto',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFF9067F1)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Copy link button
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _linkController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copiado!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9067F1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Copiar link',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildSocialMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFC),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: const Color(0xFF9067F1), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }
}






