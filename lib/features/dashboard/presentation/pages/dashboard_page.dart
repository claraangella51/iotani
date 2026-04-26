import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotani_berhasil/core/firebase/firebase_service.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';
import 'package:iotani_berhasil/features/dashboard/providers/active_plant_provider.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';
import 'package:iotani_berhasil/shared/widgets/metric_card.dart';
import 'package:iotani_berhasil/shared/widgets/plant_selector_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlant = ref.watch(activePlantProvider);
    final deviceState = ref.watch(deviceStateProvider);
    final plants = ref.watch(plantListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/device-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Plant Card
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanaman Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getPlantIcon(activePlant.category),
                            size: 32,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activePlant.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  activePlant.category,
                                  style: const TextStyle(
                                    fontSize: 12,
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
              const SizedBox(height: 24),

              // Plant Selector
              plants.when(
                data: (loadedPlants) => PlantSelectorWidget(
                  activePlant: activePlant,
                  plants: loadedPlants,
                  onPlantChanged: (plant) {
                    ref.read(activePlantProvider.notifier).state = plant;
                    // Keep auto-control threshold/fuzzy aligned with selected plant.
                    FirebaseService().setAutoPlantProfile(plant);
                  },
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Memuat daftar tanaman...'),
                      ],
                    ),
                  ),
                ),
                error: (_, __) => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Gagal memuat daftar tanaman dari shared catalog.',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Status Overview
              deviceState.when(
                data: (state) => state == null
                    ? _buildEmptyDeviceState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Ringkas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              MetricCard(
                                label: 'Kelembaban Tanah',
                                value: '${state.soilMoisture}',
                                unit: '%',
                                icon: Icons.water_drop,
                                iconColor: AppTheme.secondaryMint,
                              ),
                              MetricCard(
                                label: 'Intensitas Cahaya',
                                value: '${state.lightLux}',
                                unit: 'lux',
                                icon: Icons.light_mode,
                                iconColor: AppTheme.accentLime,
                              ),
                              MetricCard(
                                label: 'Status Tanah',
                                value: DeviceState.getSoilStatusText(
                                  state.soilMoisture,
                                  activePlant.soilMoistureMin,
                                  activePlant.soilMoistureMax,
                                ),
                                icon: Icons.local_florist,
                                iconColor: AppTheme.primaryGreen,
                                valueFontSize: 16,
                                valueMaxLines: 2,
                              ),
                              MetricCard(
                                label: 'Status Cahaya',
                                value: DeviceState.getLightStatusText(
                                  state.lightLux,
                                  activePlant.lightLuxMin,
                                  activePlant.lightLuxMax,
                                ),
                                icon: Icons.sunny,
                                iconColor: Color(0xFFFFB800),
                                valueFontSize: 16,
                                valueMaxLines: 2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildActuatorStatusSection(state),
                        ],
                      ),
                loading: () => _buildLoadingDeviceState(),
                error: (_, __) => _buildDeviceStateError(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDeviceState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Menghubungkan data perangkat...',
                style: TextStyle(color: AppTheme.textMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDeviceState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Perangkat belum mengirim data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Akun Anda sudah berhasil masuk. Hubungkan perangkat atau kirim data sensor pertama agar ringkasan beranda muncul di sini.',
              style: TextStyle(color: AppTheme.textMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStateError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Data perangkat belum bisa dimuat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cek koneksi Firebase atau pastikan data `iotani/status` tersedia di Realtime Database.',
              style: TextStyle(color: AppTheme.textMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActuatorStatusSection(DeviceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Aktuator',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: state.pumpStatus
                            ? AppTheme.statusRisikoTinggi
                            : AppTheme.textLight,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text('Pompa Air', style: TextStyle(fontSize: 12)),
                      Text(
                        state.pumpStatus ? 'Menyala' : 'Mati',
                        style: TextStyle(
                          fontSize: 11,
                          color: state.pumpStatus
                              ? AppTheme.statusRisikoTinggi
                              : AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: state.uvLampStatus
                            ? Color(0xFFFFB800)
                            : AppTheme.textLight,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text('Lampu UV', style: TextStyle(fontSize: 12)),
                      Text(
                        state.uvLampStatus ? 'Menyala' : 'Mati',
                        style: TextStyle(
                          fontSize: 11,
                          color: state.uvLampStatus
                              ? Color(0xFFFFB800)
                              : AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Diperbarui: ${state.lastUpdated.hour}:${state.lastUpdated.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
      ],
    );
  }

  IconData _getPlantIcon(String category) {
    switch (category) {
      case 'Buah':
        return Icons.favorite;
      case 'Sayur':
        return Icons.eco;
      case 'Hias':
        return Icons.local_florist;
      default:
        return Icons.nature;
    }
  }
}
