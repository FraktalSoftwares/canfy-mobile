-- Campos da Etapa 3 (Disponibilidade de atendimento) da validação profissional.
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS disponibilidade_dias TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS disponibilidade_recorrencia TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS disponibilidade_horarios TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS disponibilidade_intervalo TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS autoriza_compartilhamento_dados BOOLEAN DEFAULT FALSE;
