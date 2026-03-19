import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProdutos() {
    return _db.collection("produtos").snapshots();
  }

  Future addProduto(String nome, double preco) {

    return _db.collection("produtos").add({
      "nome": nome,
      "preco": preco
    });

  }

}