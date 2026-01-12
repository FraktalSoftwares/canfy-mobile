# Ajustes no Cadastro de Paciente - Estrutura Existente

## ✅ O que foi corrigido

### 1. Tabela `patients` removida
- A tabela `patients` que foi criada incorretamente foi removida
- Agora usamos a estrutura existente do banco

### 2. Estrutura do Banco Existente

#### Tabela `profiles` (dados gerais do usuário)
- `id` (UUID, PK, referencia auth.users.id)
- `nome_completo` (TEXT, NOT NULL)
- `telefone` (TEXT, nullable)
- `foto_perfil_url` (TEXT, nullable)
- `tipo_usuario` (ENUM: 'admin', 'medico', 'paciente')
- `ativo` (BOOLEAN, default: true)
- `created_at`, `updated_at` (TIMESTAMPTZ)

#### Tabela `pacientes` (dados específicos do paciente)
- `id` (UUID, PK)
- `user_id` (UUID, FK para profiles.id)
- `cpf` (TEXT, NOT NULL, UNIQUE)
- `data_nascimento` (DATE, NOT NULL)
- `endereco_completo` (TEXT, nullable)
- `total_consultas` (INTEGER, default: 0)
- `total_pedidos` (INTEGER, default: 0)
- `ultimo_acesso` (TIMESTAMPTZ, nullable)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 3. Código Ajustado

#### AuthService (`lib/services/api/auth_service.dart`)
- ✅ Ajustado para criar primeiro o `profile`
- ✅ Depois cria o registro em `pacientes`
- ✅ Monta `endereco_completo` a partir dos campos separados do formulário
- ✅ Busca dados combinados de `profiles` + `pacientes` no login

#### PatientModel (`lib/models/patient/patient_model.dart`)
- ✅ Atualizado para refletir a estrutura real do banco
- ✅ Factory `fromProfileAndPaciente` para combinar dados
- ✅ Factory `fromProfile` para quando não há registro em pacientes ainda

### 4. Políticas RLS Adicionadas

#### Tabela `pacientes`
- ✅ **INSERT**: "Pacientes can insert their own data" - usuários podem inserir seus próprios dados
- ✅ **UPDATE**: "Pacientes can update their own data" - usuários podem atualizar seus próprios dados
- ✅ **SELECT**: "Pacientes can view their own data" - já existia
- ✅ **ALL**: "Admins can manage pacientes" - admins podem gerenciar tudo

## 📋 Fluxo de Cadastro Ajustado

1. **Criar usuário no Supabase Auth**
   - Email e senha
   - Metadata com nome, login, user_type

2. **Criar profile na tabela `profiles`**
   - `id` = user_id do auth
   - `nome_completo` = nome do formulário
   - `telefone` = telefone do formulário
   - `tipo_usuario` = 'paciente'
   - `ativo` = true

3. **Criar registro na tabela `pacientes`**
   - `user_id` = user_id do auth
   - `cpf` = CPF do formulário
   - `data_nascimento` = data de nascimento
   - `endereco_completo` = montado a partir de cep, address, number, complement, neighborhood, city, state

## 🔄 Mapeamento de Campos

### Campos do Formulário → Banco

| Formulário | Tabela | Campo |
|------------|--------|-------|
| Nome completo | profiles | nome_completo |
| Telefone | profiles | telefone |
| Email | auth.users | email |
| CPF | pacientes | cpf |
| Data nascimento | pacientes | data_nascimento |
| CEP + Endereço + Número + Complemento + Bairro + Cidade + Estado | pacientes | endereco_completo (concatenado) |

### Campos não salvos (por enquanto)
- Login (apenas no metadata do auth)
- Gênero (não existe no banco)
- Autorizar compartilhamento de dados (não existe no banco)

## ⚠️ Observações

1. **Endereço**: Os campos separados do formulário são concatenados em `endereco_completo`
   - Formato: "Rua, nº X, Bairro, Cidade, Estado, CEP: XXXXX-XXX (Complemento)"

2. **Campos faltantes**: Alguns campos do formulário não têm correspondência no banco:
   - `login` - apenas no metadata do auth
   - `gender` - não existe no banco
   - `authorize_data_sharing` - não existe no banco
   
   Se precisar desses campos, será necessário adicionar colunas nas tabelas.

3. **Relacionamento**: 
   - `pacientes.user_id` → `profiles.id` → `auth.users.id`
   - Todos os três devem ter o mesmo UUID

## 🧪 Testando

1. Execute o app
2. Preencha o formulário de cadastro
3. Verifique se:
   - O usuário é criado no auth
   - O profile é criado em `profiles`
   - O registro é criado em `pacientes`
   - O endereço está concatenado corretamente

## 📝 Próximos Passos (Opcional)

Se precisar dos campos faltantes, adicione colunas:

```sql
-- Adicionar coluna gender na tabela pacientes
ALTER TABLE pacientes ADD COLUMN gender TEXT;

-- Adicionar coluna authorize_data_sharing na tabela pacientes
ALTER TABLE pacientes ADD COLUMN authorize_data_sharing BOOLEAN DEFAULT false;

-- Adicionar coluna login na tabela profiles (se quiser salvar separado)
ALTER TABLE profiles ADD COLUMN login TEXT UNIQUE;
```

---

**Última atualização**: Dezembro 2024
