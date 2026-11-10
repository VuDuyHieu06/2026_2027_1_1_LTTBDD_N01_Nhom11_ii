import 'ingredient.dart';

class Recipe {
  final String id;
  final String titleVi;
  final String titleEn;
  final String categoryId;
  final String imageUrl;
  final int prepTimeMinutes;
  final String difficultyVi;
  final String difficultyEn;
  final int defaultServings;
  final int calories;
  final bool isVegetarian;
  bool isFavorite;
  final List<Ingredient> ingredients;
  final List<String> stepsVi;
  final List<String> stepsEn;

  Recipe({
    required this.id,
    required this.titleVi,
    required this.titleEn,
    required this.categoryId,
    this.imageUrl = '',
    required this.prepTimeMinutes,
    required this.difficultyVi,
    required this.difficultyEn,
    this.defaultServings = 2,
    required this.calories,
    this.isVegetarian = false,
    this.isFavorite = false,
    required this.ingredients,
    required this.stepsVi,
    required this.stepsEn,
  });

  String getLocalizedTitle(String langCode) {
    return langCode == 'en' ? titleEn : titleVi;
  }

  String getLocalizedDifficulty(String langCode) {
    return langCode == 'en' ? difficultyEn : difficultyVi;
  }

  List<String> getLocalizedSteps(String langCode) {
    return langCode == 'en' ? stepsEn : stepsVi;
  }
}