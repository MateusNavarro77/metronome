import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../metronome/view_models/metronome_view_model.dart';
import '../../metronome/views/metronome_view.dart';
import '../../preferences/views/preferences_view.dart';
import '../../presets/views/presets_view.dart';
import '../../setlists/views/setlists_view.dart';

/// Top-level adaptive navigation shell providing responsive layout switching
/// between [M3EToolbar.floating] (portrait) and [M3ENavigationRail] (landscape / wide screen),
/// retaining page state via [IndexedStack] with smooth animated transitions and
/// exposing a persistent Play/Stop FAB across every destination.
class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    super.key,
    required this.metronomeViewModel,
    this.initialIndex = 0,
  });

  final MetronomeViewModel metronomeViewModel;
  final int initialIndex;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _transitionController.value = 1.0;
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    _transitionController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = orientation == Orientation.landscape;
        final isWide = constraints.maxWidth > 600;
        final useRail = isLandscape || isWide;

        final l10n = context.l10n;
        final destinations = [
          _NavigationItem(
            index: 0,
            label: l10n.navMetronome,
            icon: Icons.speed_outlined,
            selectedIcon: Icons.speed,
            railKey: const Key('rail_destination_metronome'),
          ),
          _NavigationItem(
            index: 1,
            label: l10n.navPresets,
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune_rounded,
            railKey: const Key('rail_destination_presets'),
          ),
          _NavigationItem(
            index: 2,
            label: l10n.navSetlists,
            icon: Icons.queue_music_outlined,
            selectedIcon: Icons.queue_music_rounded,
            railKey: const Key('rail_destination_setlists'),
          ),
          _NavigationItem(
            index: 3,
            label: l10n.navSettings,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            railKey: const Key('rail_destination_settings'),
          ),
        ];

        final content = FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                MetronomeView(
                  viewModel: widget.metronomeViewModel,
                  onOpenSettings: () => _onDestinationSelected(3),
                ),
                const PresetsView(),
                const SetlistsView(),
                const PreferencesView(showBackButton: false),
              ],
            ),
          ),
        );

        return ListenableBuilder(
          listenable: widget.metronomeViewModel,
          builder: (context, _) {
            final isPlaying = widget.metronomeViewModel.isPlaying;
            final fabIcon = isPlaying
                ? Icons.stop_rounded
                : Icons.play_arrow_rounded;
            final fabSemantics = isPlaying
                ? l10n.stopMetronomeSemantics
                : l10n.startMetronomeSemantics;
            final fabColor = isPlaying
                ? M3EFabColor.tertiary
                : M3EFabColor.primary;

            if (useRail) {
              return Scaffold(
                backgroundColor: context.colorScheme.surface,
                body: SafeArea(
                  bottom: false,
                  top: false,
                  child: Row(
                    children: [
                      M3ENavigationRail(
                        key: const Key('adaptive_navigation_rail'),
                        type: M3ENavigationRailType.alwaysCollapse,
                        alignment: M3ENavigationRailAlignment.center,
                        labelBehavior:
                            M3ENavigationRailLabelBehavior.onlySelected,
                        showDivider: true,
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _onDestinationSelected,
                        fab: M3ENavigationRailFabSlot(
                          icon: Icon(
                            fabIcon,
                            key: const Key('rail_play_stop_fab_icon'),
                          ),
                          label: fabSemantics,
                          tooltip: fabSemantics,
                          semanticLabel: fabSemantics,
                          color: fabColor,
                          onPressed: widget.metronomeViewModel.togglePlayStop,
                        ),
                        sections: [
                          M3ENavigationRailSection(
                            destinations: destinations.map((item) {
                              return M3ENavigationRailDestination(
                                icon: Icon(item.icon, key: item.railKey),
                                selectedIcon: Icon(item.selectedIcon),
                                label: item.label,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Expanded(child: content),
                    ],
                  ),
                ),
              );
            }

            final baseM3E = context.m3e;
            final compactToolbarTheme = baseM3E.copyWith(
              toolbarTheme: baseM3E.toolbarTheme.copyWith(
                actionGap: 0,
                screenOffset: 8,
              ),
              typography: M3ETypography(
                baseline: M3ETypeScale.fromTextTheme(
                  baseM3E.typeScale.toTextTheme().copyWith(
                    labelLarge: baseM3E.typeScale.labelLarge.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
                emphasized: baseM3E.typography.emphasized,
              ),
            );

            return Scaffold(
              backgroundColor: context.colorScheme.surface,
              extendBody: true,
              body: content,
              bottomNavigationBar: SafeArea(
                top: false,
                child: SizedBox(
                  height: 96,
                  child: M3ETheme(
                    data: compactToolbarTheme,
                    child: M3EToolbar.floating(
                      key: const Key('adaptive_navigation_toolbar'),
                      alignment: Alignment.bottomCenter,
                      safeArea: false,
                      dockEdge: M3EToolbarDockEdge.bottom,
                      colorStyle: M3EToolbarColorStyle.standard,
                      screenOffset: 8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      activeIndex: _currentIndex,
                      onActiveIndexChanged: _onDestinationSelected,
                      fabPosition: M3EToolbarFabPosition.end,
                      fabExpandsToolbar: false,
                      onFabPressed: widget.metronomeViewModel.togglePlayStop,
                      floatingActionButton: M3EFab(
                        key: const Key('toolbar_play_stop_fab'),
                        icon: Icon(
                          fabIcon,
                          key: const Key('toolbar_play_stop_fab_icon'),
                        ),
                        tooltip: fabSemantics,
                        color: fabColor,
                        onPressed: widget.metronomeViewModel.togglePlayStop,
                      ),
                      actions: destinations.map((item) {
                        final isSelected = item.index == _currentIndex;
                        return M3EToolbarAction(
                          icon: isSelected ? item.selectedIcon : item.icon,
                          label: item.label,
                          tooltip: item.label,
                          semanticLabel: item.label,
                          onPressed: () => _onDestinationSelected(item.index),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.railKey,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Key railKey;
}
