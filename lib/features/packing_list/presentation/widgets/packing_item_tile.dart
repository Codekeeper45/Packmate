import 'package:flutter/material.dart';

import '../../domain/entities/packing_item.dart';
import '../../../../core/theme/app_colors.dart';

class PackingItemTile extends StatelessWidget {
  final PackingItem item;
  final bool showCheckbox;
  final bool showDragHandle;
  final bool showRemoveButton;
  final VoidCallback? onToggle;
  final VoidCallback? onRemove;
  final Function(int)? onUpdateQuantity;

  const PackingItemTile({
    super.key,
    required this.item,
    this.showCheckbox = false,
    this.showDragHandle = false,
    this.showRemoveButton = false,
    this.onToggle,
    this.onRemove,
    this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: showCheckbox ? onToggle : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Drag handle (optional)
            if (showDragHandle) ...[
              Icon(
                Icons.drag_handle,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
              const SizedBox(width: 8),
            ],

            // Checkbox or bullet
            if (showCheckbox)
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isPacked ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.isPacked
                          ? AppColors.success
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: item.isPacked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.isEssential
                      ? AppColors.warning
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            
            const SizedBox(width: 12),
            
            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: item.isPacked && showCheckbox
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isPacked && showCheckbox
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (item.isEssential) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Важно',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Quantity
            if (item.quantity > 1 || onUpdateQuantity != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: onUpdateQuantity != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: item.quantity > 1
                                ? () => onUpdateQuantity!(item.quantity - 1)
                                : null,
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: item.quantity > 1
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onUpdateQuantity!(item.quantity + 1),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
              ),
            if (showRemoveButton && onRemove != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                tooltip: 'Удалить',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
