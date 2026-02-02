# Validação e configuração do fluxo de novo pedido no Supabase (via MCP)

Todas as operações foram feitas com o MCP **user-supabase-canfy**.

---

## 1. Validação do schema (list_tables + execute_sql)

### Tabela `produtos`
- **preco** (numeric, nullable): preço do produto. O fluxo de novo pedido usa este campo como fonte principal do valor; se não estiver definido, usa o último `pedido_itens.preco_unitario`.

### Tabela `pedidos`
- **canal_aquisicao**: enum `canal_aquisicao` → `associacao` | `marca` | `outro`
- **status**: enum `status_pedido` → `pendente`, `aprovado`, `em_analise`, etc.

### Tabela `pedido_itens`
- **produto_id**: uuid obrigatório (FK produtos)

### Tabela `documentos`
- **tipo**: enum `tipo_documento` → `identidade` | `comprovante_residencia` | `autorizacao_anvisa` | laudo_medico | exame | outro

**Ajustes no código (patient_service.dart):**
- `_normalizeCanalAquisicao()` para enviar valor do enum em `createOrder`
- Insert em `pedido_itens` apenas quando `produtoId` não é null/vazio
- `documentos.tipo`: `identidade`, `comprovante_residencia`, `autorizacao_anvisa` (não 'rg'/'anvisa')

---

## 2. Storage – bucket `documents` (execute_sql)

- **Verificação:** `SELECT * FROM storage.buckets` → existiam apenas `avatars` e `produtos`.
- **Criação:** `INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES ('documents', 'documents', true, 10485760, ARRAY['application/pdf', 'image/png', 'image/jpeg', 'image/jpg']) ON CONFLICT (id) DO NOTHING;`
- **Confirmação:** `SELECT * FROM storage.buckets` → bucket `documents` criado (public, 10MB, PDF/PNG/JPG).

---

## 3. Migrações aplicadas (apply_migration)

### storage_documents_bucket_create
- Garante o bucket `documents` de forma idempotente (`ON CONFLICT (id) DO UPDATE`).
- Versão remota: `20260202142830`.

### storage_documents_bucket_policies
- **INSERT:** usuários autenticados podem fazer upload em `order_docs/{auth.uid()}/...`
- **SELECT:** leitura pública do bucket `documents`
- **UPDATE/DELETE:** apenas em arquivos em `order_docs/{auth.uid()}/...`
- Versão remota: `20260202142806`.

---

## 4. Arquivos locais (supabase/migrations)

Para manter o histórico alinhado ao remoto:

- **007_storage_documents_bucket_create.sql** – criação idempotente do bucket
- **008_storage_documents_bucket_policies.sql** – políticas RLS em `storage.objects` para o bucket `documents`

---

## Resumo das ferramentas MCP usadas

| Ação | Ferramenta | Argumentos |
|------|------------|------------|
| Listar tabelas e colunas | list_tables | `schemas: ["public"]` |
| Listar buckets | execute_sql | `SELECT * FROM storage.buckets` |
| Criar bucket documents | execute_sql | `INSERT INTO storage.buckets ...` |
| Valores dos enums | execute_sql | `SELECT enumlabel FROM pg_enum ...` |
| Políticas storage | apply_migration | name + query (CREATE POLICY) |
| Bucket idempotente | apply_migration | name + query (INSERT ON CONFLICT) |
| Listar migrações | list_migrations | `{}` |

O fluxo de novo pedido (tabelas, enums, bucket e políticas) está validado e configurado no Supabase via MCP.
