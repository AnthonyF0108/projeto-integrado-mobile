import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'cart_page.dart';
import '../widgets/favorito_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchTerm = "";
  final TextEditingController _searchController = TextEditingController();

  String removerAcentos(String texto) {
    var comAcento = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    var semAcento = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';
    for (int i = 0; i < comAcento.length; i++) {
      texto = texto.replaceAll(comAcento[i], semAcento[i]);
    }
    return texto.toLowerCase();
  }

  String expandirBusca(String busca) {
    busca = removerAcentos(busca);
    if (busca.contains("comida") || busca.contains("fome") || busca.contains("pet")) {
      return "$busca racao semente nutriente";
    }
    if (busca.contains("limpar") || busca.contains("mato") || busca.contains("veneno")) {
      return "$busca herbicida defensivo veneno";
    }
    if (busca.contains("ferramenta") || busca.contains("mexer")) {
      return "$busca enxada pa rastelo tesoura";
    }
    return busca;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: "Pesquisar no AgroVale...",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.green),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) => setState(() => searchTerm = value),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.green),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage())),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          final todosProdutos = snapshot.data!.docs;
          final produtosFiltrados = todosProdutos.where((doc) {
            var p = doc.data() as Map<String, dynamic>;
            String nomeComp = removerAcentos(p['nome'] ?? "");
            String catComp = removerAcentos(p['categoria'] ?? "");
            String buscaProcessada = expandirBusca(searchTerm);
            return buscaProcessada.split(" ").any((palavra) => nomeComp.contains(palavra) || catComp.contains(palavra));
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: produtosFiltrados.length,
            itemBuilder: (context, index) {
              var p = produtosFiltrados[index].data() as Map<String, dynamic>;
              String id = produtosFiltrados[index].id;
              double preco = (p['preco'] is int) ? (p['preco'] as int).toDouble() : (p['preco'] as double? ?? 0.0);

              // Preparamos o Map com o ID incluso para o botão de favorito
              Map<String, dynamic> produtoDados = {...p, 'id': id};

              return GestureDetector(
                onTap: () => _mostrarDetalhes(context, p, preco, id, user),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Imagem do Produto
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  p['imagem'] ?? '',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(color: Colors.black26, child: const Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                              ),
                            ),
                            // --- BOTÃO DE FAVORITO NA TELA PRINCIPAL ---
                            if (user != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FavoritoButton(
                                  userId: user.uid,
                                  produtoId: id,
                                  produtoDados: produtoDados,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['nome'] ?? "Produto", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text("R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}", style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context, Map<String, dynamic> p, double preco, String id, User? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.network(p['imagem'] ?? '', height: 300, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['nome'] ?? "Produto", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}", style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 30),
                    const Text("Descrição", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(p['descricao'] ?? "Nenhuma descrição disponível.", style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          if (user != null) {
                            await FirestoreService().adicionarAoCarrinho(user.uid, {'id': id, 'nome': p['nome'], 'preco': preco, 'imagem': p['imagem']});
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${p['nome']} adicionado!")));
                          }
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("ADICIONAR AO CARRINHO", style: TextStyle(fontWeight: FontWeight.bold)),
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