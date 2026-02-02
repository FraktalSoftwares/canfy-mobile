-- Armazena o ID do cliente Asaas no profile para uso em pagamentos.
-- Criado no cadastro (register) e usado no fluxo de pagamento.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS asaas_customer_id TEXT;
