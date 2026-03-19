import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Descomente a linha abaixo se você usou o FlutterFire CLI (recomendado)
// import 'firebase_options.dart'; 

import 'pages/login_page.dart'; // Adicione esta linha junto com as outras
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/orders_page.dart';
import 'pages/account_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Otimização: Passar as opções de plataforma se gerado pelo FlutterFire
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, 
  );

  runApp(const AgroValeApp());
}

// 1. Raiz do App (StatelessWidget)
// Agora o MaterialApp não será reconstruído a cada troca de aba.
class AgroValeApp extends StatelessWidget {
  const AgroValeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AgroVale",
      
      // Otimização: Atualizado para o padrão moderno do Material Design 3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      home: const LoginPage(), // Agora o app começa aqui!
    );
  }
}

// 2. Tela de Navegação (StatefulWidget)
// O setState vai reconstruir apenas o Scaffold e a BottomNavigationBar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _paginaAtual = 0;

  final List<Widget> _telas = const [
    HomePage(),
    SearchPage(),
    OrdersPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey, // Ajuda a destacar no tema escuro
        
        // Otimização: Essencial quando se tem mais de 3 itens, 
        // senão o Flutter muda para o tipo "shifting" e esconde os textos
        type: BottomNavigationBarType.fixed, 
        
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Pesquisar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Conta",
          ),
        ],
      ),
    );
  }
}