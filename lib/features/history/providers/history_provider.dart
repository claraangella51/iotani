import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/features/history/domain/models/alert_record.dart';
import 'package:iotani_berhasil/features/history/domain/models/history_entry.dart';

final alertsProvider = StreamProvider<List<AlertRecord>>((ref) async* {
  // Demo alerts
  yield [
    AlertRecord(
      id: '1',
      title: 'Peringatan IoTani',
      message:
          'Kelembaban tanah terlalu tinggi dan cahaya terlalu rendah. Terdapat potensi risiko penyakit.',
      riskStatus: 'risikoTinggi',
      timestamp: DateTime.now(),
      read: false,
    ),
    AlertRecord(
      id: '2',
      title: 'Notifikasi IoTani',
      message:
          'Tanah mulai terlalu lembap. Pertimbangkan untuk mengurangi penyiraman.',
      riskStatus: 'waspada',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      read: true,
    ),
  ];
});

final historyProvider = Provider<List<HistoryEntry>>((ref) {
  return [
    HistoryEntry(
      id: '1',
      type: HistoryEntryType.sensorReading,
      timestamp: DateTime.now(),
      title: 'Pembacaan Sensor',
      description: 'Kelembaban: 65%, Cahaya: 4500 lux',
      metadata: {'soilMoisture': 65, 'lightLux': 4500, 'riskStatus': 'aman'},
    ),
    HistoryEntry(
      id: '2',
      type: HistoryEntryType.actuatorAction,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      title: 'Aksi Aktuator',
      description: 'Pompa air diaktifkan - durasi 5 menit',
      metadata: {'actionType': 'pump', 'status': 'on', 'duration': 5},
    ),
    HistoryEntry(
      id: '3',
      type: HistoryEntryType.modeChange,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      title: 'Perubahan Mode',
      description: 'Mode berubah dari Manual ke Otomatis',
      metadata: {'previousMode': 'manual', 'currentMode': 'otomatis'},
    ),
    HistoryEntry(
      id: '4',
      type: HistoryEntryType.alert,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      title: 'Peringatan Sistem',
      description:
          'Indikasi risiko penyakit sedang: Kelembaban dan cahaya tidak ideal',
      metadata: {'riskStatus': 'waspada'},
    ),
  ];
});

final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider).value ?? [];
  return alerts.where((a) => !a.read).length;
});
