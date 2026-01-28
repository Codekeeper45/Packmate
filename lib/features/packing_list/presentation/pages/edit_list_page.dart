import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/packing_item.dart';
import '../widgets/category_section.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';

class EditListPage extends ConsumerStatefulWidget {
  const EditListPage({super.key});

  @override
  ConsumerState<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends ConsumerState<EditListPage> {
  final _uuid = const Uuid();

  void _showAddItemDialog(String categoryId, String categoryName) {
    final nameController = TextEditingController();
    int quantity = 1;
    bool isEssential = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: null,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Добавить в "$categoryName"',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Название вещи',
                        hintText: 'Например: Зарядка',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    Row(
                      children: [
                        const Text(
                          'Количество:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: quantity > 1
                              ? () => setModalState(() => quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setModalState(() => quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),

                    // Essential toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Обязательная вещь'),
                      subtitle: Text(
                        'Будет выделена в списке',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      value: isEssential,
                      onChanged: (value) => setModalState(() => isEssential = value),
                    ),

                    const SizedBox(height: 24),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nameController.text.trim().isNotEmpty
                            ? () {
                                ref.read(packingListProvider.notifier).addItem(
                                      categoryId,
                                      nameController.text.trim(),
                                      quantity: quantity,
                                      isEssential: isEssential,
                                    );
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Добавить'),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(packingListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Готово'),
          ),
        ],
      ),
      body: categories.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                // Instructions
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swipe_left,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Смахни влево или нажми на корзину, чтобы удалить вещь',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Categories with items
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return Column(
                        children: [
                          CategorySection(
                            category: category,
                            isExpanded: true,
                            showCheckboxes: false,
                            enableReorder: true,
                            onRemoveItem: (catId, itemId) {
                              ref.read(packingListProvider.notifier).removeItem(catId, itemId);
                            },
                            onUpdateQuantity: (catId, itemId, qty) {
                              ref.read(packingListProvider.notifier).updateItemQuantity(catId, itemId, qty);
                            },
                            onReorderItems: (catId, oldIndex, newIndex) {
                              ref.read(packingListProvider.notifier).reorderItems(catId, oldIndex, newIndex);
                            },
                          ),
                          // Add item button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextButton.icon(
                              onPressed: () => _showAddItemDialog(category.id, category.name),
                              icon: const Icon(Icons.add),
                              label: Text('Добавить в "${category.name}"'),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: categories.length,
                  ),
                ),

                // Bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Категория'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Список пуст',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedIcon = 'category';
    String selectedColor = '#6366F1';

    final icons = [
      ('checkroom', '👕'),
      ('wash', '🧴'),
      ('devices', '📱'),
      ('medication', '💊'),
      ('folder', '📄'),
      ('sports_soccer', '⚽'),
      ('restaurant', '🍽️'),
      ('camera_alt', '📷'),
      ('backpack', '🎒'),
      ('category', '📦'),
    ];

    final colors = [
      '#6366F1', // Indigo
      '#EC4899', // Pink
      '#10B981', // Green
      '#F59E0B', // Amber
      '#3B82F6', // Blue
      '#EF4444', // Red
      '#8B5CF6', // Purple
      '#06B6D4', // Cyan
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final trip = ref.read(currentTripProvider);

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Новая категория',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Название категории',
                        hintText: 'Например: Развлечения',
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Icon picker
                    Text(
                      'Иконка',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((iconData) {
                        final iconName = iconData.$1;
                        final emoji = iconData.$2;
                        final isSelected = selectedIcon == iconName;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedIcon = iconName),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.15)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Color picker
                    Text(
                      'Цвет',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color;
                        final colorValue = Color(int.parse('FF${color.substring(1)}', radix: 16));
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorValue,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nameController.text.trim().isNotEmpty
                            ? () {
                                ref.read(packingListProvider.notifier).addCategory(
                                  tripId: trip?.id ?? '',
                                  name: nameController.text.trim(),
                                  icon: selectedIcon,
                                  colorHex: selectedColor,
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Создать'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
