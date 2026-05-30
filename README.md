# Projeto IMMA ATACADISTA

> Aplicativo mobile desenvolvido em Flutter para modernizar a operação de vendas em campo da **IMMA Atacadista**, eliminando o uso de cadernos físicos e redigitação manual de pedidos no ERP.

---


## Visão Geral

O **ADA (Agente Digital Atacadista)** é um sistema mobile que oferece ao vendedor externo da IMMA Atacadista uma ferramenta organizada, rápida e inteligente para:

- Gerenciar clientes e pedidos diretamente do celular
- Acompanhar vales a receber na rota do dia
- Consultar comissões por mês com cálculo automático
- Receber recomendações de vendas geradas por Inteligência Artificial

---

## Tecnologias

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Front-end | Flutter / Dart | ≥ 3.x |
| Autenticação | Firebase Authentication | — |
| Banco de dados | Cloud Firestore | — |
| Padrão de arquitetura | MVVM + ChangeNotifier | — |
| Inteligência Artificial | Groq API + Llama 3.3 70B | — |
| HTTP | package:http | ^1.x |

---

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **≥ 3.0.0**
- [Dart SDK](https://dart.dev/get-dart) (incluído no Flutter)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/) com a extensão Flutter
- [Git](https://git-scm.com/)
- Uma conta no [Firebase Console](https://console.firebase.google.com/)
- Uma conta na [Groq Console](https://console.groq.com/) para obter a API key da IA

Verifique se o Flutter está corretamente instalado:

```bash
flutter doctor
```

Todos os itens relevantes devem aparecer com ✓ verde antes de prosseguir.

---

## Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/projeto-imma-ada.git
cd projeto-imma-ada
```

### 2. Instale as dependências

```bash
flutter pub get
```

---

## Configuração do Firebase

O projeto utiliza o Firebase como backend. Siga os passos abaixo para conectar seu próprio projeto Firebase.

### 1. Crie um projeto no Firebase Console

1. Acesse [console.firebase.google.com](https://console.firebase.google.com/)
2. Clique em **"Adicionar projeto"**
3. Dê um nome (ex.: `imma-ada`) e conclua o assistente

### 2. Ative o Firebase Authentication

1. No menu lateral, acesse **Authentication → Método de login**
2. Ative o provedor **E-mail/senha**
3. Salve

### 3. Crie o banco de dados Firestore

1. No menu lateral, acesse **Firestore Database → Criar banco de dados**
2. Escolha o modo **Produção** (ou Teste para desenvolvimento)
3. Selecione a região mais próxima (ex.: `southamerica-east1`)

#### Coleções necessárias

O app espera as seguintes coleções no Firestore:

| Coleção | Campos principais |
|---------|------------------|
| `users` | `nome`, `email`, `criadoEm` |
| `clientes` | `razaoSocial`, `nomeFantasia`, `cnpjCpf`, `rua`, `cep`, `cidade`, `uf`, `telefone`, `email`, `vendedorId` |
| `pedidos` | `clienteNome`, `clienteId`, `itens[]`, `total`, `pagamento`, `status`, `vendedorId`, `criadoEm` |
| `produtos` | `nome`, `marca`, `codigo`, `preco`, `estoque`, `unidade`, `categoria` |

#### Regras de segurança recomendadas

No Firebase Console, em **Firestore → Regras**, configure:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuários: lê e escreve apenas o próprio documento
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Clientes: vendedor acessa apenas os seus
    match /clientes/{clienteId} {
      allow read, write: if request.auth != null
        && resource.data.vendedorId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.vendedorId == request.auth.uid;
    }

    // Pedidos: vendedor acessa apenas os seus
    match /pedidos/{pedidoId} {
      allow read, write: if request.auth != null
        && resource.data.vendedorId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.vendedorId == request.auth.uid;
    }

    // Produtos: leitura pública para vendedores autenticados
    match /produtos/{produtoId} {
      allow read: if request.auth != null;
      allow write: if false; // Apenas administrador via Console
    }
  }
}
```

### 4. Adicione o app Android ao Firebase

1. No Firebase Console, clique em **"Adicionar app" → Android**
2. Informe o **Package name** do projeto:
   ```
   com.example.projeto02
   ```
   > O package name está em `android/app/build.gradle`, campo `applicationId`.
3. Faça o download do arquivo `google-services.json`
4. Mova o arquivo para a pasta `android/app/` do projeto:
   ```
   android/
   └── app/
       └── google-services.json   ← aqui
   ```

### 5. Verifique as dependências do Android

Confirme que `android/build.gradle` contém:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

E que `android/app/build.gradle` contém ao final:

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Configuração da IA (Groq)

O assistente **ADA** utiliza a API da [Groq](https://groq.com/) com o modelo **Llama 3.3 70B**.

### 1. Obtenha sua API key

1. Acesse [console.groq.com](https://console.groq.com/)
2. Crie uma conta (gratuita)
3. Acesse **API Keys → Create API Key**
4. Copie a chave gerada (formato: `gsk_...`)

### 2. Como a chave funciona no projeto

A chave **nunca está escrita no código-fonte**. Ela é injetada pelo compilador Flutter no momento do build através do mecanismo `--dart-define`. No código, isso é declarado da seguinte forma:

```dart
// lib/app/data/service/ai_service.dart
static const _apiKey = String.fromEnvironment(
  'GROQ_API_KEY',
  defaultValue: '',
);
```

O compilador substitui `String.fromEnvironment('GROQ_API_KEY')` pelo valor real durante a compilação. Se a chave não for fornecida, o assistente exibe uma mensagem amigável e não trava o app.

---

## Executando o Projeto

### Desenvolvimento (com hot reload)

```bash
flutter run --dart-define=GROQ_API_KEY=gsk_SuaChaveAqui
```

### Build de produção (APK)

```bash
flutter build apk --dart-define=GROQ_API_KEY=gsk_SuaChaveAqui
```

O APK gerado estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Executando sem a chave da IA

Caso queira testar o app sem configurar a Groq, execute normalmente sem o `--dart-define`. Todas as funcionalidades funcionarão normalmente, exceto o assistente ADA, que exibirá a mensagem:

> *"Assistente indisponível: chave de API não configurada."*

```bash
flutter run
```

---

## Estrutura de Pastas

```
lib/
├── app/
│   ├── data/
│   │   ├── service/
│   │   │   └── ai_service.dart          # Integração com Groq API
│   │   └── usuario_mock_store.dart      # Legado (não utilizado em produção)
│   └── routes/
│       ├── app_pages.dart               # Registro de rotas com GetIt/Navigator
│       └── app_routes.dart              # Constantes de nomes de rotas
│
└── features/
    └── auth/
        ├── model/
        │   ├── usuario_model.dart        # Entidade de usuário
        │   ├── produto_model.dart        # Entidade de produto
        │   └── pedido_model.dart         # Entidade de pedido / item
        │
        ├── viewmodel/
        │   ├── splash_viewmodel.dart     # Lógica da splash screen
        │   ├── login_viewmodel.dart      # Validação e autenticação
        │   ├── register_viewmodel.dart   # Cadastro com validação de senha forte
        │   ├── home_viewmodel.dart       # Dashboard, comissões e chamada da IA
        │   ├── pedido_viewmodel.dart     # Carrinho, cálculo de total e envio
        │   ├── cadastrar_cliente_viewmodel.dart  # Cadastro com sanitização
        │   ├── editar_cliente_viewmodel.dart     # Edição de cliente existente
        │   └── vales_viewmodel.dart      # Filtros e cálculo de vencimento
        │
        └── view/
            ├── splash_page.dart
            ├── login_page.dart
            ├── register_page.dart
            ├── home_page.dart
            ├── clientes_page.dart
            ├── cadastrar_cliente_page.dart
            ├── detalhes_cliente_page.dart
            ├── editar_cliente_page.dart
            ├── pedidos_page.dart
            ├── pedido_detalhes_page.dart
            ├── novo_pedido_page.dart
            ├── produtos_page.dart
            ├── vales_page.dart
            └── comissoes_page.dart

test/
└── viewmodels/
    ├── validators_test.dart   # Testes de validadores de formulário
    └── carrinho_test.dart     # Testes do motor do carrinho e prazo
```

---

## Arquitetura

O projeto adota o padrão **MVVM (Model-View-ViewModel)** com `ChangeNotifier` do Flutter.

```
┌─────────────┐      observa       ┌──────────────────┐      lê/escreve     ┌──────────────┐
│    VIEW      │ ◄────────────────  │   VIEWMODEL      │ ───────────────────► │    MODEL     │
│  (Pages)    │                    │ (ChangeNotifier) │                      │  (Entidades) │
│             │  chama métodos     │                  │                      │              │
│             │ ───────────────►   │  regras de       │    ┌─────────────┐   │              │
└─────────────┘                    │  negócio +       │ ──►│  Firebase   │   └──────────────┘
                                   │  validações      │    │  Firestore  │
                                   └──────────────────┘    │  Auth       │
                                                           └─────────────┘
```

**Fluxo de dados:**

1. A **View** renderiza o estado atual do ViewModel via `AnimatedBuilder`
2. O usuário interage → a View chama um método do **ViewModel**
3. O ViewModel valida, processa e atualiza os dados via **Firebase**
4. O ViewModel chama `notifyListeners()` → a View reconstrói automaticamente

**Por que MVVM?**
- ViewModels são testáveis isoladamente (sem depender de widgets)
- Regras de negócio nunca ficam nas telas
- Fácil manutenção: alterar a UI não quebra a lógica

---

## Módulos e Funcionalidades

### Autenticação
- Login e cadastro via **Firebase Authentication**
- Validação de senha com requisitos: mínimo 8 caracteres, letra maiúscula, número e símbolo especial
- Indicador visual de força de senha na tela de cadastro

### Gestão de Clientes
- Lista com busca em tempo real por nome ou CNPJ/CPF
- Filtro por cidade da rota (Monte Santo, Itamogi, Arceburgo, Guaxupé, etc.)
- Cadastro com sanitização: valida CPF (11 dígitos), CNPJ (14 dígitos), CEP e telefone com DDD
- Tela de detalhes com opções de **editar** e **excluir** com confirmação

### Motor de Vendas (Pedidos)
- Carrinho com catálogo lido diretamente do Firestore
- Subtotal por item e total geral calculados em tempo real
- Formas de pagamento: À Vista, 7/14/21/28 dias e prazo customizado
- **Trava de 30 dias**: prazo customizado é validado com limite máximo de 30 dias
- Tela de detalhes do pedido com **troca de status** (Pendente → Em Preparo → Saiu para Entrega → Concluído / Cancelado)

### Vales na Rota
- Filtra pedidos com pagamento a prazo ("Dias" ou "Vale")
- Calcula data de vencimento com base no prazo selecionado
- Distingue visualmente títulos **vencidos** e **a vencer**
- Filtros por data, cidade e cliente

### Comissões
- **2,5%** para categoria padrão
- **1,5%** para categorias especiais (Cervejas, Energéticos, Óleo de Soja)
- **Seletor dinâmico de mês**: navega pelos últimos 12 meses com geração automática
- Exibe total vendido, total de pedidos e comissão por categoria

### Assistente ADA (Inteligência Artificial)
- Botão "Gerar Recomendações" na tela inicial
- Coleta contexto real: produto mais vendido, produto parado e cliente destaque dos últimos 7 dias
- Envia prompt estruturado para a **Groq API** (modelo `llama-3.3-70b-versatile`)
- Hardware LPU da Groq processa a **300–800 tokens/segundo**
- Retorna recomendação de venda personalizada em menos de 2 segundos

---

## Testes

O projeto segue a norma **ISO/IEC/IEEE 29119** com as seguintes técnicas:

| Técnica | O que cobre |
|---------|-------------|
| Particionamento de Equivalência | CPF/CNPJ, CEP, e-mail, senha |
| Análise de Valor Limite | Prazo máximo de 30 dias, senha com exatamente 8 chars |
| Transição de Estado | Fluxo de status do pedido |
| Teste Baseado em Cenário | Fluxo completo de criação de pedido |

### Executar os testes

```bash
flutter test
```

### Executar arquivo específico

```bash
# Apenas validadores
flutter test test/viewmodels/validators_test.dart

# Apenas motor do carrinho e prazo
flutter test test/viewmodels/carrinho_test.dart
```

### Cobertura de testes

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

> **Observação:** Os testes de `PedidoViewModel` funcionam sem o Firebase inicializado pois o `userId` foi implementado como um **getter lazy** (`String? get userId => FirebaseAuth.instance.currentUser?.uid`), sendo avaliado apenas quando acessado — e não na construção da classe.

---

## Segurança

### Segregação de dados no Firestore

Todas as queries filtram pelo `vendedorId` igual ao UID do usuário autenticado:

```dart
FirebaseFirestore.instance
    .collection('pedidos')
    .where('vendedorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
    .snapshots()
```

Nenhum vendedor consegue acessar dados de outro, mesmo que manipule o app.

### Proteção da API Key

A chave da Groq API nunca é escrita no código-fonte. O mecanismo `--dart-define` do Flutter injeta o valor em tempo de compilação:

```dart
// No código: apenas uma declaração
static const _apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

// No terminal: o valor é passado na hora de compilar
flutter run --dart-define=GROQ_API_KEY=gsk_SuaChave
```

**Por que isso é mais seguro?**
O repositório Git não contém a chave. Qualquer pessoa que clonar o projeto não terá acesso à IA sem a chave, que deve ser fornecida separadamente pelo desenvolvedor responsável.

---

## Observações Finais

- O campo `produtos` no Firestore deve ser populado manualmente pelo administrador via Firebase Console antes de usar o módulo de pedidos.
- O arquivo `google-services.json` **não deve ser versionado** no Git. Adicione ao `.gitignore`:
  ```
  android/app/google-services.json
  ```
- Em ambiente de produção, configure as **Security Rules** do Firestore conforme indicado na seção de configuração para evitar acesso não autorizado.
