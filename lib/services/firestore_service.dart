import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PERFIL DO USUÁRIO ---
  Future<void> salvarDadosUsuario(String uid, Map<String, dynamic> dados) async {
    await _db.collection('usuarios').doc(uid).set(dados, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getDadosUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }

  // --- PRODUTOS ---
  Stream<QuerySnapshot> getProdutos() {
    return _db.collection('produtos').snapshots();
  }

  // --- CARRINHO ---
  Future<void> adicionarAoCarrinho(String uid, Map<String, dynamic> produto) async {
    // Cria uma sub-coleção 'carrinho' dentro do documento do usuário
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('carrinho')
        .doc(produto['id']) // Usa o ID do produto para não repetir itens
        .set({
      'nome': produto['nome'],
      'preco': produto['preco'],
      'imagem': produto['imagem'],
      'quantidade': FieldValue.increment(1), // Soma +1 se já existir
    }, SetOptions(merge: true));
  }
}