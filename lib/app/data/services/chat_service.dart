import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nabelli_ecommerce/app/data/models/message_model.dart';
import 'package:nabelli_ecommerce/app/data/services/auth_service.dart';

class ChatService {
  final String _baseUrl = 'http://alybaba.com.tm/api/user/ru';

  Future<List<MessageModel>> getMessages(int orderId) async {
    final token = await Auth().getToken();
    final response = await http.get(Uri.parse('$_baseUrl/messages/$orderId'), headers: <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    });
    print('GET Messages Status Code: ${response.statusCode}'); // Added for debugging

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> rows = decoded['rows'];
      return rows.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(int orderId, String message) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'order_id': orderId,
        'message': message,
      }),
    );
    print('Status Code: ${response.statusCode}'); // Added for debugging

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
