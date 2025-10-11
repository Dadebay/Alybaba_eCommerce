import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/data/models/product_model.dart';
import 'package:nabelli_ecommerce/app/data/services/product_service.dart';

class SearchControllerMIne extends GetxController {
  TextEditingController searchTextController = TextEditingController();
  RxList<ProductModel> searchList = <ProductModel>[].obs;
  RxBool loading = false.obs;

  void searchProducts(String query) async {
    if (query.trim().isEmpty) {
      searchList.clear();
      return;
    }
    loading.value = true;
    // 'searchTextController.text' yerine parametre olarak gelen 'query' kullanın
    final result = await ProductsService().getProducts(parametrs: {'search': query});
    searchList.value = result;
    loading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
