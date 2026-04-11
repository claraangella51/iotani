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

final commandStatusProvider = StateProvider<CommandStatus>((ref) {
  return CommandStatus(state: CommandState.idle);
});

final modeStateProvider = StateProvider<String>((ref) {
  return 'otomatis'; // Default mode
});

final pumpCommandProvider = FutureProvider<void>((ref) async {
  ref.read(commandStatusProvider.notifier).state = CommandStatus(
    state: CommandState.loading,
  );

  try {
    // Simulate command execution
    await Future.delayed(const Duration(seconds: 1));
    ref.read(commandStatusProvider.notifier).state = CommandStatus(
      state: CommandState.success,
      message: 'Perintah pompa berhasil dikirim',
      timestamp: DateTime.now(),
    );
  } catch (e) {
    ref.read(commandStatusProvider.notifier).state = CommandStatus(
      state: CommandState.error,
      message: 'Gagal mengirim perintah: $e',
    );
  }
});

final uvLampCommandProvider = FutureProvider<void>((ref) async {
  ref.read(commandStatusProvider.notifier).state = CommandStatus(
    state: CommandState.loading,
  );

  try {
    // Simulate command execution
    await Future.delayed(const Duration(seconds: 1));
    ref.read(commandStatusProvider.notifier).state = CommandStatus(
      state: CommandState.success,
      message: 'Perintah lampu UV berhasil dikirim',
      timestamp: DateTime.now(),
    );
  } catch (e) {
    ref.read(commandStatusProvider.notifier).state = CommandStatus(
      state: CommandState.error,
      message: 'Gagal mengirim perintah: $e',
    );
  }
});
