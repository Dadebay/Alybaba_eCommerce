import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nabelli_ecommerce/app/constants/iconly.dart';
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
  String returnImage() {
    if (colorController.findMainColor.value == 0) {
      return 'assets/image/color1.png';
    } else if (colorController.findMainColor.value == 1) {
      return 'assets/image/color21.png';
    } else if (colorController.findMainColor.value == 2) {
      return 'assets/image/color31.png';
    }
    return 'assets/image/color41.png';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              returnImage(),
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // blur seviyesi
              child: Container(
                color: colorController.mainColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            centerTitle: true,
            leadingWidth: 0.0,
            titleSpacing: 0.0,
            automaticallyImplyLeading: false,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
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
                    ),
                  ),
                  Expanded(
                    child: searchField(
                      textEditingController,
                      onFieldSubmitted: (String value) {
                        searchController.searchProducts(value);
                      },
                    ),
                  ),
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
        ),
      ],
    );
  }
}
