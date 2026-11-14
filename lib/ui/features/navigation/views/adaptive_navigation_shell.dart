import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../core/theme/app_theme.dart';
import '../../metronome/view_models/metronome_view_model.dart';
import '../../metronome/views/metronome_view.dart';
import '../../preferences/views/preferences_view.dart';
import '../../presets/views/presets_view.dart';
import '../../setlists/views/setlists_view.dart';

/// Top-level adaptive navigation shell providing responsive layout switching
/// between [M3ENavigationBar] (portrait) and [M3ENavigationRail] (landscape / wide screen),
/// retaining page state via [IndexedStack] with smooth animated transitions.
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

        final destinations = [
          _NavigationItem(
            index: 0,
            label: 'Metronome',
            icon: Icons.speed_outlined,
            selectedIcon: Icons.speed,
            navKey: const Key('nav_destination_metronome'),
            railKey: const Key('rail_destination_metronome'),
          ),
          _NavigationItem(
            index: 1,
            label: 'Presets',
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune_rounded,
            navKey: const Key('nav_destination_presets'),
            railKey: const Key('rail_destination_presets'),
          ),
          _NavigationItem(
            index: 2,
            label: 'Setlists',
            icon: Icons.queue_music_outlined,
            selectedIcon: Icons.queue_music_rounded,
            navKey: const Key('nav_destination_setlists'),
            railKey: const Key('rail_destination_setlists'),
          ),
          _NavigationItem(
            index: 3,
            label: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            navKey: const Key('nav_destination_settings'),
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
                    labelBehavior: M3ENavigationRailLabelBehavior.onlySelected,
                    showDivider: true,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onDestinationSelected,
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

        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: content,
          bottomNavigationBar: M3ENavigationBar(
            key: const Key('adaptive_navigation_bar'),
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelBehavior: M3ENavBarLabelBehavior.alwaysShow,
            indicatorStyle: M3ENavBarIndicatorStyle.pill,
            destinations: destinations.map((item) {
              return M3ENavigationBarDestination(
                icon: Icon(item.icon, key: item.navKey),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              );
            }).toList(),
          ),
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
    required this.navKey,
    required this.railKey,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Key navKey;
  final Key railKey;
}
