# Orçamentos Dinâmicos - AltForce

## Descrição

Aplicação Flutter desenvolvida para o teste prático da AltForce, implementando um sistema de orçamentos dinâmicos com formulários inteligentes que se adaptam baseado no tipo de produto selecionado e regras de negócio configuráveis.

## Arquitetura e Princípios Implementados

### Arquitetura Geral
- **Clean Architecture**: Separação clara entre camadas (models, repositories, services, controllers, widgets)
- **MVVM Pattern**: Controllers gerenciam estado, Views são reativas
- **Dependency Injection**: Injeção de dependências através de construtores

### Princípios de Programação Aplicados

#### 1. Orientação a Objetos (OOP)
- **Encapsulamento**: Propriedades privadas com getters/setters controlados
- **Herança**: Hierarquia de produtos (Product → IndustrialProduct, ResidentialProduct, CorporateProduct)
- **Polimorfismo**: Métodos virtuais sobrescritos em classes filhas
- **Abstração**: Classes abstratas e interfaces para contratos bem definidos

#### 2. Genéricos (Generics)
- `IRepository<T>`: Repositório genérico para qualquer tipo de entidade
- `RulesEngine<T>`: Engine de regras genérica
- `FormController<T>`: Controller de formulário tipado
- `FactoryService<T>`: Serviço de fábrica genérico

#### 3. DRY (Don't Repeat Yourself)
- **Mixins**: ValidatorMixin, CalculatorMixin, FormatterMixin para funcionalidades reutilizáveis
- **Extensions**: ProductExtensions, ListExtensions, StringExtensions
- **Base Classes**: BaseModel para funcionalidades comuns

#### 4. Mixins
- `ValidatorMixin`: Validações reutilizáveis
- `CalculatorMixin`: Cálculos matemáticos comuns
- `FormatterMixin`: Formatação de dados (moeda, data, números)

#### 5. Extensions
- `ProductExtensions`: Funcionalidades específicas para produtos
- `ListExtensions`: Operações avançadas em listas
- `StringExtensions`: Manipulação e validação de strings

#### 6. Strategy Pattern
- `BusinessRule`: Diferentes estratégias de regras (pricing, validation, visibility)
- `FormField`: Diferentes estratégias de campos (text, number, dropdown, date)

#### 7. Template Method Pattern
- `Product.calculatePrice()`: Template method com steps customizáveis
- `FormField.validate()`: Template de validação com regras específicas

#### 8. Composition
- Controllers compõem repositórios, engines e services
- Widgets compõem outros widgets especializados
- Agregação de funcionalidades através de composição

### Factory Pattern
- `ProductFactory`: Criação de produtos baseada em configuração
- `BusinessRuleFactory`: Criação de regras de negócio
- `FormFieldFactory`: Criação de campos de formulário
- `FieldWidgetFactory`: Criação de widgets de campo

## Estrutura do Projeto

```
lib/
├── models/
│   ├── base_model.dart           # Classe base para todos os modelos
│   ├── products/
│   │   └── product.dart          # Hierarquia de produtos
│   ├── rules/
│   │   └── business_rule.dart    # Sistema de regras de negócio
│   └── fields/
│       └── form_field.dart       # Sistema de campos dinâmicos
├── repositories/
│   └── repository.dart           # Repositórios genéricos
├── services/
│   ├── rules_engine.dart         # Engine de processamento de regras
│   └── factory_service.dart     # Serviços de fábrica
├── mixins/
│   ├── validator_mixin.dart      # Validações reutilizáveis
│   ├── calculator_mixin.dart     # Cálculos reutilizáveis
│   └── formatter_mixin.dart      # Formatações reutilizáveis
├── extensions/
│   ├── product_extensions.dart   # Extensions para produtos
│   ├── list_extensions.dart      # Extensions para listas
│   └── string_extensions.dart    # Extensions para strings
├── controllers/
│   ├── form_controller.dart      # Controller de formulário dinâmico
│   └── quote_controller.dart     # Controller principal de orçamentos
├── widgets/
│   ├── dynamic_form_widget.dart  # Formulário dinâmico
│   ├── product_selector_widget.dart # Seletor de produtos
│   └── quote_summary_widget.dart # Resumo do orçamento
├── screens/
│   ├── home_screen.dart          # Tela principal
│   └── quotes_list_screen.dart   # Lista de orçamentos
└── main.dart                     # Ponto de entrada da aplicação
```

## Funcionalidades Implementadas

### 1. Formulário Dinâmico Inteligente
- **Campos Adaptativos**: Formulário muda baseado no tipo de produto
- **Validação em Tempo Real**: Validação reativa conforme usuário digita
- **Estados Interdependentes**: Campos influenciam uns aos outros
- **Factory Pattern**: Criação dinâmica de widgets de campo

### 2. Sistema de Produtos
- **Produtos Industriais**: Voltagem, certificação, consumo de energia
- **Produtos Residenciais**: Cor, garantia, classificação energética
- **Produtos Corporativos**: Licença, suporte, número de usuários

### 3. Engine de Regras de Negócio
- **Regras de Preço**: Descontos, taxas adicionais
- **Regras de Validação**: Campos obrigatórios condicionais
- **Regras de Visibilidade**: Campos aparecem/desaparecem dinamicamente
- **Processamento Paralelo**: Múltiplas regras processadas simultaneamente

### 4. Regras de Negócio Obrigatórias

#### Desconto por Volume
- **Condição**: Quantidade ≥ 50 unidades
- **Ação**: Desconto de 15% no valor total
- **Tipo**: Regra de preço

#### Taxa de Urgência
- **Condição**: Entrega em menos de 7 dias
- **Ação**: Taxa adicional de 20%
- **Tipo**: Regra de preço

#### Certificação Obrigatória
- **Condição**: Produto industrial com voltagem > 220V
- **Ação**: Campo certificação torna-se obrigatório
- **Tipo**: Regra de validação

#### Visibilidade de Campos
- **Condição**: Tipo de produto selecionado
- **Ação**: Mostra/oculta campos específicos
- **Tipo**: Regra de visibilidade

### 5. Interface Responsiva
- **Layout Adaptativo**: Desktop (lado a lado) e Mobile (empilhado)
- **Componentes Reutilizáveis**: Widgets modulares e configuráveis
- **Feedback Visual**: Estados de loading, erro e sucesso
- **Navegação Intuitiva**: Tabs e navegação fluida

## Como Executar

### Pré-requisitos
- Flutter SDK 3.24.5 ou superior
- Dart 3.5.4 ou superior

### Instalação
```bash
# Clone o repositório
git clone <repository-url>
cd orcamentos_dinamicos

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

### Build para Web
```bash
flutter build web --release
```

### Testes
```bash
flutter test
flutter analyze
```

## Cenários de Teste

### Cenário 1: Produto Industrial com Desconto por Volume
1. Selecione um produto industrial (ex: Motor Elétrico)
2. Configure quantidade ≥ 50 unidades
3. Verifique desconto de 15% aplicado automaticamente
4. Campos de voltagem e certificação devem estar visíveis

### Cenário 2: Entrega Urgente com Taxa Adicional
1. Selecione qualquer produto
2. Configure data de entrega para menos de 7 dias
3. Verifique taxa de urgência de 20% aplicada
4. Preço final deve refletir a taxa adicional

### Cenário 3: Certificação Obrigatória
1. Selecione produto industrial
2. Configure voltagem > 220V
3. Campo certificação deve tornar-se obrigatório
4. Validação deve impedir criação sem certificação

### Cenário 4: Campos Dinâmicos por Tipo
1. Alterne entre tipos de produto
2. Observe campos específicos aparecendo/desaparecendo
3. Produtos residenciais: cor, garantia, classificação energética
4. Produtos corporativos: licença, suporte, usuários

## Tecnologias Utilizadas

- **Flutter 3.24.5**: Framework de desenvolvimento
- **Dart 3.5.4**: Linguagem de programação
- **Material Design 3**: Sistema de design
- **Provider Pattern**: Gerenciamento de estado (via ChangeNotifier)

## Padrões de Design Implementados

1. **Repository Pattern**: Abstração de acesso a dados
2. **Factory Pattern**: Criação de objetos complexos
3. **Strategy Pattern**: Algoritmos intercambiáveis
4. **Template Method**: Esqueleto de algoritmos
5. **Observer Pattern**: Notificação de mudanças de estado
6. **Composition Pattern**: Agregação de funcionalidades
7. **Mixin Pattern**: Reutilização de código

## Características Técnicas

### Performance
- **Lazy Loading**: Carregamento sob demanda
- **Efficient Rebuilds**: Reconstrução otimizada de widgets
- **Memory Management**: Gerenciamento adequado de recursos

### Manutenibilidade
- **Código Limpo**: Nomes descritivos e funções pequenas
- **Documentação**: Comentários e documentação inline
- **Testes**: Cobertura de testes unitários
- **Modularidade**: Componentes independentes e reutilizáveis

### Escalabilidade
- **Arquitetura Flexível**: Fácil adição de novos tipos de produto
- **Sistema de Regras**: Regras configuráveis sem alteração de código
- **Extensibilidade**: Extensions e mixins para novas funcionalidades

## Autor

Desenvolvido para o teste prático da AltForce, demonstrando conhecimentos avançados em Flutter, Dart e arquitetura de software.

## Licença

Este projeto foi desenvolvido exclusivamente para fins de avaliação técnica.

