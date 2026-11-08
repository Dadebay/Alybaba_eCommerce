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


      // 3. API isteği için hazırlan
      final token = await Auth().getToken();
      if (token == null || token.isEmpty) return;
      String lang = Get.locale?.languageCode ?? 'ru';
      if (lang == 'tr' || lang == 'en') {
        lang = 'tm';
      }

      final Uri url = Uri.parse('$serverURL/api/user/$lang/fcm-token');
      final Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      };
      final String body = jsonEncode({'fcm_token': fcmToken});
      // 4. POST isteğini gönder
      final response = await http.post(url, headers: headers, body: body);
      // 5. Sonucu logla
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM TOKEN: Sunucuya başarıyla gönderildi. Status: ${response.statusCode}');
      } else {
        print('FCM TOKEN: Sunucuya gönderilirken hata oluştu. Status: ${response.statusCode}');
      }
    } catch (e) {
      // 6. Herhangi bir hata olursa yakala ve logla
      print('FCM TOKEN: Token gönderme sürecinde bir hata oluştu.');
    }
  }
}
