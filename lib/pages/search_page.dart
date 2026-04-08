import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String nomeBusca = "";
  final TextEditingController _searchController = TextEditingController();

  // --- FUNÇÃO PARA ADICIONAR AO CARRINHO ---
  void _adicionarAoCarrinho(Map<String, dynamic> produto, int qtd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Referência do documento no carrinho do usuário
    // Usamos o nome do produto como ID para evitar itens duplicados (ele apenas soma a QTD)
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('carrinho')
        .doc(produto['nome']);

    await docRef.set({
      'nome': produto['nome'],
      'preco': produto['preco'],
      'imagem': produto['imagem'],
      'quantidade': FieldValue.increment(qtd), // Incrementa se já existir
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${produto['nome']} adicionado!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- MODAL DE DETALHES DO PRODUTO ---
  void _mostrarDetalhes(Map<String, dynamic> produto) {
    int quantidadeLocal = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do Produto
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        produto['imagem'] ?? '',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título e Preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          produto['nome'] ?? 'Produto',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "R\$ ${produto['preco']}",
                        style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Descrição
                  const Text("DESCRIÇÃO", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    produto['descricao'] ?? "Sem descrição disponível.",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  // Seletor de Qtd e Botão
                  Row(
                    children: [
                      // Contador
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.green),
                              onPressed: () {
                                if (quantidadeLocal > 1) {
                                  setModalState(() => quantidadeLocal--);
                                }
                              },
                            ),
                            Text("$quantidadeLocal", style: const TextStyle(color: Colors.white, fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () => setModalState(() => quantidadeLocal++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Botão Comprar
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              _adicionarAoCarrinho(produto, quantidadeLocal);
                              Navigator.pop(context);
                            },
                            child: const Text("ADICIONAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      appBar: AppBar(
        title: const Text("Pesquisar", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Barra de Busca
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "O que você procura?",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => nomeBusca = "");
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Ajuste para bater com o banco (Primeira Letra Maiúscula)
                  nomeBusca = value.isNotEmpty
                      ? value[0].toUpperCase() + value.substring(1)
                      : "";
                });
              },
            ),
            const SizedBox(height: 20),

            // Lista de Resultados
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('produtos')
                    .where('nome', isGreaterThanOrEqualTo: nomeBusca)
                    .where('nome', isLessThanOrEqualTo: '$nomeBusca\uf8ff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.green));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Nenhum produto encontrado.", style: TextStyle(color: Colors.grey)));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final produto = docs[index].data() as Map<String, dynamic>;

                      return Card(
                        color: const Color(0xFF1A1A1A),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              produto['imagem'] ?? '',
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, color: Colors.green),
                            ),
                          ),
                          title: Text(produto['nome'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("R\$ ${produto['preco']}", style: const TextStyle(color: Colors.green)),
                          trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onTap: () => _mostrarDetalhes(produto),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}