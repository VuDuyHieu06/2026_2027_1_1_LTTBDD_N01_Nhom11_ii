import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/meal_plan_item.dart';

class MealSlotCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<MealPlanItem> items;
  final String langCode;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onRemoveItem;

  const MealSlotCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
    required this.langCode,
    required this.onAddPressed,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.15),
              child: Icon(icon, color: accentColor),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              tooltip: AppStrings.tr('add_meal_btn', langCode),
              onPressed: onAddPressed,
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                AppStrings.tr('empty_meal', langCode),
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            )
          else
            ...items.map(
              (item) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle, size: 18, color: Colors.teal),
                title: Text(
                  item.recipe.getLocalizedTitle(langCode),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${item.recipe.prepTimeMinutes} ${AppStrings.tr('minutes', langCode)} • ${item.recipe.calories} kcal',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onRemoveItem(item.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
