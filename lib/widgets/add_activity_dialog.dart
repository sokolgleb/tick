import 'package:flutter/material.dart';
import '../core/theme.dart';

class AddActivityDialog extends StatefulWidget {
  final String? initialName;
  final String? initialColor;

  const AddActivityDialog({
    super.key,
    this.initialName,
    this.initialColor,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  late final TextEditingController _nameController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor ?? '#000000';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Activity' : 'New Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Activity name'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Text('Color', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: TickTheme.activityColors.map((color) {
              final hex = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              final isSelected = hex.toLowerCase() == _selectedColor.toLowerCase();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop({'name': name, 'color': _selectedColor});
  }
}
