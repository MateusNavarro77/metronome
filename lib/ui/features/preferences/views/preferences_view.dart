import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';

import '../../../../domain/models/app_theme_mode.dart';
import '../../../../domain/models/metronome_sound.dart';
import '../../../../domain/models/sound_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/preferences_view_model.dart';

/// Preferences and settings screen using Material 3 Expressive theming
/// (FR-CFG-04, FR-SND-01..08, UI-05).
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
                  _PreferencesHeader(canPop: canPop),
                  SizedBox(height: context.dimens.spaceMd),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionHeader(
                            key: Key('appearance_section_header'),
                            icon: Icons.palette_outlined,
                            title: 'APPEARANCE',
                          ),
                          SizedBox(height: context.dimens.spaceSm),
                          _AppearanceSectionCard(viewModel: viewModel),
                          SizedBox(height: context.dimens.spaceLg),
                          const _SectionHeader(
                            key: Key('sounds_section_header'),
                            icon: Icons.equalizer_rounded,
                            title: 'SOUNDS & VOLUMES',
                          ),
                          SizedBox(height: context.dimens.spaceSm),
                          _SoundsSectionCard(viewModel: viewModel),
                          SizedBox(height: context.dimens.spaceMd),
                        ],
                      ),
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

class _PreferencesHeader extends StatelessWidget {
  const _PreferencesHeader({required this.canPop});

  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          const SizedBox(width: 48.0),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.spaceXs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colorScheme.primary),
          SizedBox(width: context.dimens.spaceSm),
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSectionCard extends StatelessWidget {
  const _AppearanceSectionCard({required this.viewModel});

  final PreferencesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return M3ECard(
      key: const Key('appearance_section_card'),
      variant: M3ECardVariant.outlined,
      padding: EdgeInsets.all(context.dimens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose between dark mode, light mode, or match your device system appearance.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
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
    );
  }
}

class _SoundsSectionCard extends StatelessWidget {
  const _SoundsSectionCard({required this.viewModel});

  final PreferencesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isMuted = viewModel.isMuted;

    return M3ECard(
      key: const Key('sounds_section_card'),
      variant: M3ECardVariant.outlined,
      padding: EdgeInsets.all(context.dimens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select the click timbre, balance strong, weak, and subdivision volumes, or mute audio while keeping the visual pulse.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          _SoundTimbreGrid(
            selectedSound: viewModel.selectedSound,
            onSelected: viewModel.selectSound,
          ),
          SizedBox(height: context.dimens.spaceMd),
          const Divider(height: 1),
          SizedBox(height: context.dimens.spaceSmPlus4),
          _MuteAudioRow(isMuted: isMuted, onChanged: viewModel.setMuted),
          SizedBox(height: context.dimens.spaceSmPlus4),
          const Divider(height: 1),
          SizedBox(height: context.dimens.spaceSmPlus4),
          AnimatedOpacity(
            opacity: isMuted ? 0.45 : 1.0,
            duration: M3EMotion.short2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VolumeSliderRow(
                  sliderKey: const Key('sound_strong_volume_slider'),
                  valueKey: const Key('sound_strong_volume_value'),
                  label: 'Strong Beat',
                  icon: Icons.looks_one_rounded,
                  value: viewModel.strongVolume,
                  enabled: !isMuted,
                  onChanged: viewModel.setStrongVolume,
                ),
                SizedBox(height: context.dimens.spaceSm),
                _VolumeSliderRow(
                  sliderKey: const Key('sound_weak_volume_slider'),
                  valueKey: const Key('sound_weak_volume_value'),
                  label: 'Weak Beats',
                  icon: Icons.music_note_outlined,
                  value: viewModel.weakVolume,
                  enabled: !isMuted,
                  onChanged: viewModel.setWeakVolume,
                ),
                SizedBox(height: context.dimens.spaceSm),
                _VolumeSliderRow(
                  sliderKey: const Key('sound_subdivision_volume_slider'),
                  valueKey: const Key('sound_subdivision_volume_value'),
                  label: 'Subdivisions',
                  icon: Icons.grain_rounded,
                  value: viewModel.subdivisionVolume,
                  enabled: !isMuted,
                  onChanged: viewModel.setSubdivisionVolume,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundTimbreGrid extends StatelessWidget {
  const _SoundTimbreGrid({
    required this.selectedSound,
    required this.onSelected,
  });

  final MetronomeSound selectedSound;
  final ValueChanged<MetronomeSound> onSelected;

  @override
  Widget build(BuildContext context) {
    final sounds = MetronomeSound.values;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SoundTimbreTile(
                sound: sounds[0],
                isSelected: selectedSound == sounds[0],
                onTap: () => onSelected(sounds[0]),
              ),
            ),
            SizedBox(width: context.dimens.spaceSm),
            Expanded(
              child: _SoundTimbreTile(
                sound: sounds[1],
                isSelected: selectedSound == sounds[1],
                onTap: () => onSelected(sounds[1]),
              ),
            ),
          ],
        ),
        SizedBox(height: context.dimens.spaceSm),
        Row(
          children: [
            Expanded(
              child: _SoundTimbreTile(
                sound: sounds[2],
                isSelected: selectedSound == sounds[2],
                onTap: () => onSelected(sounds[2]),
              ),
            ),
            SizedBox(width: context.dimens.spaceSm),
            Expanded(
              child: _SoundTimbreTile(
                sound: sounds[3],
                isSelected: selectedSound == sounds[3],
                onTap: () => onSelected(sounds[3]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SoundTimbreTile extends StatelessWidget {
  const _SoundTimbreTile({
    required this.sound,
    required this.isSelected,
    required this.onTap,
  });

  final MetronomeSound sound;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _iconFor(MetronomeSound sound) {
    return switch (sound) {
      MetronomeSound.click => Icons.adjust_rounded,
      MetronomeSound.woodBlock => Icons.music_note_rounded,
      MetronomeSound.beep => Icons.graphic_eq_rounded,
      MetronomeSound.drums => Icons.album_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? context.colorScheme.onSecondaryContainer
        : context.colorScheme.onSurface;
    final subtleForeground = isSelected
        ? context.colorScheme.onSecondaryContainer.withValues(alpha: 0.78)
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${sound.label}, ${sound.description}',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.dimens.minTouchTarget),
        child: M3ECard(
          key: Key('sound_option_${sound.id}'),
          variant: isSelected ? M3ECardVariant.filled : M3ECardVariant.outlined,
          color: isSelected ? context.colorScheme.secondaryContainer : null,
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.spaceSmPlus4,
            vertical: context.dimens.spaceSmPlus2,
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Icon(_iconFor(sound), size: 20, color: foreground),
              SizedBox(width: context.dimens.spaceSm),
              Expanded(
                child: Text(
                  sound.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: context.dimens.spaceXs),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: context.colorScheme.primary,
                ),
              ] else ...[
                SizedBox(width: context.dimens.spaceXs),
                Icon(
                  Icons.circle_outlined,
                  size: 18,
                  color: subtleForeground.withValues(alpha: 0.45),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MuteAudioRow extends StatelessWidget {
  const _MuteAudioRow({required this.isMuted, required this.onChanged});

  final bool isMuted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          size: 20,
          color: isMuted
              ? context.colorScheme.error
              : context.colorScheme.primary,
        ),
        SizedBox(width: context.dimens.spaceSmPlus4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mute audio',
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Silence click while keeping visual beat indicator active',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.dimens.spaceSm),
        M3ESwitch(
          key: const Key('sound_mute_switch'),
          value: isMuted,
          onChanged: onChanged,
          semanticLabel: 'Mute audio',
        ),
      ],
    );
  }
}

class _VolumeSliderRow extends StatelessWidget {
  const _VolumeSliderRow({
    required this.sliderKey,
    required this.valueKey,
    required this.label,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final Key sliderKey;
  final Key valueKey;
  final String label;
  final IconData icon;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
            SizedBox(width: context.dimens.spaceSm),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '$value%',
              key: valueKey,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Semantics(
          label: '$label volume',
          value: '$value%',
          child: M3ESlider(
            key: sliderKey,
            value: value.toDouble(),
            min: SoundSettings.minVolume.toDouble(),
            max: SoundSettings.maxVolume.toDouble(),
            size: M3ESliderSize.xs,
            enabled: enabled,
            label: '$value%',
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
      ],
    );
  }
}
