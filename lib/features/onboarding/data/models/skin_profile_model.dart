import '../../domain/entities/skin_profile.dart';

/// JSON-serialisable model for [SkinProfile].
///
/// Stored as a flat JSON object in SharedPreferences under key 'skin_profile'.
class SkinProfileModel {
  const SkinProfileModel({
    required this.fitzpatrickType,
    required this.spf,
  });

  final int fitzpatrickType;
  final int spf;

  factory SkinProfileModel.fromJson(Map<String, dynamic> json) =>
      SkinProfileModel(
        fitzpatrickType: json['fitzpatrick_type'] as int,
        spf: json['spf'] as int,
      );

  factory SkinProfileModel.fromEntity(SkinProfile entity) =>
      SkinProfileModel(fitzpatrickType: entity.fitzpatrickType, spf: entity.spf);

  Map<String, dynamic> toJson() => {
        'fitzpatrick_type': fitzpatrickType,
        'spf': spf,
      };

  SkinProfile toEntity() =>
      SkinProfile(fitzpatrickType: fitzpatrickType, spf: spf);
}
