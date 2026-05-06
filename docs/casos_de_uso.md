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
- Se não houver vendas, o sistema exibe mensagem "Nenhuma venda registrada"

**Relacionamento com MVP:** Histórico de vendas

---

## UC06 – Editar Produto

**Ator:** Vendedor

**Descrição:** Permite alterar as informações de um produto já cadastrado.

**Fluxo Principal:**
1. O usuário seleciona um produto na lista
2. O sistema exibe os dados atuais
3. O usuário altera as informações desejadas
4. O usuário confirma a alteração
5. O sistema salva as mudanças

**Fluxo Alternativo:**
- Se o usuário cancelar, os dados originais permanecem inalterados

**Relacionamento com MVP:** Gestão de produtos

---

## UC07 – Excluir Produto

**Ator:** Vendedor

**Descrição:** Permite remover um produto do catálogo.

**Fluxo Principal:**
1. O usuário seleciona o produto
2. O usuário solicita a exclusão
3. O sistema pede confirmação
4. O usuário confirma a ação
5. O sistema remove o produto da base de dados

**Fluxo Alternativo:**
- Se o usuário não confirmar, a exclusão é cancelada

**Relacionamento com MVP:** Gestão de produtos

---

## UC08 – Autenticação de Usuário

**Ator:** Vendedor

**Descrição:** Permite que o vendedor acesse as funcionalidades do sistema.

**Fluxo Principal:**
1. O usuário informa usuário e senha
2. O sistema valida as credenciais
3. O sistema libera o acesso ao painel principal

**Fluxo Alternativo:**
- Se os dados estiverem incorretos, o sistema exibe erro de login

**Relacionamento com MVP:** Segurança do sistema

---

## UC09 – Cancelar Venda

**Ator:** Vendedor

**Descrição:** Permite cancelar uma venda registrada por engano.

**Fluxo Principal:**
1. O usuário acessa o histórico de vendas
2. Seleciona a venda e solicita o cancelamento
3. O sistema confirma a ação e devolve o item ao estoque

**Fluxo Alternativo:**
- Se a venda já estiver cancelada, o sistema notifica o usuário

**Relacionamento com MVP:** Controle de estoque e vendas

---

## UC10 – Gerar Relatório de Vendas

**Ator:** Vendedor

**Descrição:** Permite visualizar o faturamento total e quantidade de itens vendidos.

**Fluxo Principal:**
1. O usuário acessa a aba de relatórios
2. O sistema soma as vendas realizadas no período
3. O sistema exibe o total arrecadado

**Fluxo Alternativo:**
- Se não houver dados, o sistema exibe valores zerados

**Relacionamento com MVP:** Gestão financeira
