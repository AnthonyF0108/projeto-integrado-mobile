# Requisitos Funcionais do Sistema

Os requisitos funcionais descrevem as funcionalidades que o sistema AgroVale deve oferecer aos seus usuários.

---

## RF01 – Autenticação com Google

**Descrição:** O sistema deve permitir que o usuário faça login utilizando sua conta Google.

**Critérios de Aceitação:**
- O sistema deve exibir o seletor de contas Google ao tocar em "Entrar com Google"
- O sistema deve autenticar o usuário via Firebase Auth com GoogleSignIn
- Em caso de falha, o sistema deve exibir mensagem de erro e permanecer na tela de login

**Prioridade:** Alta

---

## RF02 – Autenticação com E-mail e Senha

**Descrição:** O sistema deve permitir que o usuário faça login com e-mail e senha cadastrados.

**Critérios de Aceitação:**
- O sistema deve validar as credenciais via Firebase Auth
- Em caso de credenciais incorretas, o sistema deve exibir mensagem de erro
- O sistema deve redirecionar para a tela principal após autenticação bem-sucedida

**Prioridade:** Alta

---

## RF03 – Cadastro com E-mail e Senha

**Descrição:** O sistema deve permitir que novos usuários criem uma conta com e-mail e senha.

**Critérios de Aceitação:**
- O sistema deve criar a conta via Firebase Auth
- O sistema deve informar erro caso o e-mail já esteja cadastrado
- O sistema deve informar os requisitos mínimos de senha em caso de senha fraca

**Prioridade:** Alta

---

## RF04 – Atualizar Dados de Cadastro

**Descrição:** O sistema deve permitir que o usuário preencha e atualize seus dados pessoais e de endereço.

**Critérios de Aceitação:**
- O sistema deve exibir formulário com os campos: CPF, RG, Telefone, CEP, Rua, Número, Bairro, Cidade e UF
- O CPF deve ser validado com máscara e verificação de dígitos
- Ao informar o CEP, o sistema deve consultar a API ViaCEP e preencher automaticamente Rua, Bairro, Cidade e UF
- Os dados devem ser salvos no Firestore na coleção de usuários

**Prioridade:** Alta

---

## RF05 – Listagem de Produtos

**Descrição:** O sistema deve exibir todos os produtos cadastrados no Firestore em uma grade na tela principal.

**Critérios de Aceitação:**
- Os produtos devem ser carregados em tempo real via StreamBuilder
- Cada card deve exibir imagem, nome e preço do produto
- A grade deve ser atualizada automaticamente quando houver mudanças no banco de dados

**Prioridade:** Alta

---

## RF06 – Busca de Produtos

**Descrição:** O sistema deve permitir que o usuário pesquise produtos pelo nome ou categoria.

**Critérios de Aceitação:**
- O sistema deve normalizar o texto removendo acentos e convertendo para minúsculas
- O sistema deve expandir a busca com sinônimos relacionados (ex: "comida" inclui "ração" e "semente")
- O sistema deve filtrar os produtos em tempo real conforme o usuário digita

**Prioridade:** Alta

---

## RF07 – Visualizar Detalhes do Produto

**Descrição:** O sistema deve exibir as informações completas de um produto ao ser selecionado.

**Critérios de Aceitação:**
- O sistema deve exibir imagem, nome, preço e descrição do produto em um painel deslizante
- O painel deve conter o botão "Adicionar ao Carrinho"
- O botão deve estar disponível apenas para usuários autenticados

**Prioridade:** Alta

---

## RF08 – Gerenciar Carrinho

**Descrição:** O sistema deve permitir que o usuário visualize e gerencie os itens do carrinho de compras.

**Critérios de Aceitação:**
- O sistema deve listar os itens do carrinho com imagem, nome, preço e quantidade
- O usuário deve poder aumentar ou diminuir a quantidade de cada item
- Ao reduzir a quantidade a zero, o item deve ser removido automaticamente
- O sistema deve calcular e exibir o valor total em tempo real

**Prioridade:** Alta

---

## RF09 – Realizar Pagamento via Pix

**Descrição:** O sistema deve permitir que o usuário realize o pagamento do pedido via Pix com QR Code.

**Critérios de Aceitação:**
- O sistema deve criar o pedido no Firestore antes de chamar a API do Mercado Pago
- O sistema deve gerar o QR Code Pix via API do Mercado Pago
- O sistema deve exibir o QR Code com opção de copiar o código
- O sistema deve passar o ID do pedido como referência externa para o Mercado Pago
- O carrinho deve ser limpo somente após confirmação da API

**Prioridade:** Alta

---

## RF10 – Realizar Pagamento via Boleto

**Descrição:** O sistema deve permitir que o usuário realize o pagamento via boleto bancário.

**Critérios de Aceitação:**
- O sistema deve gerar o boleto via API do Mercado Pago
- O sistema deve abrir o link do boleto no navegador externo do dispositivo
- O sistema deve criar o pedido no Firestore com status "Aguardando Pagamento"

**Prioridade:** Média

---

## RF11 – Atualização Automática de Status do Pedido

**Descrição:** O sistema deve atualizar automaticamente o status do pedido após confirmação do pagamento pelo Mercado Pago.

**Critérios de Aceitação:**
- O Mercado Pago deve notificar a Cloud Function via webhook após o pagamento
- A Cloud Function deve consultar o pagamento na API do Mercado Pago e atualizar o status no Firestore
- O status deve ser mapeado corretamente: approved → "Pago", rejected → "Pagamento Recusado", cancelled → "Cancelado"
- A tela de pedidos deve atualizar automaticamente via StreamBuilder

**Prioridade:** Alta

---

## RF12 – Consultar Pedidos

**Descrição:** O sistema deve permitir que o usuário visualize o histórico de seus pedidos.

**Critérios de Aceitação:**
- Os pedidos devem ser exibidos em ordem decrescente por data
- Cada pedido deve exibir ID, data, itens, valor total e status com badge colorido
- Para pedidos com status "Aguardando Pagamento", o sistema deve exibir o botão "Gerar Novo Pix"
- O botão deve gerar um novo QR Code Pix para o mesmo pedido

**Prioridade:** Alta

---

## RF13 – Assistente Virtual com Inteligência Artificial

**Descrição:** O sistema deve oferecer um assistente virtual que recomenda produtos com base na necessidade descrita pelo usuário.

**Critérios de Aceitação:**
- O assistente deve ser acessado pelo botão flutuante na tela principal
- O sistema deve buscar o catálogo atualizado do Firestore antes de cada resposta
- O sistema deve enviar a mensagem do usuário e o catálogo para a API Google Gemini
- A IA deve recomendar no máximo 3 produtos do catálogo real
- Os produtos recomendados devem ser exibidos em cards com foto, preço e botão de adicionar ao carrinho
- O histórico da conversa deve ser mantido durante a sessão

**Prioridade:** Alta

---

## RF14 – Favoritar Produto

**Descrição:** O sistema deve permitir que o usuário salve produtos como favoritos.

**Critérios de Aceitação:**
- O ícone de favorito deve ser exibido no card do produto na tela principal
- Ao tocar no ícone, o produto deve ser salvo na coleção de favoritos do usuário no Firestore
- Ao tocar novamente, o produto deve ser removido dos favoritos (comportamento de toggle)
- O usuário deve poder visualizar todos os produtos favoritados na aba "Favoritos"

**Prioridade:** Média

---

## RF15 – Logout

**Descrição:** O sistema deve permitir que o usuário encerre sua sessão no aplicativo.

**Critérios de Aceitação:**
- O sistema deve exibir um diálogo de confirmação antes de encerrar a sessão
- O sistema deve encerrar a sessão no GoogleSignIn e no Firebase Auth
- Após o logout, o sistema deve redirecionar para a tela de login removendo todas as rotas anteriores

**Prioridade:** Alta
