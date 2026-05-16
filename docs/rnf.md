# Requisitos Não Funcionais do Sistema

Os requisitos não funcionais descrevem as características de qualidade, restrições técnicas e padrões que o sistema AgroVale deve atender.

---

## RNF01 – Desempenho

**Descrição:** O sistema deve responder às interações do usuário de forma ágil e eficiente.

**Critérios de Aceitação:**
- A tela principal deve carregar os produtos em no máximo 3 segundos em conexão 4G
- O filtro de busca deve atualizar os resultados em tempo real conforme o usuário digita, sem atraso perceptível
- O QR Code Pix deve ser gerado e exibido em no máximo 5 segundos após a solicitação

**Categoria:** Desempenho

---

## RNF02 – Disponibilidade

**Descrição:** O sistema deve estar disponível para uso sempre que o usuário precisar.

**Critérios de Aceitação:**
- O backend (Firebase + Cloud Functions) deve ter disponibilidade mínima de 99,5%, conforme SLA do Google Cloud
- Em caso de indisponibilidade temporária da API Gemini ou Mercado Pago, o sistema deve exibir mensagens de erro amigáveis sem travar o aplicativo

**Categoria:** Disponibilidade

---

## RNF03 – Segurança

**Descrição:** O sistema deve proteger os dados dos usuários e as credenciais de acesso às APIs externas.

**Critérios de Aceitação:**
- As chaves de API (Gemini, Mercado Pago) não devem ser expostas no código-fonte versionado no Git
- As chaves devem ser armazenadas em arquivo `.env` listado no `.gitignore`
- O acesso ao Firestore deve ser restrito por regras de segurança, permitindo que cada usuário acesse apenas seus próprios dados
- A autenticação deve ser gerenciada exclusivamente pelo Firebase Auth

**Categoria:** Segurança

---

## RNF04 – Usabilidade

**Descrição:** O sistema deve oferecer uma interface intuitiva, acessível e consistente com o tema visual do aplicativo.

**Critérios de Aceitação:**
- A interface deve seguir o padrão de design dark com tema verde, mantendo consistência em todas as telas
- Os botões de ação principal devem ser facilmente identificáveis com cor verde e ícones representativos
- O sistema deve exibir indicadores de carregamento (CircularProgressIndicator) sempre que uma operação assíncrona estiver em andamento
- As mensagens de erro e sucesso devem ser exibidas via snackbar com cores distintas (vermelho e verde)

**Categoria:** Usabilidade

---

## RNF05 – Manutenibilidade

**Descrição:** O código do sistema deve ser organizado e estruturado para facilitar manutenções e evoluções futuras.

**Critérios de Aceitação:**
- O projeto deve seguir a separação em camadas: pages, services e widgets
- Os serviços de acesso ao banco de dados devem ser centralizados no FirestoreService
- A lógica de autenticação deve ser isolada no AuthService
- A lógica de integração com a IA deve ser isolada no GeminiService

**Categoria:** Manutenibilidade

---

## RNF06 – Portabilidade

**Descrição:** O sistema deve funcionar nos principais dispositivos móveis Android.

**Critérios de Aceitação:**
- O aplicativo deve ser compatível com Android 8.0 (API 26) ou superior
- O layout deve se adaptar a diferentes tamanhos de tela sem quebrar a interface
- O aplicativo deve ser desenvolvido em Flutter para garantir base de código única

**Categoria:** Portabilidade

---

## RNF07 – Confiabilidade

**Descrição:** O sistema deve garantir a integridade dos dados em operações críticas como pagamentos e pedidos.

**Critérios de Aceitação:**
- O pedido deve ser criado no Firestore antes da chamada à API do Mercado Pago, evitando perda de dados em caso de falha
- Em caso de erro na API de pagamento, o pedido criado deve ser deletado automaticamente
- O carrinho deve ser limpo somente após confirmação de sucesso da API de pagamento
- As operações em lote no Firestore (batch) devem ser utilizadas para garantir atomicidade ao salvar pedidos e limpar o carrinho

**Categoria:** Confiabilidade

---

## RNF08 – Escalabilidade

**Descrição:** A infraestrutura do sistema deve suportar crescimento no número de usuários e produtos sem degradação de desempenho.

**Critérios de Aceitação:**
- O banco de dados Firestore deve ser utilizado com paginação (limite de 50 produtos por consulta) para evitar sobrecarga
- As Cloud Functions devem escalar automaticamente conforme a demanda de webhooks recebidos
- O catálogo enviado à API Gemini deve ser limitado a 50 produtos por requisição para respeitar o limite de tokens

**Categoria:** Escalabilidade

---

## RNF09 – Privacidade

**Descrição:** O sistema deve tratar os dados pessoais dos usuários de acordo com as boas práticas de privacidade.

**Critérios de Aceitação:**
- Dados sensíveis como CPF e RG devem ser armazenados somente no Firestore, acessíveis apenas pelo próprio usuário autenticado
- O sistema não deve compartilhar dados pessoais com terceiros além do necessário para o processamento de pagamentos
- O número de CPF enviado ao Mercado Pago deve ser utilizado exclusivamente para fins de processamento do pagamento

**Categoria:** Privacidade

---

## RNF10 – Recuperabilidade

**Descrição:** O sistema deve oferecer mecanismos para que o usuário retome operações incompletas.

**Critérios de Aceitação:**
- Pedidos com status "Aguardando Pagamento" devem permanecer visíveis na tela de pedidos
- O usuário deve poder gerar um novo QR Code Pix para pedidos pendentes diretamente na tela de pedidos
- O histórico de conversa com o assistente de IA deve ser mantido durante toda a sessão do usuário

**Categoria:** Recuperabilidade
