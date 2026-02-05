-- Médico pode ver consultas em que ele está atribuído (medico_id).
CREATE POLICY "Medicos podem ver próprias consultas"
  ON consultas FOR SELECT
  USING (
    medico_id IN (SELECT id FROM public.medicos WHERE user_id = auth.uid())
  );
