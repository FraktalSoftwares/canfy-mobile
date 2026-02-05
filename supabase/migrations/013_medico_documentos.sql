-- Tabela de documentos do médico (validação profissional - etapa 2)
CREATE TABLE IF NOT EXISTS public.medico_documentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medico_id uuid NOT NULL REFERENCES public.medicos(id) ON DELETE CASCADE,
  tipo text NOT NULL,
  arquivo_url text NOT NULL,
  nome_arquivo text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(medico_id, tipo)
);

CREATE INDEX IF NOT EXISTS idx_medico_documentos_medico_id ON public.medico_documentos(medico_id);
COMMENT ON TABLE public.medico_documentos IS 'Documentos enviados pelo médico na validação profissional (RG/CNH, comprovante, CRM, diploma, etc.)';

-- RLS: médico só acessa seus próprios documentos
ALTER TABLE public.medico_documentos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Medicos podem ver próprios documentos" ON public.medico_documentos;
CREATE POLICY "Medicos podem ver próprios documentos"
  ON public.medico_documentos FOR SELECT
  USING (
    medico_id IN (SELECT id FROM public.medicos WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS "Medicos podem inserir próprio documento" ON public.medico_documentos;
CREATE POLICY "Medicos podem inserir próprio documento"
  ON public.medico_documentos FOR INSERT
  WITH CHECK (
    medico_id IN (SELECT id FROM public.medicos WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS "Medicos podem atualizar próprio documento" ON public.medico_documentos;
CREATE POLICY "Medicos podem atualizar próprio documento"
  ON public.medico_documentos FOR UPDATE
  USING (
    medico_id IN (SELECT id FROM public.medicos WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS "Medicos podem deletar próprio documento" ON public.medico_documentos;
CREATE POLICY "Medicos podem deletar próprio documento"
  ON public.medico_documentos FOR DELETE
  USING (
    medico_id IN (SELECT id FROM public.medicos WHERE user_id = auth.uid())
  );
