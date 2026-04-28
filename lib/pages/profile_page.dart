import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'login_page.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http; // Import para a API
import 'dart:convert';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Minha Conta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _confirmarSair(context),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Usuário não encontrado", style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getDadosUsuario(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          var dados = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  // Verifica se o objeto 'user' do Firebase Auth possui uma URL de foto
                  backgroundImage: (user != null && user.photoURL != null)
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: (user == null || user.photoURL == null)
                      ? const Icon(Icons.person, size: 50, color: Colors.green)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(user.displayName ?? "Usuário", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Divider(color: Colors.green, thickness: 0.5),

                _buildInfoTile(Icons.phone, "Telefone", dados['telefone']),
                _buildInfoTile(Icons.badge, "CPF", dados['cpf']),
                _buildInfoTile(Icons.fingerprint, "RG", dados['rg']), // Novo campo visual
                _buildInfoTile(Icons.map, "CEP", dados['cep']),
                _buildInfoTile(Icons.location_on, "Endereço",
                    (dados['rua'] != null) ? "${dados['rua']}, ${dados['numero']} - ${dados['bairro']}" : null),
                _buildInfoTile(Icons.location_city, "Cidade/UF",
                    (dados['cidade'] != null) ? "${dados['cidade']} - ${dados['estado']}" : null),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black),
                    onPressed: () => _abrirFormulario(context, user.uid, dados),
                    icon: const Icon(Icons.edit),
                    label: const Text("EDITAR DADOS DE CADASTRO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 15),
                _buildBotaoSair(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGICA DE BUSCA DE CEP ---
  Future<Map<String, dynamic>?> _buscarCEP(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return null;

    final url = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Erro ao buscar CEP: $e");
    }
    return null;
  }

  void _abrirFormulario(BuildContext context, String uid, Map<String, dynamic> d) {
    final telController = TextEditingController(text: d['telefone']);
    final ruaController = TextEditingController(text: d['rua']);
    final numController = TextEditingController(text: d['numero']);
    final bairroController = TextEditingController(text: d['bairro']);
    final cidadeController = TextEditingController(text: d['cidade']);
    final estadoController = TextEditingController(text: d['estado']);
    final cpfController = TextEditingController(text: d['cpf']);
    final rgController = TextEditingController(text: d['rg']); // Novo controller
    final cepController = TextEditingController(text: d['cep']);

    final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
    final cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
    final telMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder( // Necessário para atualizar campos via API dentro do modal
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Atualizar Cadastro", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildField(cpfController, "CPF", Icons.badge, formatters: [cpfMask]),
                _buildField(rgController, "RG", Icons.fingerprint), // Campo RG
                _buildField(telController, "Telefone", Icons.phone, formatters: [telMask]),

                // Campo CEP com busca automática
                TextField(
                  controller: cepController,
                  inputFormatters: [cepMask],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) async {
                    if (value.length == 9) { // CEP completo com a máscara
                      final info = await _buscarCEP(value);
                      if (info != null && info['erro'] == null) {
                        setModalState(() {
                          ruaController.text = info['logradouro'] ?? "";
                          bairroController.text = info['bairro'] ?? "";
                          cidadeController.text = info['localidade'] ?? "";
                          estadoController.text = info['uf'] ?? "";
                        });
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "CEP",
                    prefixIcon: Icon(Icons.map, color: Colors.green),
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(flex: 3, child: _buildField(ruaController, "Rua", Icons.home)),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _buildField(numController, "Nº", Icons.numbers)),
                  ],
                ),
                _buildField(bairroController, "Bairro", Icons.layers),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildField(cidadeController, "Cidade", Icons.location_city)),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _buildField(estadoController, "UF", Icons.flag)),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black),
                    onPressed: () async {
                      await FirestoreService().salvarDadosUsuario(uid, {
                        "telefone": telController.text,
                        "rua": ruaController.text,
                        "numero": numController.text,
                        "bairro": bairroController.text,
                        "cidade": cidadeController.text,
                        "estado": estadoController.text,
                        "cep": cepController.text,
                        "cpf": cpfController.text,
                        "rg": rgController.text, // Salva o RG
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("SALVAR DADOS", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- AUXILIARES ---
  Widget _buildField(TextEditingController controller, String label, IconData icon, {List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        inputFormatters: formatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value ?? "Não informado", style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  void _confirmarSair(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Sair", style: TextStyle(color: Colors.white)),
        content: const Text("Deseja realmente sair da conta?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NÃO")),
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
          }, child: const Text("SIM", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildBotaoSair(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), foregroundColor: Colors.redAccent),
        onPressed: () => _confirmarSair(context),
        icon: const Icon(Icons.exit_to_app),
        label: const Text("SAIR DA CONTA"),
      ),
    );
  }
}