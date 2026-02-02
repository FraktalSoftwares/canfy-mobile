-- Integração Asaas: tabelas para vincular clientes e registrar cobranças
-- Documentação: https://docs.asaas.com/

-- Vincular usuário do app ao cliente (customer) no Asaas
CREATE TABLE IF NOT EXISTS asaas_customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  asaas_customer_id TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_asaas_customers_user_id ON asaas_customers(user_id);
CREATE INDEX IF NOT EXISTS idx_asaas_customers_asaas_id ON asaas_customers(asaas_customer_id);

ALTER TABLE asaas_customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own asaas customer"
  ON asaas_customers FOR SELECT
  USING (auth.uid() = user_id);

-- Inserções/atualizações são feitas pela Edge Function com service_role (bypass RLS)

-- Registro de cobranças criadas (para histórico e webhook)
CREATE TABLE IF NOT EXISTS asaas_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  asaas_payment_id TEXT NOT NULL UNIQUE,
  asaas_customer_id TEXT NOT NULL,
  reference_type TEXT, -- 'consultation', 'order', etc.
  reference_id TEXT,
  billing_type TEXT NOT NULL, -- BOLETO, PIX, CREDIT_CARD, DEBIT_CARD
  value DECIMAL(10,2) NOT NULL,
  status TEXT,
  due_date DATE,
  invoice_url TEXT,
  bank_slip_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_asaas_payments_user_id ON asaas_payments(user_id);
CREATE INDEX IF NOT EXISTS idx_asaas_payments_asaas_id ON asaas_payments(asaas_payment_id);
CREATE INDEX IF NOT EXISTS idx_asaas_payments_reference ON asaas_payments(reference_type, reference_id);

ALTER TABLE asaas_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own asaas payments"
  ON asaas_payments FOR SELECT
  USING (auth.uid() = user_id);

-- Inserções são feitas pela Edge Function com service_role (bypass RLS)

-- Trigger updated_at para asaas_customers
CREATE TRIGGER update_asaas_customers_updated_at
  BEFORE UPDATE ON asaas_customers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asaas_payments_updated_at
  BEFORE UPDATE ON asaas_payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
