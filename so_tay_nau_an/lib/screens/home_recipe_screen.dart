import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/recipe.dart';
import '../state/app_state_controller.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class HomeRecipeScreen extends StatefulWidget {
  final AppStateController state;

  const HomeRecipeScreen({super.key, required this.state});

  @override
  State<HomeRecipeScreen> createState() => _HomeRecipeScreenState();
}

class _HomeRecipeScreenState extends State<HomeRecipeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _onlyVegetarian = false;

  Widget _buildCardImage(Recipe recipe, String langCode) {
    final path = recipe.imageUrl.trim();
    if (path.isNotEmpty) {
      if (path.startsWith('data:image')) {
        try {
          final base64Str = path.split(',').last.trim();
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildFallbackBanner(recipe, langCode),
          );
        } catch (_) {
          return _buildFallbackBanner(recipe, langCode);
        }
      }
      if (path.startsWith('http') || path.startsWith('blob:')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildFallbackBanner(recipe, langCode),
        );
      }
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackBanner(recipe, langCode),
      );
    }
    return _buildFallbackBanner(recipe, langCode);
  }

  Widget _buildFallbackBanner(Recipe recipe, String langCode) {
    IconData iconData = Icons.restaurant_menu;
    List<Color> gradientColors = [
      const Color(0xFFFEF3C7),
      const Color(0xFFFDE68A),
    ];
    Color iconColor = const Color(0xFFB45309);

    if (recipe.categoryId == 'soup') {
      iconData = Icons.soup_kitchen;
      gradientColors = [
        const Color(0xFFDCFCE7),
        const Color(0xFFBBF7D0),
      ];
      iconColor = const Color(0xFF15803D);
    } else if (recipe.categoryId == 'dessert') {
      iconData = Icons.icecream;
      gradientColors = [
        const Color(0xFFFCE7F3),
        const Color(0xFFFBCFE8),
      ];
      iconColor = const Color(0xFFBE185D);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 42, color: iconColor),
          const SizedBox(height: 4),
          Text(
            AppStrings.tr('no_image_label', langCode),
            style: TextStyle(
              fontSize: 11,
              color: iconColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGridCard(Recipe recipe, String lang) {
    return Card(
      key: ValueKey('${recipe.id}_${recipe.imageUrl.length}'),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(
                recipeId: recipe.id,
                state: widget.state,
              ),
            ),
          );
          if (mounted) setState(() {});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCardImage(recipe, lang),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite
                              ? Colors.redAccent
                              : Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: () =>
                            widget.state.toggleFavorite(recipe.id),
                      ),
                    ),
                  ),
                  if (recipe.isVegetarian)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.tr('cat_veg', lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.getLocalizedTitle(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTimeMinutes} ${AppStrings.tr('minutes', lang)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.calories} kcal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final lang = widget.state.languageCode;
        final isAdmin = widget.state.isAdmin;

        final categories = [
          {'id': 'all', 'label': AppStrings.tr('cat_all', lang)},
          {'id': 'main', 'label': AppStrings.tr('cat_main', lang)},
          {'id': 'soup', 'label': AppStrings.tr('cat_soup', lang)},
          {
            'id': 'dessert',
            'label': AppStrings.tr('cat_dessert', lang),
          },
        ];

        final filteredRecipes = widget.state.recipes.where((recipe) {
          final title = recipe.getLocalizedTitle(lang).toLowerCase();
          final matchesSearch = title.contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == 'all' ||
              recipe.categoryId == _selectedCategory;
          final matchesVeg = !_onlyVegetarian || recipe.isVegetarian;
          return matchesSearch && matchesCategory && matchesVeg;
        }).toList();

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: AppStrings.tr('search_hint', lang),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    ...categories.map((cat) {
                      final isSelected =
                          _selectedCategory == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat['label']!),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(
                              () => _selectedCategory = cat['id']!,
                            );
                          },
                        ),
                      );
                    }),
                    FilterChip(
                      label: Text(AppStrings.tr('only_veg', lang)),
                      selected: _onlyVegetarian,
                      onSelected: (val) =>
                          setState(() => _onlyVegetarian = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredRecipes.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.tr('no_recipes', lang),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return _buildRecipeGridCard(recipe, lang);
                        },
                      ),
              ),
            ],
          ),

          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecipeFormScreen(state: widget.state),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.tr('add_recipe', lang)),
                )
              : null,
        );
      },
    );
  }
}