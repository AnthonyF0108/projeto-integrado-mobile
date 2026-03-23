import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Salva ou atualiza os dados do usuário usando o UID como ID do documento
  Future<void> salvarDadosUsuario(String uid, Map<String, dynamic> dados) async {
    await _db.collection('usuarios').doc(uid).set(dados, SetOptions(merge: true));
  }

  // Monitora os dados em tempo real
  Stream<DocumentSnapshot> getDadosUsuario(String uid) {
    return _db.collection('usuarios').doc(uid).snapshots();
  }
}