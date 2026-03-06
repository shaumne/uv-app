import '../../domain/entities/skin_profile.dart';

/// JSON-serialisable model for [SkinProfile].
///
/// Stored as a flat JSON object in SharedPreferences under key 'skin_profile'.
/// [spfAppliedAt] is stored as an ISO-8601 string and is nullable.
class SkinProfileModel {
  const SkinProfileModel({
    required this.fitzpatrickType,
    required this.spf,
    this.spfAppliedAt,
  });

  final int fitzpatrickType;
  final int spf;
  final DateTime? spfAppliedAt;

  factory SkinProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? appliedAt;
    final raw = json['spf_applied_at'];
    if (raw != null) {
      try {
        appliedAt = DateTime.parse(raw as String);
      } catch (_) {}
    }
    return SkinProfileModel(
      fitzpatrickType: json['fitzpatrick_type'] as int,
      spf: json['spf'] as int,
      spfAppliedAt: appliedAt,
    );
  }

  factory SkinProfileModel.fromEntity(SkinProfile entity) => SkinProfileModel(
        fitzpatrickType: entity.fitzpatrickType,
        spf: entity.spf,
        spfAppliedAt: entity.spfAppliedAt,
      );

  Map<String, dynamic> toJson() => {
        'fitzpatrick_type': fitzpatrickType,
        'spf': spf,
        'spf_applied_at': spfAppliedAt?.toIso8601String(),
      };

  SkinProfile toEntity() => SkinProfile(
        fitzpatrickType: fitzpatrickType,
        spf: spf,
        spfAppliedAt: spfAppliedAt,
      );
}
