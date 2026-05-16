# Casos de Uso do Sistema

Os casos de uso descrevem como o usuário interage com o sistema AgroVale.

---

## UC01 – Login com Google

**Ator:** Usuário

**Descrição:** Permite que o usuário acesse o aplicativo utilizando sua conta Google.

**Fluxo Principal:**
1. O usuário abre o aplicativo AgroVale
2. O sistema exibe a tela de login
3. O usuário toca em "Entrar com Google"
4. O sistema abre o seletor de contas Google
5. O usuário seleciona sua conta
6. O sistema autentica via Firebase Auth
7. O sistema redireciona para a tela principal

**Fluxo Alternativo:**
- Se o usuário cancelar a seleção de conta, o sistema retorna para a tela de login
- Se houver falha de rede, o sistema exibe mensagem de erro

**Relacionamento com MVP:** Autenticação de usuários

---

## UC02 – Login com E-mail e Senha

**Ator:** Usuário

**Descrição:** Permite que o usuário acesse o aplicativo com e-mail e senha cadastrados.

**Fluxo Principal:**
1. O usuário acessa a tela de login
2. O usuário informa e-mail e senha
3. O usuário toca em "Entrar"
4. O sistema valida as credenciais via Firebase Auth
5. O sistema redireciona para a tela principal

**Fluxo Alternativo:**
- Se as credenciais estiverem incorretas, o sistema exibe mensagem de erro
- Se o e-mail não estiver cadastrado, o sistema sugere realizar o cadastro

**Relacionamento com MVP:** Autenticação de usuários

---

## UC03 – Cadastro com E-mail e Senha

**Ator:** Usuário

**Descrição:** Permite que um novo usuário crie uma conta no sistema.

**Fluxo Principal:**
1. O usuário acessa a tela de cadastro
2. O usuário preenche e-mail e senha
3. O usuário toca em "Cadastrar"
4. O sistema cria a conta via Firebase Auth
5. O sistema redireciona para a tela principal

**Fluxo Alternativo:**
- Se o e-mail já estiver cadastrado, o sistema exibe mensagem de erro
- Se a senha não atender aos requisitos, o sistema exibe as regras de senha

**Relacionamento com MVP:** Autenticação de usuários

---

## UC04 – Atualizar Dados de Cadastro

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário preencha e atualize seus dados pessoais e de endereço.

**Fluxo Principal:**
1. O usuário acessa a aba "Conta"
2. O sistema exibe os dados atuais salvos no Firestore
3. O usuário toca em "Editar Dados de Cadastro"
4. O sistema abre o formulário com os campos: CPF, RG, Telefone, CEP, Rua, Número, Bairro, Cidade e UF
5. O usuário informa o CEP
6. O sistema consulta a API ViaCEP e preenche automaticamente Rua, Bairro, Cidade e UF
7. O usuário informa o número e os demais dados
8. O usuário toca em "Salvar Dados"
9. O sistema salva os dados no Firestore

**Fluxo Alternativo:**
- Se o CEP não for encontrado, os campos de endereço permanecem em branco para preenchimento manual
- Se o CPF for inválido, o sistema impede o salvamento

**Relacionamento com MVP:** Cadastro e perfil do usuário

---

## UC05 – Buscar Produtos

**Ator:** Usuário

**Descrição:** Permite que o usuário pesquise produtos no catálogo pelo nome ou categoria.

**Fluxo Principal:**
1. O usuário digita um termo na barra de pesquisa da tela principal
2. O sistema normaliza o texto removendo acentos
3. O sistema expande a busca com sinônimos relacionados
4. O sistema filtra os produtos por nome e categoria
5. O sistema exibe os produtos encontrados em grade

**Fluxo Alternativo:**
- Se nenhum produto for encontrado, a grade é exibida vazia

**Relacionamento com MVP:** Catálogo de produtos

---

## UC06 – Visualizar Detalhes do Produto

**Ator:** Usuário

**Descrição:** Permite que o usuário visualize as informações completas de um produto e o adicione ao carrinho.

**Fluxo Principal:**
1. O usuário toca em um produto na grade
2. O sistema exibe um painel com imagem, nome, preço e descrição
3. O usuário toca em "Adicionar ao Carrinho"
4. O sistema adiciona o produto ao carrinho no Firestore
5. O sistema exibe confirmação em snackbar

**Fluxo Alternativo:**
- Se o usuário não estiver autenticado, o botão de adicionar não executa ação

**Relacionamento com MVP:** Catálogo de produtos

---

## UC07 – Gerenciar Carrinho

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário visualize, ajuste quantidades e finalize a compra dos itens no carrinho.

**Fluxo Principal:**
1. O usuário acessa o carrinho pelo ícone na barra superior
2. O sistema lista os itens e exibe o valor total
3. O usuário ajusta as quantidades com os botões + e −
4. O sistema atualiza as quantidades no Firestore em tempo real
5. O usuário seleciona o método de pagamento

**Fluxo Alternativo:**
- Se a quantidade for reduzida a zero, o item é removido automaticamente do carrinho

**Relacionamento com MVP:** Carrinho de compras

---

## UC08 – Realizar Pagamento via Pix

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário realize o pagamento do pedido via Pix com QR Code gerado pelo Mercado Pago.

**Fluxo Principal:**
1. O usuário toca em "Pix" na tela do carrinho
2. O sistema cria o pedido no Firestore com status "Aguardando Pagamento"
3. O sistema chama a API do Mercado Pago com o ID do pedido como referência externa
4. O Mercado Pago retorna o QR Code Pix
5. O sistema exibe o QR Code com opção de copiar o código
6. O usuário realiza o pagamento pelo app bancário
7. O Mercado Pago notifica a Cloud Function via webhook
8. A Cloud Function atualiza o status do pedido para "Pago" no Firestore
9. A tela de pedidos atualiza automaticamente

**Fluxo Alternativo:**
- Se houver erro na API do Mercado Pago, o pedido criado é deletado e uma mensagem de erro é exibida
- Se o usuário não realizar o pagamento, o pedido permanece com status "Aguardando Pagamento"

**Relacionamento com MVP:** Pagamento e pedidos

---

## UC09 – Consultar Pedidos

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário visualize seus pedidos e regenere o Pix caso necessário.

**Fluxo Principal:**
1. O usuário acessa a aba "Pedidos"
2. O sistema exibe a lista de pedidos ordenados por data
3. O sistema exibe ID, data, status e badge colorido para cada pedido
4. O usuário expande um pedido para ver os itens e o total
5. Para pedidos "Aguardando Pagamento", o sistema exibe o botão "Gerar Novo Pix"
6. O usuário toca em "Gerar Novo Pix" e um novo QR Code é gerado

**Fluxo Alternativo:**
- Se não houver pedidos, o sistema exibe a mensagem "Você ainda não tem pedidos"

**Relacionamento com MVP:** Pagamento e pedidos

---

## UC10 – Consultar Assistente Virtual por IA

**Ator:** Usuário

**Descrição:** Permite que o usuário descreva uma necessidade e receba recomendações de produtos geradas por Inteligência Artificial.

**Fluxo Principal:**
1. O usuário toca no botão flutuante de IA na tela principal
2. O sistema abre o chat em painel deslizante
3. O usuário descreve sua necessidade ou dificuldade
4. O sistema busca o catálogo atualizado no Firestore
5. O sistema envia a mensagem e o catálogo para a API Google Gemini
6. O Gemini retorna a recomendação com os produtos mais adequados
7. O sistema exibe os produtos recomendados em cards com foto, preço e botão de carrinho
8. O usuário adiciona o produto ao carrinho diretamente pelo card

**Fluxo Alternativo:**
- Se houver erro na API Gemini, uma mensagem de erro amigável é exibida no chat
- Se nenhum produto for identificado na resposta, apenas o texto da resposta é exibido

**Relacionamento com MVP:** Assistente virtual com IA

---

## UC11 – Favoritar Produto

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário salve produtos favoritos para acesso rápido.

**Fluxo Principal:**
1. O usuário visualiza um produto na grade da tela principal
2. O usuário toca no ícone de coração no card do produto
3. O sistema salva o produto nos favoritos do usuário no Firestore
4. O ícone muda para coração preenchido
5. O usuário acessa a aba "Favoritos" para ver todos os produtos salvos

**Fluxo Alternativo:**
- Se o produto já estiver favoritado, o sistema o remove dos favoritos ao tocar novamente

**Relacionamento com MVP:** Catálogo de produtos

---

## UC12 – Logout

**Ator:** Usuário Autenticado

**Descrição:** Permite que o usuário encerre sua sessão no aplicativo.

**Fluxo Principal:**
1. O usuário acessa a aba "Conta"
2. O usuário toca em "Sair da Conta"
3. O sistema exibe um diálogo de confirmação
4. O usuário confirma a saída
5. O sistema encerra a sessão no Google e no Firebase Auth
6. O sistema redireciona para a tela de login

**Fluxo Alternativo:**
- Se o usuário cancelar, o sistema retorna para a tela de perfil

**Relacionamento com MVP:** Autenticação de usuários

<img width="1291" height="1415" alt="Casos de uso" src="https://github.com/user-attachments/assets/da326f29-6a0a-47e0-97aa-a31a93b57d13" />
