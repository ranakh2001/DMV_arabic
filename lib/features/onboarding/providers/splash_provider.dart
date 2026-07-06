import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True once the splash animation has fully played through.
/// Resets to false on each cold start (not persisted).
final splashDoneProvider = StateProvider<bool>((ref) => false);
