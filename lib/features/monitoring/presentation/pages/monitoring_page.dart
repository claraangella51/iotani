import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';
import 'package:iotani_berhasil/features/dashboard/providers/active_plant_provider.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';
import 'package:iotani_berhasil/features/monitoring/providers/sensor_readings_provider.dart';
import 'package:iotani_berhasil/shared/widgets/status_badge.dart';

class MonitoringPage extends ConsumerWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlant = ref.watch(activePlantProvider);
    final deviceState = ref.watch(deviceStateProvider);
    final readings = ref.watch(sensorReadingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: deviceState.when(
            data: (state) => state == null
                ? const Center(child: Text('Tidak ada data'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Plant Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePlant.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kategori: ${activePlant.category}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Current Status
                      const Text(
                        'Status Saat Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RiskStatusBadge(status: state.riskStatus, large: true),
                      const SizedBox(height: 16),

                      // Sensor Details
                      _buildSensorDetailSection(
                        'Kelembaban Tanah',
                        '${state.soilMoisture}%',
                        Icons.water_drop,
                        AppTheme.secondaryMint,
                        state.soilMoisture,
                        activePlant.soilMoistureMin,
                        activePlant.soilMoistureMax,
                        DeviceState.getSoilStatusText(
                          state.soilMoisture,
                          activePlant.soilMoistureMin,
                          activePlant.soilMoistureMax,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSensorDetailSection(
                        'Intensitas Cahaya',
                        '${state.lightLux} lux',
                        Icons.light_mode,
                        Color(0xFFFFB800),
                        state.lightLux,
                        activePlant.lightLuxMin,
                        activePlant.lightLuxMax,
                        DeviceState.getLightStatusText(
                          state.lightLux,
                          activePlant.lightLuxMin,
                          activePlant.lightLuxMax,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Explanation
                      Card(
                        color: AppTheme.primaryGreen.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Penjelasan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getExplanation(state, activePlant),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMedium,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recent Readings
                      const Text(
                        'Riwayat Sensor Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      readings.when(
                        data: (list) => Column(
                          children: list.take(5).map((reading) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tanah: ${reading.soilMoisture}% | Cahaya: ${reading.lightLux} lux',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${reading.timestamp.hour}:${reading.timestamp.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        RiskStatusBadge(
                                          status: _parseRiskStatus(
                                            reading.riskStatus,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Terjadi kesalahan')),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorDetailSection(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    num current,
    num min,
    num max,
    String status,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(current, min, max).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(
                        current,
                        min,
                        max,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(current, min, max),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (current - min) / (max - min),
                minHeight: 6,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation(
                  _getStatusColor(current, min, max),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: $min',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
                Text(
                  'Maks: $max',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(num current, num min, num max) {
    if (current < min || current > max) {
      return AppTheme.statusWaspada;
    }
    return AppTheme.statusAman;
  }

  String _getExplanation(DeviceState state, PlantProfile plant) {
    if (state.soilMoisture > 80 && state.lightLux < 300) {
      return 'Tanah terlalu lembap dan cahaya terlalu rendah. Kondisi ini dapat meningkatkan risiko jamur. Pertimbangkan untuk mengurangi penyiraman dan menambah pencahayaan.';
    } else if (state.soilMoisture > 80) {
      return 'Tanah terlalu lembap. Kurangi frekuensi penyiraman untuk mencegah pembusukan akar dan penyakit jamur.';
    } else if (state.lightLux < 300) {
      return 'Cahaya terlalu rendah. Tanaman membutuhkan lebih banyak cahaya untuk proses fotosintesis yang optimal.';
    } else if (state.soilMoisture < plant.soilMoistureMin) {
      return 'Tanah terlalu kering. Perbanyak penyiraman untuk memenuhi kebutuhan air tanaman.';
    } else if (state.lightLux > plant.lightLuxMax) {
      return 'Cahaya terlalu kuat. Pertimbangkan untuk memberikan naungan parsial.';
    }
    return 'Kondisi tanaman optimal. Nikmati pertumbuhan tanaman yang sehat!';
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
