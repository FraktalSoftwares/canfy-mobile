import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/api_service.dart';

/// Serviço para upload de imagens no Supabase Storage
class ImageStorageService {
  final ApiService _apiService = ApiService();

  /// Faz upload de uma imagem para o Supabase Storage
  ///
  /// [file] - Arquivo de imagem a ser enviado
  /// [bucket] - Nome do bucket no Supabase Storage (padrão: 'avatars')
  /// [path] - Caminho onde a imagem será salva (padrão: baseado no user_id)
  ///
  /// Retorna a URL pública da imagem ou null em caso de erro
  Future<Map<String, dynamic>> uploadImage(
    File file, {
    String bucket = 'avatars',
    String? path,
  }) async {
    try {
      final user = _apiService.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'url': null,
        };
      }

      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp.jpg';
      final filePath = path ?? 'profiles/$fileName';

      // Ler o arquivo como bytes
      final fileBytes = await file.readAsBytes();

      // Fazer upload para o Supabase Storage
      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // Substituir se já existir
            ),
          );

      // Obter URL pública da imagem
      final publicUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);

      return {
        'success': true,
        'message': 'Imagem enviada com sucesso',
        'url': publicUrl,
        'path': filePath,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao fazer upload da imagem: ${e.toString()}',
        'url': null,
      };
    }
  }

  /// Faz upload de uma imagem a partir de bytes já lidos em memória.
  ///
  /// Use este método (em vez de [uploadImage]) quando a imagem vier do
  /// `image_picker` no Flutter Web, onde `XFile.path` é uma blob URL (não um
  /// caminho de filesystem) e `dart:io File` não é utilizável.
  Future<Map<String, dynamic>> uploadImageBytes(
    Uint8List bytes, {
    String bucket = 'avatars',
    String? path,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final user = _apiService.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'url': null,
        };
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp.jpg';
      final filePath = path ?? 'profiles/$fileName';

      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);

      return {
        'success': true,
        'message': 'Imagem enviada com sucesso',
        'url': publicUrl,
        'path': filePath,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao fazer upload da imagem: ${e.toString()}',
        'url': null,
      };
    }
  }

  /// Faz upload de um documento (PDF, PNG, JPG) para o Supabase Storage.
  /// Crie o bucket 'documents' no Supabase Dashboard (Storage) se ainda não existir.
  ///
  /// [file] - Arquivo a ser enviado
  /// [bucket] - Nome do bucket (padrão: 'documents')
  /// [path] - Caminho opcional; se null, usa order_docs/{userId}/{timestamp}_{fileName}
  /// [contentType] - MIME type (ex: application/pdf, image/png)
  Future<Map<String, dynamic>> uploadDocument(
    File file, {
    String bucket = 'documents',
    String? path,
    String contentType = 'application/pdf',
  }) async {
    try {
      final user = _apiService.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'url': null,
        };
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'document_$timestamp.pdf';
      final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final filePath = path ?? 'order_docs/${user.id}/${timestamp}_$safeName';

      final fileBytes = await file.readAsBytes();

      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);

      return {
        'success': true,
        'message': 'Documento enviado com sucesso',
        'url': publicUrl,
        'path': filePath,
        'fileName': safeName,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao fazer upload do documento: ${e.toString()}',
        'url': null,
      };
    }
  }

  /// Faz upload de um documento (PDF, PNG, JPG) a partir de bytes já lidos em memória.
  ///
  /// Use este método (em vez de [uploadDocument]) quando o arquivo vier do
  /// `file_picker` no Flutter Web, onde `PlatformFile.path` é sempre `null` e
  /// só `PlatformFile.bytes` está disponível.
  ///
  /// [bytes] - conteúdo do arquivo
  /// [fileName] - nome original do arquivo (usado para derivar o nome salvo)
  /// [bucket] - nome do bucket (padrão: 'documents')
  /// [path] - caminho opcional; se null, usa order_docs/{userId}/{timestamp}_{fileName}
  /// [contentType] - MIME type (ex: application/pdf, image/png)
  Future<Map<String, dynamic>> uploadDocumentBytes(
    Uint8List bytes, {
    required String fileName,
    String bucket = 'documents',
    String? path,
    String contentType = 'application/pdf',
  }) async {
    try {
      final user = _apiService.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'url': null,
        };
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final filePath = path ?? 'order_docs/${user.id}/${timestamp}_$safeName';

      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);

      return {
        'success': true,
        'message': 'Documento enviado com sucesso',
        'url': publicUrl,
        'path': filePath,
        'fileName': safeName,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao fazer upload do documento: ${e.toString()}',
        'url': null,
      };
    }
  }

  /// Deleta uma imagem do Supabase Storage
  ///
  /// [path] - Caminho da imagem a ser deletada
  /// [bucket] - Nome do bucket (padrão: 'avatars')
  Future<Map<String, dynamic>> deleteImage(
    String path, {
    String bucket = 'avatars',
  }) async {
    try {
      await Supabase.instance.client.storage.from(bucket).remove([path]);

      return {
        'success': true,
        'message': 'Imagem deletada com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao deletar imagem: ${e.toString()}',
      };
    }
  }
}
