import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Certifique-se de ter rodado: flutter pub add intl

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

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
      // CORREÇÃO AQUI: era app_bar, o correto é appBar
      appBar: AppBar(
        title: const Text("Meus Pedidos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Se a tela continuar vazia, comente a linha do .orderBy para testar sem o índice
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('idUsuario', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Você ainda não tem pedidos.", style: TextStyle(color: Colors.grey)),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              var pedido = pedidos[index].data() as Map<String, dynamic>;

              DateTime dataValida = pedido['dataCriacao'] != null
                  ? (pedido['dataCriacao'] as Timestamp).toDate()
                  : DateTime.now();

              List itens = pedido['itens'] ?? [];
              String status = pedido['status'] ?? 'Pendente';

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  iconColor: Colors.green,
                  collapsedIconColor: Colors.grey,
                  title: Text(
                    "Pedido #${pedidos[index].id.substring(0, 6)}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yy - HH:mm').format(dataValida),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _statusBadge(status),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ITENS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          // CORREÇÃO AQUI: removido .toList() desnecessário
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
                          const Text("ENDEREÇO", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            "${pedido['enderecoEntrega']['rua']}, ${pedido['enderecoEntrega']['numero']}\n"
                                "${pedido['enderecoEntrega']['bairro']} - ${pedido['enderecoEntrega']['cidade']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text(
                                "R\$ ${pedido['valorTotal'].toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
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
        // CORREÇÃO AQUI: usei .withAlpha ou .withOpacity para evitar erro de versão
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}