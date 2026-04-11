import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';
import 'package:iotani_berhasil/features/dashboard/providers/active_plant_provider.dart';

class DeviceProfilePage extends ConsumerWidget {
  const DeviceProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlant = ref.watch(activePlantProvider);
    final deviceId = ref.watch(deviceIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Perangkat'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Information
              const Text(
                'Informasi Perangkat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('ID Perangkat', deviceId),
                      const SizedBox(height: 12),
                      _buildInfoRow('Status', 'Terhubung'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Versi Firmware', '1.0.0'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Terakhir Diperbarui', 'Baru saja'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Active Plant Information
              const Text(
                'Tanaman Aktif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Rentang Ideal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Kelembaban Tanah',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ),
                          Text(
                            '${activePlant.soilMoistureMin}-${activePlant.soilMoistureMax}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Intensitas Cahaya',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ),
                          Text(
                            '${activePlant.lightLuxMin}-${activePlant.lightLuxMax} lux',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Threshold Settings
              const Text(
                'Pengaturan Ambang Batas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            color: AppTheme.statusWaspada,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Risiko Tinggi: Kelembaban > 80% AND Cahaya < 300 lux',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Catatan: Ambang batas ini dapat disesuaikan melalui aplikasi web admin.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Actions
              const Text(
                'Aksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusRisikoTinggi,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMedium),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
