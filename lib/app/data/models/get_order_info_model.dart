class GetOrderInfoModel {
  final String? info;
  final List<TransportModel>? transports;
  GetOrderInfoModel({
    this.info,
    this.transports,
  });

  factory GetOrderInfoModel.fromJson(Map<dynamic, dynamic> json) {
    return GetOrderInfoModel(
      transports: json['transports'] != null ? (json['transports'] as List).map((json) => TransportModel.fromJson(json)).toList() : [],
      info: json['info'] ?? '',
    );
  }
}

class TransportModel {
  int? minWeek;
  int? maxWeek;
  int? transport;
  String? price;
  String? prepayment;
  String? info;
  String? name;
  String? title;

  TransportModel({this.minWeek, this.price, this.prepayment, this.maxWeek, this.info, this.transport, this.name, this.title});

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      minWeek: json['min_week'],
      info: json['info'],
      maxWeek: json['max_week'],
      transport: json['transport'],
      price: json['price'].toString(),
      prepayment: json['prepayment'].toString(),
      name: json['name'],
      title: json['title'],
    );
  }
}
