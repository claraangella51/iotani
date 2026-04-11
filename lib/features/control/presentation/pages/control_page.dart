import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';
import 'package:iotani_berhasil/features/control/providers/command_provider.dart';
import 'package:iotani_berhasil/shared/widgets/actuator_button.dart';

class ControlPage extends ConsumerStatefulWidget {
  const ControlPage({super.key});

  @override
  ConsumerState<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends ConsumerState<ControlPage> {
  bool _pumpTarget = false;
  bool _uvTarget = false;

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStateProvider);
    final mode = ref.watch(modeStateProvider);
    final commandStatus = ref.watch(commandStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: deviceState.when(
            data: (state) => state == null
                ? const Center(child: Text('Tidak ada data'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Section
                      const Text(
                        'Mode Operasional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Mode Saat Ini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      mode,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mode == 'otomatis'
                                            ? AppTheme.primaryGreen
                                            : AppTheme.dividerColor,
                                      ),
                                      onPressed: () {
                                        ref
                                                .read(
                                                  modeStateProvider.notifier,
                                                )
                                                .state =
                                            'otomatis';
                                      },
                                      child: const Text('Otomatis'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mode == 'manual'
                                            ? AppTheme.primaryGreen
                                            : AppTheme.dividerColor,
                                      ),
                                      onPressed: () {
                                        ref
                                                .read(
                                                  modeStateProvider.notifier,
                                                )
                                                .state =
                                            'manual';
                                      },
                                      child: const Text('Manual'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLime.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      mode == 'otomatis'
                                          ? Icons.info_outline
                                          : Icons.pan_tool,
                                      size: 18,
                                      color: mode == 'otomatis'
                                          ? AppTheme.primaryGreen
                                          : AppTheme.statusWaspada,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        mode == 'otomatis'
                                            ? 'Mode otomatis: Sistem akan mengontrol aktuator secara otomatis berdasarkan sensor.'
                                            : 'Mode manual: Anda dapat mengontrol aktuator secara manual.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Actuator Control (only in manual mode)
                      if (mode == 'manual') ...[
                        const Text(
                          'Kontrol Aktuator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pompa Air',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Status: ${state.pumpStatus ? 'Menyala' : 'Mati'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: state.pumpStatus
                                              ? AppTheme.statusRisikoTinggi
                                              : AppTheme.textMedium,
                                        ),
                                      ),
                                    ),
                                    ActuatorButton(
                                      label: state.pumpStatus
                                          ? 'Matikan'
                                          : 'Nyalakan',
                                      isActive: state.pumpStatus,
                                      onToggle: () {
                                        _pumpTarget = !state.pumpStatus;
                                        _showConfirmDialog(
                                          context,
                                          'Pompa Air',
                                          _pumpTarget
                                              ? 'menyalakan'
                                              : 'mematikan',
                                          () {
                                            _sendPumpCommand(_pumpTarget);
                                          },
                                        );
                                      },
                                      isLoading:
                                          commandStatus.state.name == 'loading',
                                      iconType: 'pump',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lampu UV',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Status: ${state.uvLampStatus ? 'Menyala' : 'Mati'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: state.uvLampStatus
                                              ? Color(0xFFFFB800)
                                              : AppTheme.textMedium,
                                        ),
                                      ),
                                    ),
                                    ActuatorButton(
                                      label: state.uvLampStatus
                                          ? 'Matikan'
                                          : 'Nyalakan',
                                      isActive: state.uvLampStatus,
                                      onToggle: () {
                                        _uvTarget = !state.uvLampStatus;
                                        _showConfirmDialog(
                                          context,
                                          'Lampu UV',
                                          _uvTarget
                                              ? 'menyalakan'
                                              : 'mematikan',
                                          () {
                                            _sendUVCommand(_uvTarget);
                                          },
                                        );
                                      },
                                      isLoading:
                                          commandStatus.state.name == 'loading',
                                      iconType: 'uv',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Card(
                          color: AppTheme.accentLime.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Mode Otomatis Aktif',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Ubah ke mode Manual untuk mengontrol aktuator secara manual.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Command Status
                      if (commandStatus.message != null)
                        Card(
                          color: commandStatus.state.name == 'success'
                              ? AppTheme.statusAman.withOpacity(0.1)
                              : AppTheme.statusRisikoTinggi.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  commandStatus.state.name == 'success'
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: commandStatus.state.name == 'success'
                                      ? AppTheme.statusAman
                                      : AppTheme.statusRisikoTinggi,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    commandStatus.message!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          commandStatus.state.name == 'success'
                                          ? AppTheme.statusAman
                                          : AppTheme.statusRisikoTinggi,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  void _showConfirmDialog(
    BuildContext context,
    String actuator,
    String action,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi $action $actuator'),
        content: Text('Anda yakin ingin $action $actuator?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _sendPumpCommand(bool value) {
    // Send pump command
  }

  void _sendUVCommand(bool value) {
    // Send UV command
  }
}
