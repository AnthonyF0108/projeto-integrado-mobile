import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projetointegrado/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String emailTeste = "agrovaletambau@gmail.com";
const String senhaTeste = "Agro1690";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp();
  });

  // ─────────────────────────────────────────────────────────────
  // FLUXO 1 — AUTENTICAÇÃO
  // ─────────────────────────────────────────────────────────────
  group('Fluxo de Autenticação - Teste de Integração', () {

    testWidgets(
      'TC03 — Login com campos vazios exibe SnackBar de erro',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Verificar se estou na tela de login
        expect(find.text("Criar Conta"), findsOneWidget);
        expect(find.text("ENTRAR"), findsOneWidget);

        // Deixar os campos vazios e tentar entrar
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle();

        // Verificar se a mensagem de erro foi exibida
        expect(find.text("Erro ao entrar. Verifique seus dados."), findsOneWidget);
      },
    );

    testWidgets(
      'TC04 — Login inválido exibe SnackBar de erro',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Verificar se estou na tela de login
        expect(find.text("Criar Conta"), findsOneWidget);

        // Preencher com credenciais inválidas
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          "usuario@email.com",
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          "senhaerrada",
        );

        // Executar o login
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle();

        // Verificar se a mensagem de erro foi exibida
        expect(find.text("Erro ao entrar. Verifique seus dados."), findsOneWidget);
      },
    );

    testWidgets(
      'TC02 e TC05 — Login válido e navegação para HomePage',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Verificar se estou na tela de login
        expect(find.text("Criar Conta"), findsOneWidget);
        expect(find.text("ENTRAR"), findsOneWidget);

        // Preencher os campos de login com credenciais válidas
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );

        // Executar o login
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se navegou para a HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      },
    );

// ─────────────────────────────────────────────────────────────
    // CORREÇÃO TC25: Adicionado ensureVisible para rolar a tela
    // ─────────────────────────────────────────────────────────────
    testWidgets(
      'TC25 — Logout com confirmação e retorno ao login',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login primeiro
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se estou na HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Navegar para a aba Conta
        await tester.tap(find.text("Conta"));
        await tester.pumpAndSettle();

        // Verificar se estou na tela de perfil
        expect(find.text("Minha Conta"), findsOneWidget);

        // --- CORREÇÃO AQUI ---
        // Garante que o Flutter role a tela para baixo até encontrar o botão antes de clicar
        final botaoSairConta = find.text("SAIR DA CONTA");
        await tester.ensureVisible(botaoSairConta);
        await tester.pumpAndSettle();

        // Tocar em "Sair da Conta"
        await tester.tap(botaoSairConta);
        await tester.pumpAndSettle();

        // Verificar se o diálogo de confirmação apareceu
        // (Nota: Se o texto do botão do diálogo for "SIM" ou "SAIR", certifique-se de que corresponda)
        expect(find.text("Deseja realmente sair da conta?"), findsOneWidget);

        // Confirmar o logout
        await tester.tap(find.text("SIM"));
        await tester.pumpAndSettle();

        // Verificar se voltou para a tela de login
        expect(find.text("Criar Conta"), findsOneWidget);
        expect(find.text("ENTRAR"), findsOneWidget);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────
  // FLUXO 2 — CARRINHO E PAGAMENTO PIX
  // ─────────────────────────────────────────────────────────────
  group('Fluxo de Carrinho e Pagamento - Teste de Integração', () {

    testWidgets(
      'TC14 — Adicionar produto ao carrinho',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se estou na HomePage com produtos
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Tocar no primeiro produto da grade
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Verificar se o bottom sheet de detalhes abriu
        expect(find.text("ADICIONAR AO CARRINHO"), findsOneWidget);

        // Adicionar ao carrinho
        await tester.tap(find.text("ADICIONAR AO CARRINHO"));
        await tester.pumpAndSettle();

        // Verificar se o snackbar de confirmação foi exibido
        expect(find.textContaining("adicionado!"), findsOneWidget);
      },
    );

    testWidgets(
      'TC15 — Valor total do carrinho é exibido corretamente',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        // Verificar se estou na tela do carrinho
        expect(find.text("Carrinho"), findsOneWidget);

        // Verificar se o total está sendo exibido
        expect(find.textContaining("Total: R\$"), findsOneWidget);
      },
    );

    testWidgets(
      'TC16 — Remoção de item ao reduzir quantidade a zero',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        // Verificar se estou na tela do carrinho
        expect(find.text("Carrinho"), findsOneWidget);

        // Verificar se há itens no carrinho e tocar em remover
        if (find.byIcon(Icons.remove).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.remove).first);
          await tester.pumpAndSettle();
        }

        // Verificar se o item foi removido ou o carrinho ficou vazio
        expect(
          find.text("Vazio").evaluate().isNotEmpty ||
              find.byIcon(Icons.remove).evaluate().isEmpty,
          isTrue,
        );
      },
    );

    testWidgets(
      'TC17 e TC18 — Criação de pedido e geração de QR Code Pix',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // 1. Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 2. ADICIONAR PRODUTO AO CARRINHO
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text("ADICIONAR AO CARRINHO"));
        await tester.pumpAndSettle();

        // --- CORREÇÃO AQUI ---
        // Limpa qualquer SnackBar ativo na tela para não bloquear o botão de baixo
        ScaffoldMessenger.of(tester.element(find.byType(AgroValeApp))).clearSnackBars();
        await tester.pumpAndSettle(); // Espera o SnackBar sumir da árvore de renderização

        // 3. Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verificar se mudou para a tela do carrinho
        expect(find.text("Carrinho"), findsOneWidget);

        // 4. Fluxo do Pix
        final botaoPix = find.text("Pix");

        if (botaoPix.evaluate().isNotEmpty) {
          await tester.ensureVisible(botaoPix);
          await tester.pumpAndSettle();
          await tester.tap(botaoPix);
        } else {
          await tester.drag(find.byType(ListView).first, const Offset(0, -300));
          await tester.pumpAndSettle();
          await tester.tap(find.text("Pix"));
        }

        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se o QR Code Pix foi exibido com sucesso
        expect(find.text("QR Code Pix"), findsOneWidget);
        expect(find.text("Copiar Código Pix"), findsOneWidget);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────
  // FLUXO 3 — ASSISTENTE VIRTUAL COM IA
  // ─────────────────────────────────────────────────────────────
  group('Fluxo do Assistente Virtual - Teste de Integração', () {

    testWidgets(
      'TC21 — Chat abre com mensagem de boas-vindas',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se estou na HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Tocar no botão flutuante do assistente IA
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        // Verificar se o assistente abriu corretamente
        expect(find.text("Assistente AgroVale"), findsOneWidget);
        expect(find.textContaining("Me conta o que você precisa"), findsOneWidget);

        // Fechar o chat
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Verificar se voltou para a HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);
      },
    );

    testWidgets(
      'TC22 — Usuário envia mensagem para o assistente IA',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Tocar no botão flutuante do assistente IA
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await tester.pumpAndSettle();

        // Verificar se o chat abriu
        expect(find.text("Assistente AgroVale"), findsOneWidget);

        // Digitar uma necessidade
        await tester.enterText(
          find.widgetWithText(TextField, "Descreva sua necessidade..."),
          "preciso de algo para limpar o mato",
        );
        await tester.pumpAndSettle();

        // Verificar se o texto foi inserido no campo
        expect(
          find.widgetWithText(TextField, "preciso de algo para limpar o mato"),
          findsOneWidget,
        );

        // Enviar a mensagem
        await tester.tap(find.byIcon(Icons.send_rounded));
        // Força a atualização do frame local antes de esperar animações longas
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Define o finder para buscar o texto impresso no corpo do chat (e não mais dentro do input)
        final mensagemNaTela = find.text("preciso de algo para limpar o mato");

        // Garante que pelo menos um Widget com esse texto existe na tela
        expect(mensagemNaTela, findsAtLeastNWidgets(1));

        // Se o chat rolou e a mensagem sumiu para cima/baixo, garante a visibilidade de forma segura
        if (mensagemNaTela.evaluate().isNotEmpty) {
          await tester.ensureVisible(mensagemNaTela.first);
          await tester.pumpAndSettle();
        }
      },
    );
  });

  // ─────────────────────────────────────────────────────────────
  // FLUXO 4 — FAVORITOS
  // ─────────────────────────────────────────────────────────────
  group('Fluxo de Favoritos - Teste de Integração', () {

    testWidgets(
      'TC24 — Toggle de favorito no produto',
          (WidgetTester tester) async {
        // ARRANGE
        await tester.pumpWidget(const AgroValeApp());
        await tester.pumpAndSettle();

        // Fazer login
        await tester.enterText(
          find.widgetWithText(TextField, "E-mail"),
          emailTeste,
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          senhaTeste,
        );
        await tester.tap(find.text("ENTRAR"));
        // Tempo estendido para garantir que a requisição dos produtos terminou e os ícones renderizaram
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verificar se estou na HomePage com produtos
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // --- CORREÇÃO AQUI ---
        // Garante que a árvore atualizou pós-carregamento assíncrono dos produtos
        await tester.pumpAndSettle();

        // Encontra o ícone de borda de favorito de forma segura
        final coracaoVazio = find.byIcon(Icons.favorite_border);
        expect(coracaoVazio, findsWidgets); // Garante que achou pelo menos um antes de clicar

        // Tocar no ícone de favorito do primeiro produto
        await tester.tap(coracaoVazio.first);
        await tester.pumpAndSettle();

        // Verificar se o ícone mudou para favoritado
        expect(find.byIcon(Icons.favorite), findsWidgets);

        // Tocar novamente para desfavoritar
        await tester.tap(find.byIcon(Icons.favorite).first);
        await tester.pumpAndSettle();

        // Verificar se o ícone voltou para não favoritado
        expect(find.byIcon(Icons.favorite_border), findsWidgets);
      },
    );
  });
}