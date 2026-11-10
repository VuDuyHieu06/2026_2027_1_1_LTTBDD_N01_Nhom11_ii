import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../state/app_state_controller.dart';

class BmiAdvisorScreen extends StatelessWidget {
  final AppStateController state;

  const BmiAdvisorScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.languageCode;
    final bmi = state.bmiValue;
    final recGoal = state.recommendedDietGoal;
    final maxKcal = state.dailyCalorieLimit;
    final plannedTodayKcal = state.getTotalCaloriesForDay(1);
    final remainingKcal = (maxKcal - plannedTodayKcal).clamp(
      0,
      maxKcal,
    );

    String statusText;
    Color statusColor;
    if (recGoal == 'weight_gain') {
      statusText = AppStrings.tr('bmi_status_under', lang);
      statusColor = Colors.blue[700]!;
    } else if (recGoal == 'maintain') {
      statusText = AppStrings.tr('bmi_status_normal', lang);
      statusColor = Colors.green[700]!;
    } else {
      statusText = AppStrings.tr('bmi_status_over', lang);
      statusColor = Colors.orange[800]!;
    }

    final safeCombo = state.getZeroExcessThreeMealCombo();
    final comboTotalKcal = safeCombo.fold(
      0,
      (sum, r) => sum + r.calories,
    );

    // Lọc các món ăn không vượt quá số Kcal còn lại cho phép trong ngày
    final safeDishes = state.recipes
        .where(
          (r) =>
              r.calories <=
              (remainingKcal > 0 ? remainingKcal : maxKcal),
        )
        .toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.tr('bmi_screen_title', lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'male',
                        icon: const Icon(Icons.male),
                        label: Text(
                          AppStrings.tr('bmi_gender_male', lang),
                        ),
                      ),
                      ButtonSegment(
                        value: 'female',
                        icon: const Icon(Icons.female),
                        label: Text(
                          AppStrings.tr('bmi_gender_female', lang),
                        ),
                      ),
                    ],
                    selected: {state.gender},
                    onSelectionChanged: (s) {
                      state.updateBmiProfile(newGender: s.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('bmi_height_label', lang)),
                      Text(
                        '${state.heightCm.round()} cm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.heightCm,
                    min: 140,
                    max: 200,
                    divisions: 60,
                    label: '${state.heightCm.round()} cm',
                    onChanged: (val) =>
                        state.updateBmiProfile(newHeightCm: val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('bmi_weight_label', lang)),
                      Text(
                        '${state.weightKg.round()} kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.weightKg,
                    min: 35,
                    max: 120,
                    divisions: 85,
                    label: '${state.weightKg.round()} kg',
                    onChanged: (val) =>
                        state.updateBmiProfile(newWeightKg: val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: statusColor.withValues(alpha: 0.1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: statusColor.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.tr('bmi_index_label', lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('bmi_budget_label', lang)),
                      Text(
                        '$maxKcal kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.tr('bmi_eaten_label', lang)),
                      Text('$plannedTodayKcal kcal'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.tr('bmi_remaining_label', lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$remainingKcal kcal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('bmi_combo_title', lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tổng năng lượng Combo: $comboTotalKcal / $maxKcal kcal (Dư an toàn: ${maxKcal - comboTotalKcal} kcal)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(safeCombo.length, (idx) {
                    final dish = safeCombo[idx];
                    final mealLabels = [
                      AppStrings.tr('meal_breakfast', lang),
                      AppStrings.tr('meal_lunch', lang),
                      AppStrings.tr('meal_dinner', lang),
                    ];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                        '${mealLabels[idx]}: ${dish.getLocalizedTitle(lang)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        '${dish.calories} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        state.applyComboToDay(1, safeCombo);
                        ScaffoldMessenger.of(context).showSnackBar(
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
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        AppStrings.tr('bmi_apply_combo_btn', lang),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr('bmi_safe_dishes_title', lang),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          ...safeDishes.map(
            (r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.verified_outlined,
                  color: Colors.green,
                ),
                title: Text(r.getLocalizedTitle(lang)),
                subtitle: Text(
                  '${r.prepTimeMinutes} ${AppStrings.tr('minutes', lang)}',
                ),
                trailing: Chip(label: Text('${r.calories} kcal')),
                onTap: () => state.addMealToPlan(1, 'lunch', r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
