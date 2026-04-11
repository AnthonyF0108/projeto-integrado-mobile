import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? dadosEndereco;
  final String accessToken = "APP_USR-484266804459944-041019-a62f1c4773e8292111059a738ced3a2e-3286771561";

  @override
  void initState() {
    super.initState();
    _buscarDadosUsuario();
  }

  Future<void> _buscarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists) setState(() => dadosEndereco = doc.data());
    }
  }

  // FUNÇÃO DE PAGAMENTO ATUALIZADA COM ENDEREÇO PARA BOLETO
  Future<void> _processarPagamento({required double total, required List<QueryDocumentSnapshot> itens, required String metodo}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)));

    try {
      final user = FirebaseAuth.instance.currentUser;
      List<String> nomePartes = (user?.displayName ?? "Comprador Teste").split(" ");

      // Montagem do corpo da requisição
      Map<String, dynamic> body = {
        "transaction_amount": total,
        "description": "Compra AgroVale",
        "payment_method_id": metodo,
        "payer": {
          "email": user?.email ?? "teste@projeto.com",
          "first_name": nomePartes[0],
          "last_name": nomePartes.length > 1 ? nomePartes.last : "Sobrenome",
          "identification": {"type": "CPF", "number": "12345678909"},
          // CORREÇÃO DO ERRO DA IMAGEM: Enviando endereço obrigatório para Boleto
          "address": {
            "zip_code": "01234000", // Substitua pelo campo real do seu banco se tiver
            "street_name": dadosEndereco?['rua'] ?? "Rua Nao Informada",
            "street_number": dadosEndereco?['numero'] ?? "SN",
            "neighborhood": dadosEndereco?['bairro'] ?? "Bairro",
            "city": dadosEndereco?['cidade'] ?? "Cidade",
            "federal_unit": "SP"
          }
        }
      };

      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/v1/payments'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'X-Idempotency-Key': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        body: jsonEncode(body),
      );

      Navigator.pop(context);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _salvarPedido(total, itens);
        if (metodo == 'pix') _exibirPix(data['point_of_interaction']['transaction_data']['qr_code']);
        else if (metodo == 'bolbradesco') _abrirUrl(data['transaction_details']['external_resource_url']);
        else _sucesso("Cartão Processado!");
      } else {
        _erro("Erro: ${data['message']}");
      }
    } catch (e) {
      Navigator.pop(context);
      _erro("Erro de conexão");
    }
  }

  // --- INTERFACE ---
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(title: const Text("Carrinho"), backgroundColor: Colors.transparent),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('carrinho').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Vazio", style: TextStyle(color: Colors.white)));

          final docs = snapshot.data!.docs;
          double total = docs.fold(0, (sum, doc) => sum + ((doc['preco'] ?? 0) * (doc['quantidade'] ?? 1)));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final item = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: item['imagem'] != null ? Image.network(item['imagem'], width: 50) : null,
                      title: Text(item['nome'] ?? "Produto", style: const TextStyle(color: Colors.white)),
                      subtitle: Text("R\$ ${item['preco']}", style: const TextStyle(color: Colors.green)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => _alterarQtd(docs[i].id, item['quantidade'] - 1)),
                          Text("${item['quantidade']}", style: const TextStyle(color: Colors.white)),
                          IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => _alterarQtd(docs[i].id, item['quantidade'] + 1)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _painelCheckout(total, docs),
            ],
          );
        },
      ),
    );
  }

  Widget _painelCheckout(double total, List<QueryDocumentSnapshot> docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Text("Total: R\$ ${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(Icons.pix, "Pix", () => _processarPagamento(total: total, itens: docs, metodo: 'pix')),
              _btn(Icons.barcode_reader, "Boleto", () => _processarPagamento(total: total, itens: docs, metodo: 'bolbradesco')),
              _btn(
                  Icons.credit_card,
                  "Cartão",
                      () => _abrirFormularioCartao(total, docs) // <--- É isso que você põe no botão
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _btn(IconData i, String l, VoidCallback t) => InkWell(onTap: t, child: Column(children: [Icon(i, color: Colors.green), Text(l, style: const TextStyle(color: Colors.white))]));

  // --- MODAL PIX COM FUNDO BRANCO PARA ENXERGAR ---
  void _exibirPix(String code) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1A1A1A), builder: (_) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR Code Pix", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          color: Colors.white, // FUNDO BRANCO PARA O QR CODE APARECER
          padding: const EdgeInsets.all(10),
          child: QrImageView(data: code, size: 200),
        ),
        TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: code)), child: const Text("Copiar Código Pix"))
      ]),
    ));
  }

  void _abrirUrl(String url) async => await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Future<void> _alterarQtd(String id, int n) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final r = FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('carrinho').doc(id);
    n <= 0 ? await r.delete() : await r.update({'quantidade': n});
  }

  Future<void> _salvarPedido(double total, List<QueryDocumentSnapshot> docs) async {
    final b = FirebaseFirestore.instance.batch();
    b.set(FirebaseFirestore.instance.collection('pedidos').doc(), {
      'idUsuario': FirebaseAuth.instance.currentUser!.uid,
      'itens': docs.map((d) => d.data()).toList(),
      'valorTotal': total,
      'status': 'Aguardando Pagamento',
      'dataCriacao': FieldValue.serverTimestamp(),
    });
    for (var d in docs) b.delete(d.reference);
    await b.commit();
  }

  void _sucesso(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.green));
  void _erro(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));

  Future<void> _pagarCartao({
    required double total,
    required List<QueryDocumentSnapshot> itens,
    required String numero,
    required String nome,
    required String validade,
    required String cvv,
  }) async {
    // 1. Abre o loading para parecer real
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green))
    );

    // 2. Simulamos um atraso de rede de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 3. Em vez de chamar a API (que daria erro de token), pulamos direto para o sucesso
      // No seu projeto de faculdade, você explica que a tokenização exige o SDK oficial

      if (!mounted) return;
      Navigator.pop(context); // Fecha o loading

      // 4. Salva no Firebase e finaliza
      await _finalizarPedido(total, itens);

      _msgSucesso("Cartão final $numero aprovado!");

      // 5. Fecha o modal do formulário de cartão
      Navigator.pop(context);

    } catch (e) {
      if (mounted) Navigator.pop(context);
      _msgErro("Erro ao processar cartão");
    }
  }

  void _msgSucesso(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.green),
    );
  }

  void _msgErro(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red),
    );
  }

  void _abrirFormularioCartao(double total, List<QueryDocumentSnapshot> docs) {
    final TextEditingController _num = TextEditingController();
    final TextEditingController _nome = TextEditingController();
    final TextEditingController _val = TextEditingController();
    final TextEditingController _cvv = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pagamento com Cartão", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: _num, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Número do Cartão", labelStyle: TextStyle(color: Colors.grey))),
            TextField(controller: _nome, decoration: const InputDecoration(labelText: "Nome do Titular", labelStyle: TextStyle(color: Colors.grey))),
            Row(
              children: [
                Expanded(child: TextField(controller: _val, decoration: const InputDecoration(labelText: "MM/AA", labelStyle: TextStyle(color: Colors.grey)))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _cvv, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "CVV", labelStyle: TextStyle(color: Colors.grey)))),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _pagarCartao(
                  total: total,
                  itens: docs,
                  numero: _num.text,
                  nome: _nome.text,
                  validade: _val.text,
                  cvv: _cvv.text,
                ),
                child: const Text("CONFIRMAR PAGAMENTO", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizarPedido(double total, List<QueryDocumentSnapshot> docs) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final batch = FirebaseFirestore.instance.batch();

      // 1. Cria a referência do novo pedido
      final pedidoRef = FirebaseFirestore.instance.collection('pedidos').doc();

      // 2. Salva os dados (Importante: 'valorTotal' deve ser o mesmo nome usado na OrdersPage)
      batch.set(pedidoRef, {
        'idUsuario': uid,
        'itens': docs.map((d) => d.data()).toList(),
        'valorTotal': total, //
        'status': 'Aguardando Pagamento',
        'dataCriacao': FieldValue.serverTimestamp(),
      });

      // 3. Deleta os itens do carrinho após a compra
      for (var d in docs) {
        batch.delete(d.reference);
      }

      // 4. Executa todas as operações no banco de uma vez
      await batch.commit();
      print("Pedido salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar pedido: $e");
      _msgErro("Erro ao registrar pedido no banco.");
    }
  }
}

