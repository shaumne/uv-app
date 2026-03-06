import 'package:equatable/equatable.dart';

/// Immutable domain entity representing the user's dermatological profile.
///
/// [fitzpatrickType] ranges 1–6 (Fitzpatrick scale).
/// [spf] is the sunscreen protection factor currently applied (1 = no sunscreen).
/// [spfAppliedAt] is the timestamp when sunscreen was last applied, used by the
/// bi-exponential SPF decay model (Dermatology_Math_Engine skill).
/// Null means the user has not applied sunscreen or has not recorded the time.
class SkinProfile extends Equatable {
  const SkinProfile({
    required this.fitzpatrickType,
    required this.spf,
    this.spfAppliedAt,
  })  : assert(fitzpatrickType >= 1 && fitzpatrickType <= 6, 'Fitzpatrick type must be 1-6'),
        assert(spf >= 1, 'SPF must be at least 1 (no sunscreen)');

  final int fitzpatrickType;
  final int spf;

  /// Timestamp of last sunscreen application. Null if not recorded or no sunscreen used.
  final DateTime? spfAppliedAt;

  /// Hours elapsed since sunscreen was applied. 0.0 if no application time recorded.
  double get hoursSinceApplication {
    if (spfAppliedAt == null) return 0.0;
    final elapsed = DateTime.now().difference(spfAppliedAt!);
    return elapsed.inSeconds / 3600.0;
  }

  SkinProfile copyWith({int? fitzpatrickType, int? spf, DateTime? spfAppliedAt, bool clearSpfTime = false}) =>
      SkinProfile(
        fitzpatrickType: fitzpatrickType ?? this.fitzpatrickType,
        spf: spf ?? this.spf,
        spfAppliedAt: clearSpfTime ? null : (spfAppliedAt ?? this.spfAppliedAt),
      );

  @override
  List<Object?> get props => [fitzpatrickType, spf, spfAppliedAt];
}
