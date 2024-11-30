import 'package:get/get.dart';
import 'package:nutrition_app/models/product.dart'; // Your product model file

class EatlistController extends GetxController {
  var eatlist = <Product>[].obs;

  void addToEatlist(Product product) {
    // Add the product to the eatlist
    eatlist.add(product);
  }

  void removeFromEatlist(Product product) {
    // Remove the product from the eatlist
    eatlist.remove(product);
  }
}
