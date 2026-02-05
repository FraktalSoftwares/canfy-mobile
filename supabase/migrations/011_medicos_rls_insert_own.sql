-- Permite que o próprio usuário insira seu registro em medicos (cadastro de médico).
CREATE POLICY "Users can insert own medico row"
  ON public.medicos
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Permite que o médico veja e atualize seu próprio registro.
CREATE POLICY "Medicos can view own row"
  ON public.medicos
  FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Medicos can update own row"
  ON public.medicos
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
