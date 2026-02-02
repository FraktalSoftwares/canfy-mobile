-- Políticas para o bucket 'documents' (upload de documentos do pedido)
-- Aplicado via MCP apply_migration (storage_documents_bucket_policies)

-- Usuários autenticados podem fazer upload em order_docs/{user_id}/
CREATE POLICY "Users can upload documents in own folder"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'order_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );

-- Leitura pública para documentos (bucket é público)
CREATE POLICY "Documents bucket is publicly readable"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'documents');

-- Usuários podem atualizar/deletar apenas seus próprios arquivos em order_docs/{user_id}/
CREATE POLICY "Users can update own documents"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'order_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );

CREATE POLICY "Users can delete own documents"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'order_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );
