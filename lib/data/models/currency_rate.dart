/// Курс валюты из /v1/exchangerate.
class CurrencyRate {
  const CurrencyRate({
    required this.pair,
    required this.rate,
    required this.appliedAt,
  });

  /// Валютная пара вида «USD_EUR».
  final String pair;
  final double rate;

  /// Дата, на которую установлен курс.
  final DateTime appliedAt;

  String get base => pair.contains('_') ? pair.split('_').first : pair;
  String get target => pair.contains('_') ? pair.split('_').last : pair;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final timestamp = json['timestamp'];
    return CurrencyRate(
      pair: (json['currency_pair'] ?? '').toString(),
      rate: (json['exchange_rate'] as num?)?.toDouble() ?? 0,
      appliedAt: timestamp is num
          ? DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'currency_pair': pair,
        'exchange_rate': rate,
        'timestamp': appliedAt.millisecondsSinceEpoch ~/ 1000,
      };
}
