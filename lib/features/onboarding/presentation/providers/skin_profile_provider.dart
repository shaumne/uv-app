import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/skin_profile.dart';
import 'onboarding_provider.dart';

/// Reads the persisted [SkinProfile] from local storage via the repository.
///
/// Returns a fallback (Type II, SPF 30) if nothing is stored yet,
/// so downstream providers always receive a valid non-null profile.
final storedSkinProfileProvider = FutureProvider<SkinProfile>((ref) async {
  final repo = ref.watch(skinProfileRepositoryProvider);
  final result = await repo.load();
  return result.fold(
    (_) => const SkinProfile(fitzpatrickType: 2, spf: 30),
    (profile) => profile,
  );
});
