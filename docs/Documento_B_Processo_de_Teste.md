# Documento B — Processo de Teste

Projeto: AgroVale App
Tecnologia: Flutter
Arquitetura: MVC com Services
Norma aplicada: ISO/IEC/IEEE 29119-2

---

## 1. Estratégia de Teste

- Testes de unidade para validar lógica isolada dos Services
- Testes de integração para validar fluxos completos entre telas
- Uso de FakeFirestoreService, FakeAuthService e FakeGeminiService
- Uso de FakeMercadoPagoService para simulação de pagamento

---

## 2. Ambiente de Teste

- Flutter SDK
- Dart SDK
- flutter_test
- integration_test
- mockito
- fake_cloud_firestore

---

## 3. Critérios de Entrada

- Projeto funcional com todas as telas implementadas
- Services implementados (AuthService, FirestoreService, GeminiService)
- Documento A concluído e aprovado
- Fakes e mocks disponíveis para os serviços externos

---

## 4. Critérios de Saída

- Todos os testes planejados executados
- Resultados registrados no Documento D
- Relatório final produzido
- Falhas documentadas e analisadas

---

## 5. Ordem de Execução

1. Testar AuthService (login e cadastro)
2. Testar FirestoreService (produtos, carrinho, pedidos, favoritos)
3. Testar GeminiService (busca de catálogo e recomendação)
4. Testar integração Login → HomePage
5. Testar integração Cadastro → Login
6. Testar integração Carrinho → Pagamento Pix → Pedido
7. Testar integração Chat IA → Recomendação → Carrinho

---

## 6. Implementação

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

## 7. Controle

- Planejados
- Executados
- Aprovados
- Reprovados

---

## 8. Execução

```
flutter test
flutter test integration_test
```

---

## 9. Conclusão

Encerrar após execução completa de todos os testes planejados e análise dos resultados obtidos.
