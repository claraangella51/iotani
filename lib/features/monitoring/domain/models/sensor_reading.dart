class SensorReading {
  final String id;
  final String deviceId;
  final int soilMoisture;
  final int lightLux;
  final String riskStatus;
  final DateTime timestamp;

  SensorReading({
    required this.id,
    required this.deviceId,
    required this.soilMoisture,
    required this.lightLux,
    required this.riskStatus,
    required this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      soilMoisture: json['soilMoisture'] as int,
      lightLux: json['lightLux'] as int,
      riskStatus: json['riskStatus'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'soilMoisture': soilMoisture,
    'lightLux': lightLux,
    'riskStatus': riskStatus,
    'timestamp': timestamp.toIso8601String(),
  };
}
