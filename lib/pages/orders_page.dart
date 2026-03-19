import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: Text(
        "Nenhum pedido ainda",
        style: TextStyle(fontSize: 18),
      ),
    );

  }
}