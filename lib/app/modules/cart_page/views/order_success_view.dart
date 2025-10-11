import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nabelli_ecommerce/app/constants/buttons/agree_button_view.dart';
import 'package:nabelli_ecommerce/app/constants/constants.dart';
import 'package:nabelli_ecommerce/app/modules/auth/views/connection_check_view.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/success_confetti.json',
                width: Get.width * 0.7,
                height: Get.width * 0.7,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text(
                'orderSuccessTitle'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: gilroyBold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'orderSuccessSubtitle'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: gilroyMedium,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              AgreeButton(
                onTap: () {
                  // Clear navigation stack and go to home
                  Get.offAll(() => const ConnectionCheckView());
                },
                text: 'home'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
