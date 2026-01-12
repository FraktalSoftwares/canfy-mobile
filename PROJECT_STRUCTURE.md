# Estrutura do Projeto Canfy Mobile

Este documento detalha a organização completa do projeto, facilitando navegação e manutenção.

## 📂 Estrutura de Diretórios

```
canfy_mobile/
├── android/                    # Configurações Android
├── ios/                        # Configurações iOS
├── web/                        # Configurações Web
├── assets/                     # Recursos estáticos
│   ├── images/                 # Imagens
│   ├── fonts/                  # Fontes customizadas
│   ├── videos/                 # Vídeos
│   ├── audios/                 # Áudios
│   ├── rive_animations/        # Animações Rive
│   ├── pdfs/                   # Documentos PDF
│   └── jsons/                  # Arquivos JSON
├── lib/                        # Código fonte Dart
│   ├── core/                   # Configurações centrais
│   │   ├── router/             # Navegação
│   │   └── theme/               # Temas e estilos
│   ├── pages/                   # Telas do aplicativo
│   │   ├── splash/              # Tela inicial
│   │   ├── user_selection/      # Seleção de usuário
│   │   ├── register/            # Cadastro
│   │   ├── login/               # Login
│   │   ├── phone_verification/  # Verificação telefone
│   │   ├── forgot_password/     # Recuperação senha
│   │   ├── pending_review/      # Aguardando análise
│   │   ├── professional_validation/ # Validação profissional
│   │   ├── profile/             # Perfil médico
│   │   ├── appointment/         # Atendimentos médico
│   │   ├── financial/           # Financeiro médico
│   │   ├── home/                # Home médico
│   │   └── patient/             # Módulo paciente
│   │       ├── account/          # Conta paciente
│   │       ├── home/            # Home paciente
│   │       ├── orders/          # Pedidos
│   │       ├── consultations/   # Consultas
│   │       └── prescriptions/   # Receitas
│   ├── widgets/                 # Componentes reutilizáveis
│   │   └── common/              # Componentes comuns
│   ├── models/                  # Modelos de dados
│   │   ├── user/                # Modelos de usuário
│   │   ├── consultation/        # Modelos de consulta
│   │   ├── order/               # Modelos de pedido
│   │   └── product/             # Modelos de produto
│   ├── services/                # Serviços e lógica
│   │   ├── api/                 # Serviços de API
│   │   └── storage/             # Armazenamento local
│   ├── constants/               # Constantes
│   │   ├── app_colors.dart      # Cores
│   │   └── app_strings.dart     # Strings
│   ├── utils/                   # Utilitários
│   │   ├── date_formatter.dart  # Formatação datas
│   │   └── currency_formatter.dart # Formatação moeda
│   ├── main.dart                # Ponto de entrada
│   └── index.dart               # Exportações
├── test/                        # Testes
├── pubspec.yaml                 # Dependências
└── README.md                    # Documentação principal
```

## 📁 Detalhamento por Módulo

### Core (`lib/core/`)

Configurações centrais do aplicativo.

#### Router (`lib/core/router/`)
- `app_router.dart`: Configuração completa de rotas usando GoRouter

#### Theme (`lib/core/theme/`)
- `app_theme.dart`: Definição de temas claro/escuro
- `text_styles.dart`: Estilos de texto reutilizáveis

### Pages (`lib/pages/`)

Organizadas por funcionalidade e tipo de usuário.

#### Autenticação
- `splash/`: Tela inicial
- `user_selection/`: Escolha entre paciente/médico
- `register/`: Cadastro de usuário
- `login/`: Login
- `phone_verification/`: Verificação de telefone
- `forgot_password/`: Recuperação de senha (4 telas)
- `pending_review/`: Aguardando análise

#### Médico/Prescritor
- `home/`: Home com catálogo de produtos
- `appointment/`: Gerenciamento de atendimentos (7 telas)
- `financial/`: Dashboard financeiro (3 telas)
- `profile/`: Perfil profissional (5 telas)
- `professional_validation/`: Validação profissional (4 telas)

#### Paciente
- `patient/home/`: Home com consultas e pedidos (5 telas)
- `patient/orders/`: Gerenciamento de pedidos (6 telas)
- `patient/consultations/`: Consultas do paciente (8 telas)
- `patient/prescriptions/`: Receitas médicas (1 tela)
- `patient/account/`: Conta e configurações (5 telas)

### Widgets (`lib/widgets/`)

Componentes reutilizáveis organizados por categoria.

#### Common (`lib/widgets/common/`)
- `bottom_navigation_bar_patient.dart`: NavBar para pacientes
- `bottom_navigation_bar_doctor.dart`: NavBar para médicos
- `custom_app_bar.dart`: AppBar customizado

### Models (`lib/models/`)

Modelos de dados seguindo padrão de entidades.

#### User (`lib/models/user/`)
- `user_model.dart`: Modelo de usuário com tipos (patient, doctor, prescriber)

#### Consultation (`lib/models/consultation/`)
- `consultation_model.dart`: Modelo de consulta com status

#### Order (`lib/models/order/`)
- `order_model.dart`: Modelo de pedido com itens e status

#### Product (`lib/models/product/`)
- `product_model.dart`: Modelo de produto com informações técnicas

### Services (`lib/services/`)

Lógica de negócio e comunicação externa.

#### API (`lib/services/api/`)
- `api_service.dart`: Serviço base para chamadas HTTP

#### Storage (`lib/services/storage/`)
- `storage_service.dart`: Serviço para SharedPreferences

### Constants (`lib/constants/`)

Valores constantes centralizados.

- `app_colors.dart`: Todas as cores do design system
- `app_strings.dart`: Strings do aplicativo

### Utils (`lib/utils/`)

Funções utilitárias.

- `date_formatter.dart`: Formatação de datas brasileiras
- `currency_formatter.dart`: Formatação de moeda (BRL)

## 🎯 Convenções de Nomenclatura

### Arquivos
- **Páginas**: `[nome]_page.dart` (ex: `home_page.dart`)
- **Widgets**: `[nome].dart` (ex: `custom_app_bar.dart`)
- **Models**: `[nome]_model.dart` (ex: `user_model.dart`)
- **Services**: `[nome]_service.dart` (ex: `api_service.dart`)
- **Utils**: `[nome]_formatter.dart` ou `[nome]_helper.dart`

### Classes
- **Páginas**: `[Nome]Page` (ex: `HomePage`)
- **Widgets**: `[Nome]Widget` ou descritivo (ex: `CustomAppBar`)
- **Models**: `[Nome]Model` (ex: `UserModel`)
- **Services**: `[Nome]Service` (ex: `ApiService`)

### Variáveis e Métodos
- **Públicos**: `camelCase` (ex: `userName`)
- **Privados**: `_camelCase` (ex: `_buildCard()`)
- **Constantes**: `camelCase` em classes (ex: `AppColors.primary`)

## 📊 Estatísticas do Projeto

### Telas Implementadas
- **Total**: ~65 telas
- **Médico**: ~20 telas
- **Paciente**: ~25 telas
- **Compartilhadas**: ~20 telas

### Componentes
- **Widgets Reutilizáveis**: 3+
- **Models**: 4
- **Services**: 2
- **Utils**: 2

## 🔄 Fluxo de Dados

```
UI (Pages/Widgets)
    ↓
Services (API/Storage)
    ↓
Models (Domain)
    ↓
Backend/Storage
```

## 📝 Notas de Organização

### Separação por Ambiente

O projeto separa claramente:
- **Médico/Prescritor**: `pages/home/`, `pages/appointment/`, etc.
- **Paciente**: `pages/patient/*`

### Componentes Compartilhados

Componentes usados em ambos os ambientes:
- `widgets/common/`
- `models/`
- `services/`
- `constants/`
- `utils/`

### Modais e Overlays

Modais são organizados junto com suas páginas relacionadas:
- `catalog_filters_modal.dart` em `home/` e `patient/home/`
- `share_product_modal.dart` em `home/` e `patient/home/`

## 🚀 Próximas Melhorias de Estrutura

1. **Componentes Específicos**
   - `widgets/patient/` - Componentes específicos do paciente
   - `widgets/doctor/` - Componentes específicos do médico

2. **Testes**
   - `test/unit/` - Testes unitários
   - `test/widget/` - Testes de widget
   - `test/integration/` - Testes de integração

3. **Configuração**
   - `lib/config/` - Configurações de ambiente
   - `.env` - Variáveis de ambiente

4. **Localização**
   - `lib/l10n/` - Arquivos de tradução

---

**Última atualização**: Dezembro 2024






