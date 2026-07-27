import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(ref.watch(connectivityProvider)),
);

/// Real-time internet reachability (interface change + DNS-verified).
/// Drives [ConnectivityBanner] and anything else that needs to react to
/// connectivity changes live.
final connectivityStreamProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).onConnectivityChanged,
);
