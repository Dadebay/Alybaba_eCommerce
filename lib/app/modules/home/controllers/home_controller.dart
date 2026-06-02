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

  // RxLists — layout sabit, FutureBuilder yok
  RxList<BannerModel> banners = <BannerModel>[].obs;
  RxList<BannerModel> miniBanners = <BannerModel>[].obs;
  RxList<ProductModel> newItems = <ProductModel>[].obs;
  RxList<ProductModel> originalItems = <ProductModel>[].obs;
  RxList<ProductModel> recommendedItems = <ProductModel>[].obs;
  RxList<ProductModel> inOurHandsItems = <ProductModel>[].obs;
  RxList<ProductModel> mostOrderedItems = <ProductModel>[].obs;

  RxBool isLoading = true.obs;

  final List<Map<String, String>> parameters = [
    {'new_in_come': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'DESC'},
    {'original': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'recomended': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'on_hand': 'true', 'page': '0', 'limit': '20', 'sort_column': 'random', 'sort_direction': 'ASC'},
    {'ordered_count': 'true', 'page': '0', 'limit': '20', 'sort_column': 'ordered_count', 'sort_direction': 'DESC'},
  ];

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        BannerService().getBanners(2),
        BannerService().getBanners(3),
        ProductsService().getProducts(parametrs: parameters[0], label: 'newItems'),
        ProductsService().getProducts(parametrs: parameters[1], label: 'original'),
        ProductsService().getProducts(parametrs: parameters[2], label: 'recommended'),
        ProductsService().getProducts(parametrs: parameters[3], label: 'inOurHands'),
        ProductsService().getProducts(parametrs: parameters[4], label: 'mostOrdered'),
      ]);
      banners.value = results[0] as List<BannerModel>;
      miniBanners.value = results[1] as List<BannerModel>;
      newItems.value = results[2] as List<ProductModel>;
      originalItems.value = results[3] as List<ProductModel>;
      recommendedItems.value = results[4] as List<ProductModel>;
      inOurHandsItems.value = results[5] as List<ProductModel>;
      mostOrderedItems.value = results[6] as List<ProductModel>;
    } catch (e) {
      print('[HomeController] getData error: $e');
    }
    isLoading.value = false;
  }

  final storage = GetStorage();

  var tm = const Locale('tr');
  var ru = const Locale('ru');

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
