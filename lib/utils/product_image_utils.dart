import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilitários para exibir imagens de produtos (URL completa ou path no Storage).
class ProductImageUtils {
  ProductImageUtils._();

  /// Converte valor de imagem do produto em URL exibível.
  /// - Se for URL completa (http/https), retorna como está.
  /// - Se for caminho "produtos/xxx" (com barra), usa bucket "documents" e path completo.
  /// - Caso contrário, usa bucket "produtos" e o path como está.
  static String? resolveProductImageUrl(
    dynamic value, {
    String productsBucket = 'produtos',
    String documentsBucket = 'documents',
  }) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    try {
      final isPathInDocuments = s.contains('/') &&
          (s.startsWith('produtos/') || s.startsWith('products/'));
      final bucket = isPathInDocuments ? documentsBucket : productsBucket;
      return Supabase.instance.client.storage.from(bucket).getPublicUrl(s);
    } catch (_) {
      return null;
    }
  }

  /// Obtém o valor de imagem do produto a partir de várias colunas possíveis.
  static dynamic getProductImageValue(Map<String, dynamic> product) {
    return product['image_url'] ??
        product['imageUrl'] ??
        product['imagem_url'] ??
        product['url_imagem'] ??
        product['imagem'] ??
        product['foto_url'] ??
        product['foto'];
  }
}
