# Documento A — Base Conceitual de Teste

Projeto: AgroVale App
Tecnologia: Flutter
Arquitetura: MVC com Services
Norma aplicada: ISO/IEC/IEEE 29119-1

---

## 1. Sistema sob Teste

Aplicativo mobile de comércio agropecuário desenvolvido em Flutter com backend Firebase, integrando autenticação, catálogo de produtos, carrinho de compras, pagamento via Mercado Pago e assistente virtual com IA Google Gemini.

---

## 2. Itens de Teste

- AuthService
- FirestoreService
- GeminiService
- CartPage (lógica de carrinho)
- Fluxo Login → HomePage
- Fluxo Cadastro → Login
- Fluxo Carrinho → Pagamento Pix → Pedido
- Fluxo Chat IA → Recomendação → Carrinho

---

## 3. Escopo

- Autenticação (Google e E-mail/Senha)
- Cadastro de usuário
- Listagem e busca de produtos
- Gerenciamento do carrinho
- Pagamento via Pix
- Atualização de status de pedido via webhook
- Assistente virtual com IA
- Favoritos
- Logout
- Testes de unidade
- Testes de integração

---

## 4. Fora de Escopo

- Firebase real (substituído por fake/mock)
- API real do Mercado Pago
- API real do Google Gemini
- Segurança de rede
- Performance sob alta carga
- Testes em iOS

---

## 5. Requisitos

RF01 — O usuário deve conseguir fazer login com Google.
RF02 — O usuário deve conseguir fazer login com e-mail e senha.
RF03 — O sistema deve impedir login com campos vazios.
RF04 — O sistema deve impedir login com credenciais inválidas.
RF05 — O sistema deve navegar para HomePage após login válido.
RF06 — O usuário deve conseguir se cadastrar com e-mail e senha.
RF07 — O sistema deve impedir cadastro com campos vazios.
RF08 — O sistema deve impedir cadastro com e-mail inválido.
RF09 — O sistema deve impedir cadastro duplicado.
RF10 — O sistema deve retornar para login após cadastro.
RF11 — O sistema deve exibir produtos carregados do Firestore.
RF12 — O sistema deve filtrar produtos por nome e categoria.
RF13 — O usuário deve conseguir adicionar produtos ao carrinho.
RF14 — O sistema deve calcular o valor total do carrinho corretamente.
RF15 — O sistema deve remover item ao reduzir quantidade a zero.
RF16 — O sistema deve criar pedido no Firestore antes de chamar a API de pagamento.
RF17 — O sistema deve gerar QR Code Pix via API do Mercado Pago.
RF18 — O sistema deve atualizar status do pedido para "Pago" via webhook.
RF19 — O sistema deve limpar o carrinho após pagamento confirmado.
RF20 — O assistente deve buscar catálogo do Firestore antes de cada resposta.
RF21 — O assistente deve retornar produtos recomendados com base na necessidade do usuário.
RF22 — O usuário deve conseguir adicionar ao carrinho produto recomendado pela IA.
RF23 — O sistema deve alternar o estado de favorito ao tocar no ícone.
RF24 — O sistema deve encerrar a sessão após confirmação do logout.

---

## 6. Condições de Teste

CT01 — Validar login com Google
CT02 — Validar login com e-mail e senha válidos
CT03 — Validar login com campos vazios
CT04 — Validar login com credenciais inválidas
CT05 — Validar navegação para HomePage após login
CT06 — Validar cadastro com dados válidos
CT07 — Validar cadastro com campos vazios
CT08 — Validar cadastro com e-mail inválido
CT09 — Validar cadastro duplicado
CT10 — Validar retorno ao login após cadastro
CT11 — Validar listagem de produtos
CT12 — Validar busca de produtos por nome
CT13 — Validar busca de produtos por sinônimos
CT14 — Validar adição de produto ao carrinho
CT15 — Validar cálculo do valor total do carrinho
CT16 — Validar remoção de item com quantidade zero
CT17 — Validar criação de pedido no Firestore
CT18 — Validar geração de QR Code Pix
CT19 — Validar atualização de status via webhook
CT20 — Validar limpeza do carrinho após pagamento
CT21 — Validar busca de catálogo pelo assistente IA
CT22 — Validar recomendação de produto pelo assistente IA
CT23 — Validar adição ao carrinho via assistente IA
CT24 — Validar toggle de favorito
CT25 — Validar logout com confirmação

---

## 7. Tipos de Teste

- Teste de Unidade
- Teste de Integração

---

## 8. Riscos

R01 — Login inválido permitir acesso ao sistema
R02 — Navegação não funcionar após autenticação
R03 — Cadastro aceitar dados inválidos
R04 — Mensagens de erro não serem exibidas ao usuário
R05 — Cálculo incorreto do valor total do carrinho
R06 — Pedido não ser criado no Firestore antes do pagamento
R07 — Carrinho não ser limpo após pagamento confirmado
R08 — Status do pedido não ser atualizado após webhook
R09 — Assistente IA recomendar produtos fora do catálogo
R10 — Favorito não alternar corretamente entre ativo e inativo
