import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {

  final String nome;
  final IconData icon;

  const CategoryButton({
    required this.nome,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green,
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(nome))
              );
            },
          ),
        ),

        const SizedBox(height: 5),

        Text(nome, style: const TextStyle(fontSize: 12))

      ],
    );
  }
}