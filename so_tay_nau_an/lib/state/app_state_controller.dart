import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/app_user.dart';
import '../models/ingredient.dart';
import '../models/meal_plan_item.dart';
import '../models/recipe.dart';
import '../models/team_member.dart';
import '../services/mysql_service.dart';

class AppStateController extends ChangeNotifier {
  static const String _storageKey =
      'recipe_meal_planner_saved_state_v1';

  final MySqlService mysqlService = MySqlService();
  final Random _random = Random();

  String languageCode = 'vi';
  late List<AppUser> users;
  AppUser? currentUser;

  late List<Recipe> recipes;
  late List<MealPlanItem> mealPlan;
  List<Ingredient> checklist = [];
  late List<TeamMember> members;

  String selectedDietGoal = 'maintain';

  double heightCm = 165.0;
  double weightKg = 60.0;
  int age = 21;
  String gender = 'male';

  AppStateController() {
    users = MockData.getInitialUsers();
    recipes = MockData.getInitialRecipes();
    mealPlan = MockData.getInitialMealPlan(recipes);
    members = MockData.getTeamMembers();
    syncMealPlanToChecklist();
    _loadPersistedState();
  }

  Map<String, dynamic> _ingToMap(Ingredient i) => {
    'id': i.id,
    'nameVi': i.nameVi,
    'nameEn': i.nameEn,
    'amount': i.amount,
    'unitVi': i.unitVi,
    'unitEn': i.unitEn,
    'isChecked': i.isChecked,
  };

  Ingredient _ingFromMap(Map<String, dynamic> m) => Ingredient(
    id: (m['id'] ?? '').toString(),
    nameVi: (m['nameVi'] ?? '').toString(),
    nameEn: (m['nameEn'] ?? '').toString(),
    amount: (m['amount'] is num)
        ? (m['amount'] as num).toDouble()
        : 1.0,
    unitVi: (m['unitVi'] ?? 'phần').toString(),
    unitEn: (m['unitEn'] ?? 'portion').toString(),
    isChecked: m['isChecked'] == true,
  );

  Map<String, dynamic> _recipeToMap(Recipe r) => {
    'id': r.id,
    'titleVi': r.titleVi,
    'titleEn': r.titleEn,
    'categoryId': r.categoryId,
    'imageUrl': r.imageUrl,
    'prepTimeMinutes': r.prepTimeMinutes,
    'difficultyVi': r.difficultyVi,
    'difficultyEn': r.difficultyEn,
    'defaultServings': r.defaultServings,
    'calories': r.calories,
    'isVegetarian': r.isVegetarian,
    'isFavorite': r.isFavorite,
    'ingredients': r.ingredients.map(_ingToMap).toList(),
    'stepsVi': r.stepsVi,
    'stepsEn': r.stepsEn,
  };

  Recipe _recipeFromMap(Map<String, dynamic> m) => Recipe(
    id: (m['id'] ?? '').toString(),
    titleVi: (m['titleVi'] ?? '').toString(),
    titleEn: (m['titleEn'] ?? '').toString(),
    categoryId: (m['categoryId'] ?? 'main').toString(),
    imageUrl: (m['imageUrl'] ?? '').toString(),
    prepTimeMinutes: (m['prepTimeMinutes'] is num)
        ? (m['prepTimeMinutes'] as num).toInt()
        : 25,
    difficultyVi: (m['difficultyVi'] ?? 'Dễ').toString(),
    difficultyEn: (m['difficultyEn'] ?? 'Easy').toString(),
    defaultServings: (m['defaultServings'] is num)
        ? (m['defaultServings'] as num).toInt()
        : 2,
    calories: (m['calories'] is num)
        ? (m['calories'] as num).toInt()
        : 350,
    isVegetarian: m['isVegetarian'] == true,
    isFavorite: m['isFavorite'] == true,
    ingredients: (m['ingredients'] as List<dynamic>? ?? [])
        .map((e) => _ingFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    stepsVi: (m['stepsVi'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    stepsEn: (m['stepsEn'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> _userToMap(AppUser u) => {
    'id': u.id,
    'username': u.username,
    'password': u.password,
    'fullName': u.fullName,
    'role': u.role,
  };

  AppUser _userFromMap(Map<String, dynamic> m) => AppUser(
    id: (m['id'] ?? '').toString(),
    username: (m['username'] ?? '').toString(),
    password: (m['password'] ?? '').toString(),
    fullName: (m['fullName'] ?? '').toString(),
    role: (m['role'] ?? 'user').toString(),
  );

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson == null || rawJson.isEmpty) return;

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(rawJson) as Map,
      );

      if (data['languageCode'] != null) {
        languageCode = data['languageCode'].toString();
      }
      if (data['users'] is List) {
        final loadedUsers = (data['users'] as List)
            .map(
              (e) =>
                  _userFromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        if (loadedUsers.isNotEmpty) {
          users = loadedUsers;
        }
      }
      if (data['currentUsername'] != null) {
        final savedUsername = data['currentUsername']
            .toString()
            .toLowerCase();
        for (final u in users) {
          if (u.username.toLowerCase() == savedUsername) {
            currentUser = u;
            break;
          }
        }
      }
      if (data['recipes'] is List) {
        final loadedRecipes = (data['recipes'] as List)
            .map(
              (e) =>
                  _recipeFromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        if (loadedRecipes.isNotEmpty) {
          recipes = loadedRecipes;
        }
      }
      if (data['mealPlan'] is List) {
        final List<MealPlanItem> loadedPlan = [];
        for (final item in (data['mealPlan'] as List)) {
          final m = Map<String, dynamic>.from(item as Map);
          final rId = (m['recipeId'] ?? '').toString();
          final idx = recipes.indexWhere((r) => r.id == rId);
          if (idx != -1) {
            loadedPlan.add(
              MealPlanItem(
                id: (m['id'] ?? '').toString(),
                dayOfWeek: (m['dayOfWeek'] is num)
                    ? (m['dayOfWeek'] as num).toInt()
                    : 1,
                mealType: (m['mealType'] ?? 'breakfast').toString(),
                recipe: recipes[idx],
              ),
            );
          }
        }
        if (loadedPlan.isNotEmpty) {
          mealPlan = loadedPlan;
        }
      }
      if (data['checklist'] is List) {
        checklist = (data['checklist'] as List)
            .map(
              (e) => _ingFromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      if (data['heightCm'] is num)
        heightCm = (data['heightCm'] as num).toDouble();
      if (data['weightKg'] is num)
        weightKg = (data['weightKg'] as num).toDouble();
      if (data['age'] is num) age = (data['age'] as num).toInt();
      if (data['gender'] != null) gender = data['gender'].toString();

      notifyListeners();
    } catch (_) {}
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'languageCode': languageCode,
        'users': users.map(_userToMap).toList(),
        'currentUsername': currentUser?.username,
        'recipes': recipes.map(_recipeToMap).toList(),
        'mealPlan': mealPlan
            .map(
              (m) => {
                'id': m.id,
                'dayOfWeek': m.dayOfWeek,
                'mealType': m.mealType,
                'recipeId': m.recipe.id,
              },
            )
            .toList(),
        'checklist': checklist.map(_ingToMap).toList(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'gender': gender,
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {}
  }

  bool get isAdmin => currentUser?.isAdmin ?? false;

  double get bmiValue {
    final hMeter = heightCm / 100.0;
    if (hMeter <= 0) return 22.0;
    return weightKg / (hMeter * hMeter);
  }

  String get recommendedDietGoal {
    final bmi = bmiValue;
    if (bmi < 18.5) return 'weight_gain';
    if (bmi < 23.0) return 'maintain';
    return 'weight_loss';
  }

  int get dailyCalorieLimit {
    final bmr = gender == 'male'
        ? (10 * weightKg + 6.25 * heightCm - 5 * age + 5)
        : (10 * weightKg + 6.25 * heightCm - 5 * age - 161);
    final tdee = (bmr * 1.35).round();
    final goal = recommendedDietGoal;
    if (goal == 'weight_loss') {
      return (tdee - 450).clamp(1100, 2200);
    } else if (goal == 'weight_gain') {
      return (tdee + 350).clamp(1600, 3000);
    }
    return tdee.clamp(1300, 2500);
  }

  void updateBmiProfile({
    double? newHeightCm,
    double? newWeightKg,
    int? newAge,
    String? newGender,
  }) {
    if (newHeightCm != null) heightCm = newHeightCm;
    if (newWeightKg != null) weightKg = newWeightKg;
    if (newAge != null) age = newAge;
    if (newGender != null) gender = newGender;

    mysqlService.logSaveBmiProfile(
      userId: currentUser?.id ?? 'guest',
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: bmiValue,
      recommendedGoal: recommendedDietGoal,
      dailyCalorieLimit: dailyCalorieLimit,
    );
    _savePersistedState();
    notifyListeners();
  }

  List<Recipe> getZeroExcessThreeMealCombo() {
    if (recipes.isEmpty) return [];
    final limit = dailyCalorieLimit;
    final sortedByCal = List<Recipe>.from(recipes)
      ..sort((a, b) => a.calories.compareTo(b.calories));

    for (int i = 0; i < sortedByCal.length; i++) {
      for (int j = i + 1; j < sortedByCal.length; j++) {
        for (int k = j + 1; k < sortedByCal.length; k++) {
          final total =
              sortedByCal[i].calories +
              sortedByCal[j].calories +
              sortedByCal[k].calories;
          if (total <= limit) {
            return [sortedByCal[i], sortedByCal[j], sortedByCal[k]];
          }
        }
      }
    }
    return sortedByCal.take(3).toList();
  }

  void applyComboToDay(int dayOfWeek, List<Recipe> combo) {
    if (combo.isEmpty) return;
    mealPlan.removeWhere((item) => item.dayOfWeek == dayOfWeek);
    final mealTypes = ['breakfast', 'lunch', 'dinner'];
    for (int i = 0; i < combo.length && i < 3; i++) {
      final newItem = MealPlanItem(
        id: 'mp_bmi_${DateTime.now().microsecondsSinceEpoch}_$i',
        dayOfWeek: dayOfWeek,
        mealType: mealTypes[i],
        recipe: combo[i],
      );
      mealPlan.add(newItem);
      mysqlService.logInsertMealPlan(newItem, recommendedDietGoal);
    }
    syncMealPlanToChecklist();
    _savePersistedState();
    notifyListeners();
  }

  int getRegulatedTargetCalories(String goal) {
    if (goal == 'weight_loss') return 1200;
    if (goal == 'weight_gain') return 2000;
    return 1600;
  }

  List<Recipe> _pickThreeMealsMatchingRegulatedKcal(String goal) {
    if (recipes.length < 3) return recipes;
    final targetKcal = getRegulatedTargetCalories(goal);
    final List<List<Recipe>> exactBand100To200 = [];
    final List<List<Recipe>> within200 = [];

    for (int i = 0; i < recipes.length; i++) {
      for (int j = 0; j < recipes.length; j++) {
        for (int k = 0; k < recipes.length; k++) {
          if (i == j || j == k || i == k) continue;
          final r1 = recipes[i];
          final r2 = recipes[j];
          final r3 = recipes[k];
          final total = r1.calories + r2.calories + r3.calories;
          final diff = (total - targetKcal).abs();
          if (diff >= 100 && diff <= 200) {
            exactBand100To200.add([r1, r2, r3]);
          } else if (diff < 100) {
            within200.add([r1, r2, r3]);
          }
        }
      }
    }

    if (exactBand100To200.isNotEmpty) {
      return exactBand100To200[_random.nextInt(
        exactBand100To200.length,
      )];
    }
    if (within200.isNotEmpty) {
      return within200[_random.nextInt(within200.length)];
    }
    return [recipes[0], recipes[1], recipes[2]];
  }

  void randomizeMealsForDay(int dayOfWeek, String goal) {
    selectedDietGoal = goal;
    final pickedThree = _pickThreeMealsMatchingRegulatedKcal(goal);
    if (pickedThree.length < 3) return;

    mealPlan.removeWhere((item) => item.dayOfWeek == dayOfWeek);
    final mealTypes = ['breakfast', 'lunch', 'dinner'];
    for (int i = 0; i < 3; i++) {
      mealPlan.add(
        MealPlanItem(
          id: 'mp_rnd_${DateTime.now().microsecondsSinceEpoch}_${mealTypes[i]}',
          dayOfWeek: dayOfWeek,
          mealType: mealTypes[i],
          recipe: pickedThree[i],
        ),
      );
    }
    mysqlService.logRandomizeMealPlan(
      scope: 'day_$dayOfWeek',
      dietGoal: goal,
      totalInserted: 3,
    );
    syncMealPlanToChecklist();
    _savePersistedState();
    notifyListeners();
  }

  void randomizeMealsForWeek(String goal) {
    selectedDietGoal = goal;
    mealPlan.clear();
    final mealTypes = ['breakfast', 'lunch', 'dinner'];
    for (int day = 1; day <= 7; day++) {
      final pickedThree = _pickThreeMealsMatchingRegulatedKcal(goal);
      if (pickedThree.length < 3) continue;
      for (int i = 0; i < 3; i++) {
        mealPlan.add(
          MealPlanItem(
            id: 'mp_wk_${day}_${mealTypes[i]}_${DateTime.now().microsecondsSinceEpoch}',
            dayOfWeek: day,
            mealType: mealTypes[i],
            recipe: pickedThree[i],
          ),
        );
      }
    }
    mysqlService.logRandomizeMealPlan(
      scope: 'full_week_1_to_7',
      dietGoal: goal,
      totalInserted: 21,
    );
    syncMealPlanToChecklist();
    _savePersistedState();
    notifyListeners();
  }

  List<Map<String, dynamic>>
  getSuggestedRecipesBySelectedIngredients() {
    final checkedItems = checklist.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) return [];

    final List<Map<String, dynamic>> results = [];
    for (final r in recipes) {
      int matchedCount = 0;
      final List<String> matchedNames = [];
      for (final rIng in r.ingredients) {
        final rVi = rIng.nameVi.toLowerCase();
        final rEn = rIng.nameEn.toLowerCase();
        final isMatch = checkedItems.any((c) {
          final cVi = c.nameVi.toLowerCase();
          final cEn = c.nameEn.toLowerCase();
          return rVi.contains(cVi) ||
              cVi.contains(rVi) ||
              rEn.contains(cEn) ||
              cEn.contains(rEn);
        });
        if (isMatch) {
          matchedCount++;
          matchedNames.add(rIng.getLocalizedName(languageCode));
        }
      }
      if (matchedCount > 0) {
        results.add({
          'recipe': r,
          'matchedCount': matchedCount,
          'totalIngredients': r.ingredients.length,
          'matchedNames': matchedNames,
        });
      }
    }

    results.sort(
      (a, b) => (b['matchedCount'] as int).compareTo(
        a['matchedCount'] as int,
      ),
    );
    return results;
  }

  bool login(String username, String password) {
    final cleanUser = username.trim().toLowerCase();
    mysqlService.logSelectUser(cleanUser);
    for (final u in users) {
      if (u.username.toLowerCase() == cleanUser &&
          u.password == password) {
        currentUser = u;
        _savePersistedState();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool register({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) {
    final cleanUser = username.trim().toLowerCase();
    final exists = users.any(
      (u) => u.username.toLowerCase() == cleanUser,
    );
    if (exists) return false;

    final newUser = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim(),
      password: password,
      fullName: fullName.trim(),
      role: role,
    );
    users.add(newUser);
    currentUser = newUser;
    mysqlService.logInsertUser(newUser);
    _savePersistedState();
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    _savePersistedState();
    notifyListeners();
  }

  void toggleLanguage() {
    languageCode = languageCode == 'vi' ? 'en' : 'vi';
    _savePersistedState();
    notifyListeners();
  }

  void setLanguage(String code) {
    if (languageCode != code) {
      languageCode = code;
      _savePersistedState();
      notifyListeners();
    }
  }

  void addRecipe(Recipe newRecipe) {
    if (!isAdmin) return;
    recipes.insert(0, newRecipe);
    mysqlService.logInsertRecipe(newRecipe);
    _savePersistedState();
    notifyListeners();
  }

  void updateRecipe(Recipe updatedRecipe) {
    if (!isAdmin) return;
    final idx = recipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (idx != -1) {
      recipes[idx] = updatedRecipe;
      for (int i = 0; i < mealPlan.length; i++) {
        if (mealPlan[i].recipe.id == updatedRecipe.id) {
          mealPlan[i] = MealPlanItem(
            id: mealPlan[i].id,
            dayOfWeek: mealPlan[i].dayOfWeek,
            mealType: mealPlan[i].mealType,
            recipe: updatedRecipe,
          );
        }
      }
      mysqlService.logUpdateRecipe(updatedRecipe);
      _savePersistedState();
      notifyListeners();
    }
  }

  void removeRecipe(String recipeId) {
    if (!isAdmin) return;
    recipes.removeWhere((r) => r.id == recipeId);
    mealPlan.removeWhere((item) => item.recipe.id == recipeId);
    mysqlService.logDeleteRecipe(recipeId);
    _savePersistedState();
    notifyListeners();
  }

  void toggleFavorite(String recipeId) {
    final index = recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      recipes[index].isFavorite = !recipes[index].isFavorite;
      _savePersistedState();
      notifyListeners();
    }
  }

  List<MealPlanItem> getMealsForDay(int dayOfWeek, String mealType) {
    return mealPlan
        .where(
          (item) =>
              item.dayOfWeek == dayOfWeek &&
              item.mealType == mealType,
        )
        .toList();
  }

  int getTotalCaloriesForDay(int dayOfWeek) {
    return mealPlan
        .where((item) => item.dayOfWeek == dayOfWeek)
        .fold(0, (sum, item) => sum + item.recipe.calories);
  }

  void addMealToPlan(int day, String mealType, Recipe recipe) {
    final newItem = MealPlanItem(
      id: 'mp_${DateTime.now().millisecondsSinceEpoch}',
      dayOfWeek: day,
      mealType: mealType,
      recipe: recipe,
    );
    mealPlan.add(newItem);
    mysqlService.logInsertMealPlan(newItem, selectedDietGoal);
    _savePersistedState();
    notifyListeners();
  }

  void removeMealFromPlan(String planId) {
    mealPlan.removeWhere((item) => item.id == planId);
    _savePersistedState();
    notifyListeners();
  }

  void syncMealPlanToChecklist() {
    final Map<String, Ingredient> merged = {};
    for (final plan in mealPlan) {
      for (final ing in plan.recipe.ingredients) {
        final key = ing.nameVi.toLowerCase();
        if (merged.containsKey(key)) {
          final existing = merged[key]!;
          merged[key] = Ingredient(
            id: existing.id,
            nameVi: existing.nameVi,
            nameEn: existing.nameEn,
            amount: existing.amount + ing.amount,
            unitVi: existing.unitVi,
            unitEn: existing.unitEn,
            isChecked: existing.isChecked,
          );
        } else {
          merged[key] = Ingredient(
            id: 'chk_${ing.id}_${DateTime.now().microsecondsSinceEpoch}',
            nameVi: ing.nameVi,
            nameEn: ing.nameEn,
            amount: ing.amount,
            unitVi: ing.unitVi,
            unitEn: ing.unitEn,
            isChecked: false,
          );
        }
      }
    }
    checklist = merged.values.toList();
    _savePersistedState();
    notifyListeners();
  }

  void addCustomChecklistItem(
    String name,
    double amount,
    String unit,
  ) {
    checklist.insert(
      0,
      Ingredient(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        nameVi: name,
        nameEn: name,
        amount: amount,
        unitVi: unit,
        unitEn: unit,
        isChecked: false,
      ),
    );
    _savePersistedState();
    notifyListeners();
  }

  void toggleChecklistItem(String id) {
    final idx = checklist.indexWhere((item) => item.id == id);
    if (idx != -1) {
      checklist[idx].isChecked = !checklist[idx].isChecked;
      _savePersistedState();
      notifyListeners();
    }
  }

  void removeChecklistItem(String id) {
    checklist.removeWhere((item) => item.id == id);
    _savePersistedState();
    notifyListeners();
  }

  void clearCompletedChecklistItems() {
    checklist.removeWhere((item) => item.isChecked);
    _savePersistedState();
    notifyListeners();
  }

  String _escDart(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n');

  String _escSql(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll("'", "''");

  String exportRecipesToDartCode() {
    final sb = StringBuffer();
    sb.writeln('  static List<Recipe> getInitialRecipes() {');
    sb.writeln('    return [');
    for (final r in recipes) {
      sb.writeln('      Recipe(');
      sb.writeln("        id: '${_escDart(r.id)}',");
      sb.writeln("        titleVi: '${_escDart(r.titleVi)}',");
      sb.writeln("        titleEn: '${_escDart(r.titleEn)}',");
      sb.writeln("        categoryId: '${_escDart(r.categoryId)}',");
      sb.writeln("        imageUrl: '${_escDart(r.imageUrl)}',");
      sb.writeln('        prepTimeMinutes: ${r.prepTimeMinutes},');
      sb.writeln(
        "        difficultyVi: '${_escDart(r.difficultyVi)}',",
      );
      sb.writeln(
        "        difficultyEn: '${_escDart(r.difficultyEn)}',",
      );
      sb.writeln('        defaultServings: ${r.defaultServings},');
      sb.writeln('        calories: ${r.calories},');
      sb.writeln('        isVegetarian: ${r.isVegetarian},');
      sb.writeln('        isFavorite: ${r.isFavorite},');
      sb.writeln('        ingredients: [');
      for (final i in r.ingredients) {
        sb.writeln(
          "          Ingredient(id: '${_escDart(i.id)}', nameVi: '${_escDart(i.nameVi)}', nameEn: '${_escDart(i.nameEn)}', amount: ${i.amount}, unitVi: '${_escDart(i.unitVi)}', unitEn: '${_escDart(i.unitEn)}'),",
        );
      }
      sb.writeln('        ],');
      sb.writeln(
        "        stepsVi: [${r.stepsVi.map((s) => "'${_escDart(s)}'").join(', ')}],",
      );
      sb.writeln(
        "        stepsEn: [${r.stepsEn.map((s) => "'${_escDart(s)}'").join(', ')}],",
      );
      sb.writeln('      ),');
    }
    sb.writeln('    ];');
    sb.writeln('  }');
    return sb.toString();
  }

  String exportRecipesToSqlCode() {
    final sb = StringBuffer();
    sb.writeln('INSERT IGNORE INTO recipes (');
    sb.writeln(
      '  id, title_vi, title_en, category_id, image_url, prep_time_minutes,',
    );
    sb.writeln(
      '  difficulty_vi, difficulty_en, default_servings, calories, is_vegetarian, is_favorite,',
    );
    sb.writeln('  steps_vi_json, steps_en_json');
    sb.writeln(') VALUES');
    for (int idx = 0; idx < recipes.length; idx++) {
      final r = recipes[idx];
      final stepsViJson = _escSql(jsonEncode(r.stepsVi));
      final stepsEnJson = _escSql(jsonEncode(r.stepsEn));
      final comma = idx == recipes.length - 1 ? ';' : ',';
      sb.writeln('(');
      sb.writeln(
        "  '${_escSql(r.id)}', '${_escSql(r.titleVi)}', '${_escSql(r.titleEn)}', '${_escSql(r.categoryId)}',",
      );
      sb.writeln(
        "  '${_escSql(r.imageUrl)}', ${r.prepTimeMinutes}, '${_escSql(r.difficultyVi)}', '${_escSql(r.difficultyEn)}',",
      );
      sb.writeln(
        "  ${r.defaultServings}, ${r.calories}, ${r.isVegetarian ? 'TRUE' : 'FALSE'}, ${r.isFavorite ? 'TRUE' : 'FALSE'},",
      );
      sb.writeln("  '$stepsViJson',");
      sb.writeln("  '$stepsEnJson'");
      sb.writeln(')$comma');
    }
    return sb.toString();
  }
}