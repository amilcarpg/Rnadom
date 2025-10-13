import 'package:flutter/material.dart';

class OptionItem {
  final String id;
  final String label;
  final Color color;
  const OptionItem({required this.id, required this.label, required this.color});

  OptionItem copyWith({String? id, String? label, Color? color}) => OptionItem(
        id: id ?? this.id,
        label: label ?? this.label,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'color': color.toARGB32(),
      };

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
        id: json['id'] as String,
        label: json['label'] as String,
        color: Color(json['color'] as int),
      );
}
