import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/skin_profile.dart';
import 'onboarding_provider.dart';

/// Reads the persisted [SkinProfile] from SharedPreferences.
///
/// Returns a default (Type II, SPF 30) profile if nothing is stored yet,
/// so downstream providers always have a valid non-null value to work with.
final storedSkinProfileProvider = FutureProvider<SkinProfile>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final repo = ref.watch(skinProfileRepositoryProvider);
  final result = await repo.load();
  return result.fold(
    (_) => const SkinProfile(fitzpatrickType: 2, spf: 30),
    (profile) => profile,
  );
});
