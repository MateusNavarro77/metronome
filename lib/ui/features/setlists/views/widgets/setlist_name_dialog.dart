import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

/// Prompts the user to create or rename a setlist and returns the trimmed name,
/// or `null` if cancelled.
Future<String?> showSetlistNameDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? initialName,
}) {
  return M3EDialog.show<String>(
    context,
    dialog: _SetlistNameDialog(
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
    return M3EDialog(
      key: const Key('setlist_name_dialog'),
      title: widget.title,
      content: M3ETextField(
        key: const Key('setlist_name_input'),
        controller: _controller,
        variant: M3ETextFieldVariant.outlined,
        label: 'Setlist name',
        placeholder: 'e.g. Friday Gig',
        errorText: _errorText,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
      ),
      actions: [
        M3EButton.text(
          key: const Key('setlist_name_cancel_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          key: const Key('setlist_name_save_button'),
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
