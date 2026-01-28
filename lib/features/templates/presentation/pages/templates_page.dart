import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Mock templates for demo
    final templates = [
      _MockTemplate(
        name: 'Поход в горы',
        tripType: 'hike',
        itemCount: 45,
        usageCount: 3,
      ),
      _MockTemplate(
        name: 'Пляжный отдых',
        tripType: 'beach',
        itemCount: 32,
        usageCount: 5,
      ),
      _MockTemplate(
        name: 'Командировка Москва',
        tripType: 'business',
        itemCount: 28,
        usageCount: 8,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои шаблоны'),
        automaticallyImplyLeading: false,
      ),
      body: templates.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTemplateCard(context, template);
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет сохранённых шаблонов',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Создай список и сохрани его как шаблон',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, _MockTemplate template) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Load template logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Загружаем "${template.name}"...'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getTripTypeColor(template.tripType).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getTripTypeIcon(template.tripType),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${template.itemCount} вещей • Использован ${template.usageCount} раз',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTripTypeIcon(String type) {
    const icons = {
      'hike': '🏔️',
      'beach': '🏖️',
      'city': '🏙️',
      'business': '💼',
      'other': '✈️',
    };
    return icons[type] ?? '✈️';
  }

  Color _getTripTypeColor(String type) {
    switch (type) {
      case 'hike':
        return AppColors.tripHike;
      case 'beach':
        return AppColors.tripBeach;
      case 'city':
        return AppColors.tripCity;
      case 'business':
        return AppColors.tripBusiness;
      default:
        return AppColors.tripOther;
    }
  }
}

class _MockTemplate {
  final String name;
  final String tripType;
  final int itemCount;
  final int usageCount;

  _MockTemplate({
    required this.name,
    required this.tripType,
    required this.itemCount,
    required this.usageCount,
  });
}
