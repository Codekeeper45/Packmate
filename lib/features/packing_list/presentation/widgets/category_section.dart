import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import 'packing_item_tile.dart';

/// A collapsible section displaying a category with its items.
class CategorySection extends StatefulWidget {
  final Category category;
  final bool isExpanded;
  final bool showCheckboxes;
  final bool enableReorder;
  final void Function(String categoryId, String itemId)? onToggleItem;
  final void Function(String categoryId, String itemId)? onRemoveItem;
  final void Function(String categoryId, String itemId, int quantity)?
      onUpdateQuantity;
  final void Function(String categoryId, int oldIndex, int newIndex)?
      onReorderItems;

  const CategorySection({
    super.key,
    required this.category,
    this.isExpanded = true,
    this.showCheckboxes = false,
    this.enableReorder = false,
    this.onToggleItem,
    this.onRemoveItem,
    this.onUpdateQuantity,
    this.onReorderItems,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  void didUpdateWidget(CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      _isExpanded = widget.isExpanded;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'wash':
        return Icons.wash;
      case 'devices':
        return Icons.devices;
      case 'medication':
        return Icons.medication;
      case 'folder':
        return Icons.folder;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'restaurant':
        return Icons.restaurant;
      case 'child_care':
        return Icons.child_care;
      case 'pets':
        return Icons.pets;
      case 'beach_access':
        return Icons.beach_access;
      case 'hiking':
        return Icons.hiking;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'backpack':
        return Icons.backpack;
      case 'card_travel':
        return Icons.card_travel;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor() {
    try {
      final hex = widget.category.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  /// Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(String itemName) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить вещь?'),
        content: Text('Вы уверены, что хотите удалить "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(
                  color: categoryColor,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconData(widget.category.icon),
                  color: categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.category.packedItems}/${widget.category.totalItems} собрано',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                if (widget.showCheckboxes) ...[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: widget.category.progressPercent / 100,
                          strokeWidth: 3,
                          backgroundColor: categoryColor.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                        ),
                        Text(
                          '${widget.category.progressPercent.round()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        // Items List
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: widget.enableReorder && widget.onReorderItems != null
              ? _buildReorderableList(theme)
              : _buildRegularList(theme),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRegularList(ThemeData theme) {
    return Column(
      children: widget.category.items.map((item) {
        if (widget.onRemoveItem != null) {
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: theme.colorScheme.error,
              child: Icon(
                Icons.delete,
                color: theme.colorScheme.onError,
              ),
            ),
            confirmDismiss: (_) => _showDeleteConfirmation(item.name),
            onDismissed: (_) {
              widget.onRemoveItem!(widget.category.id, item.id);
            },
            child: PackingItemTile(
              item: item,
              showCheckbox: widget.showCheckboxes,
              showDragHandle: widget.enableReorder,
              showRemoveButton: widget.onRemoveItem != null,
              onToggle: widget.onToggleItem != null
                  ? () => widget.onToggleItem!(widget.category.id, item.id)
                  : null,
              onRemove: widget.onRemoveItem != null
                  ? () async {
                      final confirmed = await _showDeleteConfirmation(item.name);
                      if (confirmed) {
                        widget.onRemoveItem!(widget.category.id, item.id);
                      }
                    }
                  : null,
              onUpdateQuantity: widget.onUpdateQuantity != null
                  ? (qty) => widget.onUpdateQuantity!(
                      widget.category.id, item.id, qty)
                  : null,
            ),
          );
        }

        return PackingItemTile(
          item: item,
          showCheckbox: widget.showCheckboxes,
          onToggle: widget.onToggleItem != null
              ? () => widget.onToggleItem!(widget.category.id, item.id)
              : null,
          onUpdateQuantity: widget.onUpdateQuantity != null
              ? (qty) =>
                  widget.onUpdateQuantity!(widget.category.id, item.id, qty)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildReorderableList(ThemeData theme) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.category.items.length,
      onReorder: (oldIndex, newIndex) {
        widget.onReorderItems!(widget.category.id, oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 4 * animation.value,
              color: theme.colorScheme.surface,
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final item = widget.category.items[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: theme.colorScheme.error,
            child: Icon(
              Icons.delete,
              color: theme.colorScheme.onError,
            ),
          ),
          confirmDismiss: (_) => _showDeleteConfirmation(item.name),
          onDismissed: (_) {
            widget.onRemoveItem?.call(widget.category.id, item.id);
          },
          child: PackingItemTile(
            key: ValueKey('tile_${item.id}'),
            item: item,
            showCheckbox: widget.showCheckboxes,
            showDragHandle: true,
            showRemoveButton: widget.onRemoveItem != null,
            onToggle: widget.onToggleItem != null
                ? () => widget.onToggleItem!(widget.category.id, item.id)
                : null,
            onRemove: widget.onRemoveItem != null
                ? () async {
                    final confirmed = await _showDeleteConfirmation(item.name);
                    if (confirmed) {
                      widget.onRemoveItem!(widget.category.id, item.id);
                    }
                  }
                : null,
            onUpdateQuantity: widget.onUpdateQuantity != null
                ? (qty) => widget.onUpdateQuantity!(
                    widget.category.id, item.id, qty)
                : null,
          ),
        );
      },
    );
  }
}
