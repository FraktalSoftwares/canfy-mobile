# Canfy Mobile

Aplicativo mobile desenvolvido em Flutter para a plataforma Canfy, uma solução de saúde canabinoide que conecta pacientes, médicos prescritores e produtos.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Tecnologias](#tecnologias)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Arquitetura](#arquitetura)
- [Fluxos de Usuário](#fluxos-de-usuário)
- [Componentes](#componentes)
- [Modelos de Dados](#modelos-de-dados)
- [Serviços](#serviços)
- [Rotas](#rotas)
- [Temas e Estilos](#temas-e-estilos)
- [Desenvolvimento](#desenvolvimento)
- [Build e Deploy](#build-e-deploy)

## 🎯 Visão Geral

O Canfy Mobile é um aplicativo multiplataforma (iOS e Android) que oferece:

- **Para Pacientes:**
  - Agendamento de consultas com médicos prescritores
  - Catálogo de produtos canabinoides
  - Acompanhamento de pedidos
  - Gerenciamento de receitas médicas
  - Perfil e configurações

- **Para Médicos/Prescritores:**
  - Gerenciamento de atendimentos
  - Prescrição de produtos
  - Dashboard financeiro
  - Perfil profissional
  - Agenda e disponibilidade

## 📁 Estrutura do Projeto

```
lib/
├── core/                    # Configurações centrais
│   ├── router/             # Configuração de rotas (GoRouter)
│   └── theme/              # Temas e estilos globais
│
├── pages/                   # Telas do aplicativo
│   ├── splash/             # Tela inicial
│   ├── user_selection/      # Seleção de tipo de usuário
│   ├── register/           # Cadastro
│   ├── login/              # Login
│   ├── phone_verification/ # Verificação de telefone
│   ├── forgot_password/    # Recuperação de senha
│   ├── pending_review/     # Aguardando análise
│   ├── professional_validation/ # Validação profissional
│   ├── profile/            # Perfil do médico
│   ├── appointment/        # Atendimentos (médico)
│   ├── financial/          # Financeiro (médico)
│   ├── home/               # Home do médico
│   └── patient/            # Módulo do paciente
│       ├── account/        # Conta e configurações
│       ├── home/           # Home do paciente
│       ├── orders/         # Pedidos
│       ├── consultations/  # Consultas
│       └── prescriptions/  # Receitas
│
├── widgets/                # Componentes reutilizáveis
│   └── common/             # Componentes comuns
│
├── models/                 # Modelos de dados
│   ├── user/               # Modelos de usuário
│   ├── consultation/       # Modelos de consulta
│   ├── order/              # Modelos de pedido
│   └── product/            # Modelos de produto
│
├── services/               # Serviços e lógica de negócio
│   ├── api/                # Serviços de API
│   └── storage/            # Serviços de armazenamento
│
├── constants/              # Constantes do aplicativo
│   ├── app_colors.dart     # Cores
│   └── app_strings.dart    # Strings
│
└── utils/                  # Utilitários
    ├── date_formatter.dart # Formatação de datas
    └── currency_formatter.dart # Formatação de moeda
```

## 🛠 Tecnologias

### Dependências Principais

- **Flutter SDK**: >=3.0.0 <4.0.0
- **go_router**: ^12.1.3 - Navegação declarativa
- **provider**: ^6.1.5 - Gerenciamento de estado
- **shared_preferences**: ^2.5.3 - Armazenamento local
- **google_fonts**: ^6.1.0 - Fontes customizadas
- **intl**: ^0.20.2 - Internacionalização e formatação

### Dependências de Desenvolvimento

- **flutter_lints**: 4.0.0 - Linting
- **lints**: 4.0.0 - Regras de lint

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (para builds nativos)
- Git

### Passos

1. Clone o repositório:
```bash
git clone <repository-url>
cd canfy_mobile
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto (quando necessário):

```env
API_BASE_URL=https://api.canfy.com/v1
API_KEY=your_api_key_here
```

### Assets

Os assets estão organizados em:
- `assets/images/` - Imagens
- `assets/fonts/` - Fontes customizadas
- `assets/videos/` - Vídeos
- `assets/audios/` - Áudios
- `assets/rive_animations/` - Animações Rive
- `assets/pdfs/` - Documentos PDF
- `assets/jsons/` - Arquivos JSON

## 🏗 Arquitetura

O projeto segue uma arquitetura em camadas:

### Camada de Apresentação
- **Pages**: Telas completas do aplicativo
- **Widgets**: Componentes reutilizáveis

### Camada de Domínio
- **Models**: Entidades de negócio
- **Services**: Lógica de negócio e comunicação com APIs

### Camada de Dados
- **Storage**: Armazenamento local (SharedPreferences)
- **API**: Comunicação com backend (a implementar)

## 👥 Fluxos de Usuário

### Fluxo de Autenticação

1. **Splash Screen** → Tela inicial
2. **Seleção de Usuário** → Escolha entre Paciente ou Médico/Prescritor
3. **Cadastro/Login** → Autenticação
4. **Verificação de Telefone** → (se cadastro)
5. **Validação Profissional** → (se médico, 3 etapas)
6. **Aguardando Análise** → (se médico)
7. **Home** → Tela principal

### Fluxo do Paciente

1. **Home** → Próximas consultas e últimos pedidos
2. **Consultas** → Agendar, visualizar e gerenciar consultas
3. **Pedidos** → Criar e acompanhar pedidos
4. **Catálogo** → Explorar produtos
5. **Receitas** → Visualizar receitas médicas
6. **Conta** → Configurações e dados pessoais

### Fluxo do Médico/Prescritor

1. **Home** → Dashboard com produtos e informações
2. **Atendimentos** → Gerenciar consultas e prescrições
3. **Financeiro** → Visualizar histórico financeiro
4. **Perfil** → Dados profissionais e configurações

## 🧩 Componentes

### Componentes Comuns

#### BottomNavigationBar

- **PatientBottomNavigationBar**: Navegação para pacientes
  - Home, Pedidos, Consultas

- **DoctorBottomNavigationBar**: Navegação para médicos
  - Home, Atendimento, Financeiro

#### CustomAppBar

AppBar customizado reutilizável com suporte a:
- Título customizado
- Ações personalizadas
- Leading widget customizado
- Cores customizáveis

## 📊 Modelos de Dados

### UserModel

Representa um usuário do sistema:
- `id`: Identificador único
- `name`: Nome completo
- `email`: Email
- `phone`: Telefone (opcional)
- `avatar`: URL do avatar (opcional)
- `type`: Tipo de usuário (patient, doctor, prescriber)
- `createdAt`: Data de criação

### ConsultationModel

Representa uma consulta:
- `id`: Identificador único
- `doctorId`: ID do médico
- `doctorName`: Nome do médico
- `doctorSpecialty`: Especialidade (opcional)
- `patientId`: ID do paciente
- `scheduledDate`: Data agendada
- `reason`: Motivo da consulta (opcional)
- `status`: Status (scheduled, inProgress, finished, cancelled)

### OrderModel

Representa um pedido:
- `id`: Identificador único
- `userId`: ID do usuário
- `items`: Lista de itens do pedido
- `status`: Status do pedido
- `total`: Valor total
- `createdAt`: Data de criação
- `updatedAt`: Data de atualização

### ProductModel

Representa um produto:
- `id`: Identificador único
- `name`: Nome do produto
- `description`: Descrição (opcional)
- `price`: Preço
- `imageUrl`: URL da imagem (opcional)
- `indications`: Lista de indicações clínicas
- `composition`: Composição (opcional)
- `usageForms`: Formas de uso (opcional)
- `cannabinoids`: Canabinoides (opcional)
- `concentration`: Concentração (opcional)

## 🔌 Serviços

### ApiService

Serviço base para comunicação com a API (a implementar):
- `get()`: Requisições GET
- `post()`: Requisições POST
- `put()`: Requisições PUT
- `delete()`: Requisições DELETE

### StorageService

Serviço para armazenamento local:
- `setString()`: Salvar string
- `getString()`: Obter string
- `setBool()`: Salvar boolean
- `getBool()`: Obter boolean
- `setInt()`: Salvar int
- `getInt()`: Obter int
- `remove()`: Remover chave
- `clear()`: Limpar tudo

## 🗺 Rotas

O aplicativo usa GoRouter para navegação declarativa. Principais rotas:

### Rotas Públicas
- `/splash` - Tela inicial
- `/user-selection` - Seleção de usuário
- `/register` - Cadastro
- `/login` - Login
- `/forgot-password` - Recuperação de senha

### Rotas do Médico
- `/home` - Home do médico
- `/catalog` - Catálogo de produtos
- `/appointment` - Atendimentos
- `/financial` - Financeiro
- `/profile` - Perfil

### Rotas do Paciente
- `/patient/home` - Home do paciente
- `/patient/catalog` - Catálogo
- `/patient/orders` - Pedidos
- `/patient/consultations` - Consultas
- `/patient/prescriptions` - Receitas
- `/patient/account` - Conta

## 🎨 Temas e Estilos

### Cores

O aplicativo usa um sistema de cores consistente:

- **Primárias**: Verde Canfy (#00994B), Roxo Canfy (#9067F1)
- **Neutras**: Escala de cinzas (000 a 900)
- **Status**: Amarelo, Azul, Cinza para diferentes estados

### Fontes

- **Títulos**: Truculenta (Google Fonts)
- **Corpo**: Arimo (Google Fonts)
- **Inter**: Para elementos específicos

### Tema

Suporte a tema claro e escuro através do `ThemeNotifier`.

## 💻 Desenvolvimento

### Executar em modo debug:
```bash
flutter run
```

### Executar testes:
```bash
flutter test
```

### Analisar código:
```bash
flutter analyze
```

### Formatar código:
```bash
flutter format .
```

## 📦 Build e Deploy

### Android

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 📝 Notas de Desenvolvimento

### Estado Atual

- ✅ Interface completa implementada
- ✅ Navegação configurada
- ✅ Componentes reutilizáveis criados
- ✅ Modelos de dados definidos
- ⏳ Integração com backend (pendente)
- ⏳ Testes automatizados (pendente)

### Próximos Passos

1. Implementar integração com API
2. Adicionar testes unitários e de widget
3. Implementar cache local
4. Adicionar tratamento de erros robusto
5. Implementar notificações push
6. Adicionar analytics

## 📄 Licença

[Especificar licença]

## 👥 Contribuidores

[Lista de contribuidores]

---

**Desenvolvido com ❤️ para Canfy**
