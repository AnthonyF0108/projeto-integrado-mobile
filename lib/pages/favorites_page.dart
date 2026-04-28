import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // Importe o serviço para o carrinho

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Meus Favoritos",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: user == null
          ? const Center(
          child: Text("Faça login para ver seus favoritos",
              style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('favoritos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Você ainda não salvou nada.",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          final favs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: favs.length,
            itemBuilder: (context, index) {
              var p = favs[index].data() as Map<String, dynamic>;
              String id = favs[index].id;
              // Garantir que o preço seja double para evitar erros de formatação
              double preco = (p['preco'] is int)
                  ? (p['preco'] as int).toDouble()
                  : (p['preco'] as double? ?? 0.0);

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  // AO CLICAR NO ITEM: Abre os detalhes
                  onTap: () => _mostrarDetalhes(context, p, preco, id, user),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(p['imagem'] ?? '',
                        width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(p['nome'] ?? "",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(color: Colors.green)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      favs[index].reference.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- FUNÇÃO DE DETALHES (REUTILIZADA) ---
  void _mostrarDetalhes(BuildContext context, Map<String, dynamic> p,
      double preco, String id, User? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.network(p['imagem'] ?? '',
                    height: 300, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['nome'] ?? "Produto",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}",
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 30),
                    const Text("Descrição",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                        p['descricao'] ??
                            "Nenhuma descrição disponível para este produto.",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16, height: 1.5)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          if (user != null) {
                            await FirestoreService().adicionarAoCarrinho(user.uid, {
                              'id': id,
                              'nome': p['nome'],
                              'preco': preco,
                              'imagem': p['imagem']
                            });
                            Navigator.pop(context); // Fecha o modal
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${p['nome']} adicionado ao carrinho!")));
                          }
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("ADICIONAR AO CARRINHO",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}