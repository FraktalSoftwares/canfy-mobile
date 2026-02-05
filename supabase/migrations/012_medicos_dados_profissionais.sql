-- Campos para dados profissionais complementares (Step1 validação).
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS cpf TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS tempo_atuacao TEXT;
ALTER TABLE public.medicos ADD COLUMN IF NOT EXISTS endereco_completo TEXT;
