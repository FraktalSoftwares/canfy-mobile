# Setup do Cadastro de Paciente

## ✅ O que foi implementado

1. **AuthService** (`lib/services/api/auth_service.dart`)
   - Método `registerPatient()` para cadastrar novos pacientes
   - Método `login()` para autenticação
   - Método `getCurrentPatient()` para obter dados do paciente logado
   - Método `logout()` para encerrar sessão

2. **PatientModel** (`lib/models/patient/patient_model.dart`)
   - Modelo completo com todos os campos do cadastro
   - Métodos `fromJson()` e `toJson()` para serialização

3. **Integração na RegisterPage**
   - Validação completa do formulário
   - Integração com AuthService
   - Feedback visual (loading, erros)
   - Navegação para verificação de telefone após cadastro

4. **SQL de Migração**
   - Arquivo `supabase/migrations/001_create_patients_table.sql`
   - Pronto para ser executado no Supabase

## 📋 Próximos Passos

### 1. Criar Tabela no Supabase

**IMPORTANTE**: Execute o SQL de migração no Supabase antes de testar o cadastro.

Você pode fazer isso de duas formas:

#### Opção A: Via Dashboard do Supabase
1. Acesse o [Dashboard do Supabase](https://supabase.com/dashboard)
2. Vá em **SQL Editor**
3. Cole o conteúdo do arquivo `supabase/migrations/001_create_patients_table.sql`
4. Execute o SQL

#### Opção B: Via MCP (quando tiver permissões)
```dart
// Use o MCP para criar a migração
mcp_supabase-canfy_apply_migration(
  name: "create_patients_table",
  query: "<conteúdo do arquivo SQL>"
)
```

### 2. Configurar Chave Anônima

Certifique-se de que a chave anônima do Supabase está configurada em:
- `lib/constants/supabase_config.dart`

Para obter a chave:
1. Dashboard do Supabase → Settings → API
2. Copie a **anon key**
3. Cole em `SupabaseConfig.supabaseAnonKey`

### 3. Testar o Cadastro

1. Execute o app: `flutter run`
2. Navegue até a tela de cadastro
3. Preencha todos os campos obrigatórios:
   - Nome completo
   - Login
   - Email
   - Senha (mínimo 6 caracteres)
   - CPF
   - Telefone
   - Data de nascimento (DD/MM/AAAA)
   - Aceitar termos de uso
4. Clique em "Criar conta"
5. Deve navegar para a tela de verificação de telefone

## 🔍 Campos do Formulário

### Obrigatórios
- Nome completo
- Login
- Email
- Senha
- Confirmar senha
- CPF
- Telefone
- Data de nascimento
- Aceitar termos de uso

### Opcionais
- Gênero
- CEP
- Endereço
- Número
- Complemento
- Bairro
- Cidade
- Estado
- Autorizar compartilhamento de dados

## 🗄️ Estrutura da Tabela

A tabela `patients` contém:
- `id` - UUID (chave primária)
- `user_id` - UUID (referência ao auth.users)
- `name` - Nome completo
- `login` - Login único
- `email` - Email
- `phone` - Telefone
- `cpf` - CPF único
- `birth_date` - Data de nascimento
- `gender` - Gênero
- `cep`, `address`, `address_number`, `complement`, `neighborhood`, `city`, `state` - Endereço
- `avatar_url` - URL do avatar
- `authorize_data_sharing` - Autorização de compartilhamento
- `created_at`, `updated_at` - Timestamps

## 🔐 Segurança (RLS)

A tabela está protegida com Row Level Security (RLS):
- Usuários só podem ver seus próprios dados
- Usuários só podem inserir seus próprios dados
- Usuários só podem atualizar seus próprios dados

## 🐛 Troubleshooting

### Erro: "Table 'patients' does not exist"
- Execute o SQL de migração no Supabase

### Erro: "Invalid API key"
- Verifique se a chave anônima está configurada corretamente

### Erro: "User already exists"
- O email já está cadastrado no Supabase Auth

### Erro: "Login already exists"
- O login escolhido já está em uso

### Erro: "CPF already exists"
- O CPF já está cadastrado

## 📝 Notas

- O cadastro cria primeiro o usuário no Supabase Auth
- Depois cria o perfil na tabela `patients`
- Se a criação do perfil falhar, o usuário ainda será criado no Auth (em produção, considere usar triggers ou funções para garantir consistência)
- A validação de telefone é feita na próxima tela (`/phone-verification`)

---

**Última atualização**: Dezembro 2024
