import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? dadosEndereco;
  double valorFrete = 15.00;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarDadosUsuario();
  }

  // --- BUSCA ENDEREÇO DO FIREBASE (Sua Coleção 'usuarios') ---
  Future<void> _buscarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          dadosEndereco = doc.data();
          carregando = false;
        });
      }
    }
  }

  // ==========================================================
  // ESPAÇO PARA MERCADO PAGO (PRO)
  // ==========================================================
  Future<void> _gerarPagamentoMercadoPago(double total, List<QueryDocumentSnapshot> itens) async {
    // 1. Mostrar Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)));

    try {
      // COLOQUE SEU ACCESS TOKEN PJ AQUI
      const String accessToken = "SEU_ACCESS_TOKEN_AQUI";

      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/checkout/preferences'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "items": itens.map((doc) => {
            "title": doc['nome'],
            "quantity": doc['quantidade'],
            "unit_price": doc['preco'],
            "currency_id": "BRL"
          }).toList(),
          "back_urls": {
            "success": "https://sualoja.com/sucesso", // Opcional
            "failure": "https://sualoja.com/erro",
          },
          "auto_return": "approved",
        }),
      );

      Navigator.pop(context); // Fecha Loading

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String urlPagamento = data['init_point']; // Link do Checkout (Pix, Boleto, Cartão)

        // 2. Salva o pedido no Firebase antes de abrir o pagamento
        await _salvarPedidoNoFirebase(total, itens, data['id']);

        // 3. Abre o navegador/App do Mercado Pago
        if (await canLaunchUrl(Uri.parse(urlPagamento))) {
          await launchUrl(Uri.parse(urlPagamento), mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print("Erro Mercado Pago: $e");
    }
  }

  // --- SALVA NO FIREBASE E LIMPA CARRINHO ---
  Future<void> _salvarPedidoNoFirebase(double total, List<QueryDocumentSnapshot> itens, String paymentId) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final batch = firestore.batch();

    final pedidoRef = firestore.collection('pedidos').doc();

    batch.set(pedidoRef, {
      'idUsuario': user!.uid,
      'itens': itens.map((doc) => doc.data()).toList(),
      'valorTotal': total + valorFrete,
      'status': 'Aguardando Pagamento',
      'pagamentoId': paymentId, // ID do Mercado Pago
      'enderecoEntrega': dadosEndereco,
      'dataCriacao': FieldValue.serverTimestamp(),
    });

    // Deleta itens do carrinho
    for (var doc in itens) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Meu Carrinho", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(user?.uid).collection('carrinho').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Carrinho vazio", style: TextStyle(color: Colors.grey)));
          }

          final itens = snapshot.data!.docs;
          double subtotal = itens.fold(0, (sum, doc) => sum + (doc['preco'] * doc['quantidade']));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    var item = itens[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.network(item['imagem'], width: 50, errorBuilder: (_,__,___) => const Icon(Icons.shopping_bag)),
                      title: Text(item['nome'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text("${item['quantidade']}x R\$ ${item['preco']}", style: const TextStyle(color: Colors.green)),
                    );
                  },
                ),
              ),

              // RODAPÉ COM ENDEREÇO E PAGAMENTO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Endereço (Vindo do Firebase usuarios/{uid})
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ENTREGA EM:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        TextButton(onPressed: () {}, child: const Text("Alterar", style: TextStyle(color: Colors.green))),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on, color: Colors.green),
                      title: Text("${dadosEndereco?['rua'] ?? 'Não cadastrado'}, ${dadosEndereco?['numero'] ?? ''}", style: const TextStyle(color: Colors.white)),
                      subtitle: Text("${dadosEndereco?['bairro'] ?? ''}", style: const TextStyle(color: Colors.grey)),
                    ),

                    const Divider(color: Colors.white10),

                    _linhaPreco("Subtotal", "R\$ ${subtotal.toStringAsFixed(2)}"),
                    _linhaPreco("Frete", "R\$ ${valorFrete.toStringAsFixed(2)}"),
                    _linhaPreco("TOTAL", "R\$ ${(subtotal + valorFrete).toStringAsFixed(2)}", bold: true),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => _gerarPagamentoMercadoPago(subtotal, itens),
                        child: const Text("PAGAR COM MERCADO PAGO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Pix, Cartão ou Boleto", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _linhaPreco(String label, String valor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? Colors.white : Colors.grey, fontSize: bold ? 18 : 14)),
          Text(valor, style: TextStyle(color: bold ? Colors.green : Colors.white, fontSize: bold ? 22 : 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}