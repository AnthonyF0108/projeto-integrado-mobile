# Casos de Uso do Sistema


## UC01 – Autenticação via Google Sign-In

**Ator:** Usuário

**Descrição:** Permite o acesso seguro utilizando a conta Google.

**Fluxo Principal:**
1. O usuário clica em "Entrar com Google".
2. O sistema realiza a validação via Firebase.
3. O acesso ao catálogo é liberado.

**Relacionamento com MVP:** Segurança.

---

## UC02 – Consultar Localização por CEP

**Ator:** Usuário

**Descrição:** Preenchimento automático de endereço para entrega.

**Fluxo Principal:**
1. O usuário insere o CEP.
2. O sistema busca os dados (Rua, Bairro, Cidade).
3. O usuário confirma a localização.

**Relacionamento com MVP:** Integração de API.

---

## UC03 – Gerir Lista de Favoritos

**Ator:** Usuário

**Descrição:** Permite salvar itens para consulta rápida.

**Fluxo Principal:**
1. O usuário seleciona um produto.
2. Clica no ícone de favoritar.
3. O sistema armazena o item na lista do usuário.

**Relacionamento com MVP:** Experiência do Usuário (UX).

---

## UC04 – Atualizar Identificação (RG)

**Ator:** Usuário

**Descrição:** Registro do documento para validação de compra.

**Fluxo Principal:**
1. O usuário acessa o perfil.
2. Insere o número do RG.
3. O sistema salva a informação.

**Relacionamento com MVP:** Segurança e Cadastro.

---

## UC05 – Realizar Pagamento Funcional

**Ator:** Usuário

**Descrição:** Fluxo de conclusão de compra.

**Fluxo Principal:**
1. O usuário inicia o checkout.
2. O sistema processa o pagamento.
3. O pedido é confirmado.

**Relacionamento com MVP:** Sistema de Pagamento.

---

## UC06 – Navegação no Catálogo

**Ator:** Usuário

**Descrição:** Visualização dos itens disponíveis.

**Fluxo Principal:**
1. O usuário abre o app.
2. O sistema carrega os produtos disponíveis.
3. O usuário navega entre as categorias.

**Relacionamento com MVP:** Interface Principal.
