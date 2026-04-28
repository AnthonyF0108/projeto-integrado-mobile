import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PERFIL DO USUÁRIO ---
  Future<void> salvarDadosUsuario(String uid,
      Map<String, dynamic> dados) async {
    await _db.collection('usuarios').doc(uid).set(
        dados, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getDadosUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  // --- PRODUTOS ---
  Stream<QuerySnapshot> getProdutos() {
    return _db.collection('produtos').snapshots();
  }

  // --- CARRINHO ---
  Future<void> adicionarAoCarrinho(String uid,
      Map<String, dynamic> produto) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrinho')
          .doc(produto['id'].toString()) // Garante que o ID é uma String
          .set({
        'nome': produto['nome'],
        'preco': produto['preco'],
        'imagem': produto['imagem'],
        'quantidade': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao adicionar ao carrinho: $e");
    }
  }

// No services/firestore_service.dart

// Lógica de Alternar (Toggle): Adiciona ou Remove
  Future<void> alternarFavorito(String userId,
      Map<String, dynamic> produto) async {
    // Garante que temos um ID válido
    String produtoId = produto['id']?.toString() ?? DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    // Referência do documento nos favoritos
    var ref = _db
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .doc(produtoId);

    var doc = await ref.get();

    if (doc.exists) {
      // Se já é favorito, deleta (remove o coração pintado)
      await ref.delete();
      print("Produto $produtoId removido dos favoritos.");
    } else {
      // Se não é, adiciona (pinta o coração)
      await ref.set({
        ...produto, // Salva todos os dados originais
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Produto $produtoId favoritado!");
    }
  }
}