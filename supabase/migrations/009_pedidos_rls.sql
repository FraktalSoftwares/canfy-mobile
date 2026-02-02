-- RLS para tabelas de pedidos: paciente só acessa/insere seus próprios pedidos.
-- Usa get_paciente_ids_for_current_user() da migração 005 (pacientes ou patients).

-- Garante que a função exista (caso 005 não tenha sido aplicada antes)
CREATE OR REPLACE FUNCTION get_paciente_ids_for_current_user()
RETURNS SETOF UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'pacientes'
  ) THEN
    RETURN QUERY SELECT id FROM pacientes WHERE user_id = auth.uid();
    RETURN;
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'patients'
  ) THEN
    RETURN QUERY SELECT id FROM patients WHERE user_id = auth.uid();
  END IF;
END;
$$;

-- pedidos: SELECT e INSERT apenas para o próprio paciente_id
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Pacientes podem ver próprios pedidos" ON pedidos;
CREATE POLICY "Pacientes podem ver próprios pedidos"
  ON pedidos FOR SELECT
  USING (paciente_id IN (SELECT get_paciente_ids_for_current_user()));

DROP POLICY IF EXISTS "Pacientes podem inserir próprio pedido" ON pedidos;
CREATE POLICY "Pacientes podem inserir próprio pedido"
  ON pedidos FOR INSERT
  WITH CHECK (paciente_id IN (SELECT get_paciente_ids_for_current_user()));

-- pedido_itens: SELECT/INSERT apenas para itens de pedidos do paciente
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Pacientes podem ver itens dos próprios pedidos" ON pedido_itens;
CREATE POLICY "Pacientes podem ver itens dos próprios pedidos"
  ON pedido_itens FOR SELECT
  USING (
    pedido_id IN (
      SELECT id FROM pedidos
      WHERE paciente_id IN (SELECT get_paciente_ids_for_current_user())
    )
  );

DROP POLICY IF EXISTS "Pacientes podem inserir itens nos próprios pedidos" ON pedido_itens;
CREATE POLICY "Pacientes podem inserir itens nos próprios pedidos"
  ON pedido_itens FOR INSERT
  WITH CHECK (
    pedido_id IN (
      SELECT id FROM pedidos
      WHERE paciente_id IN (SELECT get_paciente_ids_for_current_user())
    )
  );

-- documentos: SELECT/INSERT apenas para documentos do próprio paciente (se a tabela existir)
ALTER TABLE documentos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Pacientes podem ver próprios documentos" ON documentos;
CREATE POLICY "Pacientes podem ver próprios documentos"
  ON documentos FOR SELECT
  USING (paciente_id IN (SELECT get_paciente_ids_for_current_user()));

DROP POLICY IF EXISTS "Pacientes podem inserir próprio documento" ON documentos;
CREATE POLICY "Pacientes podem inserir próprio documento"
  ON documentos FOR INSERT
  WITH CHECK (paciente_id IN (SELECT get_paciente_ids_for_current_user()));
