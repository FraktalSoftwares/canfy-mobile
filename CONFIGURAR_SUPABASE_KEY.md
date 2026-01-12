# 🔑 Como Configurar a Chave do Supabase

## ⚠️ Erro Atual

Você está recebendo o erro: **"Invalid API key"** porque a chave anônima do Supabase não está configurada.

## 📋 Passo a Passo

### 1. Acessar o Dashboard do Supabase

1. Acesse: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: **agqqxxfrnpuriwrmwdrq**

### 2. Obter a Chave Anônima

1. No menu lateral, clique em **Settings** (Configurações)
2. Clique em **API** (ou vá direto: https://supabase.com/dashboard/project/agqqxxfrnpuriwrmwdrq/settings/api)
3. Na seção **Project API keys**, você verá:
   - **anon public** - Esta é a chave que você precisa
   - **service_role** - NÃO use esta (é secreta)

### 3. Copiar a Chave

1. Clique no ícone de **copiar** ao lado da chave **anon public**
2. A chave será algo como: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (muito longa)

### 4. Configurar no Projeto

1. Abra o arquivo: `lib/constants/supabase_config.dart`
2. Localize a linha:
   ```dart
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```
3. Substitua `'YOUR_ANON_KEY_HERE'` pela chave que você copiou:
   ```dart
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```
4. Salve o arquivo

### 5. Reiniciar o App

1. Pare o app (se estiver rodando)
2. Execute novamente: `flutter run`
3. Tente criar uma conta novamente

## 🔍 Verificar se Está Correto

O arquivo `lib/constants/supabase_config.dart` deve ficar assim:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://agqqxxfrnpuriwrmwdrq.supabase.co';
  
  static const String supabaseAnonKey = 'SUA_CHAVE_AQUI'; // ← Deve ter uma chave longa aqui
  
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty && 
           supabaseAnonKey != 'YOUR_ANON_KEY_HERE';
  }
}
```

## ⚠️ Importante

- **NUNCA** commite a chave anônima no Git se o repositório for público
- A chave anônima é segura para usar no cliente (app mobile)
- Se o repositório for público, considere usar variáveis de ambiente

## 🆘 Se Ainda Não Funcionar

1. Verifique se copiou a chave completa (ela é muito longa)
2. Verifique se não há espaços extras
3. Verifique se está usando a chave **anon public**, não a **service_role**
4. Tente reiniciar o app completamente

---

**URL Direta para API Settings**: https://supabase.com/dashboard/project/agqqxxfrnpuriwrmwdrq/settings/api
