class IoTaniModel {
  final int kelembapan;
  final int cahaya;
  final int plantIndex;
  final String pompa;
  final String lampu;
  final String riskStatus;
  final String plantName;
  final int lastUpdate;

  IoTaniModel({
    required this.kelembapan,
    required this.cahaya,
    required this.plantIndex,
    required this.pompa,
    required this.lampu,
    required this.riskStatus,
    required this.plantName,
    required this.lastUpdate,
  });

  factory IoTaniModel.fromMap(Map data) {
    return IoTaniModel(
      kelembapan: _toInt(data['kelembapan'] ?? data['soilMoisture']),
      cahaya: _toInt(data['cahaya'] ?? data['lightLux']),
      plantIndex: _toInt(data['plantIndex']),
      pompa: (data['pompa'] ?? data['pumpStatus'] ?? 'OFF').toString(),
      lampu: (data['lampu'] ?? data['uvLampStatus'] ?? 'OFF').toString(),
      riskStatus: (data['riskStatus'] ?? 'aman').toString(),
      plantName: data['plant'] is Map
          ? (data['plant']?['local_name'] ?? data['plant']?['name'] ?? '-')
                .toString()
          : '-',
      lastUpdate: _toInt(data['lastUpdate'] ?? data['lastUpdated']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }
}
