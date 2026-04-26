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

  factory SensorReading.fromRealtimeDb(Map<String, dynamic> json) {
    final timestampRaw = json['timestamp'] ?? json['lastUpdate'];
    final timestamp = _parseTimestamp(timestampRaw);

    return SensorReading(
      id: (json['id'] as String?) ?? '',
      deviceId: (json['deviceId'] as String?) ?? '',
      soilMoisture: _toInt(json['soilMoisture'] ?? json['kelembapan']),
      lightLux: _toInt(json['lightLux'] ?? json['cahaya']),
      riskStatus: (json['riskStatus'] as String?) ?? 'aman',
      timestamp: timestamp,
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

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final iso = DateTime.tryParse(value);
      if (iso != null) {
        return iso;
      }

      final epoch = int.tryParse(value);
      if (epoch != null) {
        return DateTime.fromMillisecondsSinceEpoch(epoch);
      }
    }
    return DateTime.now();
  }
}
