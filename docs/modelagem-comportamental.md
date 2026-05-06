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
<img width="555" height="601" alt="image" src="https://github.com/user-attachments/assets/be101f40-942f-4abf-bd5b-27ba7c838338" />

### Diagrama de Sequência
<img width="579" height="490" alt="image" src="https://github.com/user-attachments/assets/f9af07e4-d99f-4d9a-9513-8d49df481f58" />

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
<img width="324" height="473" alt="image" src="https://github.com/user-attachments/assets/a3560f12-377f-4832-ab58-e6294207aabb" />

### Diagrama de Sequência
<img width="494" height="415" alt="image" src="https://github.com/user-attachments/assets/b93b999d-d9f6-4896-a06f-1fd7c6afedee" />

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
<img width="682" height="601" alt="image" src="https://github.com/user-attachments/assets/144265bf-71d0-4043-a5fa-b57e108c55f9" />

### Diagrama de Sequência
<img width="519" height="490" alt="image" src="https://github.com/user-attachments/assets/6d78c4df-2569-4374-a459-6a968c55bc48" />

---

## Caso de Uso 4: Gestão de Favoritos

### Fluxo Detalhado

1. Usuário navega pelo catálogo de produtos.

2. Usuário clica no ícone de "Favoritar" (Coração).

3. Sistema verifica a sessão ativa do usuário.

4. Sistema persiste o ID do produto na lista de favoritos vinculada ao usuário no Firebase.

5. Sistema atualiza o estado visual do ícone na interface.

### Diagrama de Atividade
<img width="346" height="429" alt="image" src="https://github.com/user-attachments/assets/12a59aa3-b990-4938-8774-ae294608da6e" />

### Diagrama de Sequência
<img width="432" height="357" alt="image" src="https://github.com/user-attachments/assets/e9af3e68-f0a3-4f53-b58e-d28a65af013e" />

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
<img width="412" height="483" alt="image" src="https://github.com/user-attachments/assets/045e1244-ef65-4eeb-88af-3eb32afa1ac9" />

### Diagrama de Sequência
<img width="463" height="532" alt="image" src="https://github.com/user-attachments/assets/8dfdb0eb-def4-4ab8-aaad-a6509acb1b13" />

