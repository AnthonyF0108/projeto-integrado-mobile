# Documento C — Técnicas e Casos de Teste

Projeto: AgroVale App
Tecnologia: Flutter
Arquitetura: MVC com Services
Norma aplicada: ISO/IEC/IEEE 29119-4

---

## 1. Técnicas Utilizadas

| Técnica | Finalidade |
|---------|-----------|
| Particionamento de Equivalência | Separar entradas válidas e inválidas |
| Valor Limite | Validar campos vazios e quantidades mínimas |
| Transição de Estado | Validar mudança de status do pedido e toggle de favorito |
| Teste Baseado em Cenário | Validar fluxos completos entre telas |

---

## 2. Derivação das Condições de Teste

---

### CT01 — Validar login com Google

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Justificativa:**
O fluxo envolve múltiplos sistemas externos (GoogleSignIn e FirebaseAuth), sendo necessário validar o cenário completo de autenticação.

**TC01 — Login com Google**

Entradas:
```
conta Google válida selecionada
```
Resultado Esperado:
- Autenticação realizada com sucesso
- Navegação para HomePage

---

### CT02 — Validar login com e-mail e senha válidos

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
Existe uma classe válida de entrada:
- e-mail válido
- senha correta

**TC02 — Login com e-mail e senha válidos**

Entradas:
```
email = "usuario@email.com"
senha = "123456"
```
Resultado Esperado:
- Login realizado com sucesso
- Navegação para HomePage

---

### CT03 — Validar login com campos vazios

**Técnica Utilizada:**
- Particionamento de Equivalência
- Valor Limite

**Justificativa:**
Campos vazios representam partição inválida e limite inferior aceitável.

**TC03 — Login com campos vazios**

Entradas:
```
email = ""
senha = ""
```
Resultado Esperado:
- Mensagem: "Preencha e-mail e senha."

---

### CT04 — Validar login com credenciais inválidas

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
Senha incorreta representa classe inválida de entrada.

**TC04 — Login inválido**

Entradas:
```
email = "usuario@email.com"
senha = "senhaerrada"
```
Resultado Esperado:
- Mensagem: "E-mail ou senha inválidos."

---

### CT05 — Validar navegação para HomePage após login

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Login válido → sucesso → navegação para HomePage

**TC05 — Navegação para HomePage**

Resultado Esperado:
- Tela HomePage exibida com sucesso

---

### CT06 — Validar cadastro com dados válidos

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
Existe uma classe válida de entrada:
- nome preenchido
- e-mail válido
- senha preenchida

**TC06 — Cadastro com dados válidos**

Entradas:
```
nome = "João Silva"
email = "joao@email.com"
senha = "123456"
```
Resultado Esperado:
- Cadastro realizado com sucesso
- Mensagem de sucesso exibida
- Navegação para tela de login

---

### CT07 — Validar cadastro com campos vazios

**Técnica Utilizada:**
- Particionamento de Equivalência
- Valor Limite

**Justificativa:**
Campos vazios representam partição inválida e limite inferior aceitável.

**TC07 — Cadastro com campos vazios**

Entradas:
```
nome = ""
email = ""
senha = ""
```
Resultado Esperado:
- Mensagem: "Preencha todos os campos."

---

### CT08 — Validar cadastro com e-mail inválido

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
E-mails sem @ ou sem domínio representam classe inválida.

**TC08 — Cadastro com e-mail inválido**

Entradas:
```
email = "joaoemail.com"
```
Resultado Esperado:
- Mensagem: "Informe um e-mail válido."

---

### CT09 — Validar cadastro duplicado

**Técnica Utilizada:**
- Transição de Estado

**Justificativa:**
O sistema muda de:
- usuário inexistente
para:
- usuário já cadastrado

**TC09 — Cadastro duplicado**

Pré-condição:
Usuário já cadastrado no sistema.

Resultado Esperado:
- Mensagem: "E-mail já cadastrado."

---

### CT10 — Validar retorno ao login após cadastro

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Cadastro válido → sucesso → retorno para tela de login

**TC10 — Retorno ao login após cadastro**

Resultado Esperado:
- Tela de login exibida após cadastro bem-sucedido

---

### CT11 — Validar listagem de produtos

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário autenticado → acessa HomePage → produtos carregados do Firestore

**TC11 — Listagem de produtos**

Pré-condição:
Produtos cadastrados no Firestore.

Resultado Esperado:
- Grade de produtos exibida com imagem, nome e preço

---

### CT12 — Validar busca de produtos por nome

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
Termo de busca correspondente ao nome do produto representa classe válida.

**TC12 — Busca por nome**

Entradas:
```
termo = "Martelo"
```
Resultado Esperado:
- Produto "Martelo" exibido na grade filtrada

---

### CT13 — Validar busca de produtos por sinônimos

**Técnica Utilizada:**
- Particionamento de Equivalência

**Justificativa:**
Termos como "comida" devem expandir para "ração" e "semente".

**TC13 — Busca por sinônimo**

Entradas:
```
termo = "comida"
```
Resultado Esperado:
- Produtos de categoria ração ou semente exibidos

---

### CT14 — Validar adição de produto ao carrinho

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário autenticado → toca em produto → adiciona ao carrinho

**TC14 — Adição ao carrinho**

Resultado Esperado:
- Produto adicionado à subcoleção carrinho do usuário no Firestore
- Snackbar de confirmação exibido

---

### CT15 — Validar cálculo do valor total do carrinho

**Técnica Utilizada:**
- Particionamento de Equivalência
- Valor Limite

**Justificativa:**
Total deve ser a soma de preço × quantidade de cada item.

**TC15 — Cálculo do total**

Entradas:
```
item1: preco = 40.0, quantidade = 2
item2: preco = 30.0, quantidade = 1
```
Resultado Esperado:
- Total = R$ 110,00

---

### CT16 — Validar remoção de item com quantidade zero

**Técnica Utilizada:**
- Valor Limite
- Transição de Estado

**Justificativa:**
Quantidade zero representa o limite inferior, devendo acionar remoção do item.

**TC16 — Remoção com quantidade zero**

Entradas:
```
quantidade = 0
```
Resultado Esperado:
- Item removido automaticamente do carrinho

---

### CT17 — Validar criação de pedido no Firestore

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário toca em Pix → sistema cria pedido antes de chamar a API

**TC17 — Criação de pedido**

Resultado Esperado:
- Documento criado na coleção pedidos com status "Aguardando Pagamento"
- ID do pedido gerado corretamente

---

### CT18 — Validar geração de QR Code Pix

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Pedido criado → chamada à API do Mercado Pago → QR Code retornado

**TC18 — Geração de QR Code Pix**

Resultado Esperado:
- QR Code Pix exibido ao usuário
- Opção de copiar código disponível

---

### CT19 — Validar atualização de status via webhook

**Técnica Utilizada:**
- Transição de Estado

**Justificativa:**
O sistema muda de:
- "Aguardando Pagamento"
para:
- "Pago"

**TC19 — Atualização de status via webhook**

Pré-condição:
Pagamento aprovado pelo Mercado Pago.

Resultado Esperado:
- Status do pedido atualizado para "Pago" no Firestore
- Tela de pedidos atualizada automaticamente

---

### CT20 — Validar limpeza do carrinho após pagamento

**Técnica Utilizada:**
- Transição de Estado

**Justificativa:**
O sistema muda de:
- carrinho com itens
para:
- carrinho vazio

**TC20 — Limpeza do carrinho**

Pré-condição:
API do Mercado Pago retornou sucesso (status 200 ou 201).

Resultado Esperado:
- Todos os itens removidos do carrinho no Firestore

---

### CT21 — Validar busca de catálogo pelo assistente IA

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário envia mensagem → sistema busca catálogo no Firestore antes de chamar a API Gemini

**TC21 — Busca de catálogo pelo assistente**

Resultado Esperado:
- Catálogo de produtos carregado do Firestore
- Prompt montado com os produtos reais

---

### CT22 — Validar recomendação de produto pelo assistente IA

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário descreve necessidade → IA recomenda produto do catálogo

**TC22 — Recomendação pelo assistente**

Entradas:
```
mensagem = "preciso de algo para limpar o mato"
```
Resultado Esperado:
- IA retorna recomendação com produto existente no catálogo
- Card do produto exibido no chat

---

### CT23 — Validar adição ao carrinho via assistente IA

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
IA recomenda produto → usuário toca em "Adicionar ao Carrinho" no card

**TC23 — Adição ao carrinho via assistente**

Resultado Esperado:
- Produto adicionado ao carrinho no Firestore
- Snackbar de confirmação exibido

---

### CT24 — Validar toggle de favorito

**Técnica Utilizada:**
- Transição de Estado

**Justificativa:**
O sistema alterna entre:
- produto não favoritado
para:
- produto favoritado
e vice-versa.

**TC24 — Toggle de favorito**

Pré-condição:
Usuário autenticado.

Resultado Esperado:
- Primeiro toque: produto adicionado aos favoritos
- Segundo toque: produto removido dos favoritos

---

### CT25 — Validar logout com confirmação

**Técnica Utilizada:**
- Teste Baseado em Cenário

**Cenário:**
Usuário toca em "Sair" → confirma → sessão encerrada → tela de login

**TC25 — Logout**

Resultado Esperado:
- Sessão encerrada no Firebase Auth e GoogleSignIn
- Tela de login exibida

---

## 3. Tabela Consolidada de Técnicas

| Condição | Técnica |
|----------|---------|
| CT01 | Cenário |
| CT02 | Particionamento |
| CT03 | Particionamento + Valor Limite |
| CT04 | Particionamento |
| CT05 | Cenário |
| CT06 | Particionamento |
| CT07 | Particionamento + Valor Limite |
| CT08 | Particionamento |
| CT09 | Transição de Estado |
| CT10 | Cenário |
| CT11 | Cenário |
| CT12 | Particionamento |
| CT13 | Particionamento |
| CT14 | Cenário |
| CT15 | Particionamento + Valor Limite |
| CT16 | Valor Limite + Transição de Estado |
| CT17 | Cenário |
| CT18 | Cenário |
| CT19 | Transição de Estado |
| CT20 | Transição de Estado |
| CT21 | Cenário |
| CT22 | Cenário |
| CT23 | Cenário |
| CT24 | Transição de Estado |
| CT25 | Cenário |

---

## 4. Tabela Consolidada de Casos de Teste

| ID | Caso |
|----|------|
| TC01 | Login com Google |
| TC02 | Login com e-mail e senha válidos |
| TC03 | Login com campos vazios |
| TC04 | Login inválido |
| TC05 | Navegação para HomePage |
| TC06 | Cadastro com dados válidos |
| TC07 | Cadastro com campos vazios |
| TC08 | Cadastro com e-mail inválido |
| TC09 | Cadastro duplicado |
| TC10 | Retorno ao login após cadastro |
| TC11 | Listagem de produtos |
| TC12 | Busca por nome |
| TC13 | Busca por sinônimo |
| TC14 | Adição ao carrinho |
| TC15 | Cálculo do total do carrinho |
| TC16 | Remoção com quantidade zero |
| TC17 | Criação de pedido no Firestore |
| TC18 | Geração de QR Code Pix |
| TC19 | Atualização de status via webhook |
| TC20 | Limpeza do carrinho após pagamento |
| TC21 | Busca de catálogo pelo assistente |
| TC22 | Recomendação pelo assistente IA |
| TC23 | Adição ao carrinho via assistente |
| TC24 | Toggle de favorito |
| TC25 | Logout com confirmação |

---

## 5. Conclusão da Etapa

As condições de teste identificadas foram derivadas em casos de teste completos utilizando técnicas formais definidas pela ISO/IEC/IEEE 29119-4.

Os casos de teste produzidos estão preparados para implementação automatizada no projeto Flutter, utilizando testes de unidade e testes de integração.
