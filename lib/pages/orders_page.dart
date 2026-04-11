import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // Função para abrir o Mercado Pago novamente caso o pagamento não tenha sido feito
  Future<void> _refazerPagamento(BuildContext context, Map<String, dynamic> pedido) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      const String accessToken = "SEU_ACCESS_TOKEN_AQUI"; // MESMO TOKEN DA TELA DE CARRINHO

      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/checkout/preferences'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "items": (pedido['itens'] as List).map((item) => {
            "title": item['nome'],
            "quantity": int.parse(item['quantidade'].toString()),
            "unit_price": double.parse(item['preco'].toString()),
            "currency_id": "BRL"
          }).toList(),
          "back_urls": {"success": "https://google.com", "failure": "https://google.com"},
          "auto_return": "approved",
        }),
      );

      Navigator.pop(context); // Fecha loading

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Uri url = Uri.parse(data['init_point']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao gerar novo link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E0A),
        body: Center(child: Text("Faça login para ver seus pedidos", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Meus Pedidos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('idUsuario', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Você ainda não tem pedidos.", style: TextStyle(color: Colors.grey)));

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              var pedidoDoc = pedidos[index];
              var pedido = pedidoDoc.data() as Map<String, dynamic>;

              // TRATAMENTO DE SEGURANÇA PARA VALORES NULOS
              double valorTotal = (pedido['valorTotal'] ?? 0.0).toDouble();
              String status = pedido['status'] ?? 'Pendente';
              DateTime dataValida = pedido['dataCriacao'] != null ? (pedido['dataCriacao'] as Timestamp).toDate() : DateTime.now();
              List itens = pedido['itens'] ?? [];

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  iconColor: Colors.green,
                  collapsedIconColor: Colors.grey,
                  title: Text("Pedido #${pedidoDoc.id.substring(0, 6)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yy - HH:mm').format(dataValida), style: const TextStyle(color: Colors.grey)),
                  trailing: _statusBadge(status),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...itens.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${item['quantidade']}x ${item['nome']}", style: const TextStyle(color: Colors.white)),
                                Text("R\$ ${item['preco']}", style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          )),
                          const Divider(color: Colors.white10, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text("R\$ ${valorTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),

                          // SE O STATUS FOR PAGAMENTO PENDENTE, MOSTRA BOTÃO DE REFAZER
                          if (status == 'Aguardando Pagamento') ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _refazerPagamento(context, pedido),
                                child: const Text("PAGAR AGORA (MERCADO PAGO)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}