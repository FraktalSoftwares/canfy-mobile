-- Permite que usuários autenticados façam upload em medico_docs/{user_id}/
CREATE POLICY "Users can upload in medico_docs folder"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'medico_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );

-- Atualizar e deletar apenas em medico_docs/{user_id}/
CREATE POLICY "Users can update own medico_docs"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'medico_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );

CREATE POLICY "Users can delete own medico_docs"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = 'medico_docs'
    AND (storage.foldername(name))[2] = (auth.uid())::text
  );
