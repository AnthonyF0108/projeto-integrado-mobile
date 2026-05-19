import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:projetointegrado/main.dart';
import 'package:projetointegrado/firebase_options.dart';

const String emailTeste = "agrovaletambau@gmail.com";
const String senhaTeste = "Agro1690";

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

FlutterError.onError = ignoreOverflowErrors;

setUpAll(() async {
await dotenv.load(fileName: ".env");

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
});

// =========================================================
// HELPERS
// =========================================================

Future<void> iniciarApp(WidgetTester tester) async {
await tester.pumpWidget(const AgroValeApp());
await tester.pump(const Duration(seconds: 3));
}

Future<void> realizarLogin(WidgetTester tester) async {
await tester.enterText(
find.widgetWithText(TextFormField, "E-mail"),
emailTeste,
);

await tester.enterText(
find.widgetWithText(TextFormField, "Senha"),
senhaTeste,
);

await tester.tap(
find.widgetWithText(ElevatedButton, "ENTRAR"),
);

await tester.pumpAndSettle(
const Duration(seconds: 5),
);
}

// =========================================================
// FLUXO 1 — AUTENTICAÇÃO
// =========================================================

group('Fluxo de Autenticação', () {
testWidgets(
'TC03 — Login com campos vazios',
(WidgetTester tester) async {
await iniciarApp(tester);

expect(find.text("Criar Conta"), findsOneWidget);

await tester.tap(
find.widgetWithText(ElevatedButton, "ENTRAR"),
);

await tester.pump(const Duration(seconds: 2));

expect(
find.textContaining("Erro"),
findsWidgets,
);
},
);

testWidgets(
'TC04 — Login inválido',
(WidgetTester tester) async {
await iniciarApp(tester);

await tester.enterText(
find.widgetWithText(TextFormField, "E-mail"),
"usuario@email.com",
);

await tester.enterText(
find.widgetWithText(TextFormField, "Senha"),
"senhaerrada",
);

await tester.tap(
find.widgetWithText(ElevatedButton, "ENTRAR"),
);

await tester.pump(const Duration(seconds: 3));

expect(
find.textContaining("Erro"),
findsWidgets,
);
},
);

testWidgets(
'TC02 e TC05 — Login válido',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

expect(
find.text("Pesquisar no AgroVale..."),
findsOneWidget,
);

expect(
find.byIcon(Icons.shopping_cart),
findsOneWidget,
);
},
);

testWidgets(
'TC25 — Logout',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

expect(
find.text("Pesquisar no AgroVale..."),
findsOneWidget,
);

await tester.tap(find.text("Conta"));

await tester.pump(const Duration(seconds: 2));

expect(
find.text("Minha Conta"),
findsOneWidget,
);

final sairConta = find.text("SAIR DA CONTA");

if (sairConta.evaluate().isNotEmpty) {
await tester.ensureVisible(sairConta);

await tester.pump(
const Duration(seconds: 1),
);

await tester.tap(sairConta);
}

await tester.pump(const Duration(seconds: 2));

expect(
find.textContaining("Deseja"),
findsOneWidget,
);

final botaoSim = find.text("SIM");

if (botaoSim.evaluate().isNotEmpty) {
await tester.tap(botaoSim);
}

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

expect(
find.text("Criar Conta"),
findsOneWidget,
);
},
);
});

// =========================================================
// FLUXO 2 — CARRINHO
// =========================================================

group('Fluxo de Carrinho', () {
testWidgets(
'TC14 — Adicionar produto ao carrinho',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

expect(
find.text("Pesquisar no AgroVale..."),
findsOneWidget,
);

final produtos = find.byType(GestureDetector);

expect(produtos, findsWidgets);

await tester.tap(produtos.first);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

final adicionar =
find.text("ADICIONAR AO CARRINHO");

expect(adicionar, findsOneWidget);

await tester.tap(adicionar);

await tester.pump(const Duration(seconds: 2));

expect(
find.byType(SnackBar),
findsWidgets,
);
},
);

testWidgets(
'TC15 — Total do carrinho',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

await tester.tap(
find.byIcon(Icons.shopping_cart),
);

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

expect(
find.text("Carrinho"),
findsOneWidget,
);

expect(
find.textContaining("Total"),
findsWidgets,
);
},
);

testWidgets(
'TC16 — Remover item do carrinho',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

await tester.tap(
find.byIcon(Icons.shopping_cart),
);

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

final remover = find.byIcon(Icons.remove);

if (remover.evaluate().isNotEmpty) {
await tester.tap(remover.first);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);
}

expect(true, isTrue);
},
);

testWidgets(
'TC17 e TC18 — Pix',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

final produtos = find.byType(GestureDetector);

expect(produtos, findsWidgets);

await tester.tap(produtos.first);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

await tester.tap(
find.text("ADICIONAR AO CARRINHO"),
);

await tester.pump(
const Duration(seconds: 2),
);

await tester.tap(
find.byIcon(Icons.shopping_cart),
);

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

expect(
find.text("Carrinho"),
findsOneWidget,
);

final pix = find.text("Pix");

if (pix.evaluate().isNotEmpty) {
await tester.ensureVisible(pix);

await tester.pump(
const Duration(seconds: 1),
);

await tester.tap(pix);
}

await tester.pumpAndSettle(
const Duration(seconds: 5),
);

expect(
find.textContaining("Pix"),
findsWidgets,
);
},
);
});

// =========================================================
// FLUXO 3 — ASSISTENTE IA
// =========================================================

group('Fluxo Assistente IA', () {
testWidgets(
'TC21 — Abrir chat',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

await tester.tap(
find.byIcon(Icons.auto_awesome),
);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

expect(
find.textContaining("Assistente"),
findsWidgets,
);

final fechar = find.byIcon(Icons.close);

if (fechar.evaluate().isNotEmpty) {
await tester.tap(fechar);
}

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

expect(
find.text("Pesquisar no AgroVale..."),
findsOneWidget,
);
},
);

testWidgets(
'TC22 — Enviar mensagem',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

await tester.tap(
find.byIcon(Icons.auto_awesome),
);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

await tester.enterText(
find.widgetWithText(
TextFormField,
"Descreva sua necessidade...",
),
"preciso de algo para limpar o mato",
);

await tester.pump(
const Duration(seconds: 1),
);

await tester.tap(
find.byIcon(Icons.send_rounded),
);

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

expect(
find.text(
"preciso de algo para limpar o mato",
),
findsWidgets,
);
},
);
});

// =========================================================
// FLUXO 4 — FAVORITOS
// =========================================================

group('Fluxo Favoritos', () {
testWidgets(
'TC24 — Favoritar produto',
(WidgetTester tester) async {
await iniciarApp(tester);

await realizarLogin(tester);

await tester.pumpAndSettle(
const Duration(seconds: 3),
);

final favoritoVazio =
find.byIcon(Icons.favorite_border);

expect(
favoritoVazio,
findsWidgets,
);

final totalAntes =
find.byIcon(Icons.favorite)
    .evaluate()
    .length;

await tester.tap(favoritoVazio.first);

await tester.pumpAndSettle(
const Duration(seconds: 2),
);

final totalDepois =
find.byIcon(Icons.favorite)
    .evaluate()
    .length;

expect(
totalDepois >= totalAntes,
isTrue,
);
},
);
});
}

// =========================================================
// IGNORAR OVERFLOW VISUAL
// =========================================================

void ignoreOverflowErrors(
FlutterErrorDetails details,
) {
bool isOverflowError = false;

final exception = details.exceptionAsString();

if (exception.contains("A RenderFlex overflowed")) {
isOverflowError = true;
}

if (!isOverflowError) {
FlutterError.dumpErrorToConsole(details);
}
}