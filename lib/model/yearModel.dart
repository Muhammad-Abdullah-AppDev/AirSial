class YearModel {
  final String pkcode;
  final DateTime frdt;
  final DateTime todt;
  final String name;
  final dynamic ast;
  final String cocd;

  YearModel({
    required this.pkcode,
    required this.frdt,
    required this.todt,
    required this.name,
    required this.ast,
    required this.cocd,
  });

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      pkcode: json['PKCODE'],
      frdt: DateTime.parse(json['FRMDT']),
      todt: DateTime.parse(json['TODT']),
      name: json['NAME'],
      ast: json['AST'],
      cocd: json['COCD'],
    );
  }
}
