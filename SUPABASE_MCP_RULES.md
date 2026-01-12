# Regras de Uso do MCP Supabase

## 🚨 REGRA FUNDAMENTAL

**SEMPRE use o MCP do Supabase (supabase-canfy) para operações de backend.**

Esta é uma regra obrigatória do projeto. Qualquer operação relacionada a backend deve ser feita através do MCP do Supabase.

## 📋 Quando Usar o MCP

### ✅ Use o MCP do Supabase para:

1. **Criação e gerenciamento de tabelas**
   - Use `mcp_supabase-canfy_apply_migration` para criar/modificar tabelas
   - Use `mcp_supabase-canfy_list_tables` para verificar estrutura

2. **Consultas SQL diretas**
   - Use `mcp_supabase-canfy_execute_sql` para queries complexas
   - Use `mcp_supabase-canfy_apply_migration` para DDL (CREATE, ALTER, DROP)

3. **Gerenciamento de migrações**
   - Use `mcp_supabase-canfy_list_migrations` para ver migrações
   - Use `mcp_supabase-canfy_apply_migration` para criar novas migrações

4. **Verificação de segurança e performance**
   - Use `mcp_supabase-canfy_get_advisors` para verificar problemas
   - Use `mcp_supabase-canfy_get_logs` para debug

5. **Geração de tipos TypeScript**
   - Use `mcp_supabase-canfy_generate_typescript_types` quando necessário

6. **Gerenciamento de branches (desenvolvimento)**
   - Use `mcp_supabase-canfy_create_branch` para criar branches
   - Use `mcp_supabase-canfy_merge_branch` para merge
   - Use `mcp_supabase-canfy_rebase_branch` para rebase

7. **Edge Functions**
   - Use `mcp_supabase-canfy_list_edge_functions` para listar
   - Use `mcp_supabase-canfy_deploy_edge_function` para deploy

### ⚠️ Quando NÃO usar o MCP (usar cliente Flutter)

1. **Operações em tempo real no app**
   - Queries que precisam de atualização em tempo real
   - Subscriptions e real-time
   - Operações que dependem do estado do app

2. **Autenticação no app**
   - Login/logout do usuário
   - Gerenciamento de sessão
   - Refresh tokens

3. **Operações que precisam de resposta imediata na UI**
   - Formulários
   - Ações do usuário que precisam de feedback instantâneo

## 🔧 Configuração

### URL do Projeto
- **URL**: `https://agqqxxfrnpuriwrmwdrq.supabase.co`
- Obtida via: `mcp_supabase-canfy_get_project_url`

### Chave Anônima
- Deve ser configurada em `lib/constants/supabase_config.dart`
- Para obter: use `mcp_supabase-canfy_get_anon_key` (se tiver permissões)
- Ou obtenha no dashboard do Supabase

## 📝 Exemplos de Uso

### Criar uma Tabela (via MCP)

```dart
// Use o MCP para criar tabelas
mcp_supabase-canfy_apply_migration(
  name: "create_users_table",
  query: """
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  """
)
```

### Consultar Dados (via Cliente Flutter)

```dart
// Use o cliente Flutter para queries no app
final apiService = ApiService();
final result = await apiService.getFiltered(
  'users',
  filters: {'status': 'active'},
);
```

### Verificar Segurança (via MCP)

```dart
// Use o MCP para verificar problemas de segurança
mcp_supabase-canfy_get_advisors(type: "security")
```

## 🎯 Estrutura de Arquivos

### Configuração
- `lib/constants/supabase_config.dart` - Configuração do Supabase

### Serviços
- `lib/services/api/api_service.dart` - Serviço base usando Supabase Flutter

### Migrações
- As migrações devem ser criadas via MCP, não manualmente

## ⚡ Boas Práticas

1. **Sempre verifique permissões antes de usar o MCP**
   - Algumas operações podem requerer privilégios específicos

2. **Use migrações para mudanças de schema**
   - Nunca altere tabelas diretamente em produção
   - Sempre use `apply_migration` para mudanças de estrutura

3. **Verifique advisors regularmente**
   - Execute `get_advisors` após mudanças importantes
   - Corrija problemas de segurança e performance

4. **Use branches para desenvolvimento**
   - Crie branches para testar mudanças
   - Merge apenas após validação

5. **Documente mudanças importantes**
   - Comente migrações complexas
   - Documente decisões de design

## 🔐 Segurança

- **Nunca commite chaves de API no código**
- Use variáveis de ambiente ou configuração segura
- Sempre verifique RLS (Row Level Security) policies
- Use `get_advisors` para verificar vulnerabilidades

## 📚 Referências

- [Documentação Supabase](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- MCP Tools disponíveis: verifique `list_mcp_resources` para ver todas as ferramentas

---

**Última atualização**: Dezembro 2024
**MCP Server**: supabase-canfy
**Projeto**: Canfy Mobile
