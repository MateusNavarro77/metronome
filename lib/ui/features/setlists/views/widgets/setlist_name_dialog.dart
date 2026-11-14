import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';

/// Prompts the user to create or rename a setlist and returns the trimmed name,
/// or `null` if cancelled.
Future<String?> showSetlistNameDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? initialName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SetlistNameDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
    ),
  );
}

class _SetlistNameDialog extends StatefulWidget {
  const _SetlistNameDialog({
    required this.title,
    required this.confirmLabel,
    this.initialName,
  });

  final String title;
  final String confirmLabel;
  final String? initialName;

  @override
  State<_SetlistNameDialog> createState() => _SetlistNameDialogState();
}

class _SetlistNameDialogState extends State<_SetlistNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _errorText = 'Enter a setlist name.';
      });
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('setlist_name_dialog'),
      backgroundColor: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      title: Text(
        widget.title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurface,
        ),
      ),
      content: Container(
        padding: EdgeInsets.fromLTRB(
          context.dimens.spaceMd,
          context.dimens.spaceSm,
          context.dimens.spaceMd,
          context.dimens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
        ),
        child: TextField(
          key: const Key('setlist_name_input'),
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Friday Gig',
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            errorText: _errorText,
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('setlist_name_cancel_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: context.colorScheme.onSurface),
          ),
        ),
        FilledButton(
          key: const Key('setlist_name_save_button'),
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
          ),
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
