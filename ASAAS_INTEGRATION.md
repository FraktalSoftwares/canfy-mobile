# Integração Asaas – Gateway de pagamento (via Supabase)

Este projeto utiliza o **Asaas** como gateway de pagamento, integrado **via Supabase** (Edge Functions + tabelas). Documentação Asaas: [https://docs.asaas.com/](https://docs.asaas.com/).

## Visão geral

- **API:** v3 (REST)
- **Formas de pagamento suportadas:** PIX, boleto bancário, cartão de crédito, cartão de débito, TED
- **Ambientes:**
  - **Sandbox (testes):** API base `https://api-sandbox.asaas.com/v3` | Conta: [sandbox.asaas.com](https://sandbox.asaas.com)
  - **Produção:** API base `https://api.asaas.com/v3` | Conta: [asaas.com](https://asaas.com)

A Asaas é instituição de pagamento autorizada pelo Banco Central e certificada PCI-DSS.

## Integração via Supabase (MCP)

A integração foi feita **pelo MCP Supabase (user-supabase-canfy)**:

1. **Migrations aplicadas** – Banco:
   - `asaas_customers`: vincula `user_id` (auth.users) ao `asaas_customer_id`
   - `asaas_payments`: registro de cobranças (id Asaas, valor, status, invoice_url, bank_slip_url, referência)
   - **`profiles.asaas_customer_id`**: coluna na tabela `profiles` para guardar o ID do cliente Asaas do usuário. Criado no cadastro e usado em todos os pagamentos.

2. **Edge Functions implantadas**:
   - **asaas-sync-customer** (JWT obrigatório) – Cria ou retorna o cliente Asaas do usuário logado e **atualiza `profiles.asaas_customer_id`**. Body: `{ name, cpfCnpj?, email?, mobilePhone? }`.
   - **asaas-create-payment** (JWT obrigatório) – Cria cobrança no Asaas. Body: `{ asaas_customer_id?, value, billingType, dueDate?, description?, reference_type?, reference_id? }`. Se não enviar `asaas_customer_id`, usa o vínculo em `asaas_customers`.
   - **asaas-webhook** (sem JWT) – Recebe eventos do Asaas (PAYMENT_RECEIVED, PAYMENT_CONFIRMED, etc.), atualiza `asaas_payments.status` e, quando o pagamento é confirmado, atualiza o **pedido** (`pedidos.status = 'aprovado'`) ou a **consulta** (`consultas.status = 'confirmada'`) conforme `reference_type`/`reference_id` gravados na cobrança.

3. **App Flutter** – `lib/services/api/asaas_service.dart` chama essas Edge Functions. No **cadastro** (`register_page.dart`), após criar a conta, o app chama `syncCustomer` para criar o cliente no Asaas e gravar o ID no profile. No **pagamento** (step 4 da consulta), o app usa `asaas_customer_id` do profile quando existir; caso contrário, chama `syncCustomer` e depois `createPayment`.

### Configurar secrets no Supabase

As Edge Functions usam variáveis de ambiente. **Defina no projeto Supabase**:

1. Dashboard Supabase → **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   - **ASAAS_API_KEY** – API Key do Asaas (Sandbox ou Produção)
   - **ASAAS_BASE_URL** (opcional) – `https://api-sandbox.asaas.com/v3` (sandbox) ou `https://api.asaas.com/v3` (produção). Se não definir, usa sandbox.
   - **ASAAS_WEBHOOK_ACCESS_TOKEN** (opcional) – Token que o Asaas envia no header `asaas-access-token` ao chamar o webhook. Gere um UUID v4 e configure o mesmo valor no Asaas ao criar o webhook; a Edge Function valida esse header. Se não definir, o webhook aceita qualquer chamada (útil em dev; em produção é recomendado configurar).

Para obter a API Key: [Sandbox Asaas](https://sandbox.asaas.com/) → Minha conta → Integrações → API Key.

### Repetir migration ou deploy via MCP

- **Migration:** use a ferramenta `apply_migration` do MCP com `name` (snake_case) e `query` (SQL). O SQL está em `supabase/migrations/002_asaas_tables.sql` (a função `update_updated_at_column` foi incluída na migration aplicada para ser autocontida).
- **Edge Functions:** use `deploy_edge_function` com `name`, `entrypoint_path`, `files` (array com `index.ts`). Para **asaas-sync-customer** e **asaas-create-payment** use `verify_jwt: true`; para **asaas-webhook** use **`verify_jwt: false`** (o Asaas chama a URL sem JWT). Código em:
  - `supabase/functions/asaas-sync-customer/index.ts`
  - `supabase/functions/asaas-create-payment/index.ts`
  - `supabase/functions/asaas-webhook/index.ts`

## Fluxo no app

### Cadastro (Canfy)

1. Usuário preenche o formulário e toca em **Criar conta**.
2. `AuthService.registerPatient` cria o usuário, profile e paciente.
3. Após sucesso, o app chama `AsaasService.syncCustomer(name, email, mobilePhone, cpfCnpj)`.
4. A Edge Function cria o cliente no Asaas, grava em `asaas_customers` e **atualiza `profiles.asaas_customer_id`**.
5. Assim, todo usuário novo já tem cliente Asaas e ID salvo no profile.

### Pagamento (consultas)

1. Usuário preenche step 4 (pagamento) e toca em **Confirmar pagamento** (ou **Gerar código Pix**).
2. App busca dados do paciente (`getCurrentPatient`). Se o **profile** tiver `asaas_customer_id`, usa esse ID.
3. Se não tiver, chama `AsaasService.syncCustomer(...)` (que atualiza o profile) e usa o ID retornado.
4. App chama `AsaasService.createPayment(asaasCustomerId: ..., value, billingType, ...)`.
5. Edge Function cria cobrança no Asaas, grava em `asaas_payments` e retorna `invoiceUrl` / `bankSlipUrl` quando aplicável.
6. App exibe sucesso e pode abrir o link (PIX/boleto); depois navega para a lista de consultas.

## Webhook – confirmação de pagamento

Para que o sistema atualize automaticamente o status do **pedido** ou da **consulta** quando o pagamento for confirmado (PIX pago, boleto pago, cartão aprovado), é necessário configurar o **webhook** no Asaas apontando para a Edge Function **asaas-webhook**.

### O que o webhook faz

1. Recebe eventos POST do Asaas (ex.: `PAYMENT_RECEIVED`, `PAYMENT_CONFIRMED`).
2. Atualiza o registro em `asaas_payments` com o novo `status`.
3. Se o evento for de pagamento confirmado e existir `reference_type`/`reference_id`:
   - **order** → atualiza `pedidos.status` para `aprovado` e insere em `pedido_historico`.
   - **consultation** → atualiza `consultas.status` para `confirmada`.

### Configurar o webhook no Asaas

1. **Implante a Edge Function** `asaas-webhook` com **`verify_jwt: false`** (o Asaas não envia JWT).
2. **URL do webhook:**  
   `https://<PROJECT_REF>.supabase.co/functions/v1/asaas-webhook`  
   (substitua `<PROJECT_REF>` pelo ID do projeto no Supabase).
3. No painel do Asaas (Sandbox ou Produção):
   - **Integrações** → **Webhooks** → **Criar novo webhook**
   - **URL:** a URL acima
   - **Eventos:** marque pelo menos **PAYMENT_RECEIVED** e **PAYMENT_CONFIRMED** (e outros que quiser)
   - **accessToken (opcional):** gere um UUID v4 e defina o mesmo valor no secret **ASAAS_WEBHOOK_ACCESS_TOKEN** no Supabase; o Asaas enviará esse valor no header `asaas-access-token` e a função validará.
4. Teste com um pagamento em Sandbox e confira os [Logs de Webhooks](https://sandbox.asaas.com/customerConfigIntegrations/webhookLogs) no Asaas.

Documentação Asaas: [Receba eventos do Asaas no seu endpoint de Webhook](https://docs.asaas.com/docs/receba-eventos-do-asaas-no-seu-endpoint-de-webhook), [Eventos para cobranças](https://docs.asaas.com/docs/webhook-para-cobrancas).

## Onde o app usa pagamento

- **Consultas (patient):** `lib/pages/patient/consultations/new_consultation_step4_page.dart` – integrado com Asaas via Supabase.
- **Pedidos (patient):** `lib/pages/patient/orders/new_order_step5_page.dart` – pode usar o mesmo `AsaasService.createPayment` com `referenceType: 'order'` e `referenceId`.

## Referência rápida

| Recurso        | Link |
|----------------|------|
| Documentação   | [docs.asaas.com](https://docs.asaas.com/) |
| Guias         | [docs.asaas.com/docs](https://docs.asaas.com/docs) |
| Referência API| [docs.asaas.com/reference](https://docs.asaas.com/reference) |
| Cobrança cartão| [Criar cobrança com cartão de crédito](https://docs.asaas.com/reference/criar-cobranca-com-cartao-de-credito) |
| Cobrança boleto| [Cobranças via boleto](https://docs.asaas.com/docs/cobrancas-via-boleto) |
| Sandbox       | [sandbox.asaas.com](https://sandbox.asaas.com/) |
| Status        | [status.asaas.com](https://status.asaas.com/) |

## Segurança

- A **API Key do Asaas** fica apenas no Supabase (secrets das Edge Functions), nunca no app.
- As Edge Functions de criação/sync exigem **JWT** (`verify_jwt: true`); o app envia o token do usuário logado. A **asaas-webhook** usa **`verify_jwt: false`** (chamada pelo Asaas) e opcionalmente valida o header `asaas-access-token`.
- Para cartão, preferir fluxo em que os dados sensíveis passem pelo backend ou pelo próprio Asaas (tokenização/checkout).
