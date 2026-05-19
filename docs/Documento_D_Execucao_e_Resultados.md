# Documento D — Execução e Resultados dos Testes

Projeto: AgroVale App
Tecnologia: Flutter
Arquitetura: MVC com Services
Norma aplicada: ISO/IEC/IEEE 29119
Tipo de teste:
- Unidade
- Integração

---

## 1. Objetivo

Registrar a execução dos testes implementados no projeto Flutter AgroVale, documentando os resultados obtidos, falhas encontradas e análise final do comportamento do sistema.

---

## 2. Ambiente de Execução

Ambiente utilizado:
- Flutter SDK
- Dart SDK
- flutter_test
- integration_test
- mockito
- fake_cloud_firestore

Arquitetura:
- MVC com Services
- FakeAuthService
- FakeFirestoreService
- FakeGeminiService
- FakeMercadoPagoService

---

## 3. Estrutura dos Testes Executados

```
test/
  services/
    auth_service_test.dart
    firestore_service_test.dart
    gemini_service_test.dart
  cart/
    cart_logic_test.dart
integration_test/
  auth_flow_test.dart
  cart_payment_flow_test.dart
  ai_assistant_flow_test.dart
```

---

## 4. Execução dos Testes

**Testes unitários**
```
flutter test
```

**Testes de integração**
```
flutter test integration_test
```

---

## 5. Resultados dos Testes Unitários

| Caso | Objetivo | Resultado Esperado | Resultado Obtido | Status |
|------|----------|--------------------|------------------|--------|
| TC01 | Login com Google | Navegação para HomePage | Navegação realizada | Aprovado |
| TC02 | Login e-mail/senha válidos | Login realizado | Login realizado | Aprovado |
| TC03 | Login campos vazios | Mensagem de erro | Mensagem exibida | Aprovado |
| TC04 | Login inválido | Mensagem de erro | Mensagem exibida | Aprovado |
| TC05 | Navegação para HomePage | HomePage exibida | HomePage exibida | Aprovado |
| TC06 | Cadastro válido | Cadastro realizado | Cadastro realizado | Aprovado |
| TC07 | Cadastro campos vazios | Mensagem de erro | Mensagem exibida | Aprovado |
| TC08 | Cadastro e-mail inválido | Mensagem de erro | Mensagem exibida | Aprovado |
| TC09 | Cadastro duplicado | Bloqueio do cadastro | Bloqueio realizado | Aprovado |
| TC10 | Retorno ao login | Tela de login exibida | Tela de login exibida | Aprovado |
| TC11 | Listagem de produtos | Produtos exibidos | Produtos exibidos | Aprovado |
| TC12 | Busca por nome | Produto filtrado | Produto filtrado | Aprovado |
| TC13 | Busca por sinônimo | Produtos relacionados | Produtos relacionados | Aprovado |
| TC14 | Adição ao carrinho | Produto no carrinho | Produto adicionado | Aprovado |
| TC15 | Cálculo do total | R$ 110,00 | R$ 110,00 | Aprovado |
| TC16 | Remoção quantidade zero | Item removido | Item removido | Aprovado |
| TC17 | Criação de pedido | Pedido no Firestore | Pedido criado | Aprovado |
| TC18 | Geração QR Code Pix | QR Code exibido | QR Code exibido | Aprovado |
| TC19 | Atualização via webhook | Status "Pago" | Status atualizado | Aprovado |
| TC20 | Limpeza do carrinho | Carrinho vazio | Carrinho limpo | Aprovado |
| TC21 | Busca catálogo IA | Catálogo carregado | Catálogo carregado | Aprovado |
| TC22 | Recomendação IA | Produto recomendado | Produto recomendado | Aprovado |
| TC23 | Adição via assistente | Produto no carrinho | Produto adicionado | Aprovado |
| TC24 | Toggle favorito | Favorito alternado | Favorito alternado | Aprovado |
| TC25 | Logout | Sessão encerrada | Sessão encerrada | Aprovado |

---

## 6. Simulação de Falha

Foi realizada uma simulação de falha alterando propositalmente o valor esperado do teste TC15.

**Objetivo da simulação**

Demonstrar:
- funcionamento do framework de teste
- diferença entre resultado esperado e obtido
- comportamento de falhas automatizadas

**Resultado da simulação**

Esperado pelo teste:
```
R$ 120,00
```

Resultado obtido:
```
R$ 110,00
```

Resultado do Teste:
Reprovado

---

## 7. Análise dos Resultados

Os testes unitários validaram corretamente:
- regras de autenticação
- validações de campos
- mensagens de erro
- cálculo do carrinho
- criação e atualização de pedidos
- lógica do assistente virtual
- toggle de favoritos

---

## 8. Benefícios Observados

A arquitetura MVC com Services permitiu:
- isolamento da lógica de negócio
- facilidade de teste
- reutilização dos serviços
- separação entre UI e regras de negócio

A utilização de Fakes permitiu:
- independência de backend real (Firebase, Mercado Pago, Gemini)
- execução rápida dos testes
- previsibilidade dos resultados
- sem custos de API durante os testes

---

## 9. Problemas Encontrados

Nenhuma falha funcional foi encontrada durante os testes oficiais.

Apenas a falha simulada no TC15 apresentou erro propositalmente induzido para fins didáticos.

---

## 10. Conclusão Final

Os testes executados demonstraram que o sistema atende aos requisitos funcionais definidos inicialmente.

Os testes unitários validaram corretamente os Services isoladamente.

Os testes de integração validaram os fluxos completos entre telas, serviços e banco de dados.

A utilização da ISO/IEC/IEEE 29119 permitiu organizar:
- conceitos
- processo
- técnicas
- execução
- documentação de forma estruturada e rastreável.

---

## 11. Estatísticas Finais

| Tipo | Quantidade |
|------|-----------|
| Testes planejados | 25 |
| Testes executados | 25 |
| Testes aprovados | 25 |
| Testes reprovados | 0 |
| Falhas simuladas | 1 |
