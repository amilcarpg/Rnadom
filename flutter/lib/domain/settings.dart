class Settings {
  final bool soundOn;
  final bool hapticsOn;
  final int rangeMin;
  final int rangeMax;
  final String? localeCode;

  const Settings({
    required this.soundOn,
    required this.hapticsOn,
    required this.rangeMin,
    required this.rangeMax,
    this.localeCode,
  });

  Settings copyWith(
          {bool? soundOn,
          bool? hapticsOn,
          int? rangeMin,
          int? rangeMax,
          String? localeCode,
          bool clearLocale = false}) =>
      Settings(
        soundOn: soundOn ?? this.soundOn,
        hapticsOn: hapticsOn ?? this.hapticsOn,
        rangeMin: rangeMin ?? this.rangeMin,
        rangeMax: rangeMax ?? this.rangeMax,
        localeCode: clearLocale ? null : localeCode ?? this.localeCode,
      );

  Map<String, dynamic> toJson() => {
        'soundOn': soundOn,
        'hapticsOn': hapticsOn,
        'rangeMin': rangeMin,
        'rangeMax': rangeMax,
        'localeCode': localeCode,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        soundOn: json['soundOn'] as bool? ?? true,
        hapticsOn: json['hapticsOn'] as bool? ?? true,
        rangeMin: json['rangeMin'] as int? ?? 1,
        rangeMax: json['rangeMax'] as int? ?? 10,
        localeCode: json['localeCode'] as String?,
      );
}
