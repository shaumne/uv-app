import 'package:equatable/equatable.dart';

/// Immutable domain entity representing the user's dermatological profile.
///
/// [fitzpatrickType] ranges 1–6 (Fitzpatrick scale).
/// [spf] is the sunscreen protection factor currently applied (1 = no sunscreen).
class SkinProfile extends Equatable {
  const SkinProfile({
    required this.fitzpatrickType,
    required this.spf,
  })  : assert(fitzpatrickType >= 1 && fitzpatrickType <= 6, 'Fitzpatrick type must be 1-6'),
        assert(spf >= 1, 'SPF must be at least 1 (no sunscreen)');

  final int fitzpatrickType;
  final int spf;

  SkinProfile copyWith({int? fitzpatrickType, int? spf}) => SkinProfile(
        fitzpatrickType: fitzpatrickType ?? this.fitzpatrickType,
        spf: spf ?? this.spf,
      );

  @override
  List<Object> get props => [fitzpatrickType, spf];
}
