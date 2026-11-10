import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/recipe.dart';
import '../state/app_state_controller.dart';
import 'recipe_detail_screen.dart';

class ChecklistScreen extends StatelessWidget {
  final AppStateController state;

  const ChecklistScreen({super.key, required this.state});

  void _showAddIngredientDialog(BuildContext context) {
    final lang = state.languageCode;
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController(text: 'phần');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('add_custom_item', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.tr('item_name_hint', lang),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr(
                        'item_amount_hint',
                        lang,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: unitCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr(
                        'item_unit_hint',
                        lang,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.tr('cancel', lang)),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                state.addCustomChecklistItem(
                  nameCtrl.text.trim(),
                  double.tryParse(amountCtrl.text) ?? 1,
                  unitCtrl.text.trim().isEmpty
                      ? 'phần'
                      : unitCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(AppStrings.tr('add', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.languageCode;
    final items = state.checklist;
    final completedCount = items.where((i) => i.isChecked).length;
    final progress = items.isEmpty
        ? 0.0
        : completedCount / items.length;
    final suggestedByIngredients = state
        .getSuggestedRecipesBySelectedIngredients();

    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('checklist_progress', lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('$completedCount / ${items.length}'),
                      ],
                    ),
                  ),
                  if (completedCount > 0)
                    TextButton(
                      onPressed: state.clearCompletedChecklistItems,
                      child: Text(
                        AppStrings.tr('clear_checked', lang),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            color: Colors.teal.withValues(alpha: 0.08),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.teal.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppStrings.tr('suggest_by_ing_title', lang)} ($completedCount)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (completedCount == 0 ||
                      suggestedByIngredients.isEmpty)
                    Text(
                      AppStrings.tr('suggest_by_ing_empty', lang),
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        itemCount: suggestedByIngredients.length,
                        itemBuilder: (ctx, idx) {
                          final sug = suggestedByIngredients[idx];
                          final Recipe r = sug['recipe'] as Recipe;
                          final int matched =
                              sug['matchedCount'] as int;
                          final int total =
                              sug['totalIngredients'] as int;
                          final List<String> names =
                              sug['matchedNames'] as List<String>;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.restaurant,
                              size: 18,
                              color: Colors.teal,
                            ),
                            title: Text(
                              r.getLocalizedTitle(lang),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Khớp $matched/$total nguyên liệu: ${names.join(", ")}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(
                                          recipeId: r.id,
                                          state: state,
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Nấu ngay'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        AppStrings.tr('empty_checklist', lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            state.removeChecklistItem(item.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: item.isChecked,
                            onChanged: (_) =>
                                state.toggleChecklistItem(item.id),
                            title: Text(
                              item.getLocalizedName(lang),
                              style: TextStyle(
                                decoration: item.isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              '${item.amount} ${item.getLocalizedUnit(lang)}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIngredientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
