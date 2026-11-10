import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../state/app_state_controller.dart';
import '../widgets/meal_slot_card.dart';

class MealPlannerScreen extends StatefulWidget {
  final AppStateController state;

  const MealPlannerScreen({super.key, required this.state});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  String _dietGoal =
      'maintain'; // 'weight_loss', 'maintain', 'weight_gain'

  void _openRecipeSelector(
    BuildContext context,
    int dayOfWeek,
    String mealType,
  ) {
    final lang = widget.state.languageCode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppStrings.tr('select_recipe_title', lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.state.recipes.length,
                  itemBuilder: (_, idx) {
                    final recipe = widget.state.recipes[idx];
                    return ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(recipe.getLocalizedTitle(lang)),
                      subtitle: Text('${recipe.calories} kcal'),
                      trailing: const Icon(Icons.add),
                      onTap: () {
                        widget.state.addMealToPlan(
                          dayOfWeek,
                          mealType,
                          recipe,
                        );
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.languageCode;
    final days = List.generate(7, (i) => i + 1);

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: false,
              tabs: days
                  .map(
                    (d) => Tab(text: AppStrings.tr('day_$d', lang)),
                  )
                  .toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: days.map((day) {
            final totalCals = widget.state.getTotalCaloriesForDay(
              day,
            );
            final regulatedTarget = widget.state
                .getRegulatedTargetCalories(_dietGoal);
            final diff = totalCals - regulatedTarget;
            final isWithinTolerance = diff.abs() <= 200;
            final progress = (totalCals / regulatedTarget).clamp(
              0.0,
              1.0,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shuffle,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.tr(
                                  'random_planner_title',
                                  lang,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _dietGoal,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'weight_loss',
                              child: Text(
                                AppStrings.tr(
                                  'goal_weight_loss',
                                  lang,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'maintain',
                              child: Text(
                                AppStrings.tr('goal_maintain', lang),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'weight_gain',
                              child: Text(
                                AppStrings.tr(
                                  'goal_weight_gain',
                                  lang,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _dietGoal = val);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  widget.state.randomizeMealsForDay(
                                    day,
                                    _dietGoal,
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppStrings.tr(
                                          'random_day_success',
                                          lang,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.today,
                                  size: 18,
                                ),
                                label: Text(
                                  AppStrings.tr(
                                    'random_day_btn',
                                    lang,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  widget.state.randomizeMealsForWeek(
                                    _dietGoal,
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppStrings.tr(
                                          'random_week_success',
                                          lang,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.date_range,
                                  size: 18,
                                ),
                                label: Text(
                                  AppStrings.tr(
                                    'random_week_btn',
                                    lang,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.4),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.tr('daily_calories', lang),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$totalCals / $regulatedTarget kcal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isWithinTolerance
                                    ? Colors.green[800]
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngưỡng quy định: ${regulatedTarget - 200} - ${regulatedTarget + 200} kcal (Chênh lệch: ${diff >= 0 ? "+$diff" : "$diff"} kcal)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isWithinTolerance
                                ? Colors.green[800]
                                : Colors.orange[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              widget.state.syncMealPlanToChecklist();
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.tr(
                                      'sync_success',
                                      lang,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.playlist_add_check,
                            ),
                            label: Text(
                              AppStrings.tr('sync_checklist', lang),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MealSlotCard(
                  title: AppStrings.tr('meal_breakfast', lang),
                  icon: Icons.wb_twilight,
                  accentColor: Colors.orange,
                  items: widget.state.getMealsForDay(
                    day,
                    'breakfast',
                  ),
                  langCode: lang,
                  onAddPressed: () =>
                      _openRecipeSelector(context, day, 'breakfast'),
                  onRemoveItem: widget.state.removeMealFromPlan,
                ),
                MealSlotCard(
                  title: AppStrings.tr('meal_lunch', lang),
                  icon: Icons.wb_sunny_outlined,
                  accentColor: Colors.blue,
                  items: widget.state.getMealsForDay(day, 'lunch'),
                  langCode: lang,
                  onAddPressed: () =>
                      _openRecipeSelector(context, day, 'lunch'),
                  onRemoveItem: widget.state.removeMealFromPlan,
                ),
                MealSlotCard(
                  title: AppStrings.tr('meal_dinner', lang),
                  icon: Icons.nights_stay_outlined,
                  accentColor: Colors.indigo,
                  items: widget.state.getMealsForDay(day, 'dinner'),
                  langCode: lang,
                  onAddPressed: () =>
                      _openRecipeSelector(context, day, 'dinner'),
                  onRemoveItem: widget.state.removeMealFromPlan,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
