import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projetointegrado/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ⚠️ Substitua pelas credenciais reais cadastradas no Firebase
const String emailTeste = "agrovaletambau@gmail.com";
const String senhaTeste = "Agro1690";

// Helper para aguardar operações assíncronas com segurança
Future<void> aguardar(WidgetTester tester, {int segundos = 3}) async {
  await tester.pump(Duration(seconds: segundos));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

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
        await aguardar(tester);

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
          "usuario@invalido.com",
        );
        await tester.enterText(
          find.widgetWithText(TextField, "Senha"),
          "senhaerrada",
        );

        // Executar o login
        await tester.tap(find.text("ENTRAR"));
        await aguardar(tester, segundos: 5);

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
        await aguardar(tester, segundos: 6);

        // Verificar se navegou para a HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      },
    );

    testWidgets(
      'TC25 — Logout com confirmação e retorno ao login',
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
        await aguardar(tester, segundos: 6);

        // Verificar se estou na HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Navegar para a aba Conta
        await tester.tap(find.text("Conta"));
        await aguardar(tester);

        // Verificar se estou na tela de perfil
        expect(find.text("Minha Conta"), findsOneWidget);

        // Rolar até o botão que pode estar fora da tela
        await tester.scrollUntilVisible(
          find.text("SAIR DA CONTA"),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await aguardar(tester);

        // Tocar em "Sair da Conta"
        await tester.tap(find.text("SAIR DA CONTA"), warnIfMissed: false);
        await aguardar(tester);

        // Verificar se o diálogo de confirmação apareceu
        expect(find.text("Sair"), findsOneWidget);
        expect(find.text("Deseja realmente sair da conta?"), findsOneWidget);

        // Confirmar o logout
        await tester.tap(find.text("SIM"));
        await aguardar(tester);

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
        await aguardar(tester, segundos: 6);

        // Verificar se estou na HomePage com produtos
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Aguardar produtos carregarem do Firestore
        await aguardar(tester, segundos: 3);

        // Tocar no primeiro produto da grade
        await tester.tap(find.byType(GestureDetector).first);
        await aguardar(tester);

        // Verificar se o bottom sheet de detalhes abriu
        expect(find.text("ADICIONAR AO CARRINHO"), findsOneWidget);

        // Adicionar ao carrinho
        await tester.tap(find.text("ADICIONAR AO CARRINHO"));
        await aguardar(tester);

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
        await aguardar(tester, segundos: 6);

        // Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await aguardar(tester, segundos: 3);

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
        await aguardar(tester, segundos: 6);

        // Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await aguardar(tester, segundos: 3);

        // Verificar se estou na tela do carrinho
        expect(find.text("Carrinho"), findsOneWidget);

        // Tocar em remover repetidamente até o item sumir (independente da quantidade)
        while (find.byIcon(Icons.remove).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.remove).first);
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Verificar se o carrinho ficou vazio
        expect(find.text("Vazio"), findsOneWidget);
      },
    );

    testWidgets(
      'TC17 e TC18 — Criação de pedido e geração de QR Code Pix',
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
        await aguardar(tester, segundos: 6);

        // Aguardar produtos carregarem
        await aguardar(tester, segundos: 3);

        // Adicionar produto ao carrinho antes de testar o Pix
        await tester.tap(find.byType(GestureDetector).first);
        await aguardar(tester);
        expect(find.text("ADICIONAR AO CARRINHO"), findsOneWidget);
        await tester.tap(find.text("ADICIONAR AO CARRINHO"));
        await aguardar(tester, segundos: 2);

        // Abrir o carrinho
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await aguardar(tester, segundos: 3);

        // Verificar se estou na tela do carrinho com itens
        expect(find.text("Carrinho"), findsOneWidget);
        expect(find.textContaining("Total: R\$"), findsOneWidget);

        // Tocar em Pix para iniciar o pagamento
        await tester.tap(find.text("Pix"));

        // Aguardar criação do pedido no Firestore + chamada à API do MP
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verificar se o QR Code Pix foi exibido
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
        await aguardar(tester, segundos: 6);

        // Verificar se estou na HomePage
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Tocar no botão flutuante do assistente IA
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await aguardar(tester);

        // Verificar se o assistente abriu corretamente
        expect(find.text("Assistente AgroVale"), findsOneWidget);
        expect(find.textContaining("Me conta o que você precisa"), findsOneWidget);

        // Fechar o chat
        await tester.tap(find.byIcon(Icons.close));
        await aguardar(tester);

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
        await aguardar(tester, segundos: 6);

        // Tocar no botão flutuante do assistente IA
        await tester.tap(find.byIcon(Icons.auto_awesome));
        await aguardar(tester);

        // Verificar se o chat abriu
        expect(find.text("Assistente AgroVale"), findsOneWidget);

        // Digitar uma necessidade
        await tester.enterText(
          find.widgetWithText(TextField, "Descreva sua necessidade..."),
          "preciso de algo para limpar o mato",
        );

        // Verificar se o texto foi inserido no campo
        expect(
          find.widgetWithText(TextField, "preciso de algo para limpar o mato"),
          findsOneWidget,
        );

        // Enviar a mensagem
        await tester.tap(find.byIcon(Icons.send_rounded));
        await aguardar(tester);

        // Verificar se a mensagem do usuário apareceu no chat
        expect(
          find.text("preciso de algo para limpar o mato"),
          findsOneWidget,
        );
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
        await aguardar(tester, segundos: 6);

        // Verificar se estou na HomePage com produtos
        expect(find.text("Pesquisar no AgroVale..."), findsOneWidget);

        // Aguardar produtos carregarem
        await aguardar(tester, segundos: 3);

        // Tocar no ícone de favorito do primeiro produto
        await tester.tap(find.byIcon(Icons.favorite_border).first);
        await aguardar(tester, segundos: 2);

        // Verificar se o ícone mudou para favoritado
        expect(find.byIcon(Icons.favorite), findsWidgets);

        // Tocar novamente para desfavoritar
        await tester.tap(find.byIcon(Icons.favorite).first);
        await aguardar(tester, segundos: 2);

        // Verificar se o ícone voltou para não favoritado
        expect(find.byIcon(Icons.favorite_border), findsWidgets);
      },
    );
  });
}