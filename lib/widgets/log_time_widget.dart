import 'package:flutter/material.dart';
import '../core/constants.dart';

class LogTimeWidget extends StatelessWidget {
  final void Function(int minutes) onLog;

  const LogTimeWidget({super.key, required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Log Time', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...durationPresets.map((minutes) => _TimeButton(
                  label: durationLabels[minutes]!,
                  onTap: () => onLog(minutes),
                )),
            _TimeButton(
              label: '...',
              onTap: () => _showCustomDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _CustomDurationDialog(onSubmit: onLog),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomDurationDialog extends StatefulWidget {
  final void Function(int minutes) onSubmit;

  const _CustomDurationDialog({required this.onSubmit});

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Duration'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Minutes',
          suffixText: 'min',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    final minutes = int.tryParse(_controller.text.trim());
    if (minutes == null || minutes <= 0) return;
    Navigator.of(context).pop();
    widget.onSubmit(minutes);
  }
}
