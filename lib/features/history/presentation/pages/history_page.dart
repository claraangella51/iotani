import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';
import 'package:iotani_berhasil/features/history/domain/models/alert_record.dart';
import 'package:iotani_berhasil/features/history/domain/models/history_entry.dart';
import 'package:iotani_berhasil/features/history/providers/history_provider.dart';
import 'package:iotani_berhasil/shared/widgets/status_badge.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final alerts = ref.watch(alertsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Aktivitas'),
              Tab(text: 'Peringatan'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Activity Tab
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return _buildHistoryEntryCard(entry);
                },
              ),

              // Alerts Tab
              alerts.when(
                data: (alertList) => alertList.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off,
                                size: 48,
                                color: AppTheme.textLight,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada peringatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: alertList.length,
                        itemBuilder: (context, index) {
                          final alert = alertList[index];
                          return _buildAlertCard(alert);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading alerts')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryEntryCard(HistoryEntry entry) {
    IconData icon;
    Color color;

    switch (entry.type) {
      case HistoryEntryType.sensorReading:
        icon = Icons.show_chart;
        color = AppTheme.secondaryMint;
        break;
      case HistoryEntryType.actuatorAction:
        icon = Icons.settings;
        color = AppTheme.statusWaspada;
        break;
      case HistoryEntryType.modeChange:
        icon = Icons.swap_horiz;
        color = AppTheme.primaryGreen;
        break;
      case HistoryEntryType.alert:
        icon = Icons.warning;
        color = AppTheme.statusRisikoTinggi;
        break;
      case HistoryEntryType.deviceEvent:
        icon = Icons.device_hub;
        color = AppTheme.textMedium;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')} - ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertRecord alert) {
    final riskStatus = _parseRiskStatus(alert.riskStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                RiskStatusBadge(status: riskStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
                if (!alert.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.statusRisikoTinggi,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  RiskStatus _parseRiskStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aman':
        return RiskStatus.aman;
      case 'waspada':
        return RiskStatus.waspada;
      case 'risiko_tinggi':
      case 'risikoTinggi':
        return RiskStatus.risikoTinggi;
      default:
        return RiskStatus.aman;
    }
  }
}
