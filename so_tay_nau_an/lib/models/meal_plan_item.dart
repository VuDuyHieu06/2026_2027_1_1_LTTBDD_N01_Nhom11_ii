import 'recipe.dart';

class MealPlanItem {
  final String id;
  final int dayOfWeek;
  final String mealType;
  final Recipe recipe;

  MealPlanItem({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.recipe,
  });
}
