import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FavoritoButton extends StatelessWidget {
  final String userId;
  final String produtoId;
  final Map<String, dynamic> produtoDados; // Dados completos para salvar

  const FavoritoButton({
    super.key,
    required this.userId,
    required this.produtoId,
    required this.produtoDados,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // ESCOPO: Escutar apenas o documento deste produto específico nos favoritos
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('favoritos')
          .doc(produtoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(width: 20, height: 20); // Pequeno placeholder
        }

        // Se o documento existe nos favoritos, está salvo.
        bool isFavoritado = snapshot.hasData && snapshot.data!.exists;

        return CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          radius: 18,
          child: IconButton(
            // Tamanho menor para caber no CircleAvatar
            iconSize: 18,
            padding: EdgeInsets.zero, // Remove paddings internos
            icon: Icon(
              isFavoritado ? Icons.favorite : Icons.favorite_border,
              // Cor vermelha quando salvo, cinza claro quando não
              color: isFavoritado ? Colors.red : Colors.grey.shade300,
            ),
            onPressed: () async {
              // Lógica de alternar (se existe, remove; se não existe, adiciona)
              // Você precisará atualizar sua função no FirestoreService!
              await FirestoreService().alternarFavorito(userId, produtoDados);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavoritado
                        ? "${produtoDados['nome']} removido dos favoritos"
                        : "${produtoDados['nome']} salvo nos favoritos!",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }
}