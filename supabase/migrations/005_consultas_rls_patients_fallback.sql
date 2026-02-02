-- Permite que a RLS de consultas funcione tanto com tabela "pacientes" quanto "patients".
-- Útil quando o banco usa a tabela "patients" (001) em vez de "pacientes".

CREATE OR REPLACE FUNCTION get_paciente_ids_for_current_user()
RETURNS SETOF UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Tenta primeiro a tabela "pacientes" (PT)
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'pacientes'
  ) THEN
    RETURN QUERY SELECT id FROM pacientes WHERE user_id = auth.uid();
    RETURN;
  END IF;
  -- Fallback para "patients" (EN)
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'patients'
  ) THEN
    RETURN QUERY SELECT id FROM patients WHERE user_id = auth.uid();
  END IF;
END;
$$;

-- Remove políticas antigas que referenciam só "pacientes" (evita duplicata de permissão)
DROP POLICY IF EXISTS "Pacientes podem ver próprias consultas" ON consultas;
DROP POLICY IF EXISTS "Pacientes podem inserir própria consulta" ON consultas;

-- Nova política SELECT usando a função (aceita pacientes ou patients)
CREATE POLICY "Pacientes podem ver próprias consultas"
  ON consultas FOR SELECT
  USING (paciente_id IN (SELECT get_paciente_ids_for_current_user()));

-- Nova política INSERT usando a função
CREATE POLICY "Pacientes podem inserir própria consulta"
  ON consultas FOR INSERT
  WITH CHECK (paciente_id IN (SELECT get_paciente_ids_for_current_user()));
