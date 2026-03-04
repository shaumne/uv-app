import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/datasources/dose_history_local_datasource.dart';
import '../../data/datasources/uv_index_remote_datasource.dart';
import '../../data/repositories/dose_history_repository_impl.dart';
import '../../data/repositories/uv_index_repository_impl.dart';
import '../../domain/entities/daily_dose_summary.dart';
import '../../domain/entities/uv_index.dart';
import '../../domain/usecases/get_current_uv_index.dart';
import '../../domain/usecases/get_daily_dose_summary.dart';

// ── Infrastructure providers ─────────────────────────────────────────────────

final uvIndexRemoteDatasourceProvider = Provider<UvIndexRemoteDatasource>(
  (ref) => UvIndexRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final doseHistoryLocalDatasourceProvider = Provider<DoseHistoryLocalDatasource>(
  (ref) => DoseHistoryLocalDatasourceImpl(
    ref.watch(sharedPreferencesProvider),
  ),
);

final uvIndexRepositoryProvider = Provider(
  (ref) => UvIndexRepositoryImpl(
    remoteDatasource: ref.watch(uvIndexRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final doseHistoryRepositoryProvider = Provider(
  (ref) => DoseHistoryRepositoryImpl(ref.watch(doseHistoryLocalDatasourceProvider)),
);

final getUvIndexUseCaseProvider = Provider(
  (ref) => GetCurrentUvIndex(ref.watch(uvIndexRepositoryProvider)),
);

final getDailyDoseSummaryProvider = Provider(
  (ref) => GetDailyDoseSummary(ref.watch(doseHistoryRepositoryProvider)),
);

// ── State ─────────────────────────────────────────────────────────────────────

class HomeState {
  const HomeState({
    this.uvIndex,
    this.doseSummary,
    this.isLoadingUv = false,
    this.isLoadingDose = false,
    this.uvFailure,
    this.doseFailure,
  });

  final UvIndex? uvIndex;
  final DailyDoseSummary? doseSummary;
  final bool isLoadingUv;
  final bool isLoadingDose;
  final Failure? uvFailure;
  final Failure? doseFailure;

  bool get isLoading => isLoadingUv || isLoadingDose;

  HomeState copyWith({
    UvIndex? uvIndex,
    DailyDoseSummary? doseSummary,
    bool? isLoadingUv,
    bool? isLoadingDose,
    Failure? uvFailure,
    Failure? doseFailure,
  }) =>
      HomeState(
        uvIndex: uvIndex ?? this.uvIndex,
        doseSummary: doseSummary ?? this.doseSummary,
        isLoadingUv: isLoadingUv ?? this.isLoadingUv,
        isLoadingDose: isLoadingDose ?? this.isLoadingDose,
        uvFailure: uvFailure,
        doseFailure: doseFailure,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier({
    required this.getUvIndex,
    required this.getDoseSummary,
    required this.fitzpatrickType,
  }) : super(const HomeState());

  final GetCurrentUvIndex getUvIndex;
  final GetDailyDoseSummary getDoseSummary;
  final int fitzpatrickType;

  /// Loads UV index and daily dose summary in parallel.
  Future<void> loadAll() async {
    await Future.wait([_loadUvIndex(), _loadDoseSummary()]);
  }

  Future<void> _loadUvIndex() async {
    state = state.copyWith(isLoadingUv: true);
    try {
      final position = await _determinePosition();
      final result = await getUvIndex(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      result.fold(
        (failure) {
          appLogger.w('[HomeProvider] UV index failure: ${failure.message}');
          state = state.copyWith(isLoadingUv: false, uvFailure: failure);
        },
        (uvIndex) =>
            state = state.copyWith(isLoadingUv: false, uvIndex: uvIndex),
      );
    } catch (e) {
      appLogger.w('[HomeProvider] Location unavailable: $e');
      state = state.copyWith(
        isLoadingUv: false,
        uvFailure: LocationFailure(_friendlyLocationError(e.toString())),
      );
    }
  }

  Future<void> _loadDoseSummary() async {
    state = state.copyWith(isLoadingDose: true);
    final result = await getDoseSummary(fitzpatrickType);
    result.fold(
      (f) => state = state.copyWith(isLoadingDose: false, doseFailure: f),
      (s) => state = state.copyWith(isLoadingDose: false, doseSummary: s),
    );
  }

  /// Requests location permission and returns the best available position.
  ///
  /// Strategy:
  /// 1. Check/request permission — fail fast if permanently denied.
  /// 2. Use last-known position immediately if < 30 minutes old (no GPS wait).
  /// 3. Fall back to getCurrentPosition with 20-second timeout at lowest
  ///    accuracy for the fastest possible satellite fix.
  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('location_service_disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('location_permission_denied_forever');
    }
    if (permission == LocationPermission.denied) {
      throw Exception('location_permission_denied');
    }

    // Fast path: last-known position if it is recent (< 30 minutes).
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final age = DateTime.now().difference(last.timestamp);
        if (age.inMinutes < 30) {
          appLogger.d(
            '[HomeProvider] Using last-known position (age=${age.inMinutes}m)',
          );
          return last;
        }
      }
    } catch (_) {
      // getLastKnownPosition can throw on some devices — fall through.
    }

    // Slow path: fresh GPS fix with generous timeout.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  String _friendlyLocationError(String raw) {
    if (raw.contains('location_service_disabled')) {
      return 'Location services are off.';
    }
    if (raw.contains('denied_forever')) {
      return 'Location permission denied. Enable in device Settings.';
    }
    if (raw.contains('permission_denied')) {
      return 'Location permission required for UV index.';
    }
    if (raw.contains('TimeoutException')) {
      return 'Location timed out. UV index unavailable.';
    }
    return 'Location unavailable.';
  }
}

final homeNotifierProvider =
    StateNotifierProvider.autoDispose<HomeNotifier, HomeState>((ref) {
  // Read cached Fitzpatrick type from SharedPreferences (pre-initialised).
  final prefs = ref.watch(sharedPreferencesProvider);

  int fitzpatrickType = 2;
  final raw = prefs.getString('skin_profile');
  if (raw != null) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      fitzpatrickType = (map['fitzpatrick_type'] as int?) ?? 2;
    } catch (_) {}
  }

  final notifier = HomeNotifier(
    getUvIndex: ref.watch(getUvIndexUseCaseProvider),
    getDoseSummary: ref.watch(getDailyDoseSummaryProvider),
    fitzpatrickType: fitzpatrickType,
  );
  notifier.loadAll();
  return notifier;
});
