import '../models/product.dart';

class CartService {

  static List<Product> cart = [];

  static void add(Product product){
    cart.add(product);
  }

}