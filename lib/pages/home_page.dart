import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import 'search_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int page = 0;

  final List<Widget> pages = const [
    HomeContent(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("AgroVale"),
        centerTitle: true,
      ),

      body: pages[page],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,

        children: const [

          ProductCard(
            name: "Motosserra",
            price: "R\$2105",
          ),

          ProductCard(
            name: "Cortador",
            price: "R\$1665",
          ),

          ProductCard(
            name: "Trator",
            price: "R\$30000",
          ),

          ProductCard(
            name: "Sementes",
            price: "R\$250",
          ),

        ],
      ),
    );
  }
}