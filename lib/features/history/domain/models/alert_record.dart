class AlertRecord {
  final String id;
  final String title;
  final String message;
  final String riskStatus;
  final DateTime timestamp;
  final bool read;
  final String? actionType;
  final String? actionValue;

  AlertRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.riskStatus,
    required this.timestamp,
    required this.read,
    this.actionType,
    this.actionValue,
  });

  factory AlertRecord.fromJson(Map<String, dynamic> json) {
    return AlertRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      riskStatus: json['riskStatus'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool? ?? false,
      actionType: json['actionType'] as String?,
      actionValue: json['actionValue'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'riskStatus': riskStatus,
    'timestamp': timestamp.toIso8601String(),
    'read': read,
    if (actionType != null) 'actionType': actionType,
    if (actionValue != null) 'actionValue': actionValue,
  };

  AlertRecord copyWith({bool? read}) {
    return AlertRecord(
      id: id,
      title: title,
      message: message,
      riskStatus: riskStatus,
      timestamp: timestamp,
      read: read ?? this.read,
      actionType: actionType,
      actionValue: actionValue,
    );
  }
}
