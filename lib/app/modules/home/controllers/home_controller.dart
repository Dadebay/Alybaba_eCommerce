import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/banner_service.dart';
import '../../../data/services/product_service.dart';

class HomeController extends GetxController {
  RxInt bannerDotsIndex = 0.obs;
  RxString balance = '0'.obs;
  RxBool agreeButton = false.obs;
  RxInt loading = 0.obs;
  RxInt page = 0.obs;
  RxList showAllList = [].obs;

  Future<List<BannerModel>> bannersFuture = Future.value([]);
  Future<List<BannerModel>> minibannerFuture = Future.value([]);
  Future<List<ProductModel>> newItemsProducts = Future.value([]);
  Future<List<ProductModel>> originalProducts = Future.value([]);
  Future<List<ProductModel>> mostOrdered = Future.value([]);
  List parameters = [
    {'new_in_come': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'DESC'},
    {'original': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'recomended': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'on_hand': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'ordered_count': 'true', 'page': '0', 'limit': '20', 'sort_column': 'ordered_count', 'sort_direction': 'DESC'},
  ];

  //
  Future<List<ProductModel>> productsFutureInOurHands = Future.value([]);
  Future<List<ProductModel>> productsFutureRecomended = Future.value([]);
  dynamic getData() {
    minibannerFuture = BannerService().getBanners(3);
    bannersFuture = BannerService().getBanners(2);
    newItemsProducts = ProductsService().getProducts(parametrs: parameters[0], label: 'newItems [index:0]');

    originalProducts = ProductsService().getProducts(parametrs: parameters[1], label: 'original [index:1]');

    productsFutureRecomended = ProductsService().getProducts(parametrs: parameters[2], label: 'recommended [index:2]');
    productsFutureInOurHands = ProductsService().getProducts(parametrs: parameters[3], label: 'inOurHands [index:3]');
    mostOrdered = ProductsService().getProducts(parametrs: parameters[4], label: 'mostOrdered [index:4]');
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  final storage = GetStorage();

  var tm = const Locale(
    'tr',
  );
  var ru = const Locale(
    'ru',
  );

  dynamic switchLang(String value) {
    if (value == 'ru') {
      Get.updateLocale(ru);
      storage.write('langCode', 'ru');
    } else {
      Get.updateLocale(tm);
      storage.write('langCode', 'tr');
    }
    update();
  }
}
