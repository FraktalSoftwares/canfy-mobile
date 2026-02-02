-- Vincula documentos ao pedido para que a tela de detalhes do pedido
-- mostre apenas os documentos enviados naquele pedido (não todos do paciente).

ALTER TABLE documentos
  ADD COLUMN IF NOT EXISTS pedido_id uuid REFERENCES pedidos(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_documentos_pedido_id ON documentos(pedido_id);

COMMENT ON COLUMN documentos.pedido_id IS 'Quando preenchido, o documento foi enviado neste pedido.';
