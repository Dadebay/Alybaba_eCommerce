import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nabelli_ecommerce/app/data/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('refresh token is saved independently of the access token', () async {
    final directory =
        await Directory.systemTemp.createTemp('alybaba-auth-test');
    addTearDown(() => directory.delete(recursive: true));

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    GetStorage('GetStorage', directory.path);
    await GetStorage.init();
    final auth = Auth();
    await auth.removeToken();
    await auth.removeRefreshToken();

    expect(await auth.setRefreshToken('refresh-token'), isTrue);
    expect(await auth.getRefreshToken(), 'refresh-token');
    expect(await auth.getToken(), isNull);
  });
}
