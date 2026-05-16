# Regras de Negócio do Sistema

As regras de negócio definem as políticas, restrições e condições que o sistema AgroVale deve respeitar para garantir o correto funcionamento dos processos.

---

## RN01 – Acesso Restrito a Usuários Autenticados

**Descrição:** Determinadas funcionalidades do sistema são exclusivas para usuários autenticados.

**Regra:**
- Usuários não autenticados podem visualizar produtos e utilizar o assistente virtual
- Somente usuários autenticados podem adicionar produtos ao carrinho, favoritar produtos, realizar compras e visualizar pedidos
- Caso um usuário não autenticado tente realizar uma ação restrita, o sistema não executa a operação

**Relacionamento:** RF01, RF02, RF03, RF07, RF08

---

## RN02 – Validação de CPF

**Descrição:** O sistema deve garantir que apenas CPFs válidos sejam aceitos no cadastro do usuário.

**Regra:**
- O CPF deve ser validado utilizando o algoritmo de verificação de dígitos
- CPFs com formato incorreto ou dígitos verificadores inválidos não devem ser aceitos
- O campo CPF deve aceitar apenas o formato 000.000.000-00

**Relacionamento:** RF04

---

## RN03 – Preenchimento Automático de Endereço

**Descrição:** O sistema deve preencher automaticamente os campos de endereço ao informar um CEP válido.

**Regra:**
- Ao digitar um CEP com 8 dígitos, o sistema deve consultar a API ViaCEP
- Os campos Rua, Bairro, Cidade e UF devem ser preenchidos automaticamente com os dados retornados
- Caso o CEP não seja encontrado, os campos devem permanecer em branco para preenchimento manual
- O campo Número nunca é preenchido automaticamente e deve ser informado pelo usuário

**Relacionamento:** RF04

---

## RN04 – Cálculo do Valor Total do Carrinho

**Descrição:** O valor total do carrinho deve ser calculado com base no preço unitário e na quantidade de cada item.

**Regra:**
- Total = soma de (preço × quantidade) para cada item do carrinho
- O valor total deve ser recalculado automaticamente sempre que a quantidade de um item for alterada
- O valor total exibido deve ser formatado com duas casas decimais

**Relacionamento:** RF08

---

## RN05 – Remoção Automática de Item do Carrinho

**Descrição:** Itens com quantidade zero devem ser removidos automaticamente do carrinho.

**Regra:**
- Ao reduzir a quantidade de um item para zero ou valor negativo, o item deve ser excluído da coleção de carrinho no Firestore
- O usuário não pode informar quantidade negativa manualmente

**Relacionamento:** RF08

---

## RN06 – Criação do Pedido Antes do Pagamento

**Descrição:** O pedido deve ser registrado no Firestore antes de qualquer chamada à API de pagamento.

**Regra:**
- O sistema deve criar o documento do pedido no Firestore com status "Aguardando Pagamento" antes de chamar a API do Mercado Pago
- O ID gerado pelo Firestore deve ser utilizado como referência externa (external_reference) na chamada ao Mercado Pago
- Em caso de erro na API de pagamento, o pedido criado deve ser deletado do Firestore para não gerar registros inconsistentes

**Relacionamento:** RF09, RF10

---

## RN07 – Limpeza do Carrinho Após Pagamento

**Descrição:** O carrinho do usuário deve ser limpo somente após a confirmação de sucesso da API de pagamento.

**Regra:**
- Os itens do carrinho devem ser removidos somente quando a API do Mercado Pago retornar status 200 ou 201
- Em caso de erro na API, o carrinho deve ser mantido intacto para que o usuário possa tentar novamente
- A remoção dos itens deve ser realizada em lote (batch) para garantir atomicidade

**Relacionamento:** RF09, RF10

---

## RN08 – Atualização de Status do Pedido via Webhook

**Descrição:** O status do pedido deve ser atualizado exclusivamente com base na notificação oficial do Mercado Pago.

**Regra:**
- O sistema não deve alterar o status do pedido com base apenas na ação do usuário no app
- A Cloud Function deve consultar a API do Mercado Pago para confirmar o status antes de atualizar o Firestore
- O mapeamento de status deve seguir a tabela:
  - approved → "Pago"
  - pending / in_process → "Aguardando Pagamento"
  - rejected → "Pagamento Recusado"
  - cancelled → "Cancelado"
  - refunded → "Reembolsado"

**Relacionamento:** RF11

---

## RN09 – Restrição de Geração de Novo Pix

**Descrição:** A opção de gerar um novo QR Code Pix deve estar disponível apenas para pedidos com pagamento pendente.

**Regra:**
- O botão "Gerar Novo Pix" deve ser exibido somente para pedidos com status "Aguardando Pagamento"
- Para pedidos com status "Pago", "Cancelado" ou "Pagamento Recusado", o botão não deve ser exibido
- Cada geração de novo Pix cria um novo registro de pagamento no Mercado Pago vinculado ao mesmo pedido

**Relacionamento:** RF12

---

## RN10 – Catálogo Real na Recomendação por IA

**Descrição:** O assistente virtual deve recomendar apenas produtos existentes no catálogo do Firestore.

**Regra:**
- O sistema deve buscar o catálogo atualizado do Firestore antes de cada mensagem enviada à API Gemini
- O prompt enviado à IA deve conter apenas os produtos reais cadastrados no banco de dados
- A IA não deve recomendar produtos que não constem no catálogo
- O sistema deve cruzar os nomes citados pela IA com o catálogo para exibir os cards de produto

**Relacionamento:** RF13

---

## RN11 – Limite de Produtos no Prompt da IA

**Descrição:** O número de produtos enviados no contexto da IA deve ser limitado para respeitar os limites da API.

**Regra:**
- O sistema deve enviar no máximo 50 produtos por consulta à API Gemini
- A IA deve recomendar no máximo 3 produtos por resposta
- Caso o catálogo possua mais de 50 produtos, os primeiros 50 retornados pelo Firestore devem ser utilizados

**Relacionamento:** RF13, RNF08

---

## RN12 – Comportamento de Toggle nos Favoritos

**Descrição:** O sistema deve alternar o estado de favorito de um produto a cada toque do usuário.

**Regra:**
- Se o produto não estiver favoritado, ao tocar no ícone o produto deve ser adicionado aos favoritos
- Se o produto já estiver favoritado, ao tocar no ícone o produto deve ser removido dos favoritos
- O estado do ícone de favorito deve refletir o estado atual do produto no Firestore em tempo real

**Relacionamento:** RF14

---

## RN13 – Histórico de Conversa com a IA

**Descrição:** O assistente virtual deve manter o contexto da conversa durante toda a sessão.

**Regra:**
- O histórico de mensagens deve ser mantido na memória durante a sessão do usuário no chat
- O histórico deve ser incluído em cada nova chamada à API Gemini para garantir continuidade do contexto
- Ao fechar o chat e reabrir, o histórico deve ser reiniciado automaticamente

**Relacionamento:** RF13

---

## RN14 – Ordenação dos Pedidos

**Descrição:** Os pedidos devem ser exibidos sempre do mais recente para o mais antigo.

**Regra:**
- A consulta ao Firestore deve ordenar os pedidos pelo campo dataCriacao de forma decrescente
- O índice composto (idUsuario + dataCriacao) deve estar criado no Firestore para suportar esta consulta

**Relacionamento:** RF12

---

## RN15 – Confirmação Antes do Logout

**Descrição:** O sistema deve solicitar confirmação do usuário antes de encerrar a sessão.

**Regra:**
- Ao tocar em "Sair da Conta", o sistema deve exibir um diálogo de confirmação
- A sessão só deve ser encerrada após o usuário confirmar a ação
- Após o logout, todas as rotas anteriores devem ser removidas da pilha de navegação, impedindo o retorno sem novo login

**Relacionamento:** RF15
