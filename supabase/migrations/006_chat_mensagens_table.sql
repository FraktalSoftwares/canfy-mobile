-- Tabela de mensagens do chat entre médico e paciente
-- Cada mensagem pertence a uma consulta

CREATE TABLE IF NOT EXISTS chat_mensagens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  consulta_id UUID NOT NULL REFERENCES consultas(id) ON DELETE CASCADE,
  remetente_tipo TEXT NOT NULL CHECK (remetente_tipo IN ('paciente', 'medico')),
  remetente_id UUID NOT NULL, -- user_id do remetente (paciente ou médico)
  mensagem TEXT NOT NULL,
  lida BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_chat_mensagens_consulta_id ON chat_mensagens(consulta_id);
CREATE INDEX IF NOT EXISTS idx_chat_mensagens_created_at ON chat_mensagens(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_mensagens_remetente ON chat_mensagens(remetente_id);

-- Habilitar RLS
ALTER TABLE chat_mensagens ENABLE ROW LEVEL SECURITY;

-- Função auxiliar para verificar se o usuário é participante da consulta
CREATE OR REPLACE FUNCTION is_consulta_participant(consulta_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
  v_is_paciente BOOLEAN;
  v_is_medico BOOLEAN;
BEGIN
  v_user_id := auth.uid();
  
  -- Verificar se é o paciente da consulta
  SELECT EXISTS(
    SELECT 1 FROM consultas c
    JOIN pacientes p ON c.paciente_id = p.id
    WHERE c.id = consulta_uuid AND p.user_id = v_user_id
  ) INTO v_is_paciente;
  
  IF v_is_paciente THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar se é o médico da consulta
  SELECT EXISTS(
    SELECT 1 FROM consultas c
    JOIN medicos m ON c.medico_id = m.id
    WHERE c.id = consulta_uuid AND m.user_id = v_user_id
  ) INTO v_is_medico;
  
  RETURN v_is_medico;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Políticas RLS

-- SELECT: Participantes da consulta podem ver as mensagens
CREATE POLICY "Participantes podem ver mensagens"
  ON chat_mensagens FOR SELECT
  USING (is_consulta_participant(consulta_id));

-- INSERT: Participantes podem enviar mensagens
CREATE POLICY "Participantes podem enviar mensagens"
  ON chat_mensagens FOR INSERT
  WITH CHECK (
    is_consulta_participant(consulta_id) AND
    remetente_id = auth.uid()
  );

-- UPDATE: Apenas para marcar como lida (o destinatário pode marcar)
CREATE POLICY "Participantes podem marcar como lida"
  ON chat_mensagens FOR UPDATE
  USING (is_consulta_participant(consulta_id))
  WITH CHECK (is_consulta_participant(consulta_id));

-- Habilitar Realtime para a tabela
ALTER PUBLICATION supabase_realtime ADD TABLE chat_mensagens;
