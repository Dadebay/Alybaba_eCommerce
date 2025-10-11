import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabelli_ecommerce/app/data/services/auth_service.dart';

import '../../constants/constants.dart';

class FCMService {
  Future<void> sendFcmToken() async {
    try {
      // 1. FCM Token'ı almayı dene
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // 2. Token null veya boş ise işlemi durdur
      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM TOKEN: Token alınamadı, sunucuya gönderilmeyecek.');
        return;
      }

      print('FCM TOKEN: Başarıyla alındı: $fcmToken');

      // 3. API isteği için hazırlan
      final token = await Auth().getToken();
      String lang = Get.locale?.languageCode ?? 'ru';
      if (lang == 'tr' || lang == 'en') {
        lang = 'tm';
      }

      final Uri url = Uri.parse('$serverURL/api/user/$lang/fcm-token');
      print(url);
      final Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      };
      final String body = jsonEncode({'fcm_token': fcmToken});
      print(body);
      // 4. POST isteğini gönder
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      // 5. Sonucu logla
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM TOKEN: Sunucuya başarıyla gönderildi. Status: ${response.statusCode}');
        print('FCM TOKEN: Sunucu yanıtı: ${response.body}');
      } else {
        print('FCM TOKEN: Sunucuya gönderilirken hata oluştu. Status: ${response.statusCode}');
        print('FCM TOKEN: Hata yanıtı: ${response.body}');
      }
    } catch (e) {
      // 6. Herhangi bir hata olursa yakala ve logla
      print('FCM TOKEN: Token gönderme sürecinde bir hata oluştu: $e');
    }
  }
}
