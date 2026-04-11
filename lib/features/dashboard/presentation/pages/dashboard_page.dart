import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';
import 'package:iotani_berhasil/features/dashboard/providers/active_plant_provider.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';
import 'package:iotani_berhasil/shared/widgets/metric_card.dart';
import 'package:iotani_berhasil/shared/widgets/plant_selector_widget.dart';
import 'package:iotani_berhasil/shared/widgets/status_badge.dart';

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
              PlantSelectorWidget(
                activePlant: activePlant,
                plants: plants,
                onPlantChanged: (plant) {
                  ref.read(activePlantProvider.notifier).state = plant;
                },
              ),
              const SizedBox(height: 28),

              // Status Overview
              deviceState.when(
                data: (state) => state == null
                    ? const SizedBox.shrink()
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
                                value: 'Ideal',
                                icon: Icons.local_florist,
                                iconColor: AppTheme.primaryGreen,
                              ),
                              MetricCard(
                                label: 'Status Cahaya',
                                value: 'Ideal',
                                icon: Icons.sunny,
                                iconColor: Color(0xFFFFB800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatusSection(state, activePlant),
                          const SizedBox(height: 16),
                          _buildRecommendationSection(state, activePlant),
                          const SizedBox(height: 16),
                          _buildActuatorStatusSection(state),
                        ],
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(DeviceState state, PlantProfile plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Risiko',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            RiskStatusBadge(status: state.riskStatus, large: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.riskStatus.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(DeviceState state, PlantProfile plant) {
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
