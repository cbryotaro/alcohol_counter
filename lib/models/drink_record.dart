class DrinkRecord {
  final String type; // ビール、日本酒など
  final String size; // 中ジョッキ、一合など
  final double alcoholGrams;

  DrinkRecord({
    required this.type,
    required this.size,
    required this.alcoholGrams,
  });

  // SharedPreferencesで保存するためのJSON変換メソッド
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'size': size,
      'alcoholGrams': alcoholGrams,
    };
  }

  // JSONからインスタンスを作成するファクトリメソッド
  factory DrinkRecord.fromJson(Map<String, dynamic> json) {
    return DrinkRecord(
      type: json['type'] as String,
      size: json['size'] as String,
      alcoholGrams: json['alcoholGrams'] as double,
    );
  }
}
