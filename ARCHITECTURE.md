# Arquitetura do Projeto Canfy Mobile

## 📐 Visão Geral da Arquitetura

O projeto Canfy Mobile segue uma **arquitetura em camadas** (Layered Architecture), separando responsabilidades de forma clara e facilitando manutenção e escalabilidade.

```
┌─────────────────────────────────────────┐
│      CAMADA DE APRESENTAÇÃO             │
│  (Pages, Widgets, UI Components)        │
├─────────────────────────────────────────┤
│      CAMADA DE DOMÍNIO                  │
│  (Models, Business Logic)               │
├─────────────────────────────────────────┤
│      CAMADA DE DADOS                    │
│  (Services, API, Storage)                │
└─────────────────────────────────────────┘
```

## 🏗 Estrutura de Camadas

### 1. Camada de Apresentação

**Localização**: `lib/pages/` e `lib/widgets/`

#### Responsabilidades:
- Renderização da UI
- Interação com o usuário
- Navegação entre telas
- Validação de formulários (nível de apresentação)

#### Componentes:

**Pages (Telas)**
- Cada tela é um widget independente
- Organizadas por módulo/funcionalidade
- Separadas por tipo de usuário (patient/, doctor/)

**Widgets (Componentes)**
- Componentes reutilizáveis
- Widgets comuns (BottomNavigationBar, CustomAppBar)
- Componentes específicos de funcionalidade

### 2. Camada de Domínio

**Localização**: `lib/models/`

#### Responsabilidades:
- Definição de entidades de negócio
- Validação de dados
- Lógica de negócio pura

#### Modelos:

**UserModel**
- Representa usuários do sistema
- Suporta diferentes tipos (patient, doctor, prescriber)

**ConsultationModel**
- Representa consultas médicas
- Gerencia estados e relacionamentos

**OrderModel**
- Representa pedidos de produtos
- Contém itens e status

**ProductModel**
- Representa produtos canabinoides
- Informações técnicas e clínicas

### 3. Camada de Dados

**Localização**: `lib/services/`

#### Responsabilidades:
- Comunicação com APIs externas
- Armazenamento local
- Cache de dados
- Transformação de dados

#### Serviços:

**ApiService**
- Base para todas as chamadas HTTP
- Gerenciamento de headers e autenticação
- Tratamento de erros de rede

**StorageService**
- Armazenamento local (SharedPreferences)
- Cache de dados do usuário
- Configurações da aplicação

## 🔄 Fluxo de Dados

```
User Action
    ↓
Page/Widget
    ↓
Service (API/Storage)
    ↓
Model (Domain)
    ↓
Service Response
    ↓
Page Update (UI)
```

## 🎯 Princípios de Design

### 1. Separation of Concerns (SoC)
Cada camada tem uma responsabilidade específica e bem definida.

### 2. Single Responsibility Principle (SRP)
Cada classe/arquivo tem uma única responsabilidade.

### 3. Don't Repeat Yourself (DRY)
Componentes reutilizáveis evitam duplicação de código.

### 4. Dependency Inversion
Camadas superiores não dependem de implementações específicas.

## 📦 Organização de Módulos

### Módulo de Autenticação
```
pages/
├── splash/
├── user_selection/
├── register/
├── login/
├── phone_verification/
├── forgot_password/
└── pending_review/
```

### Módulo do Médico/Prescritor
```
pages/
├── home/              # Home do médico
├── appointment/       # Atendimentos
├── financial/         # Financeiro
└── profile/           # Perfil profissional
```

### Módulo do Paciente
```
pages/patient/
├── home/              # Home do paciente
├── catalog/           # Catálogo de produtos
├── orders/            # Pedidos
├── consultations/     # Consultas
├── prescriptions/     # Receitas
└── account/          # Conta e configurações
```

## 🔌 Integração com Backend

### Estrutura de API (Planejada)

```
services/api/
├── api_service.dart          # Base
├── auth_service.dart         # Autenticação
├── consultation_service.dart # Consultas
├── order_service.dart        # Pedidos
├── product_service.dart      # Produtos
└── user_service.dart         # Usuários
```

### Padrão de Resposta

```dart
{
  "success": true,
  "data": { ... },
  "message": "Operação realizada com sucesso",
  "errors": []
}
```

## 💾 Gerenciamento de Estado

### Provider Pattern

O projeto usa **Provider** para gerenciamento de estado:

- **ThemeNotifier**: Tema claro/escuro
- **AuthProvider**: Estado de autenticação (a implementar)
- **UserProvider**: Dados do usuário (a implementar)

### Estado Local vs Global

- **Estado Local**: `StatefulWidget` para estado específico da tela
- **Estado Global**: Provider para dados compartilhados

## 🧪 Testabilidade

### Estrutura de Testes (Planejada)

```
test/
├── unit/              # Testes unitários
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/            # Testes de widget
│   └── pages/
└── integration/       # Testes de integração
```

## 🔐 Segurança

### Boas Práticas Implementadas

1. **Armazenamento Seguro**
   - SharedPreferences para dados não sensíveis
   - (Futuro: SecureStorage para tokens)

2. **Validação de Dados**
   - Validação em formulários
   - Sanitização de inputs

3. **Autenticação**
   - Tokens JWT (a implementar)
   - Refresh tokens (a implementar)

## 📱 Navegação

### GoRouter

Navegação declarativa usando GoRouter:

- Rotas nomeadas
- Deep linking
- Navegação aninhada
- Guards de autenticação (a implementar)

## 🎨 Temas e Estilos

### Sistema de Design

- **Cores**: Centralizadas em `app_colors.dart`
- **Strings**: Centralizadas em `app_strings.dart`
- **Temas**: Configurados em `app_theme.dart`
- **Fontes**: Google Fonts (Truculenta, Arimo, Inter)

## 🚀 Performance

### Otimizações

1. **Lazy Loading**: Carregamento sob demanda
2. **Image Caching**: Cache de imagens (a implementar)
3. **Code Splitting**: Separação por módulos
4. **Widget Reuse**: Componentes reutilizáveis

## 📈 Escalabilidade

### Preparação para Crescimento

1. **Modularização**: Estrutura por módulos
2. **Abstrações**: Interfaces para serviços
3. **Configuração**: Constantes centralizadas
4. **Documentação**: Código documentado

## 🔄 Versionamento

### Estrutura de Versão

```
MAJOR.MINOR.PATCH+BUILD
1.0.0+1
```

- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs
- **BUILD**: Número de build

## 📝 Convenções de Código

### Nomenclatura

- **Classes**: PascalCase (`UserModel`)
- **Arquivos**: snake_case (`user_model.dart`)
- **Variáveis**: camelCase (`userName`)
- **Constantes**: camelCase com prefixo (`appColors`)

### Estrutura de Arquivo

```dart
// 1. Imports
import 'package:flutter/material.dart';

// 2. Classe principal
class MyWidget extends StatelessWidget {
  // 3. Construtor
  const MyWidget({super.key});
  
  // 4. Métodos públicos
  @override
  Widget build(BuildContext context) {
    // 5. Implementação
  }
  
  // 6. Métodos privados
  Widget _buildPrivateMethod() {
    // ...
  }
}
```

## 🎯 Próximos Passos Arquiteturais

1. ✅ Estrutura de pastas organizada
2. ✅ Componentes reutilizáveis
3. ✅ Modelos de dados
4. ⏳ Integração com API
5. ⏳ Gerenciamento de estado global
6. ⏳ Testes automatizados
7. ⏳ CI/CD Pipeline
8. ⏳ Monitoramento e Analytics

---

**Última atualização**: Dezembro 2024






