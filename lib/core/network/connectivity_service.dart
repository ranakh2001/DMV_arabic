import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks real internet reachability, not just that a network interface is
/// up — WiFi/mobile data can report "connected" with no actual route to the
/// internet (captive portals, router with no WAN link, etc.), which is what
/// produces a raw "Failed host lookup" from Dio instead of a clean failure.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  // Probed in parallel — if usaarabdrivers.com's own DNS has a transient
  // hiccup (its resolver, not the user's connection), google.com still
  // resolves and we correctly report "connected" instead of a false
  // "no internet" on an otherwise healthy network.
  static const _probeHosts = ['usaarabdrivers.com', 'google.com'];
  static const _probeTimeout = Duration(seconds: 5);

  /// True only if there's a network interface up AND it can actually reach
  /// the internet.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    return _hasInternetAccess();
  }

  /// Emits the current reachability on every interface-level change
  /// (WiFi ↔ mobile ↔ none), re-verified against a real DNS lookup.
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.asyncMap((results) async {
        if (results.every((r) => r == ConnectivityResult.none)) return false;
        return _hasInternetAccess();
      });

  /// True if ANY probe host resolves — races all hosts concurrently so a
  /// single flaky lookup can't dominate the result or the latency.
  Future<bool> _hasInternetAccess() async {
    final results = await Future.wait(_probeHosts.map(_probe));
    return results.any((ok) => ok);
  }

  Future<bool> _probe(String host) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(_probeTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
