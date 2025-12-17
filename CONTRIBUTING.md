# Guia de Contribuição - Canfy Mobile

Obrigado por considerar contribuir com o Canfy Mobile! Este documento fornece diretrizes para contribuir com o projeto.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Padrões de Código](#padrões-de-código)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Processo de Pull Request](#processo-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Funcionalidades](#sugerir-funcionalidades)

## 📜 Código de Conduta

Este projeto adere a um código de conduta. Ao participar, você concorda em manter este código.

## 🤝 Como Contribuir

### 1. Fork o Projeto

1. Faça fork do repositório
2. Clone seu fork: `git clone <seu-fork-url>`
3. Crie uma branch: `git checkout -b feature/nova-funcionalidade`

### 2. Faça suas Alterações

- Siga os padrões de código
- Adicione testes quando apropriado
- Atualize a documentação se necessário

### 3. Commit suas Alterações

Use mensagens de commit descritivas:

```bash
git commit -m "feat: adiciona funcionalidade X"
git commit -m "fix: corrige bug Y"
git commit -m "docs: atualiza documentação"
```

### 4. Push e Pull Request

```bash
git push origin feature/nova-funcionalidade
```

Depois, abra um Pull Request no repositório principal.

## 📝 Padrões de Código

### Formatação

Execute o formatador antes de commitar:

```bash
flutter format .
```

### Linting

Execute o analisador:

```bash
flutter analyze
```

### Convenções de Nomenclatura

- **Classes**: PascalCase
  ```dart
  class UserModel { }
  ```

- **Arquivos**: snake_case
  ```dart
  user_model.dart
  ```

- **Variáveis/Métodos**: camelCase
  ```dart
  String userName;
  void getUserData() { }
  ```

- **Constantes**: camelCase
  ```dart
  static const Color primaryColor = Color(0xFF00994B);
  ```

- **Métodos privados**: camelCase com prefixo `_`
  ```dart
  Widget _buildCard() { }
  ```

### Estrutura de Widget

```dart
class MyWidget extends StatelessWidget {
  // 1. Constantes
  static const String title = 'Título';
  
  // 2. Propriedades
  final String data;
  
  // 3. Construtor
  const MyWidget({
    super.key,
    required this.data,
  });
  
  // 4. Método build
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildContent(),
    );
  }
  
  // 5. Métodos privados
  Widget _buildContent() {
    return Text(data);
  }
}
```

### Comentários

- Use comentários para explicar **por quê**, não **o quê**
- Documente funções públicas com doc comments:

```dart
/// Calcula o total do pedido incluindo impostos.
/// 
/// [items] Lista de itens do pedido
/// Retorna o valor total formatado em BRL
double calculateTotal(List<OrderItem> items) {
  // ...
}
```

## 📁 Estrutura do Projeto

Mantenha a organização:

```
lib/
├── core/           # Configurações centrais
├── pages/          # Telas
├── widgets/        # Componentes reutilizáveis
├── models/         # Modelos de dados
├── services/       # Serviços
├── constants/      # Constantes
└── utils/          # Utilitários
```

### Onde Colocar Código Novo?

- **Nova tela**: `lib/pages/[modulo]/[nome]_page.dart`
- **Componente reutilizável**: `lib/widgets/common/[nome].dart`
- **Modelo de dados**: `lib/models/[entidade]/[nome]_model.dart`
- **Serviço**: `lib/services/[tipo]/[nome]_service.dart`
- **Utilitário**: `lib/utils/[nome]_formatter.dart` ou similar

## 🔄 Processo de Pull Request

### Antes de Abrir um PR

1. ✅ Código formatado (`flutter format .`)
2. ✅ Sem erros de análise (`flutter analyze`)
3. ✅ Testes passando (se aplicável)
4. ✅ Documentação atualizada
5. ✅ Sem conflitos com a branch principal

### Template de Pull Request

```markdown
## Descrição
Breve descrição das mudanças

## Tipo de Mudança
- [ ] Bug fix
- [ ] Nova funcionalidade
- [ ] Breaking change
- [ ] Documentação

## Checklist
- [ ] Código formatado
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] Sem erros de lint
```

## 🐛 Reportar Bugs

### Template de Bug Report

```markdown
**Descrição do Bug**
Descrição clara e concisa do bug

**Passos para Reproduzir**
1. Vá para '...'
2. Clique em '...'
3. Veja o erro

**Comportamento Esperado**
O que deveria acontecer

**Comportamento Atual**
O que está acontecendo

**Screenshots**
Se aplicável, adicione screenshots

**Ambiente**
- OS: [ex: iOS 17.0]
- Device: [ex: iPhone 14]
- App Version: [ex: 1.0.0]

**Informações Adicionais**
Qualquer outra informação relevante
```

## 💡 Sugerir Funcionalidades

### Template de Feature Request

```markdown
**Funcionalidade Proposta**
Descrição clara da funcionalidade

**Problema que Resolve**
Qual problema isso resolve?

**Solução Proposta**
Como você imagina que isso funcionaria?

**Alternativas Consideradas**
Outras soluções que você considerou

**Contexto Adicional**
Qualquer outra informação relevante
```

## ✅ Checklist de Contribuição

Antes de submeter:

- [ ] Código segue os padrões do projeto
- [ ] Comentários adicionados onde necessário
- [ ] Documentação atualizada
- [ ] Testes adicionados (se aplicável)
- [ ] Sem warnings ou erros
- [ ] PR tem descrição clara
- [ ] Commits são descritivos

## 🎯 Tipos de Contribuições

### Correção de Bugs
- Identifique o bug
- Crie um fix
- Adicione testes
- Documente a correção

### Novas Funcionalidades
- Discuta a funcionalidade primeiro (issue)
- Implemente seguindo os padrões
- Adicione testes
- Atualize documentação

### Melhorias de Código
- Refatoração
- Otimizações
- Melhorias de performance
- Limpeza de código

### Documentação
- Correções de typos
- Melhorias de clareza
- Exemplos adicionais
- Traduções

## 📞 Dúvidas?

Se tiver dúvidas sobre como contribuir:
1. Abra uma issue
2. Consulte a documentação
3. Entre em contato com os mantenedores

---

**Obrigado por contribuir! 🎉**





