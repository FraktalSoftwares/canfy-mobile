-- Fase 1 — Backend do loop médico↔paciente.
--
-- Hoje o médico só tem SELECT em receitas/receita_itens/consultas e nenhum
-- acesso a repasses_medicos, então não consegue: emitir receita, assumir/
-- atualizar/finalizar atendimento, nem ver os próprios repasses. Em vez de
-- afrouxar o RLS, seguimos o padrão da casa (funções SECURITY DEFINER, como as
-- admin_*): o app chama via supabase.rpc() e a função valida que o chamador é o
-- médico dono do recurso antes de gravar.

-- Coluna para o resumo do atendimento (finalização pelo médico).
ALTER TABLE public.consultas
  ADD COLUMN IF NOT EXISTS resumo_atendimento TEXT;

-- Helper: id do médico do usuário autenticado (ou NULL se não for médico).
CREATE OR REPLACE FUNCTION public.medico_atual_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT id FROM public.medicos WHERE user_id = auth.uid() LIMIT 1;
$$;

-- ---------------------------------------------------------------------------
-- Atendimentos: listar, assumir da fila, atualizar status, finalizar.
-- ---------------------------------------------------------------------------

-- Lista consultas atribuídas ao médico logado; opcionalmente inclui a "fila"
-- (consultas agendadas ainda sem médico) para o médico assumir.
CREATE OR REPLACE FUNCTION public.medico_listar_atendimentos(
  p_status text DEFAULT NULL,
  p_incluir_fila boolean DEFAULT false,
  p_limit integer DEFAULT 100
)
RETURNS TABLE(
  id uuid,
  data_consulta timestamptz,
  status text,
  queixa_principal text,
  eh_retorno boolean,
  paciente_id uuid,
  paciente_nome text,
  receita_id uuid,
  na_fila boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  RETURN QUERY
  SELECT
    c.id,
    c.data_consulta,
    c.status::text,
    c.queixa_principal,
    c.eh_retorno,
    c.paciente_id,
    pr.nome_completo,
    c.receita_id,
    (c.medico_id IS NULL) AS na_fila
  FROM consultas c
  JOIN pacientes pac ON pac.id = c.paciente_id
  JOIN profiles pr ON pr.id = pac.user_id
  WHERE (
      c.medico_id = v_medico
      OR (p_incluir_fila AND c.medico_id IS NULL AND c.status = 'agendada')
    )
    AND (p_status IS NULL OR c.status::text = p_status)
  ORDER BY c.data_consulta DESC
  LIMIT GREATEST(COALESCE(p_limit, 100), 1);
END;
$$;

-- Médico assume uma consulta da fila (medico_id ainda NULL).
CREATE OR REPLACE FUNCTION public.medico_assumir_consulta(p_consulta_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  UPDATE consultas
  SET medico_id = v_medico, updated_at = now()
  WHERE id = p_consulta_id AND medico_id IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'consulta indisponivel';
  END IF;
END;
$$;

-- Médico altera o status de uma consulta sua (em_andamento / finalizada / agendada).
CREATE OR REPLACE FUNCTION public.medico_atualizar_status_consulta(
  p_consulta_id uuid,
  p_status text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  IF p_status NOT IN ('agendada', 'em_andamento', 'finalizada') THEN
    RAISE EXCEPTION 'status invalido';
  END IF;

  UPDATE consultas
  SET status = p_status::status_consulta, updated_at = now()
  WHERE id = p_consulta_id AND medico_id = v_medico;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not authorized';
  END IF;
END;
$$;

-- Finaliza o atendimento: status = finalizada, grava resumo e incrementa o
-- contador de atendimentos do médico.
CREATE OR REPLACE FUNCTION public.medico_finalizar_atendimento(
  p_consulta_id uuid,
  p_resumo text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  UPDATE consultas
  SET status = 'finalizada'::status_consulta,
      resumo_atendimento = COALESCE(p_resumo, resumo_atendimento),
      updated_at = now()
  WHERE id = p_consulta_id AND medico_id = v_medico;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  UPDATE medicos
  SET total_atendimentos = total_atendimentos + 1, updated_at = now()
  WHERE id = v_medico;
END;
$$;

-- ---------------------------------------------------------------------------
-- Emissão de receita pelo médico (receitas + receita_itens).
-- p_itens: jsonb array de objetos
--   { "produto_id": uuid, "posologia": text,
--     "quantidade_prescrita": int, "duracao_tratamento": text }
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.medico_emitir_receita(
  p_paciente_id uuid,
  p_validade date,
  p_itens jsonb,
  p_consulta_id uuid DEFAULT NULL,
  p_observacoes text DEFAULT NULL
)
RETURNS TABLE(id uuid, numero_receita text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
  v_paciente uuid;
  v_receita_id uuid;
  v_numero text;
  v_item jsonb;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  -- Se veio de uma consulta, valida que é do médico e deriva o paciente.
  IF p_consulta_id IS NOT NULL THEN
    SELECT c.paciente_id INTO v_paciente
    FROM consultas c
    WHERE c.id = p_consulta_id AND c.medico_id = v_medico;
    IF v_paciente IS NULL THEN
      RAISE EXCEPTION 'consulta invalida';
    END IF;
  ELSE
    v_paciente := p_paciente_id;
  END IF;

  IF v_paciente IS NULL THEN
    RAISE EXCEPTION 'paciente obrigatorio';
  END IF;

  IF p_itens IS NULL OR jsonb_typeof(p_itens) <> 'array'
     OR jsonb_array_length(p_itens) = 0 THEN
    RAISE EXCEPTION 'itens obrigatorios';
  END IF;

  v_numero := public.gerar_numero_receita();

  INSERT INTO receitas(
    numero_receita, medico_id, paciente_id, data_emissao,
    validade, observacoes, status
  )
  VALUES (
    v_numero, v_medico, v_paciente, now(),
    p_validade, p_observacoes, 'ativa'
  )
  RETURNING receitas.id INTO v_receita_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_itens)
  LOOP
    INSERT INTO receita_itens(
      receita_id, produto_id, posologia,
      quantidade_prescrita, duracao_tratamento
    )
    VALUES (
      v_receita_id,
      (v_item->>'produto_id')::uuid,
      v_item->>'posologia',
      COALESCE((v_item->>'quantidade_prescrita')::int, 1),
      v_item->>'duracao_tratamento'
    );
  END LOOP;

  IF p_consulta_id IS NOT NULL THEN
    UPDATE consultas
    SET receita_id = v_receita_id, updated_at = now()
    WHERE consultas.id = p_consulta_id; -- qualificado: OUT param `id` colide
  END IF;

  UPDATE medicos
  SET total_receitas = total_receitas + 1, updated_at = now()
  WHERE medicos.id = v_medico; -- qualificado: OUT param `id` colide

  RETURN QUERY SELECT v_receita_id, v_numero;
END;
$$;

-- ---------------------------------------------------------------------------
-- Financeiro do médico: listar repasses e resumo.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.medico_listar_repasses(p_limit integer DEFAULT 100)
RETURNS TABLE(
  id uuid,
  data_repasse date,
  valor numeric,
  status text,
  observacao text,
  pedido_id uuid
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  RETURN QUERY
  SELECT r.id, r.data_repasse, r.valor, r.status, r.observacao, r.pedido_id
  FROM repasses_medicos r
  WHERE r.medico_id = v_medico
  ORDER BY r.data_repasse DESC
  LIMIT GREATEST(COALESCE(p_limit, 100), 1);
END;
$$;

CREATE OR REPLACE FUNCTION public.medico_resumo_financeiro()
RETURNS TABLE(
  total_recebido numeric,
  total_pendente numeric,
  total_atendimentos integer
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_medico uuid;
BEGIN
  v_medico := public.medico_atual_id();
  IF v_medico IS NULL THEN
    RAISE EXCEPTION 'not authorized';
  END IF;

  RETURN QUERY
  SELECT
    COALESCE(SUM(r.valor) FILTER (WHERE r.status = 'pago'), 0)::numeric,
    COALESCE(SUM(r.valor) FILTER (WHERE r.status = 'pendente'), 0)::numeric,
    (SELECT m.total_atendimentos FROM medicos m WHERE m.id = v_medico)
  FROM repasses_medicos r
  WHERE r.medico_id = v_medico;
END;
$$;

-- Permitir que usuários autenticados executem as RPCs (a autorização fina é
-- feita dentro de cada função via medico_atual_id()).
GRANT EXECUTE ON FUNCTION public.medico_atual_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_listar_atendimentos(text, boolean, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_assumir_consulta(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_atualizar_status_consulta(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_finalizar_atendimento(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_emitir_receita(uuid, date, jsonb, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_listar_repasses(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.medico_resumo_financeiro() TO authenticated;
