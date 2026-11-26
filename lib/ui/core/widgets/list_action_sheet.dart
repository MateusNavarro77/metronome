import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../theme/app_theme.dart';

/// Descriptor for a single action inside [showListItemActionSheet].
class ListActionItem {
  const ListActionItem({
    this.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.enabled = true,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool enabled;
}

/// Presents an ergonomic thumb-zone modal bottom sheet with list item actions
/// (typically opened via long-press on mobile cards).
Future<void> showListItemActionSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<ListActionItem> actions,
  Key? sheetKey,
}) {
  HapticFeedback.mediumImpact();
  return M3EBottomSheet.show<void>(
    context,
    showDragHandle: true,
    isDismissible: true,
    initialValue: M3EBottomSheetValue.expanded,
    builder: (sheetContext) {
      final standardActions = actions
          .where((item) => !item.isDestructive)
          .toList(growable: false);
      final destructiveActions = actions
          .where((item) => item.isDestructive)
          .toList(growable: false);

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: sheetContext.dimens.maxContentWidth,
        ),
        child: SafeArea(
          key: sheetKey,
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sheetContext.dimens.spaceMd,
              sheetContext.dimens.spaceXs,
              sheetContext.dimens.spaceMd,
              sheetContext.dimens.spaceLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sheetContext.dimens.spaceSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sheetContext.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: sheetContext.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        SizedBox(height: sheetContext.dimens.spaceXs),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sheetContext.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: sheetContext.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: sheetContext.dimens.spaceMd),
                for (final item in standardActions) _ActionSheetRow(item: item),
                if (standardActions.isNotEmpty &&
                    destructiveActions.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sheetContext.dimens.spaceXs,
                    ),
                    child: const M3EDivider(),
                  ),
                ],
                for (final item in destructiveActions)
                  _ActionSheetRow(item: item),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ActionSheetRow extends StatelessWidget {
  const _ActionSheetRow({required this.item});

  final ListActionItem item;

  @override
  Widget build(BuildContext context) {
    final fgColor = !item.enabled
        ? context.colorScheme.onSurface.withValues(alpha: 0.38)
        : item.isDestructive
        ? context.colorScheme.error
        : context.colorScheme.onSurface;

    final iconColor = !item.enabled
        ? context.colorScheme.onSurface.withValues(alpha: 0.38)
        : item.isDestructive
        ? context.colorScheme.error
        : context.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: item.key,
        borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
        onTap: item.enabled
            ? () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                item.onTap();
              }
            : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.dimens.minTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimens.spaceSmPlus2,
              vertical: context.dimens.spaceSmPlus2,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 22, color: iconColor),
                SizedBox(width: context.dimens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
                      if (item.subtitle != null &&
                          item.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
