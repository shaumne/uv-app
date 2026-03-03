/// Contract for checking device internet connectivity.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}
