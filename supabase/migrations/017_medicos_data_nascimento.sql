-- Migration: Adiciona coluna data_nascimento na tabela medicos
-- Permite armazenar a data de nascimento do médico

ALTER TABLE medicos
ADD COLUMN IF NOT EXISTS data_nascimento DATE;

-- Comentário para documentação
COMMENT ON COLUMN medicos.data_nascimento IS 'Data de nascimento do médico';
