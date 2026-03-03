import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/constants/cards/order_history_card.dart';
import 'package:nabelli_ecommerce/app/constants/custom_app_bar.dart';
import 'package:nabelli_ecommerce/app/constants/loaders/loader_widgets.dart';
import 'package:nabelli_ecommerce/app/constants/widgets.dart';
import 'package:nabelli_ecommerce/app/data/services/history_order_service.dart';
import 'package:nabelli_ecommerce/app/data/services/payment_service.dart';
import 'package:nabelli_ecommerce/app/modules/user_profil/history_order/online_payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/constants.dart';
import '../../../constants/errors/empty_widgets.dart';
import '../../../constants/errors/error_widgets.dart';
import '../../../data/models/history_orders_model.dart';
import 'chat_page.dart';

class OrderStatusWait extends StatelessWidget {
  final int whichStatus;
  const OrderStatusWait({
    required this.whichStatus,
    Key? key,
  }) : super(key: key);

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
          // appBar: CustomAppBar(backArrow: true, actionIcon: false, name: 'orders'),
          body: FutureBuilder<List<HistoryOrdersModel>>(
            future: HistoryOrdersService().getHistoryOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: spinKit());
              } else if (snapshot.hasError) {
                return referalPageError();
              } else if (snapshot.data!.isEmpty) {
                return orderPageEmpty();
              }
              snapshot.data!.sort((a, b) {
                final DateTime aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                final DateTime bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bDate.compareTo(aDate);
              });
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemExtent: 240,
                reverse: false,
                shrinkWrap: false,
                itemBuilder: (BuildContext context, int index) {
                  return OrderHistoryCard(index: index, snapshot: snapshot);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

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

class HistoryOrderProductProfil extends StatelessWidget {
  const HistoryOrderProductProfil({required this.id, required this.pageName, Key? key}) : super(key: key);
  final int id;
  final String pageName;
  @override
  Widget build(BuildContext context) {
    print(pageName);
    return SafeArea(
      bottom: true,
      top: false,
      child: Stack(
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
            appBar: CustomAppBar(
              backArrow: true,
              actionIcon: false,
              name: pageName,
            ),
            body: FutureBuilder<HistoryOrdersModelByID>(
              future: HistoryOrdersService().getHistoryByID(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return spinKit();
                } else if (snapshot.hasError) {
                  return locationPageError();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return locationPageError(); // Or some other error widget
                }

                // Safely parse values, providing defaults
                final totalString = snapshot.data!.total ?? '0';
                final transportPriceString = snapshot.data!.totalTransportPrice ?? '0';

                final double totalValue = double.tryParse(totalString) ?? 0.0;
                final double transportValue = double.tryParse(transportPriceString) ?? 0.0;

                final double sumPrice = totalValue + transportValue;

                // Format prices without decimals
                final String formattedTransportPrice = transportValue.truncate().toString();
                final String formattedTotal = sumPrice.truncate().toString();

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        itemCount: snapshot.data!.items!.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => HistoryOrderCard(
                          historyOrder: true,
                          image: '$serverURL/${snapshot.data!.items![index].image}-mini.webp',
                          name: snapshot.data!.items![index].name!,
                          price: snapshot.data!.items![index].price!,
                          color: snapshot.data!.items![index].color!,
                          size: snapshot.data!.items![index].size!,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3 / 5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'orderDetails'.tr,
                            style: const TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: bottomPart2('date', snapshot.data!.createdAt!),
                          ),
                          bottomPart2('countProducts', snapshot.data!.items!.length.toString()),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: formattedTransportPrice.toString() != '0' ? bottomPart2('transportPrice', ': + $formattedTransportPrice TMT') : SizedBox.shrink(),
                          ),
                          bottomPart2('priceProduct', '$formattedTotal TMT'),
                          snapshot.data!.statusId == 2
                              ? Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.grey.shade100),
                                  child: Text(
                                    'order_accepted_message'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: gilroySemiBold, color: Colors.black, fontSize: 18),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() => ChatPage(orderId: id));
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: colorController.mainColor, elevation: 1, shape: const RoundedRectangleBorder(borderRadius: borderRadius5)),
                                          child: Text(
                                            'chat'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final available = await HistoryOrdersService().isAvailableOnlinePayment();
                                            final prepaymentAmount = (double.parse(snapshot.data!.total!) * snapshot.data!.prepayment_percent!) / 100;
                                            Get.dialog(
                                              AlertDialog(
                                                title: Text('${'prepayment'.tr}: ${prepaymentAmount.toStringAsFixed(2)} TMT', style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 20)),
                                                content: Container(
                                                  width: double.maxFinite,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Card(
                                                        elevation: 2,
                                                        shape: RoundedRectangleBorder(borderRadius: borderRadius10),
                                                        child: ListTile(
                                                          leading: const Icon(IconlyLight.wallet, color: Colors.black),
                                                          title: Text('onlinePay'.tr, style: const TextStyle(fontFamily: gilroySemiBold)),
                                                          onTap: () async {
                                                            Get.back(); // Close dialog
                                                            if (available) {
                                                              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                                                              final formUrl = await HistoryOrdersService().prepayment(id);
                                                              Get.back(); // Close loading indicator

                                                              if (formUrl != null) {
                                                                await Get.to(() => MyWebView(url: formUrl));
                                                              } else {
                                                                showSnackBar('errorTitle'.tr, 'paymentFailedError'.tr, Colors.red);
                                                              }
                                                            } else {
                                                              showSnackBar('errorTitle'.tr, 'onlinePaymentNotAvailable'.tr, Colors.red);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Card(
                                                        elevation: 2,
                                                        shape: RoundedRectangleBorder(borderRadius: borderRadius10),
                                                        child: ListTile(
                                                          leading: const Icon(IconlyLight.call, color: Colors.black),
                                                          title: Text('payByPhone'.tr, style: const TextStyle(fontFamily: gilroySemiBold)),
                                                          onTap: () async {
                                                            Get.back();
                                                            Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                                                            try {
                                                              final phoneNumbers = await PaymentService().getPaymentNumbers();
                                                              Get.back(); // Close loading indicator
                                                              _showPhoneNumberDialog(snapshot.data!, phoneNumbers);
                                                            } catch (e) {
                                                              Get.back(); // Close loading indicator
                                                              showSnackBar('errorTitle'.tr, 'no_phone_numbers_available'.tr, Colors.red);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, elevation: 1, shape: const RoundedRectangleBorder(borderRadius: borderRadius5)),
                                          child: Text(
                                            'prepayment'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPhoneNumberDialog(HistoryOrdersModelByID orderData, List<String> phoneNumbers) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: borderRadius20),
        title: Text('online_payment_numbers_title'.tr, style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 20)),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: phoneNumbers.length,
            itemBuilder: (context, index) {
              final phoneNumber = phoneNumbers[index].substring(4, phoneNumbers[index].length);
              final prepaymentAmount = (double.parse(orderData.total!) * orderData.prepayment_percent!) / 100;
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: borderRadius10),
                child: ListTile(
                  leading: const Icon(IconlyLight.call, color: Colors.black),
                  title: Text(phoneNumber, style: const TextStyle(fontFamily: gilroyMedium)),
                  onTap: () {
                    final smsBody = '$phoneNumber ${prepaymentAmount.toStringAsFixed(2)}';
                    print(smsBody);
                    print(smsBody);
                    print(smsBody);
                    print(smsBody);
                    print(smsBody);
                    _sendSmsIntent('0804', smsBody);
                    Get.back();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _sendSmsIntent(String phone, String body) async {
    try {
      // Android için doğrudan SMS intent'i oluştur
      final String smsUri = 'sms:$phone?body=$body';
      print(smsUri);
      print(smsUri);
      print(smsUri);
      print(smsUri);
      print(smsUri);
      if (await canLaunchUrl(Uri.parse(smsUri))) {
        await launchUrl(
          Uri.parse(smsUri),
          mode: LaunchMode.externalApplication,
        );
      } else {
        showSnackBar('errorTitle'.tr, 'sms_app_not_found'.tr, Colors.red);
      }
    } catch (e) {
      print("SMS hatası: $e");
      showSnackBar('errorTitle'.tr, 'sms_send_failed'.tr, Colors.red);
    }
  }

  Row bottomPart2(String name, String name1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name.tr,
          style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18),
        ),
        Text(
          name1,
          style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18),
        ),
      ],
    );
  }
}

class HistoryOrderCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String color;
  final String size;
  final bool historyOrder;

  const HistoryOrderCard({
    required this.image,
    required this.name,
    required this.price,
    required this.color,
    required this.size,
    required this.historyOrder,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width >= 800 ? 280 : 180,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius15,
      ),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: Colors.white,
          shadowColor: colorController.mainColor,
          padding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 5),
          shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
        ),
        onPressed: () {},
        child: Column(
          children: [
            imagePart(size),
            namePart1(),
          ],
        ),
      ),
    );
  }

  Expanded imagePart(Size size) {
    return Expanded(
      flex: 3,
      child: CachedNetworkImage(
        fadeInCurve: Curves.ease,
        imageUrl: image,
        imageBuilder: (context, imageProvider) => Container(
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: borderRadius15,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => spinKit(),
        errorWidget: (context, url, error) => noBannerImage(),
      ),
    );
  }

  Widget namePart1() {
    final double pricee = double.parse(price.toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 5, left: 4, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          normalPrice(pricee),
          Text(
            name == '' ? 'product_name_placeholder'.tr : name,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18),
          ),
          size.isNotEmpty
              ? Row(
                  children: [
                    Text(
                      'chooseTheSize'.tr,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontFamily: gilroyBold, fontSize: 16),
                    ),
                    Text(
                      size,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          color.isNotEmpty
              ? Row(
                  children: [
                    Text(
                      'productColor'.tr + ' ',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontFamily: gilroyBold, fontSize: 16),
                    ),
                    Text(
                      color,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Row normalPrice(double pricee) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          pricee.toString(),
          style: TextStyle(
            color: colorController.mainColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: gilroySemiBold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 6),
          child: Text(
            ' TMT',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorController.mainColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: gilroySemiBold,
            ),
          ),
        ),
      ],
    );
  }
}
