enum HistoryEntryType {
  sensorReading,
  modeChange,
  actuatorAction,
  alert,
  deviceEvent,
}

class HistoryEntry {
  final String id;
  final HistoryEntryType type;
  final DateTime timestamp;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;

  HistoryEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.metadata,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      type: HistoryEntryType.values.firstWhere(
        (e) => e.toString() == 'HistoryEntryType.${json['type']}',
        orElse: () => HistoryEntryType.sensorReading,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'title': title,
    'description': description,
    'metadata': metadata,
  };
}
