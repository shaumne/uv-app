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
    ref.watch(sharedPreferencesProvider).requireValue,
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
      appLogger.e('[HomeProvider] Location error', error: e);
      state = state.copyWith(
        isLoadingUv: false,
        uvFailure: LocationFailure(e.toString()),
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

  /// Requests location permission and returns the current device position.
  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
  }
}

final homeNotifierProvider =
    StateNotifierProvider.autoDispose<HomeNotifier, HomeState>((ref) {
  // Read cached Fitzpatrick type from SharedPreferences
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (p) => p,
        orElse: () => null,
      );

  int fitzpatrickType = 2;
  if (prefs != null) {
    final raw = prefs.getString('skin_profile');
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        fitzpatrickType = (map['fitzpatrick_type'] as int?) ?? 2;
      } catch (_) {}
    }
  }

  final notifier = HomeNotifier(
    getUvIndex: ref.watch(getUvIndexUseCaseProvider),
    getDoseSummary: ref.watch(getDailyDoseSummaryProvider),
    fitzpatrickType: fitzpatrickType,
  );
  notifier.loadAll();
  return notifier;
});
