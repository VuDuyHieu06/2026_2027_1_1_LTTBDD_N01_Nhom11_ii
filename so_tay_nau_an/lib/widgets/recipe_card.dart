import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String langCode;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.langCode,
    required this.onTap,
    required this.onToggleFavorite,
  });

  Widget _buildRecipeVisual(BuildContext context) {
    final path = recipe.imageUrl.trim();
    if (path.isNotEmpty) {
      if (path.startsWith('data:image')) {
        try {
          final base64Str = path.split(',').last;
          return Image.memory(
            base64Decode(base64Str),
            key: ValueKey(path.hashCode),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildFallbackBanner(),
          );
        } catch (_) {
          return _buildFallbackBanner();
        }
      }
      if (path.startsWith('http')) {
        return Image.network(
          path,
          key: ValueKey(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildFallbackBanner(),
        );
      }
      return Image.asset(
        path,
        key: ValueKey(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildFallbackBanner(),
      );
    }
    return _buildFallbackBanner();
  }

  Widget _buildFallbackBanner() {
    IconData iconData = Icons.restaurant_menu;
    List<Color> gradientColors = [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
    Color iconColor = const Color(0xFFB45309);

    if (recipe.categoryId == 'soup') {
      iconData = Icons.soup_kitchen;
      gradientColors = [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)];
      iconColor = const Color(0xFF15803D);
    } else if (recipe.categoryId == 'dessert') {
      iconData = Icons.icecream;
      gradientColors = [const Color(0xFFFCE7F3), const Color(0xFFFBCFE8)];
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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildRecipeVisual(context)),
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
                          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.redAccent : Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: onToggleFavorite,
                      ),
                    ),
                  ),
                  if (recipe.isVegetarian)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.tr('cat_veg', langCode),
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
                    recipe.getLocalizedTitle(langCode),
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
                      Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTimeMinutes} ${AppStrings.tr('minutes', langCode)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      Icon(Icons.local_fire_department, size: 14, color: Colors.orange[700]),
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
}