# Modelagem Comportamental

## Caso de Uso 1: Autenticação via Google Sign-In

### Fluxo Detalhado

1. Usuário abre o aplicativo e clica em "Entrar com Google".

2. Sistema aciona o Firebase Auth / Google Sign-In.

3. Sistema exibe a interface nativa do Google para escolha da conta.

4. Google retorna o token de autenticação.

5. Sistema valida o token com o Firebase.

6. Se válido → acesso liberado ao catálogo.

7. Se inválido/cancelado → mensagem de erro e permanece no login.

### Diagrama de Atividade
[Inserir Diagrama de Atividade 2 aqui]

### Diagrama de Sequência
[Inserir Diagrama de Sequência 2 aqui]

---

## Caso de Uso 2: Localização por CEP

### Fluxo Detalhado

1. Usuário acessa tela de perfil ou checkout.

2. Usuário insere o número do CEP.

3. Sistema realiza requisição assíncrona para API externa (ViaCEP).

4. API retorna dados de endereço (Logradouro, Bairro, Localidade).

5. Sistema preenche automaticamente os campos na interface.

6. Usuário confirma e o sistema salva no banco de dados.

### Diagrama de Atividade
[Inserir Diagrama de Atividade 2 aqui]

### Diagrama de Sequência
[Inserir Diagrama de Sequência 2 aqui]

---

## Caso de Uso 3: Finalização de Pagamento (Mercado Pago)

### Fluxo Detalhado

1. Usuário seleciona o produto e inicia o checkout.

2. Sistema valida se o perfil possui RG e CEP cadastrados.

3. Sistema envia os dados para o módulo de pagamento da **API do Mercado Pago**.

4. Sistema recebe a confirmação de transação aprovada.

5. Sistema registra a venda com status "Confirmado" no histórico.

6. Sistema exibe confirmação de compra concluída com sucesso via interface do Mercado Pago.

### Diagrama de Atividade
[Inserir Diagrama de Atividade 2 aqui]

### Diagrama de Sequência
[Inserir Diagrama de Sequência 2 aqui]

---

## Caso de Uso 4: Gestão de Favoritos

### Fluxo Detalhado

1. Usuário navega pelo catálogo de produtos.

2. Usuário clica no ícone de "Favoritar" (Coração).

3. Sistema verifica a sessão ativa do usuário.

4. Sistema persiste o ID do produto na lista de favoritos vinculada ao usuário no Firebase.

5. Sistema atualiza o estado visual do ícone na interface.

### Diagrama de Atividade
[Inserir Diagrama de Atividade 2 aqui]

### Diagrama de Sequência
[Inserir Diagrama de Sequência 2 aqui]

---

## Caso de Uso 5: Gestão e Edição de Perfil (RG e Dados)

### Fluxo Detalhado

1. Usuário acessa a aba de perfil/configurações a qualquer momento.

2. O sistema recupera e exibe os dados atuais (RG e CEP) do banco de dados.

3. Usuário insere ou altera as informações nos campos de texto.

4. Sistema valida se os campos obrigatórios foram preenchidos.

5. Sistema envia o comando de atualização (update) para a base de dados em tempo real.

6. Sistema exibe mensagem de sucesso: "Dados atualizados com sucesso".

### Diagrama de Atividade
[Inserir Diagrama de Atividade 2 aqui]

### Diagrama de Sequência
[Inserir Diagrama de Sequência 2 aqui]
