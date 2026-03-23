# Casos de Uso do Sistema

Os casos de uso descrevem como o usuário interage com o sistema AgroVale.

---

## UC01 – Cadastrar Produto

**Ator:** Vendedor

**Descrição:** Permite cadastrar um novo produto no sistema.

**Fluxo Principal:**
1. O usuário acessa a tela de cadastro
2. Informa nome, preço e quantidade
3. Confirma o cadastro
4. O sistema salva o produto

**Fluxo Alternativo:**
- Se algum campo estiver vazio, o sistema exibe uma mensagem de erro

**Relacionamento com MVP:** Cadastro de produtos

---

## UC02 – Visualizar Produtos

**Ator:** Vendedor

**Descrição:** Permite visualizar os produtos cadastrados.

**Fluxo Principal:**
1. O usuário acessa a lista de produtos
2. O sistema exibe os produtos cadastrados

**Fluxo Alternativo:**
- Se não houver produtos, o sistema exibe mensagem "Nenhum produto cadastrado"

**Relacionamento com MVP:** Visualização de produtos

---

## UC03 – Registrar Venda

**Ator:** Vendedor

**Descrição:** Permite registrar uma venda.

**Fluxo Principal:**
1. O usuário seleciona um produto
2. Informa a quantidade
3. Confirma a venda
4. O sistema registra a venda

**Fluxo Alternativo:**
- Se a quantidade for maior que o estoque, o sistema exibe erro

**Relacionamento com MVP:** Registro de vendas

---

## UC04 – Atualizar Estoque

**Ator:** Sistema

**Descrição:** Atualiza automaticamente o estoque após venda.

**Fluxo Principal:**
1. Uma venda é realizada
2. O sistema reduz a quantidade no estoque

**Fluxo Alternativo:**
- Se houver erro, o sistema não atualiza o estoque

**Relacionamento com MVP:** Controle de estoque

---

## UC05 – Visualizar Histórico de Vendas

**Ator:** Vendedor

**Descrição:** Permite visualizar o histórico de vendas.

**Fluxo Principal:**
1. O usuário acessa a tela de histórico
2. O sistema exibe as vendas realizadas

**Fluxo Alternativo:**
- Se não houver vendas, o sistema exibe mensagem

**Relacionamento com MVP:** Histórico de vendas
