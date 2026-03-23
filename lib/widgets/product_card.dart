import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {

  final String name;
  final String price;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 6,

      child: Padding(
        padding: const EdgeInsets.all(10),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.agriculture,
              size: 50,
              color: Colors.green,
            ),

            const SizedBox(height: 10),

            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(price),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Comprar"),
            )
          ],
        ),
      ),
    );
  }
}