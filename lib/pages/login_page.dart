import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Ajuste o caminho se a sua pasta for diferente
import '../main.dart'; // Para podermos navegar para a MainNavigation depois do login
import 'register_page.dart'; // Para navegar para a tela de registro

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para capturar o que o usuário digita
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variável para mostrar a bolinha de carregando
  bool _isLoading = false;

  // Função que chama o nosso AuthService
  void _fazerLogin() async {
    setState(() {
      _isLoading = true; // Liga o carregamento
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Chama a função que criamos lá no auth_service.dart
    final user = await AuthService().loginComEmailSenha(email, password);

    setState(() {
      _isLoading = false; // Desliga o carregamento
    });

    if (user != null) {
      // Deu certo! Vai para a tela principal e não deixa o usuário voltar pra tela de login pelo botão de voltar do celular
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      // Deu erro! Mostra um aviso na parte de baixo da tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao entrar. Verifique seu e-mail e senha.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Função para o Login com Google
  void _loginComGoogle() async {
    setState(() => _isLoading = true);

    // Aqui você chama a função que deve estar no seu AuthService
    final user = await AuthService().loginComGoogle();

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com Google cancelado ou falhou.')),
        );
      }
    }
  }

  @override
  void dispose() {
    // É boa prática limpar os controladores quando a tela é fechada
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Um ícone para dar um charme (depois você pode trocar pela sua logo)
              const Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 32),

              const Text(
                "Bem-vindo ao AgroVale!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Campo de E-mail
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextField(
                controller: _passwordController,
                obscureText: true, // Esconde a senha com bolinhas
                decoration: const InputDecoration(
                  labelText: "Senha",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Botão de Login
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _fazerLogin,
                  // Se estiver carregando, mostra a bolinha, senão mostra o texto
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ENTRAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green), // Borda verde
                    foregroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.account_circle), // Ou uma imagem do logo do google
                  label: const Text("CONTINUAR COM GOOGLE"),
                  onPressed: _isLoading ? null : _loginComGoogle,
                ),
              ),

              TextButton(
                onPressed: () {
                  // Adicione esta navegação aqui:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Ainda não tem conta? Cadastre-se",
                  style: TextStyle(color: Colors.green),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}