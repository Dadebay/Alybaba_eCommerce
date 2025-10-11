import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabelli_ecommerce/app/constants/widgets.dart';
import 'package:nabelli_ecommerce/app/data/models/history_orders_model.dart';

import '../../constants/constants.dart';
import 'auth_service.dart';

class HistoryOrdersService {
  Future<List<HistoryOrdersModel>> getHistoryOrders() async {
    String lang = Get.locale!.languageCode;
    final token = await Auth().getToken();
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    final List<HistoryOrdersModel> historyOrders = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/user/$lang/get-orders',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    print("$serverURL/api/user/$lang/get-orders");
    print(response.body);
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body)['rows'];
      for (final Map product in responseJson) {
        historyOrders.add(HistoryOrdersModel.fromJson(product));
      }
      return historyOrders;
    } else {
      return [];
    }
  }

  Future<bool> cancelOrder(int id) async {
    String lang = Get.locale!.languageCode;
    final token = await Auth().getToken();
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    print('$serverURL/api/user/$lang/cancel-order/$id');
    print(token);
    final response = await http.post(
      Uri.parse(
        '$serverURL/api/user/$lang/cancel-order/$id',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      getHistoryOrders();

      showSnackBar("canceled", "canceledSubtitle", Colors.green);
      return true;
    } else {
      showSnackBar("errorTitle", "error", Colors.red);
      return false;
    }
  }

  Future<HistoryOrdersModelByID> getHistoryByID(int id) async {
    String lang = Get.locale!.languageCode;
    final token = await Auth().getToken();
    if (lang == 'tr' || lang == 'en') {
      lang = 'tm';
    }
    print('$serverURL/api/user/$lang/order/$id');
    print(token);

    final response = await http.get(
      Uri.parse(
        '$serverURL/api/user/$lang/order/$id',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body)['data'];
      print(responseJson);
      return HistoryOrdersModelByID.fromJson(responseJson);
    } else {
      return HistoryOrdersModelByID();
    }
  }

  Future<bool> isAvailableOnlinePayment() async {
    const lang = 'ru';
    final token = await Auth().getToken();
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/user/$lang/is-available-online-payment',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return responseJson['available'];
    } else {
      return false;
    }
  }

  Future<String?> prepayment(int orderId) async {
    const lang = 'ru';
    final token = await Auth().getToken();
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/user/$lang/prepayment/$orderId',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    print(
      '$serverURL/api/user/$lang/prepayment/$orderId',
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (responseJson['errorCode'] == '0') {
        return responseJson['formUrl'];
      }
    }
    return null;
  }
}
