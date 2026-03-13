import 'package:equatable/equatable.dart';

/// Virtual currency earned from each safe scan.
///
/// Gamification: users earn SunCoins when they complete a safe scan
/// (UV within limits, protection maintained).
class SunCoin extends Equatable {
  const SunCoin({
    required this.balance,
    required this.totalEarned,
  });

  final int balance;
  final int totalEarned;

  @override
  List<Object> get props => [balance, totalEarned];
}
