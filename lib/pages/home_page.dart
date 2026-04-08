import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'cart_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("AgroVale Loja", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.green),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar dados", style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum produto encontrado.", style: TextStyle(color: Colors.grey)));
          }

          final produtosDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: produtosDocs.length,
            itemBuilder: (context, index) {
              var p = produtosDocs[index].data() as Map<String, dynamic>;
              String id = produtosDocs[index].id;

              double preco = (p['preco'] is int)
                  ? (p['preco'] as int).toDouble()
                  : (p['preco'] as double? ?? 0.0);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ÁREA DA IMAGEM CORRIGIDA ---
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          p['imagem'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Mostra carregando
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2));
                          },
                          // Se o link do Firebase falhar, mostra esse ícone:
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black26,
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // --------------------------------
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['nome'] ?? "Produto",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                if (user != null) {
                                  await FirestoreService().adicionarAoCarrinho(user.uid, {
                                    'id': id,
                                    'nome': p['nome'],
                                    'preco': preco,
                                    'imagem': p['imagem'],
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${p['nome']} no carrinho!")),
                                  );
                                }
                              },
                              child: const Icon(Icons.add_shopping_cart, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}