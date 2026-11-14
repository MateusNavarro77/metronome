import 'package:material_ui/material_ui.dart';

import '../../../core/theme/sonic_theme.dart';
import '../../metronome/view_models/metronome_view_model.dart';
import '../../metronome/views/metronome_view.dart';
import '../../preferences/views/preferences_view.dart';
import '../../presets/views/presets_placeholder_view.dart';
import '../../setlists/views/setlists_placeholder_view.dart';

/// Top-level adaptive navigation shell providing responsive layout switching
/// between [NavigationBar] (portrait) and [NavigationRail] (landscape / wide screen),
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
                const PresetsPlaceholderView(),
                const SetlistsPlaceholderView(),
                const PreferencesView(showBackButton: false),
              ],
            ),
          ),
        );

        if (useRail) {
          return Scaffold(
            backgroundColor: context.colors.surfaceLowest,
            body: SafeArea(
              bottom: false,
              top: false,
              child: Row(
                children: [
                  NavigationRail(
                    mainAxisAlignment: MainAxisAlignment.center,
                    key: const Key('adaptive_navigation_rail'),
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.selected,
                    backgroundColor: context.colors.surfaceLow,
                    indicatorColor: context.colors.primaryContainer,
                    selectedIconTheme: IconThemeData(
                      color: context.colors.onPrimaryContainer,
                      size: 24,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: context.colors.onSurfaceMuted,
                      size: 24,
                    ),
                    selectedLabelTextStyle: context.textTheme.labelMedium
                        ?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: context.colors.primaryAccent,
                        ),
                    unselectedLabelTextStyle: context.textTheme.labelMedium
                        ?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: context.colors.onSurfaceMuted,
                        ),
                    destinations: destinations.map((item) {
                      return NavigationRailDestination(
                        icon: Icon(item.icon, key: item.railKey),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      );
                    }).toList(),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: context.colors.ghostBorder,
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.surfaceLowest,
          body: content,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: context.colors.surfaceLow,
                indicatorColor: context.colors.primaryContainer,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(
                      color: context.colors.onPrimaryContainer,
                      size: 24,
                    );
                  }
                  return IconThemeData(
                    color: context.colors.onSurfaceMuted,
                    size: 24,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: context.colors.primaryAccent,
                    );
                  }
                  return context.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: context.colors.onSurfaceMuted,
                  );
                }),
              ),
            ),
            child: NavigationBar(
              key: const Key('adaptive_navigation_bar'),
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: destinations.map((item) {
                return NavigationDestination(
                  key: item.navKey,
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
            ),
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
