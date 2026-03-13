import 'package:equatable/equatable.dart';

/// Invisible Shield badge — state-based achievement.
///
/// Example: "Desert Warrior" for completing UV 8+ day safely.
class AchievementBadge extends Equatable {
  const AchievementBadge({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconKey,
    this.unlockedAt,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconKey;

  /// Null = not yet unlocked.
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  @override
  List<Object?> get props => [id, nameKey, descriptionKey, iconKey, unlockedAt];
}
