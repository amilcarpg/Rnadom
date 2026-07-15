import '../core/constants.dart';

class Result {
  final ModeId mode;
  final String value;
  final DateTime timestamp;
  const Result(
      {required this.mode, required this.value, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'value': value,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        mode: ModeId.values.byName(json['mode'] as String),
        value: json['value'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
