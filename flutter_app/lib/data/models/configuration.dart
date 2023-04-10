class Configuration {
  final String heater;
  double targetTmp;
  double delta;

  Configuration(
      {required this.heater, required this.targetTmp, required this.delta});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      heater: json['heater'],
      targetTmp: json['targetTmp'],
      delta: json['delta'],
    );
  }

  Map toJson() => {
        'heater': heater,
        'targetTmp': targetTmp,
        'delta': delta,
      };
}
