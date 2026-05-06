# Casos de Uso do Sistema


## UC01 – Autenticação via Google Sign-In

**Ator:** Usuário

**Descrição:** Permite o acesso seguro utilizando a conta Google.

**Fluxo Principal:**
1. O usuário clica em "Entrar com Google".
2. O sistema realiza a validação via Firebase.
3. O acesso ao catálogo é liberado.

**Fluxo Alternativo:**
- Se o usuário cancelar a seleção da conta Google, o sistema retorna à tela de login.

**Relacionamento com MVP:** Segurança.

---

## UC02 – Consultar Localização por CEP

**Ator:** Usuário

**Descrição:** Preenchimento automático de endereço para entrega.

**Fluxo Principal:**
1. O usuário insere o CEP.
2. O sistema busca os dados (Rua, Bairro, Cidade).
3. O usuário confirma a localização.

**Fluxo Alternativo:**
- Se o CEP for inválido ou não for encontrado, o sistema solicita que o usuário verifique o número ou digite o endereço manualmente.

**Relacionamento com MVP:** Integração de API.

---

## UC03 – Gerir Lista de Favoritos

**Ator:** Usuário

**Descrição:** Permite salvar itens para consulta rápida.

**Fluxo Principal:**
1. O usuário seleciona um produto.
2. Clica no ícone de favoritar.
3. O sistema armazena o item na lista do usuário.

**Fluxo Alternativo:**
- Se o item já estiver favoritado, o clique no ícone remove o produto da lista de favoritos.

**Relacionamento com MVP:** Experiência do Usuário (UX).

---

## UC04 – Gestão e Edição de Perfil (RG e Dados)

**Ator:** Usuário

**Descrição:** Permite que o usuário realize o cadastro inicial e a edição de seus dados de identificação (RG) e localização a qualquer momento.

**Fluxo Principal:**
1. O usuário acessa o perfil.
2. O sistema exibe os dados atuais.
3. O usuário insere ou altera o número do RG e outros dados.
4. O usuário confirma a alteração.
5. O sistema valida e salva as novas informações na base de dados.

**Fluxo Alternativo:**
- Se o campo de RG for deixado em branco, o sistema exibe uma mensagem de erro informando que o dado é obrigatório para salvar.

**Relacionamento com MVP:** Gestão de Usuário e Segurança.

---

## UC05 – Realizar Pagamento via API Mercado Pago

**Ator:** Usuário

**Descrição:** Fluxo de conclusão de compra utilizando a integração com a API do Mercado Pago para processamento funcional de pagamentos.

**Fluxo Principal:**
1. O usuário inicia o checkout do produto selecionado.
2. O sistema envia os dados da transação para a API do Mercado Pago.
3. O usuário realiza o pagamento na interface da API (Pix, Cartão, etc.).
4. O sistema recebe a confirmação de pagamento concluído.
5. O pedido é confirmado e registrado no histórico.

**Fluxo Alternativo:**
- Se a transação for recusada pelo Mercado Pago, o sistema exibe o erro e permite que o usuário tente novamente com outro método.

**Relacionamento com MVP:** Sistema de Pagamento.

---

## UC06 – Navegação no Catálogo

**Ator:** Usuário

**Descrição:** Visualização dos itens disponíveis.

**Fluxo Principal:**
1. O usuário abre o app.
2. O sistema carrega os produtos disponíveis.
3. O usuário navega entre as categorias.

**Fluxo Alternativo:**
- Se houver falha no carregamento dos dados, o sistema exibe um botão de "Recarregar" para tentar buscar os produtos novamente.

**Relacionamento com MVP:** Interface Principal.
