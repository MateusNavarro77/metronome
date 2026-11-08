import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/app_theme_mode.dart';
import '../../../core/theme/sonic_theme.dart';
import '../view_models/preferences_view_model.dart';

/// Preferences and settings screen adhering to "The Sonic Architect" design system
/// (specs/DESIGN_DARK.md, specs/DESIGN_LIGHT.md, FR-CFG-04, UI-05).
class PreferencesView extends StatelessWidget {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreferencesViewModel>();

    return Scaffold(
      backgroundColor: context.colors.surfaceLowest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.dimens.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimens.spaceMd,
                vertical: context.dimens.spaceSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Custom Architectural Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        key: const Key('preferences_back_button'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: context.colors.onSurfacePrimary,
                        tooltip: 'Back to metronome',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'PREFERENCES',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfacePrimary,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(
                        width: 48.0,
                      ), // Visual balancing for back button
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceMd),

                  // Appearance Section Plate
                  Container(
                    padding: EdgeInsets.all(context.dimens.spaceMd),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLow,
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusMd,
                      ),
                      border: Border.all(color: context.colors.ghostBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 20,
                              color: context.colors.primaryAccent,
                            ),
                            SizedBox(width: context.dimens.spaceSm),
                            Text(
                              'APPEARANCE',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colors.onSurfacePrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.dimens.spaceXs),
                        Text(
                          'Choose between studio dark mode, architectural daylight mode, or match your device system appearance.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: context.dimens.spaceMd),

                        // Architectural SegmentedButton for Theme Selection
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AppThemeMode>(
                            key: const Key('theme_mode_segmented_button'),
                            segments: const [
                              ButtonSegment<AppThemeMode>(
                                value: AppThemeMode.system,
                                label: Text('System'),
                                icon: Icon(Icons.brightness_auto_rounded),
                              ),
                              ButtonSegment<AppThemeMode>(
                                value: AppThemeMode.light,
                                label: Text('Light'),
                                icon: Icon(Icons.light_mode_rounded),
                              ),
                              ButtonSegment<AppThemeMode>(
                                value: AppThemeMode.dark,
                                label: Text('Dark'),
                                icon: Icon(Icons.dark_mode_rounded),
                              ),
                            ],
                            selected: {viewModel.themeMode},
                            onSelectionChanged: (selected) {
                              if (selected.isNotEmpty) {
                                viewModel.setThemeMode(selected.first);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return context.colors.primaryContainer;
                                }
                                return context.colors.surfaceHigh;
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return context.colors.primaryAccent;
                                }
                                return context.colors.onSurfaceMuted;
                              }),
                              side: WidgetStateProperty.resolveWith((states) {
                                return BorderSide(
                                  color: states.contains(WidgetState.selected)
                                      ? context.colors.neonGhostBorder
                                      : context.colors.ghostBorder,
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
