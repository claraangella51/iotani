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

                      // Recommendation
                      _buildRecommendationSection(activePlant),
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

  Widget _buildRecommendationSection(PlantProfile plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppTheme.accentLime.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rentang Ideal untuk ${plant.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: AppTheme.secondaryMint,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanah: ${plant.soilMoistureMin}-${plant.soilMoistureMax}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.light_mode,
                            color: Color(0xFFFFB800),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cahaya: ${plant.lightLuxMin}-${plant.lightLuxMax}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getExplanation(DeviceState state, PlantProfile plant) {
    final notes = <String>[];

    if (state.soilMoisture < plant.soilMoistureMin) {
      notes.add(
        'Tanah terlalu kering. Tambahkan penyiraman bertahap sampai kelembapan masuk rentang ideal ${plant.soilMoistureMin}-${plant.soilMoistureMax}%.',
      );
    } else if (state.soilMoisture > plant.soilMoistureMax) {
      notes.add(
        'Tanah terlalu basah. Kurangi frekuensi penyiraman dan pastikan drainase baik agar akar tidak busuk.',
      );
    }

    if (state.lightLux < plant.lightLuxMin) {
      notes.add(
        'Intensitas cahaya terlalu rendah. Pindahkan tanaman ke area lebih terang atau tambah lampu tanam.',
      );
    } else if (state.lightLux > plant.lightLuxMax) {
      notes.add(
        'Intensitas cahaya terlalu tinggi. Berikan naungan parsial atau jauhkan dari sumber cahaya langsung.',
      );
    }

    if (notes.isEmpty) {
      return 'Kelembapan tanah dan intensitas cahaya sudah dalam rentang ideal untuk tanaman ini.';
    }

    return notes.join(' ');
  }
}
