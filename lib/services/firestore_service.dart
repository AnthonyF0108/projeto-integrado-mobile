import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarDadosUsuario(String uid,
      Map<String, dynamic> dados) async {
    await _db.collection('usuarios').doc(uid).set(
        dados, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getDadosUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getProdutos() {
    return _db.collection('produtos').snapshots();
  }

  Future<void> adicionarAoCarrinho(String uid,
      Map<String, dynamic> produto) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .collection('carrinho')
          .doc(produto['id'].toString())
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

  Future<void> alternarFavorito(String userId,
      Map<String, dynamic> produto) async {
    String produtoId = produto['id']?.toString() ?? DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    var ref = _db
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .doc(produtoId);

    var doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
      print("Produto $produtoId removido dos favoritos.");
    } else {
      await ref.set({
        ...produto,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Produto $produtoId favoritado!");
    }
  }
}