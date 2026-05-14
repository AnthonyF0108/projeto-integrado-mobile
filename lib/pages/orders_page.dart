import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static String get _accessToken => dotenv.env['MP_ACCESS_TOKEN'] ?? '';
  static const String _webhookUrl =
      "https://webhookmercadopago-i2giblwa3q-uc.a.run.app";

  Future<void> _refazerPix(
      BuildContext context, Map<String, dynamic> pedido, String pedidoId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
      const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final double total =
      (pedido['valorTotal'] ?? 0.0).toDouble();

      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/v1/payments'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'X-Idempotency-Key':
          DateTime.now().millisecondsSinceEpoch.toString(),
        },
        body: jsonEncode({
          "transaction_amount": total,
          "description": "Compra AgroVale",
          "payment_method_id": "pix",
          "external_reference": pedidoId,
          "notification_url": _webhookUrl,
          "payer": {
            "email": user?.email ?? "teste@projeto.com",
            "first_name": "Comprador",
            "last_name": "AgroVale",
            "identification": {"type": "CPF", "number": "12345678909"},
          }
        }),
      );

      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final qrCode =
        data['point_of_interaction']['transaction_data']['qr_code'];
        // Atualiza o paymentId no pedido existente
        await FirebaseFirestore.instance
            .collection('pedidos')
            .doc(pedidoId)
            .update({'paymentId': data['id'].toString()});
        _exibirPix(context, qrCode);
      } else {
        _erro(context, "Erro ao gerar Pix: ${data['message']}");
      }
    } catch (e) {
      Navigator.pop(context);
      _erro(context, "Erro de conexão");
    }
  }

  void _exibirPix(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("QR Code Pix",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: QrImageView(data: code, size: 200),
            ),
            const SizedBox(height: 10),
            const Text(
              "Após pagar, o status atualiza automaticamente.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            TextButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy, color: Colors.green),
              label: const Text("Copiar Código Pix",
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  void _erro(BuildContext context, String m) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E0A),
        body: Center(
            child: Text("Faça login para ver seus pedidos",
                style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Meus Pedidos",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('idUsuario', isEqualTo: user.uid)
            .orderBy('dataCriacao', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text("Erro: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Você ainda não tem pedidos.",
                    style: TextStyle(color: Colors.grey)));
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedidoDoc = pedidos[index];
              final pedido = pedidoDoc.data() as Map<String, dynamic>;
              final pedidoId = pedidoDoc.id;

              double valorTotal = (pedido['valorTotal'] ?? 0.0).toDouble();
              String status = pedido['status'] ?? 'Pendente';
              DateTime dataValida = pedido['dataCriacao'] != null
                  ? (pedido['dataCriacao'] as Timestamp).toDate()
                  : DateTime.now();
              List itens = pedido['itens'] ?? [];

              return Card(
                color: const Color(0xFF1A1A1A),
                margin:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  iconColor: Colors.green,
                  collapsedIconColor: Colors.grey,
                  title: Text("Pedido #${pedidoId.substring(0, 6)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      DateFormat('dd/MM/yy - HH:mm').format(dataValida),
                      style: const TextStyle(color: Colors.grey)),
                  trailing: _statusBadge(status),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...itens.map((item) => Padding(
                            padding:
                            const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${item['quantidade']}x ${item['nome']}",
                                    style: const TextStyle(
                                        color: Colors.white)),
                                Text("R\$ ${item['preco']}",
                                    style: const TextStyle(
                                        color: Colors.white70)),
                              ],
                            ),
                          )),
                          const Divider(color: Colors.white10, height: 20),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text(
                                  "R\$ ${valorTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),

                          if (status == 'Aguardando Pagamento') ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12)),
                                onPressed: () => _refazerPix(
                                    context, pedido, pedidoId),
                                icon: const Icon(Icons.pix,
                                    color: Colors.black),
                                label: const Text("GERAR NOVO PIX",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],

                          if (status == 'Pago') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 6),
                                Text("Pagamento confirmado",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13)),
                              ],
                            )
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
    final isPago = status == 'Pago';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPago ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isPago ? Colors.green : Colors.orange),
      ),
      child: Text(status,
          style: TextStyle(
              color: isPago ? Colors.green : Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }
}