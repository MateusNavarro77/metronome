import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

/// Presents an [M3ESnackbar] with an explicit auto-dismiss [duration] and
/// automatic clearance above the floating bottom toolbar when present.
void showAppSnackbar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool showCloseButton = false,
  Duration? duration,
  bool clearFloatingToolbar = true,
}) {
  final hasAction = actionLabel != null && actionLabel.trim().isNotEmpty;
  final resolvedDuration = duration ?? Duration(seconds: hasAction ? 5 : 3);

  // Inside AdaptiveNavigationShell portrait mode, Scaffold(extendBody: true)
  // adds the floating toolbar height to MediaQuery.padding.bottom, whereas
  // M3ESnackbarHost renders in the root overlay above that Scaffold.
  final mediaQuery = MediaQuery.maybeOf(context);
  final extraBottomInset = clearFloatingToolbar && mediaQuery != null
      ? (mediaQuery.padding.bottom - mediaQuery.viewPadding.bottom).clamp(
          0.0,
          120.0,
        )
      : 0.0;

  final snackbar = M3ESnackbar(
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    showCloseButton: showCloseButton,
  );

  M3ESnackbar.defaultController.present(
    context,
    duration: resolvedDuration,
    child: extraBottomInset > 0
        ? Padding(
            padding: EdgeInsets.only(bottom: extraBottomInset),
            child: snackbar,
          )
        : snackbar,
  );
}

/// Immediately dismisses any visible [M3ESnackbar].
void dismissAppSnackbar({bool immediate = false}) {
  M3ESnackbar.defaultController.dismiss(immediate: immediate);
}
