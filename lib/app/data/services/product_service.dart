import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabelli_ecommerce/app/constants/widgets.dart';

import '../../constants/constants.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../models/product_model.dart';

class ProductsService {
  Future<List<ProductModel>> getProducts({required Map<String, String> parametrs, String label = 'UNKNOWN'}) async {
    String lang = Get.locale!.languageCode;
    final List<ProductModel> productsList = [];
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    final fullUrl = Uri.parse('$serverURL/api/$lang/get-products').replace(queryParameters: parametrs);
    print('[$label] ➡️  URL: $fullUrl');
    print('[$label] 📦 Query Params: $parametrs');
    final response = await http.get(
      fullUrl,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('[$label] ✅ Status: 200');
      final responseJson = jsonDecode(response.body)['products'] as List;
      print('[$label] 🔢 Ürün sayısı: ${responseJson.length}');
      for (final Map product in responseJson) {
        productsList.add(ProductModel.fromJson(product));
      }
      print('[$label] 🏁 Toplam yüklenen: ${productsList.length}');
      return productsList;
    } else {
      print('[$label] ❌ Hata: ${response.statusCode}');
      print('[$label] Response Body: ${response.body}');
      return [];
    }
  }

  Future<List<ProductModel>> getShowAllProducts({required Map<String, String> parametrs}) async {
    final HomeController homeController = Get.put(HomeController());
    String lang = Get.locale!.languageCode;
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    print('ShowAllProducts - URL: $serverURL/api/$lang/get-products');
    print('ShowAllProducts - Parameters: $parametrs');
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/$lang/get-products',
      ).replace(queryParameters: parametrs),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('ShowAllProducts - Response Status: 200');
      print('ShowAllProducts - Response Body: ${response.body}');
      homeController.loading.value = 3;
      final responseJson = jsonDecode(response.body)['products'] as List;
      print('ShowAllProducts - Products Count from API: ${responseJson.length}');
      if (jsonDecode(response.body)['products'] == null || jsonDecode(response.body)['products'].toString() == '[]') {
        print('ShowAllProducts - No products found');
        showSnackBar('noProductTitle', 'noProductSubtitle', Colors.red);
      } else {
        print('ShowAllProducts - Processing products...');
        for (final Map product in responseJson) {
          homeController.showAllList.add({
            'id': ProductModel.fromJson(product).id,
            'name': ProductModel.fromJson(product).name,
            'price': ProductModel.fromJson(product).price,
            'createdAt': ProductModel.fromJson(product).createdAt,
            'image': ProductModel.fromJson(product).image,
            'discountValue': ProductModel.fromJson(product).discountValue,
            'discountValueType': ProductModel.fromJson(product).discountValueType,
          });
        }
        print('ShowAllProducts - Total items in showAllList: ${homeController.showAllList.length}');
        if (homeController.showAllList.isEmpty) {
          print('ShowAllProducts - List is empty, setting loading to 2');
          homeController.loading.value = 2;
        }
      }

      return [];
    } else {
      print('ShowAllProducts - Response Status Error: ${response.statusCode}');
      print('ShowAllProducts - Response Body: ${response.body}');
      homeController.loading.value = 1;
      return [];
    }
  }

  Future<ProductByIDModel> getProductByID(int id) async {
    String lang = Get.locale!.languageCode;
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    print('$serverURL/api/$lang/get-product/$id');
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/$lang/get-product/$id',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('GetProductByID - Response Status: 200');
      final decoded = utf8.decode(response.bodyBytes);
      print('GetProductByID - Response Body: $decoded');
      final responseJson = json.decode(decoded);
      print('GetProductByID - Product: ${responseJson[0]}');
      return ProductByIDModel.fromJson(responseJson[0]);
    } else {
      print('GetProductByID - Response Status Error: ${response.statusCode}');
      print('GetProductByID - Response Body: ${response.body}');
      return ProductByIDModel();
    }
  }
}
