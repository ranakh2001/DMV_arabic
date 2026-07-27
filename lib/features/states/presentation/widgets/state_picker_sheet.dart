import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass_effect_theme.dart';
import '../../domain/entities/us_state.dart';
import '../providers/states_providers.dart';

/// Opens the shared [StatePickerSheet] as a modal bottom sheet.
/// Used by both the register screen and onboarding's state-selection step.
Future<void> showStatePickerSheet(
  BuildContext context, {
  required int? currentStateId,
  required ValueChanged<UsState> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatePickerSheet(currentStateId: currentStateId, onSelected: onSelected),
  );
}

/// Searchable list of US states backed by `GET /states` (via [statesProvider]).
class StatePickerSheet extends ConsumerStatefulWidget {
  const StatePickerSheet({super.key, required this.currentStateId, required this.onSelected});

  final int? currentStateId;
  final ValueChanged<UsState> onSelected;

  @override
  ConsumerState<StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends ConsumerState<StatePickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UsState> _filter(List<UsState> states) {
    if (_query.isEmpty) return states;
    final lower = _query.toLowerCase();
    return states
        .where((s) => s.nameEn.toLowerCase().contains(lower) || s.nameAr.contains(_query) || s.abbreviation.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;
    final textColor = context.appTextPrimary;
    final dividerColor = context.appGlassBorder;
    final accent = context.appPrimary;
    final statesAsync = ref.watch(statesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) {
        final glassTheme = Theme.of(context).extension<GlassEffectTheme>()!;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: glassTheme.blur, sigmaY: glassTheme.blur),
            child: Container(
              decoration: BoxDecoration(
                color: context.appSurface.withAlpha(235),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: accent.withAlpha(60)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: accent.withAlpha(120), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(fontFamily: 'Almarai', color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: isAr ? 'ابحث...' : 'Search...',
                        prefixIcon: Icon(Icons.search_rounded, color: accent),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: dividerColor, height: 1),
                  Expanded(
                    child: statesAsync.when(
                      data: (states) => _StateList(
                        states: _filter(states),
                        isAr: isAr,
                        currentStateId: widget.currentStateId,
                        scrollController: scrollCtrl,
                        onSelected: widget.onSelected,
                      ),
                      loading: () => Center(child: CircularProgressIndicator(color: accent)),
                      error: (error, _) => _StateListError(isAr: isAr, onRetry: () => ref.invalidate(statesProvider)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StateList extends StatelessWidget {
  const _StateList({
    required this.states,
    required this.isAr,
    required this.currentStateId,
    required this.scrollController,
    required this.onSelected,
  });

  final List<UsState> states;
  final bool isAr;
  final int? currentStateId;
  final ScrollController scrollController;
  final ValueChanged<UsState> onSelected;

  @override
  Widget build(BuildContext context) {
    if (states.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد نتائج' : 'No results',
          style: TextStyle(fontFamily: 'Almarai', color: context.appTextSecondary),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: states.length,
      itemBuilder: (context, i) {
        final state = states[i];
        final isSelected = currentStateId == state.id;
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            onSelected(state);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
              color: isSelected ? context.appPrimary.withAlpha(30) : Colors.transparent,
              border: Border(bottom: BorderSide(color: context.appGlassBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.name(arabic: isAr),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? context.appPrimary : context.appTextPrimary,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check_rounded, color: context.appPrimary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StateListError extends StatelessWidget {
  const _StateListError({required this.isAr, required this.onRetry});

  final bool isAr;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAr ? 'تعذر جلب قائمة الولايات.' : 'Failed to load states.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Almarai', color: context.appTextSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
          ],
        ),
      ),
    );
  }
}
