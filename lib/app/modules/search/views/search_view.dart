import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/constants/cards/product_card.dart';
import 'package:nabelli_ecommerce/app/constants/constants.dart';
import 'package:nabelli_ecommerce/app/constants/errors/empty_widgets.dart';
import 'package:nabelli_ecommerce/app/constants/loaders/loader_widgets.dart';
import 'package:nabelli_ecommerce/app/constants/widgets.dart';
import 'package:nabelli_ecommerce/app/modules/home/controllers/color_controller.dart';
import 'package:nabelli_ecommerce/app/modules/search/controllers/search_controller.dart';

class SearchView extends GetView<SearchControllerMIne> {
  SearchView({Key? key}) : super(key: key);
  final SearchControllerMIne searchController = Get.put(SearchControllerMIne());
  final ColorController colorController = Get.find<ColorController>();
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: colorController.mainColor,
        centerTitle: true,
        
        leadingWidth: 0.0,
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        shadowColor: colorController.mainColor,
        foregroundColor: colorController.mainColor,
        scrolledUnderElevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: Container(
          width: Get.size.width,
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 5, top: 5),
                    child: Icon(IconlyLight.arrowLeftCircle, color: Colors.white),
                  )),
              Expanded(
                  child: searchField(textEditingController, onFieldSubmitted: (String value) {
                searchController.searchProducts(value);
              })),
            ],
          ),
        ),
      ),
      body: Obx(() {
        print(searchController.loading.value);
        if (searchController.loading.value) {
          return loaderShowAllProducts();
        } else if (searchController.searchList.isEmpty) {
          return referalPageEmptyData();
        } else {
          return GridView.builder(
            itemCount: searchController.searchList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final product = searchController.searchList[index];
              return ProductCard(
                historyOrder: false,
                discountValue: product.discountValue!,
                discountValueType: product.discountValueType!,
                id: product.id!,
                createdAt: product.createdAt!,
                image: '$serverURL/${product.image!}-mini.webp',
                name: product.name!,
                price: product.price!,
              );
            },
          );
        }
      }),
    );
  }
}
