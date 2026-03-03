import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_info.dart';

/// [NetworkInfo] implementation backed by [connectivity_plus].
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._connectivity);
  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (r) => r != ConnectivityResult.none,
    );
  }
}
