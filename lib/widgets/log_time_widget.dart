import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';

class LogTimeWidget extends StatelessWidget {
  final void Function({required double timeMinutes, required double countValue}) onLog;

  const LogTimeWidget({
    super.key,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time presets
        Text(
          l10n.logTime,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _ChipButton(label: '5m', onTap: () => onLog(timeMinutes: 5, countValue: 0)),
            _ChipButton(label: '10m', onTap: () => onLog(timeMinutes: 10, countValue: 0)),
            _ChipButton(label: '15m', onTap: () => onLog(timeMinutes: 15, countValue: 0)),
            _ChipButton(label: '30m', onTap: () => onLog(timeMinutes: 30, countValue: 0)),
            _ChipButton(label: '1h', onTap: () => onLog(timeMinutes: 60, countValue: 0)),
            _ChipButton(
              label: '...',
              onTap: () => _showCustomDialog(context, isTimeOnly: true),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Count presets
        Text(
          l10n.logCount,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _ChipButton(label: '+1', onTap: () => onLog(timeMinutes: 0, countValue: 1)),
            _ChipButton(label: '+5', onTap: () => onLog(timeMinutes: 0, countValue: 5)),
            _ChipButton(label: '+10', onTap: () => onLog(timeMinutes: 0, countValue: 10)),
            _ChipButton(label: '+25', onTap: () => onLog(timeMinutes: 0, countValue: 25)),
            _ChipButton(
              label: '...',
              onTap: () => _showCustomDialog(context, isTimeOnly: false),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomDialog(BuildContext context, {required bool isTimeOnly}) {
    final l10n = S.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => _CustomValueDialog(
        title: isTimeOnly ? l10n.customDuration : l10n.customCount,
        showTimeField: isTimeOnly,
        showCountField: !isTimeOnly,
        timeSuffix: l10n.minutes,
        onSubmit: onLog,
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
  }
}

class _CustomValueDialog extends StatefulWidget {
  final String title;
  final bool showTimeField;
  final bool showCountField;
  final String? timeSuffix;
  final void Function({required double timeMinutes, required double countValue}) onSubmit;

  const _CustomValueDialog({
    required this.title,
    this.showTimeField = true,
    this.showCountField = false,
    this.timeSuffix,
    required this.onSubmit,
  });

  @override
  State<_CustomValueDialog> createState() => _CustomValueDialogState();
}

class _CustomValueDialogState extends State<_CustomValueDialog> {
  final _timeController = TextEditingController();
  final _countController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTimeField)
            TextField(
              controller: _timeController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                suffixText: widget.timeSuffix,
              ),
              onSubmitted: (_) => _submit(),
            ),
          if (widget.showCountField)
            TextField(
              controller: _countController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _submit(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.add),
        ),
      ],
    );
  }

  void _submit() {
    final time = double.tryParse(_timeController.text.trim()) ?? 0;
    final count = double.tryParse(_countController.text.trim()) ?? 0;
    if (time <= 0 && count <= 0) return;
    Navigator.of(context).pop();
    widget.onSubmit(timeMinutes: time, countValue: count);
  }
}
