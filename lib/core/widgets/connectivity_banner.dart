import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_providers.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/glass.dart';

/// Wraps [child] with a persistent top banner that appears whenever real
/// internet reachability is lost and auto-dismisses the moment it returns.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Defaults to "online" while the first connectivity event hasn't
    // arrived yet, so the banner never flashes on app startup.
    final isOffline = ref.watch(connectivityStreamProvider).maybeWhen(
          data: (online) => !online,
          orElse: () => false,
        );

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(12), vertical: context.sp(8)),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                offset: isOffline ? Offset.zero : const Offset(0, -2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isOffline ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !isOffline,
                    child: const _OfflineBanner(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 14,
      tint: context.appError,
      opacity: 0.18,
      border: context.appError.withAlpha(140),
      padding: EdgeInsets.symmetric(horizontal: context.sp(14), vertical: context.sp(10)),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: context.sp(18), color: context.appError),
            SizedBox(width: context.sp(10)),
            Flexible(
              child: Text(
                'لا يوجد اتصال بالإنترنت، الرجاء التحقق من الشبكة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  color: context.appError,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
