import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';

import '../../../../domain/models/app_theme_mode.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/preferences_view_model.dart';

/// Preferences and settings screen using Material 3 Expressive theming
/// (FR-CFG-04, UI-05).
class PreferencesView extends StatelessWidget {
  const PreferencesView({super.key, this.showBackButton});

  /// Explicit flag to control back button visibility.
  /// When omitted, checks [Navigator.canPop].
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreferencesViewModel>();
    final canPop = showBackButton ?? (ModalRoute.of(context)?.canPop ?? false);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
                      if (canPop) ...[
                        M3EIconButton(
                          key: const Key('preferences_back_button'),
                          variant: M3EIconButtonVariant.standard,
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back to metronome',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'PREFERENCES',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(
                          width: 48.0,
                        ), // Visual balancing for back button
                      ] else ...[
                        Text(
                          'PREFERENCES',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox.shrink(),
                      ],
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceMd),

                  // Appearance Section Plate
                  M3ECard(
                    variant: M3ECardVariant.outlined,
                    padding: EdgeInsets.all(context.dimens.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 20,
                              color: context.colorScheme.primary,
                            ),
                            SizedBox(width: context.dimens.spaceSm),
                            Text(
                              'APPEARANCE',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.dimens.spaceXs),
                        Text(
                          'Choose between dark mode, light mode, or match your device system appearance.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: context.dimens.spaceMd),

                        // Expressive SegmentedButton for Theme Selection
                        SizedBox(
                          width: double.infinity,
                          child: M3ESegmentedButton<AppThemeMode>(
                            key: const Key('theme_mode_segmented_button'),
                            segments: const [
                              M3ESegment<AppThemeMode>(
                                value: AppThemeMode.system,
                                label: 'System',
                                icon: Icon(Icons.brightness_auto_rounded),
                              ),
                              M3ESegment<AppThemeMode>(
                                value: AppThemeMode.light,
                                label: 'Light',
                                icon: Icon(Icons.light_mode_rounded),
                              ),
                              M3ESegment<AppThemeMode>(
                                value: AppThemeMode.dark,
                                label: 'Dark',
                                icon: Icon(Icons.dark_mode_rounded),
                              ),
                            ],
                            selected: {viewModel.themeMode},
                            onSelectionChanged: (selected) {
                              if (selected.isNotEmpty) {
                                viewModel.setThemeMode(selected.first);
                              }
                            },
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
