import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/favorites_page.dart'; // Importação da sua nova página
import 'pages/orders_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AgroValeApp());
}

class AgroValeApp extends StatelessWidget {
  const AgroValeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AgroVale",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _paginaAtual = 0;

  // Lista de telas atualizada com FavoritesPage
  final List<Widget> _telas = const [
    HomePage(),
    FavoritesPage(), // Substituiu a SearchPage
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usar IndexedStack mantém o estado das páginas (ex: não reseta a busca ao voltar)
      body: IndexedStack(
        index: _paginaAtual,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1A1A1A), // Combina com o seu tema dark
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          // --- MUDANÇA AQUI: PESQUISAR -> FAVORITOS ---
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: "Favoritos",
          ),
          // --------------------------------------------
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Conta",
          ),
        ],
      ),
    );
  }
}