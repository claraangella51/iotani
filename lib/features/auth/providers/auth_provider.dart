import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iotani_berhasil/core/firebase/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final authStateProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.getCurrentUser();
});

// Auth actions
final signUpProvider = FutureProvider.family<void, (String, String)>((
  ref,
  args,
) async {
  final service = ref.watch(firebaseServiceProvider);
  final (email, password) = args;
  await service.signUp(email: email, password: password);
});

final signInProvider = FutureProvider.family<void, (String, String)>((
  ref,
  args,
) async {
  final service = ref.watch(firebaseServiceProvider);
  final (email, password) = args;
  await service.signIn(email: email, password: password);
});

final signOutProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(firebaseServiceProvider);
  await service.signOut();
});
