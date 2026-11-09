import 'package:flutter/material.dart';

import '../../../core/theme/sonic_theme.dart';

/// Placeholder screen for Setlists adhering to "The Sonic Architect" design system
/// and PRD section 3.7 (FR-PRE-06..10, UI-05).
class SetlistsPlaceholderView extends StatelessWidget {
  const SetlistsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceLowest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.dimens.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimens.spaceMd,
                vertical: context.dimens.spaceSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Architectural Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SETLISTS',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfacePrimary,
                          letterSpacing: 2.2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dimens.spaceSmPlus4,
                          vertical: context.dimens.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceHigh,
                          borderRadius: BorderRadius.circular(
                            context.dimens.radiusFull,
                          ),
                        ),
                        child: Text(
                          'COMING SOON',
                          style: context.textTheme.labelMedium?.copyWith(
                            fontSize: 10,
                            color: context.colors.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceLg),

                  // Hero Icon & Title Section
                  Container(
                    padding: EdgeInsets.all(context.dimens.spaceLg),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLow,
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusLg,
                      ),
                      border: Border.all(
                        color: context.colors.ghostBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.queue_music_rounded,
                            size: 32,
                            color: context.colors.primaryAccent,
                          ),
                        ),
                        SizedBox(height: context.dimens.spaceMd),
                        Text(
                          'Live Setlists',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.colors.onSurfacePrimary,
                          ),
                        ),
                        SizedBox(height: context.dimens.spaceXs + 2),
                        Text(
                          'Sequence your songs for concerts, church services, and band rehearsals with seamless tempo transitions.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dimens.spaceMd),

                  // Feature Preview Cards (FR-PRE-06..10)
                  _FeatureCard(
                    icon: Icons.sync_rounded,
                    title: 'Bar-Synced Transitions (FR-PRE-09)',
                    description: 'Switch between songs during playback; the new tempo and meter apply on the next bar without stopping.',
                  ),
                  SizedBox(height: context.dimens.spaceSm),
                  _FeatureCard(
                    icon: Icons.drag_indicator_rounded,
                    title: 'Drag-and-Drop Reordering (FR-PRE-07)',
                    description: 'Easily adjust your show order on the fly with intuitive touch reordering.',
                  ),
                  SizedBox(height: context.dimens.spaceSm),
                  _FeatureCard(
                    icon: Icons.skip_next_rounded,
                    title: 'Live Stage Stepper (FR-PRE-08)',
                    description: 'Large, high-contrast previous and next buttons designed for quick glance-and-tap on dark stages.',
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dimens.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceLow,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        border: Border.all(color: context.colors.ghostBorder, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.dimens.spaceSm),
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              borderRadius: BorderRadius.circular(context.dimens.radiusSm),
            ),
            child: Icon(icon, size: 20, color: context.colors.primaryAccent),
          ),
          SizedBox(width: context.dimens.spaceSmPlus4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfacePrimary,
                  ),
                ),
                SizedBox(height: context.dimens.spaceXs),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
