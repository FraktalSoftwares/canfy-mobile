-- Tabela de consultas (nova consulta pelo paciente).
-- Se o projeto já tiver a tabela com outro schema, esta migration não altera (IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS consultas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  paciente_id UUID NOT NULL,
  medico_id UUID,
  data_consulta TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'agendada',
  queixa_principal TEXT,
  eh_retorno BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_consultas_paciente_id ON consultas(paciente_id);
CREATE INDEX IF NOT EXISTS idx_consultas_data_consulta ON consultas(data_consulta);
CREATE INDEX IF NOT EXISTS idx_consultas_status ON consultas(status);

ALTER TABLE consultas ENABLE ROW LEVEL SECURITY;

-- Paciente só vê/insere consultas do próprio paciente_id (via user -> pacientes).
CREATE POLICY "Pacientes podem ver próprias consultas"
  ON consultas FOR SELECT
  USING (
    paciente_id IN (
      SELECT id FROM pacientes WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Pacientes podem inserir própria consulta"
  ON consultas FOR INSERT
  WITH CHECK (
    paciente_id IN (
      SELECT id FROM pacientes WHERE user_id = auth.uid()
    )
  );

-- Trigger updated_at
CREATE TRIGGER update_consultas_updated_at
  BEFORE UPDATE ON consultas
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
