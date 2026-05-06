# Modelagem Comportamental

## Caso de Uso 1: Autenticação via Google Sign-In

### Fluxo Detalhado
1. Usuário abre o aplicativo e clica em "Entrar com Google"
2. Sistema aciona o Firebase Auth / Google Sign-In
3. Sistema exibe a interface nativa do Google para escolha da conta
4. Google retorna o token de autenticação
5. Sistema valida o token com o Firebase
6. Se válido → acesso liberado ao catálogo
7. Se inválido/cancelado → mensagem de erro e permanece no login

### Diagrama de Atividade

### Diagrama de Sequência


## Caso de Uso 2: Localização por CEP

### Fluxo Detalhado
1. Usuário acessa tela de perfil ou checkout
2. Usuário insere o número do CEP
3. Sistema realiza requisição assíncrona para API externa (ViaCEP)
4. API retorna dados de endereço (Logradouro, Bairro, Localidade)
5. Sistema preenche automaticamente os campos na interface
6. Usuário confirma e o sistema salva no banco de dados

### Diagrama de Atividade

### Diagrama de Sequência


## Caso de Uso 3: Finalização de Pagamento (Checkout)

### Fluxo Detalhado
1. Usuário seleciona o produto e inicia o checkout
2. Sistema valida se o perfil possui RG e CEP cadastrados
3. Sistema processa a transação via módulo de pagamento
4. Sistema registra a venda com status "Confirmado" no histórico
5. Sistema exibe confirmação de compra concluída com sucesso

### Diagrama de Atividade

### Diagrama de Sequência


## Caso de Uso 4: Gestão de Favoritos

### Fluxo Detalhado
1. Usuário navega pelo catálogo de produtos
2. Usuário clica no ícone de "Favoritar" (Coração)
3. Sistema verifica a sessão ativa do usuário
4. Sistema persiste o ID do produto na lista de favoritos vinculada ao usuário
5. Sistema atualiza o estado visual do ícone na interface

### Diagrama de Atividade

### Diagrama de Sequência


## Caso de Uso 5: Atualização de Identificação (RG)

### Fluxo Detalhado
1. Usuário acessa a aba de perfil/configurações
2. Usuário insere o número do RG no campo de texto
3. Sistema valida se o campo não está vazio
4. Sistema envia o comando de atualização para a base de dados
5. Sistema exibe mensagem de sucesso: "Perfil atualizado"

### Diagrama de Atividade

### Diagrama de Sequência
### Diagrama de Sequência

