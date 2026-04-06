import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/auth_repository.dart';
import 'package:telme/services/notification_service.dart';
import 'package:telme/services/shift_repository.dart';
import 'package:telme/services/shift_sync_service.dart';
import 'package:telme/models/profile_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final shiftRepositoryProvider = Provider((ref) => ShiftRepository());
final notificationServiceProvider =
    Provider((ref) => NotificationService.instance);
final shiftSyncServiceProvider = Provider(
  (ref) => ShiftSyncService(
    shiftRepository: ref.read(shiftRepositoryProvider),
    notificationService: ref.read(notificationServiceProvider),
  ),
);

final allEmployeesProvider = FutureProvider<List<Profile>>((ref) async {
  return ref.read(authRepositoryProvider).getAllProfiles();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  final user =
      authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getProfile(user.id);
});

final myShiftsProvider = StreamProvider<List<Shift>>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(shiftRepositoryProvider).myShiftsStream(user.id);
});

final adminShiftsProvider = StreamProvider<List<Shift>>((ref) {
  return ref.watch(shiftRepositoryProvider).shiftsStream;
});

final userLogsProvider = StreamProvider<List<ShiftLog>>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(shiftRepositoryProvider).userLogsStream(user.id);
});
