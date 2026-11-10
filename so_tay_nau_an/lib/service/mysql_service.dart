import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/meal_plan_item.dart';
import '../models/recipe.dart';

class MySqlQueryLog {
  final String timestamp;
  final String action;
  final String sql;

  MySqlQueryLog({
    required this.timestamp,
    required this.action,
    required this.sql,
  });
}

class MySqlService {
  static const String host = '10.0.2.2';
  static const int port = 3306;
  static const String user = 'root';
  static const String password = '';
  static const String databaseName = 'recipe_meal_planner';

  final List<MySqlQueryLog> queryLogs = [];

  void _recordQuery(String action, String sql) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    queryLogs.insert(
      0,
      MySqlQueryLog(timestamp: timeStr, action: action, sql: sql),
    );
    if (queryLogs.length > 30) {
      queryLogs.removeLast();
    }
    debugPrint('[MySQL $databaseName] [$action] $sql');
  }

  static bool isValidJpgImage(String imagePath) {
    final trimmed = imagePath.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    return trimmed.endsWith('.jpg');
  }

  Future<void> logSelectUser(String username) async {
    _recordQuery(
      'SELECT',
      "SELECT id, username, full_name, role FROM users WHERE username = '$username' LIMIT 1;",
    );
  }

  Future<void> logInsertUser(AppUser newUser) async {
    _recordQuery(
      'INSERT',
      "INSERT INTO users (id, username, password_hash, full_name, role) VALUES ('${newUser.id}', '${newUser.username}', '***', '${newUser.fullName}', '${newUser.role}');",
    );
  }

  Future<void> logInsertRecipe(Recipe recipe) async {
    _recordQuery(
      'INSERT',
      "INSERT INTO recipes (id, title_vi, title_en, category_id, image_url, prep_time_minutes, calories, is_vegetarian) VALUES ('${recipe.id}', '${recipe.titleVi}', '${recipe.titleEn}', '${recipe.categoryId}', '${recipe.imageUrl}', ${recipe.prepTimeMinutes}, ${recipe.calories}, ${recipe.isVegetarian ? 1 : 0});",
    );
  }

  Future<void> logUpdateRecipe(Recipe recipe) async {
    _recordQuery(
      'UPDATE',
      "UPDATE recipes SET title_vi='${recipe.titleVi}', image_url='${recipe.imageUrl}', calories=${recipe.calories}, prep_time_minutes=${recipe.prepTimeMinutes} WHERE id='${recipe.id}';",
    );
  }

  Future<void> logDeleteRecipe(String recipeId) async {
    _recordQuery(
      'DELETE',
      "DELETE FROM recipes WHERE id = '$recipeId';",
    );
  }

  Future<void> logInsertMealPlan(
    MealPlanItem item,
    String dietGoal,
  ) async {
    _recordQuery(
      'INSERT',
      "INSERT INTO meal_plan_items (id, day_of_week, meal_type, recipe_id, diet_goal) VALUES ('${item.id}', ${item.dayOfWeek}, '${item.mealType}', '${item.recipe.id}', '$dietGoal');",
    );
  }

  Future<void> logRandomizeMealPlan({
    required String scope,
    required String dietGoal,
    required int totalInserted,
  }) async {
    _recordQuery(
      'REPLACE',
      "DELETE FROM meal_plan_items WHERE scope='$scope'; INSERT INTO meal_plan_items /* $totalInserted meals randomized for goal=$dietGoal */;",
    );
  }

  Future<void> logSaveBmiProfile({
    required String userId,
    required double heightCm,
    required double weightKg,
    required double bmi,
    required String recommendedGoal,
    required int dailyCalorieLimit,
  }) async {
    _recordQuery(
      'REPLACE',
      "REPLACE INTO user_bmi_profiles (user_id, height_cm, weight_kg, bmi_value, recommended_goal, daily_calorie_limit) VALUES ('$userId', $heightCm, $weightKg, ${bmi.toStringAsFixed(1)}, '$recommendedGoal', $dailyCalorieLimit);",
    );
  }
}
