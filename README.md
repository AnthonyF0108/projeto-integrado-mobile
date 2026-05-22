# 🌱 AgroVale

**Aplicativo mobile de comércio agropecuário com Inteligência Artificial**

> Projeto Integrado — ADS | UniFeob · 2026  
> Desenvolvido com Flutter + Firebase + Google Gemini

---

## 📱 Sobre o Projeto

O AgroVale é um aplicativo mobile que conecta clientes a produtos agropecuários de forma inteligente. O diferencial é o assistente virtual com IA generativa (Google Gemini) que interpreta a necessidade do cliente em linguagem natural e recomenda os produtos mais adequados do catálogo em tempo real.

**Problema resolvido:** Pequenos produtores rurais frequentemente não conhecem o nome técnico dos produtos que precisam. O assistente permite descrever o problema — *"meu pasto está cheio de mato"* — e recebe a recomendação certa.

---

## ✨ Funcionalidades

| # | Funcionalidade | Descrição |
|---|---------------|-----------|
| 01 | **Autenticação** | Login com Google e e-mail/senha via Firebase Auth |
| 02 | **Catálogo** | Grade de produtos com busca inteligente e expansão de sinônimos |
| 03 | **Assistente IA** | Chat com Google Gemini recomendando produtos do catálogo real |
| 04 | **Carrinho** | Gerenciamento de itens com cálculo em tempo real |
| 05 | **Pagamento Pix** | QR Code via Mercado Pago com atualização automática via webhook |
| 06 | **Pagamento Boleto** | Boleto bancário gerado via Mercado Pago |
| 07 | **Pedidos** | Histórico com status em tempo real e opção de gerar novo Pix |
| 08 | **Favoritos** | Salvar produtos com toggle |
| 09 | **Perfil** | Dados pessoais com preenchimento automático de endereço via ViaCEP |

---

## 🤖 Inteligência Artificial

O assistente virtual usa o modelo **Google Gemini 2.5 Flash** e funciona assim:

```
Usuário descreve necessidade
        ↓
Sistema busca catálogo atualizado no Firestore
        ↓
Monta prompt com catálogo + mensagem do usuário
        ↓
Gemini gera recomendação citando produtos reais
        ↓
App exibe cards com foto, preço e botão de carrinho
```

**Métricas reais medidas:**
- Tokens de entrada por chamada: ~1.630
- Tokens de saída por chamada: ~140
- Tempo médio de resposta: < 5 segundos
- Limite do catálogo: 50 produtos por consulta

---

## 🏗️ Arquitetura

```
lib/
├── pages/
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── chat_ia_page.dart
│   ├── cart_page.dart
│   ├── orders_page.dart
│   ├── favorites_page.dart
│   └── profile_page.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── gemini_service.dart
└── widgets/
    ├── favorito_button.dart
    ├── product_card.dart
    └── category_button.dart

functions/
└── index.js          ← Cloud Function (webhook Mercado Pago)

integration_test/
└── auth_flow_test.dart
```

---

## 🛠️ Stack Tecnológico

| Tecnologia | Uso |
|-----------|-----|
| **Flutter** | Framework mobile (Android) |
| **Firebase Auth** | Autenticação Google + e-mail/senha |
| **Cloud Firestore** | Banco de dados em tempo real |
| **Firebase Cloud Functions** | Webhook de pagamento |
| **Google Gemini 2.5 Flash** | IA generativa para recomendação |
| **Mercado Pago API** | Pagamento via Pix e Boleto |
| **ViaCEP API** | Preenchimento automático de endereço |
| **flutter_dotenv** | Proteção de chaves de API |

---

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK `^3.11.1`
- Dart SDK
- Android Studio ou VS Code
- Conta Firebase
- Chave Google Gemini (aistudio.google.com)
- Credenciais Mercado Pago

### Configuração

**1. Clone o repositório**
```bash
git clone https://github.com/AnthonyF0108/projeto-integrado-mobile.git
cd projeto-integrado-mobile
```

**2. Instale as dependências**
```bash
flutter pub get
```

**3. Configure as variáveis de ambiente**

Crie o arquivo `.env` na raiz do projeto:
```env
GEMINI_API_KEY=sua_chave_gemini_aqui
MP_ACCESS_TOKEN=seu_token_mercado_pago_aqui
```

**4. Configure o Firebase**

O arquivo `google-services.json` (Android) deve ser colocado em `android/app/`.

**5. Execute o app**
```bash
flutter run
```

---

## 💳 Pagamento — Cloud Function

O webhook do Mercado Pago foi implantado via Firebase Cloud Functions:

```bash
cd functions
npm install
firebase deploy --only functions
```

URL do webhook: `https://webhookmercadopago-i2giblwa3q-uc.a.run.app`

Quando o cliente paga, o Mercado Pago notifica a function, que atualiza o status do pedido no Firestore automaticamente.

---

## 🧪 Testes

Testes de integração implementados com `flutter_test` + `integration_test`, seguindo a norma **ISO/IEC/IEEE 29119**.

```bash
flutter test integration_test/auth_flow_test.dart
```

| Grupo | Testes | Status |
|-------|--------|--------|
| Autenticação | TC03, TC04, TC02+05, TC25 | ✅ |
| Carrinho & Pix | TC14, TC15, TC16, TC17+18 | ✅ |
| Assistente IA | TC21, TC22 | ✅ |
| Favoritos | TC24 | ✅ |

**25 casos de teste planejados · 9 testes de integração automatizados**

---

## 🔐 Segurança

- Chaves de API armazenadas em `.env` (listado no `.gitignore`)
- Acesso ao Firestore restrito por usuário autenticado
- Token do Mercado Pago protegido no arquivo de ambiente
- Cloud Function com acesso público apenas para receber webhooks

---

## 📄 Documentação

A pasta `docs/` contém a documentação completa do projeto:

- `casos_de_uso_agrovale.md` — 12 casos de uso (UC01–UC12)
- `requisitos_funcionais.md` — 15 requisitos funcionais
- `requisitos_nao_funcionais.md` — 10 requisitos não funcionais
- `regras_de_negocio.md` — 15 regras de negócio
- `backlog.md` — 27 user stories em 6 épicos
- `diagrama_casos_uso.puml` — Diagrama PlantUML
- `diagrama_classes.puml` — Diagrama de classes
- `diagramas_sequencia.puml` — 4 diagramas de sequência
- `diagramas_atividade.puml` — 4 diagramas de atividade
- `Documento_A_Base_Conceitual.md` — Testes ISO 29119 (Parte A)
- `Documento_B_Processo_de_Teste.md` — Testes ISO 29119 (Parte B)
- `Documento_C_Tecnicas_e_Casos_de_Teste.md` — Testes ISO 29119 (Parte C)
- `Documento_D_Execucao_e_Resultados.md` — Testes ISO 29119 (Parte D)
- `Documento_E_Implementacao_Testes_Integracao.md` — Testes ISO 29119 (Parte E)

---

## 👥 Equipe

| Nome | RA |
|------|----|
| Anthony Ferreira | 25002349 |
| Aline de Souza Fragoso | 24000921 |
| Grazielly Zambello Fuzato | 24000211 |

---

## 🎓 Informações Acadêmicas

- **Curso:** Análise e Desenvolvimento de Sistemas
- **Instituição:** UniFeob — Centro Universitário da Fundação de Ensino Octávio Bastos
- **Disciplina:** Projeto Integrado Mobile
- **Professora:** Mariângela Martimbianco Santos
- **Ano:** 2026

---

<div align="center">
  <sub>Feito com 💚 para o campo brasileiro</sub>
</div>
