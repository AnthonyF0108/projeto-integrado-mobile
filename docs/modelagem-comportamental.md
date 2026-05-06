# Modelagem Comportamental

## Caso de Uso 1: Login

### Fluxo Detalhado
1. Usuário abre o aplicativo
2. Usuário insere email e senha
3. Sistema valida os dados
4. Sistema consulta o banco de dados
5. Se válido → acesso liberado
6. Se inválido → mensagem de erro

### Diagrama de Atividade
<img width="957" height="773" alt="image" src="https://github.com/user-attachments/assets/8bf554ff-c709-4d68-b243-05b5e0a7c27c" />

### Diagrama de Sequência
<img width="584" height="796" alt="image" src="https://github.com/user-attachments/assets/d530b2eb-1e77-4a7f-9e35-592077a852dd" />


## Caso de Uso 2: Cadastro

### Fluxo Detalhado
1. Usuário acessa tela de cadastro
2. Usuário preenche os dados
3. Sistema valida as informações
4. Sistema salva no banco de dados
5. Sistema exibe mensagem de sucesso

### Diagrama de Atividade
<img width="714" height="655" alt="image" src="https://github.com/user-attachments/assets/ee01d483-c165-4aa6-ad35-3f40b6fd9041" />

### Diagrama de Sequência
<img width="657" height="666" alt="image" src="https://github.com/user-attachments/assets/4c36464c-f9a5-41c6-a9cf-0b88a0de9eca" />

## Caso de Uso 3: Registro de Venda

### Fluxo Detalhado e Estoque
1. Usuário seleciona o produto e informa a quantidade
2. Sistema verifica disponibilidade no estoque
3. Sistema processa o pagamento/venda
4. Sistema subtrai a quantidade do banco de dados
5. Sistema registra a venda no histórico
6. Sistema exibe confirmação para o usuário

### Diagrama de Atividade
<img width="681" height="763" alt="image" src="https://github.com/user-attachments/assets/8c735815-f673-4373-82ff-7582245affd5" />

### Diagrama de Sequência
<img width="584" height="695" alt="image" src="https://github.com/user-attachments/assets/3c492f87-93ca-4a07-846e-1b34650b720b" />

## Caso de Uso 4: Cancelamento e Estorno (Novo)

### Fluxo Detalhado
1. Usuário acessa o histórico de vendas
2. Usuário seleciona uma venda ativa
3. Usuário solicita o cancelamento
4. Sistema valida se a venda pode ser cancelada
5. Sistema incrementa a quantidade do produto de volta ao estoque
6. Sistema atualiza o status da venda para "Cancelada"
7. Sistema confirma a operação ao usuário

### Diagrama de Atividade
<img width="681" height="763" alt="image" src="https://github.com/user-attachments/assets/8c735815-f673-4373-82ff-7582245affd5" />

### Diagrama de Sequência
<img width="584" height="695" alt="image" src="https://github.com/user-attachments/assets/3c492f87-93ca-4a07-846e-1b34650b720b" />

## Caso de Uso 5: Geração de Resumo Financeiro (Novo)

### Fluxo Detalhado
1. Usuário acessa a aba de Dashboard/Relatórios
2. Sistema busca todas as vendas com status "Concluída"
3. Sistema realiza o somatório de valores e quantidades
4. Sistema apresenta o total faturado e métricas na tela

### Diagrama de Atividade
<img width="681" height="763" alt="image" src="https://github.com/user-attachments/assets/8c735815-f673-4373-82ff-7582245affd5" />

### Diagrama de Sequência
<img width="584" height="695" alt="image" src="https://github.com/user-attachments/assets/3c492f87-93ca-4a07-846e-1b34650b720b" />
