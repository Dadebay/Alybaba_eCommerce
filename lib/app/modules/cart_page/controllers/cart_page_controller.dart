import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartPageController extends GetxController {
  RxList list = [].obs;
  RxList cartListToCompare = [].obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    ever(list, (_) {
      printCartSummary();
    });
  }

  int get badgeItemCount => list.length;

  double get totalPrice {
    double sum = 0;
    for (final element in list) {
      final double price = double.tryParse(element['price'].toString()) ?? 0;
      final int quantity = (element['quantity'] as num?)?.toInt() ?? 0;
      sum += price * quantity;
    }
    return sum;
  }

  void printCartSummary() {
    print('═══════════════════════════════════════');
    print('SEPET OTOMATIK GUNCELLEME:');
    print('Badge Urun Sayisi: $badgeItemCount');
    print('Toplam Fiyat: ${totalPrice.toStringAsFixed(2)} TMT');
    print('═══════════════════════════════════════');
  }

  void addToCard(
      {required int id,
      required String price,
      required String image,
      required String name,
      required String createdAt,
      required bool airplane,
      required int sizeID,
      required int colorID,
      required double weight}) {
    if (list.isEmpty) {
      list.add({'id': id, 'price': price, 'image': image, 'name': name, 'createdAt': createdAt, 'quantity': 1, 'sizeID': sizeID, 'colorID': colorID, 'airplane': airplane, 'weight': weight});
    } else {
      bool value = false;
      for (final element in list) {
        if (element['id'] == id) {
          element['quantity'] += 1;
          value = true;
        }
      }
      if (!value) {
        list.add({'id': id, 'price': price, 'name': name, 'image': image, 'createdAt': createdAt, 'quantity': 1, 'sizeID': sizeID, 'colorID': colorID, 'airplane': airplane, 'weight': weight});
      }
    }
    list.refresh();
    final String jsonString = jsonEncode(list);
    storage.write('cartList', jsonString);
  }

  dynamic returnCartList() {
    final result = storage.read('cartList') ?? '[]';
    final List jsonData = jsonDecode(result);
    if (jsonData.isEmpty) {
      return;
    }
    list.assignAll(
      jsonData
          .map(
            (element) => {
              'id': element['id'],
              'price': element['price'],
              'image': element['image'],
              'name': element['name'],
              'createdAt': element['createdAt'],
              'quantity': element['quantity'],
              'sizeID': element['sizeID'],
              'colorID': element['colorID'],
              'airplane': element['airplane'],
              'weight': element['weight'],
            },
          )
          .toList(),
    );
  }

  void minusCardElement(int id) {
    for (final element in list) {
      if (element['id'] == id) {
        element['quantity'] -= 1;
        if (element['quantity'] == 0) {
          cartListToCompare.removeWhere((element) => element['id'] == id);
        }
      }
    }

    list.removeWhere((element) => element['quantity'] == 0);
    list.refresh();
    cartListToCompare.refresh();
    final String jsonString = jsonEncode(list);
    storage.write('cartList', jsonString);
  }

  void updateCartQuantity(int id) {
    for (var element in list) {
      if (element['id'] == id) {
        element['quantity'] += 1;
      }
    }
    list.refresh();
    final String jsonString = jsonEncode(list);
    storage.write('cartList', jsonString);
  }

  void removeCardXButton(int id) {
    cartListToCompare.removeWhere((element) => element['id'] == id);
    list.removeWhere((element) => element['id'] == id);
    list.refresh();
    cartListToCompare.refresh();
    final String jsonString = jsonEncode(list);
    storage.write('cartList', jsonString);
  }

  void removeAllCartElements() {
    list.clear();
    cartListToCompare.clear();
    cartListToCompare.refresh();
    final String jsonString = jsonEncode(list);
    storage.write('cartList', jsonString);
  }
}
