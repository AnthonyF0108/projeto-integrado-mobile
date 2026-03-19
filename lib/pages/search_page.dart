import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(

        children: [

          TextField(
            decoration: InputDecoration(
              hintText: "Buscar produto",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Digite o nome de um produto para buscar",
            style: TextStyle(fontSize: 16),
          )

        ],
      ),
    );
  }
}