class Settings {
  final bool soundOn;
  final bool hapticsOn;
  final int rangeMin;
  final int rangeMax;

  const Settings({
    required this.soundOn,
    required this.hapticsOn,
    required this.rangeMin,
    required this.rangeMax,
  });

  Settings copyWith({bool? soundOn, bool? hapticsOn, int? rangeMin, int? rangeMax}) => Settings(
        soundOn: soundOn ?? this.soundOn,
        hapticsOn: hapticsOn ?? this.hapticsOn,
        rangeMin: rangeMin ?? this.rangeMin,
        rangeMax: rangeMax ?? this.rangeMax,
      );

  Map<String, dynamic> toJson() => {
        'soundOn': soundOn,
        'hapticsOn': hapticsOn,
        'rangeMin': rangeMin,
        'rangeMax': rangeMax,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        soundOn: json['soundOn'] as bool? ?? true,
        hapticsOn: json['hapticsOn'] as bool? ?? true,
        rangeMin: json['rangeMin'] as int? ?? 1,
        rangeMax: json['rangeMax'] as int? ?? 10,
      );
}

