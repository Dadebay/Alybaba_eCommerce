
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  Future<List<String>> getPaymentNumbers() async {
    final response = await http.get(Uri.parse('http://alybaba.com.tm/api/user/ru/numbers'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<String> numbers = (decoded['rows'] as List)
          .map((row) => row['phone'].toString())
          .toList();
      return numbers;
    } else {
      throw Exception('Failed to load payment numbers');
    }
  }
}
