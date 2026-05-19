# Documento E — Implementação dos Testes de Integração

Projeto: AgroVale App
Tecnologia: Flutter
Arquitetura: MVC com Services
Tipo de teste: Integração

---

**Testes implementados:**
- TC01 — Login com Google e navegação para HomePage
- TC03 — Login com campos vazios exibindo SnackBar
- TC04 — Login inválido exibindo SnackBar
- TC05 — Navegação para HomePage após login válido
- TC06 — Cadastro válido e retorno ao login
- TC14 — Adição de produto ao carrinho
- TC17 — Criação de pedido no Firestore antes do pagamento
- TC18 — Geração de QR Code Pix e exibição na tela
- TC19 — Atualização de status do pedido via webhook
- TC22 — Recomendação de produto pelo assistente IA
- TC23 — Adição ao carrinho via assistente IA
- TC25 — Logout com confirmação e retorno ao login

**Arquivo:**
- integration_test/auth_flow_test.dart
- integration_test/cart_payment_flow_test.dart
- integration_test/ai_assistant_flow_test.dart

**Ferramentas:**
- flutter_test
- integration_test
- pumpWidget
- pumpAndSettle
- tap
- enterText
- find
- mockito
- fake_cloud_firestore

**Objetivo:**
Validar o funcionamento integrado entre Page, Service, Repository, Service fake e navegação nos principais fluxos do AgroVale: autenticação, carrinho, pagamento via Pix e assistente virtual com IA.

**Resultado esperado:**
Os testes devem executar o app, simular interações do usuário e verificar mensagens, navegação e atualizações no banco de dados.
