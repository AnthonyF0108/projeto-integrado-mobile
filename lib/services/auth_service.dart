import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // IMPORTANTE: Adicione este import

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instância do Google Sign-In

  // --- FUNÇÃO NOVA PARA O GOOGLE ---
  Future<User?> loginComGoogle() async {
    try {
      // 1. Inicia o processo de login no Google (abre a janelinha de escolha de conta)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // Usuário cancelou o login

      // 2. Obtém os detalhes da autenticação do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria uma credencial para o Firebase usando os tokens do Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz o login no Firebase com essa credencial
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Erro no Login com Google: $e");
      return null;
    }
  }

  // --- SUAS FUNÇÕES QUE JÁ EXISTIAM ---

  Future<User?> registarComEmailSenha(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Erro ao registar: $e");
      return null;
    }
  }

  Future<User?> loginComEmailSenha(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  Future<void> sair() async {
    await _googleSignIn.signOut(); // Desloga do Google também
    await _auth.signOut();
  }
}