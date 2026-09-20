import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<bool> confirmRemove(
  BuildContext context, {
  String title = 'Remove item?',
  required String description,
  String confirmLabel = 'Remove',
}) async {
  final confirmed = await showShadDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final dialogWidth = MediaQuery.sizeOf(dialogContext).width - 48;
      const horizontalPadding = 48.0;
      final actionsWidth = dialogWidth - horizontalPadding;

      return ShadDialog.alert(
        constraints: BoxConstraints.tightFor(width: dialogWidth),
        scrollable: false,
        useSafeArea: false,
        actionsAxis: Axis.horizontal,
        actionsMainAxisSize: MainAxisSize.min,
        expandActionsWhenTiny: false,
        title: Text(title),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(description),
        ),
        actions: [
          SizedBox(
            width: actionsWidth,
            child: Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    width: double.infinity,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShadButton.destructive(
                    width: double.infinity,
                    child: Text(confirmLabel),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}
