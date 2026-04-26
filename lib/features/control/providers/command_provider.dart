import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CommandState { idle, loading, success, error }

class CommandStatus {
  final CommandState state;
  final String? message;
  final DateTime? timestamp;

  CommandStatus({required this.state, this.message, this.timestamp});

  CommandStatus copyWith({
    CommandState? state,
    String? message,
    DateTime? timestamp,
  }) {
    return CommandStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class CommandController extends StateNotifier<CommandStatus> {
  CommandController() : super(CommandStatus(state: CommandState.idle));

  final db = FirebaseDatabase.instance.ref();

  // =========================
  // MODE
  // =========================
  Future<void> setMode(String mode) async {
    try {
      state = CommandStatus(state: CommandState.loading);

      final normalizedMode = mode == 'manual' ? 'manual' : 'auto';
      final modeLabel = normalizedMode == 'manual' ? 'manual' : 'otomatis';

      await db.update({
        'iotani/control/mode': normalizedMode,
        'iotani/status/mode': normalizedMode,
      });

      state = CommandStatus(
        state: CommandState.success,
        message: "Mode $modeLabel aktif",
        timestamp: DateTime.now(),
      );
    } catch (e) {
      state = CommandStatus(
        state: CommandState.error,
        message: "Gagal set mode: $e",
      );
    }
  }

  // =========================
  // POMPA
  // =========================
  Future<void> setPump(bool value) async {
    try {
      state = CommandStatus(state: CommandState.loading);

      final command = value ? 'ON' : 'OFF';
      final modeSnapshot = await db.child('iotani/control/mode').get();
      final mode = (modeSnapshot.value as String?) ?? 'auto';

      final updates = <String, Object?>{'iotani/manual/pompa': command};

      // Device firmware reads control node directly, so mirror manual command.
      if (mode == 'manual') {
        updates['iotani/control/pompa'] = command;
        updates['iotani/status/pompa'] = command;
      }

      await db.update(updates);

      state = CommandStatus(
        state: CommandState.success,
        message: 'Pompa $command',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      state = CommandStatus(
        state: CommandState.error,
        message: "Gagal kontrol pompa: $e",
      );
    }
  }

  // =========================
  // LAMPU
  // =========================
  Future<void> setUvLamp(bool value) async {
    try {
      state = CommandStatus(state: CommandState.loading);

      final command = value ? 'ON' : 'OFF';
      final modeSnapshot = await db.child('iotani/control/mode').get();
      final mode = (modeSnapshot.value as String?) ?? 'auto';

      final updates = <String, Object?>{'iotani/manual/lampu': command};

      // Device firmware reads control node directly, so mirror manual command.
      if (mode == 'manual') {
        updates['iotani/control/lampu'] = command;
        updates['iotani/status/lampu'] = command;
      }

      await db.update(updates);

      state = CommandStatus(
        state: CommandState.success,
        message: 'Lampu $command',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      state = CommandStatus(
        state: CommandState.error,
        message: "Gagal kontrol lampu: $e",
      );
    }
  }
}

final commandStatusProvider =
    StateNotifierProvider<CommandController, CommandStatus>((ref) {
      return CommandController();
    });
