import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _fazerLogin() async {
    setState(() => _isLoading = true);
    final user = await AuthService().loginComEmailSenha(
        _emailController.text.trim(),
        _passwordController.text.trim()
    );
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao entrar. Verifique seus dados.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _loginComGoogle() async {
    setState(() => _isLoading = true);
    final user = await AuthService().loginComGoogle();
    setState(() => _isLoading = false);
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Widget auxiliar para os campos de texto estilo "Glass"
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com Degradê Radial (AgroVale Style)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF1B4D3E), Color(0xFF0A2417)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // LOGO (Aqui você pode colocar um Image.asset da sua logo)
                    Image.asset(
                      'assets/images/logo_agrovale.png', // <-- CERTIFIQUE-SE DE QUE O NOME DO ARQUIVO ESTÁ CORRETO AQUI
                      height: 120, // Ajuste a altura se necessário para ficar bom no layout
                      fit: BoxFit.contain, // Garante que a imagem não seja cortada
                    ),
                    const SizedBox(height: 20),
                    const Text("Criar Conta", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Cadastre-se para comprar com a gente.", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 40),

                    // Container Centralizado (Card de Login)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(controller: _emailController, hint: "E-mail", icon: Icons.person),
                          const SizedBox(height: 15),
                          _buildTextField(controller: _passwordController, hint: "Senha", icon: Icons.lock, obscure: true),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text("Esqueceu sua senha?", style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Botão ENTRAR com Degradê Verde
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6DA34D), Color(0xFF3B6B2E)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              onPressed: _isLoading ? null : _fazerLogin,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text("OU", style: TextStyle(color: Colors.white60)),
                          ),

                          // Botão Google
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
                              label: const Text("Entrar com Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              onPressed: _isLoading ? null : _loginComGoogle,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Botão Cliente Novo (Laranja/Dourado)
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFB87333), Color(0xFF8B4513)]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                              },
                              child: const Text("Cliente novo? Comece agora!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}