import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/modules/search/controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchControllerMIne>(
      () => SearchControllerMIne(),
    );
  }
}
