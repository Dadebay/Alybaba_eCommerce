import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/constants/cards/product_card.dart';
import 'package:nabelli_ecommerce/app/constants/constants.dart';
import 'package:nabelli_ecommerce/app/data/models/product_model.dart';
import 'package:nabelli_ecommerce/app/data/services/banner_service.dart';
import 'package:nabelli_ecommerce/app/data/services/fcm_service.dart';
import 'package:nabelli_ecommerce/app/modules/cart_page/controllers/cart_page_controller.dart';
import 'package:nabelli_ecommerce/app/modules/other_pages/show_all_products.dart';
import 'package:nabelli_ecommerce/app/modules/user_profil/controllers/favorites_page_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../constants/widgets.dart';
import '../controllers/color_controller.dart';
import '../controllers/home_controller.dart';
import 'banners.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CartPageController _cartController = Get.put(CartPageController());
  final FavoritesPageController _favController = Get.put(FavoritesPageController());
  final HomeController _homeController = Get.put(HomeController());
  final ColorController _colorController = Get.put(ColorController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await BannerService().getBanners(3);
    await FCMService().sendFcmToken();
    _cartController.returnCartList();
    _favController.returnFavList();
  }

  void _onRefresh() async {
    await _homeController.getData();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SmartRefresher(
      footer: footer(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      enablePullUp: false,
      header: MaterialClassicHeader(color: _colorController.mainColor),
      child: Obx(() {
        if (_homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            _bannerSection(size),
            _productSection(size, 'newItems', _homeController.newItems, 0),
            _productSection(size, 'originalProducts', _homeController.originalItems, 1),
            _miniBannerSection(size),
            _productSection(size, 'recomendedItems', _homeController.recommendedItems, 2),
            _productSection(size, 'inOurHands', _homeController.inOurHandsItems, 3),
            _productSection(size, 'mostOrdered', _homeController.mostOrderedItems, 4),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  Widget _bannerSection(Size size) {
    final banners = _homeController.banners;
    if (banners.isEmpty) return const SizedBox.shrink();
    return Banners(items: List.from(banners), miniBanner: false);
  }

  Widget _miniBannerSection(Size size) {
    final banners = _homeController.miniBanners;
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Banners(items: List.from(banners), miniBanner: true),
    );
  }

  Widget _productSection(Size size, String nameKey, RxList<ProductModel> items, int paramIndex) {
    if (items.isEmpty) return const SizedBox.shrink();
    final double listHeight = size.width >= 800 ? 400 : 300;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        listViewName(nameKey, true, size, () {
          Get.to(() => ShowAllProducts(
                pageName: nameKey,
                parametrs: _homeController.parameters[paramIndex],
              ));
        }),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              final p = items[i];
              return ProductCard(
                historyOrder: false,
                discountValue: p.discountValue!,
                discountValueType: p.discountValueType!,
                id: p.id!,
                createdAt: p.createdAt!,
                image: '$serverURL/${p.image!}-mini.webp',
                name: p.name!,
                price: p.price!,
              );
            },
          ),
        ),
      ],
    );
  }
}
