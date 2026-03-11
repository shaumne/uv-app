import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/network_info_impl.dart';
import '../../core/services/ambient_light_service.dart';
import '../../core/services/permission_service.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

/// Secure storage for sensitive data (skin profile, dose history).
/// Uses iOS Keychain / Android Keystore.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final ambientLightServiceProvider = Provider<AmbientLightService>(
  (_) => AmbientLightService(),
);

final permissionServiceProvider = Provider<PermissionService>(
  (_) => const PermissionService(),
);

final connectivityProvider = Provider<Connectivity>(
  (_) => Connectivity(),
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

final dioProvider = Provider(
  (_) => ApiClient.instance.dio,
);

// ── Feature providers are co-located with their features ─────────────────────
// See: lib/features/<feature>/presentation/providers/
