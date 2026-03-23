import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para formatadores
import '../services/firestore_service.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Minha Conta", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getDadosUsuario(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          var dados = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 15),
                Text(user.displayName ?? "Usuário", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user.email ?? "", style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),
                const Divider(color: Colors.green, thickness: 0.5),

                _buildInfoTile(Icons.phone, "Telefone", dados['telefone']),
                _buildInfoTile(Icons.badge, "CPF", dados['cpf']),
                _buildInfoTile(Icons.location_on, "Endereço",
                    (dados['rua'] != null) ? "${dados['rua']}, ${dados['numero']} - ${dados['bairro']}" : null),
                _buildInfoTile(Icons.location_city, "Cidade", dados['cidade']),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black),
                    onPressed: () => _abrirFormulario(context, user.uid, dados),
                    child: const Text("EDITAR DADOS DE CADASTRO"),
                  ),
                ),
              ],
            ),
          );
        },
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

  void _abrirFormulario(BuildContext context, String uid, Map<String, dynamic> d) {
    final telController = TextEditingController(text: d['telefone']);
    final ruaController = TextEditingController(text: d['rua']);
    final numController = TextEditingController(text: d['numero']);
    final bairroController = TextEditingController(text: d['bairro']);
    final cidadeController = TextEditingController(text: d['cidade']);
    final cpfController = TextEditingController(text: d['cpf']);

    // DEFINIÇÃO DAS MÁSCARAS
    final cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
    final telMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Atualizar Cadastro", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildField(cpfController, "CPF", Icons.badge, formatters: [cpfMask]),
              _buildField(telController, "Telefone", Icons.phone, formatters: [telMask]),

              Row(
                children: [
                  Expanded(flex: 3, child: _buildField(ruaController, "Rua", Icons.map)),
                  const SizedBox(width: 10),
                  Expanded(flex: 1, child: _buildField(numController, "Nº", Icons.home)),
                ],
              ),
              _buildField(bairroController, "Bairro", Icons.layers),
              _buildField(cidadeController, "Cidade", Icons.location_city),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // VALIDAÇÃO DE CPF
                    if (!CPFValidator.isValid(cpfController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("CPF Inválido!"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    await FirestoreService().salvarDadosUsuario(uid, {
                      "telefone": telController.text,
                      "rua": ruaController.text,
                      "numero": numController.text,
                      "bairro": bairroController.text,
                      "cidade": cidadeController.text,
                      "cpf": cpfController.text,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("SALVAR DADOS"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        inputFormatters: formatters,
        keyboardType: label == "CPF" || label == "Telefone" || label == "Nº" ? TextInputType.number : TextInputType.text,
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
}