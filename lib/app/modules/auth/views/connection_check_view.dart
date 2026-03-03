// ignore_for_file: file_names, always_use_package_imports

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/constants/constants.dart';

import '../../home/controllers/color_controller.dart';
import '../../home/views/bottom_nav_bar.dart';

class ConnectionCheckView extends StatefulWidget {
  const ConnectionCheckView({Key? key}) : super(key: key);

  @override
  _ConnectionCheckViewState createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State<ConnectionCheckView> with SingleTickerProviderStateMixin {
  final ColorController colorController = Get.put(ColorController());

  late List<int> extendedItemList;
  final int itemCount = 52;
  final int loopMultiplier = 20;
  final ScrollController _scrollController = ScrollController();
  Ticker? _ticker;
  bool _isPreparingGrid = false;
  bool _isGridReady = false;

  @override
  void initState() {
    super.initState();
    _generateExtendedItems(); // sync — list is ready before first build
    checkConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPreparingGrid) {
      _prepareGrid();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _prepareGrid() async {
    _isPreparingGrid = true;
    // Grid is already rendering (invisible). Just precache then reveal.
    await _precacheImages();
    if (!mounted) return;
    setState(() {
      _isGridReady = true;
    });
    startAutoScroll();
  }

  void _generateExtendedItems() {
    final random = Random();
    final startIndex = random.nextInt(itemCount);
    extendedItemList = List.generate(
      itemCount * loopMultiplier,
      (index) => (index + startIndex) % itemCount + 1,
    );
  }

  Future<void> _precacheImages() async {
    final futures = <Future<void>>[];
    for (int i = 1; i <= itemCount; i++) {
      futures.add(precacheImage(AssetImage('assets/onboarding/$i.webp'), context));
    }
    await Future.wait(futures);
  }

  void startAutoScroll() {
    const double scrollSpeed = 1.5;
    _ticker?.dispose();
    _ticker = createTicker((_) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      var nextOffset = _scrollController.offset + scrollSpeed;
      if (nextOffset >= maxExtent - 200) {
        nextOffset = maxExtent * 0.2;
      }
      _scrollController.jumpTo(nextOffset);
    });
    _ticker!.start();
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 4), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const BottomNavBar();
              },
            ),
          );
        });
      }
    } on SocketException catch (_) {
      _showDialog();
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: borderRadius20),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                padding: const EdgeInsets.only(top: 100, left: 15, right: 15),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: borderRadius20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'noConnection1'.tr,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: colorController.mainColor,
                        fontFamily: gilroyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Text(
                        'noConnection2'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: gilroyMedium,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          checkConnection();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorController.mainColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: borderRadius10,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      ),
                      child: Text(
                        'noConnection3'.tr,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: gilroyMedium),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 70,
                minRadius: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/icons/noconnection.gif',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridView() {
    return MasonryGridView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: extendedItemList.length,
      mainAxisSpacing: 6.0,
      crossAxisSpacing: 6.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/onboarding/${extendedItemList[index]}.webp',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Grid is always rendered; fades in once images are cached
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isGridReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: _gridView(),
            ),
          ),

          // White overlay hides the grid until it's ready
          if (!_isGridReady)
            const Positioned.fill(
              child: ColoredBox(color: Colors.white, child: SizedBox.expand()),
            ),

          // Top gradient with logo and app name
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.005),
                  ],
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(logo, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: gilroyBold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient with progress indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 70, bottom: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.005),
                  ],
                ),
              ),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                color: colorController.mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
