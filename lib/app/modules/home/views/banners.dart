import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/modules/home/controllers/home_controller.dart';

import '../../../constants/cards/banner_card.dart';
import '../../../data/models/banner_model.dart';
import '../controllers/color_controller.dart';

class Banners extends StatelessWidget {
  final List<BannerModel> items;
  final bool miniBanner;

  const Banners({
    required this.items,
    required this.miniBanner,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 800;
    final HomeController homeController = Get.put(HomeController());
    final ColorController colorController = Get.put(ColorController());

    if (items.isEmpty) return const SizedBox.shrink();

    final double height = isTablet
        ? (miniBanner ? 300 : 420)
        : (miniBanner ? 170 : 220);

    return Column(
      children: [
        carousel.CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder: (context, index, count) {
            return BannerCard(
              miniBanner: miniBanner,
              model: items[index],
            );
          },
          options: carousel.CarouselOptions(
            onPageChanged: (index, _) {
              homeController.bannerDotsIndex.value = index;
            },
            height: height,
            viewportFraction: miniBanner ? 0.65 : 1.0,
            autoPlay: true,
            scrollPhysics: const BouncingScrollPhysics(),
            autoPlayCurve: Curves.fastLinearToSlowEaseIn,
            autoPlayAnimationDuration: const Duration(milliseconds: 2000),
          ),
        ),
        if (!miniBanner)
          SizedBox(
            height: isTablet ? 40 : 20,
            width: double.infinity,
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isActive = homeController.bannerDotsIndex.value == index;
                    return AnimatedContainer(
                      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                      height: isActive ? (isTablet ? 22 : 16) : (isTablet ? 16 : 10),
                      width: isActive ? (isTablet ? 21 : 15) : (isTablet ? 16 : 10),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.transparent : Colors.grey,
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(color: colorController.mainColor, width: 3)
                            : Border.all(color: Colors.white),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
