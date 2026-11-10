import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/recipe.dart';
import '../state/app_state_controller.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final AppStateController state;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.state,
  });

  @override
  State<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _currentServings = 2;
  int _currentStep = 0;

  Timer? _cookingTimer;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isTimerRunning = false;

  Recipe? get _recipe {
    final idx = widget.state.recipes.indexWhere(
      (r) => r.id == widget.recipeId,
    );
    return idx != -1 ? widget.state.recipes[idx] : null;
  }

  @override
  void initState() {
    super.initState();
    final r = _recipe;
    if (r != null) {
      _currentServings = r.defaultServings;
      _totalSeconds = r.prepTimeMinutes * 60;
      _remainingSeconds = _totalSeconds;
    } else {
      _totalSeconds = 600;
      _remainingSeconds = 600;
    }
  }

  @override
  void dispose() {
    _cookingTimer?.cancel();
    super.dispose();
  }

  void _toggleCookingTimer() {
    final lang = widget.state.languageCode;
    if (_isTimerRunning) {
      _cookingTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _cookingTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        if (!mounted) return;
        if (_remainingSeconds > 1) {
          setState(() => _remainingSeconds -= 1);
        } else {
          timer.cancel();
          setState(() {
            _remainingSeconds = 0;
            _isTimerRunning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green[700],
              content: Text(
                AppStrings.tr('timer_finished_msg', lang),
              ),
            ),
          );
        }
      });
    }
  }

  void _pauseTimer() {
    _cookingTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetCookingTimer(int prepMinutes) {
    _cookingTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _totalSeconds = prepMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  String _formatDuration(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _confirmDelete(BuildContext context, Recipe recipe) {
    final lang = widget.state.languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('delete_recipe_title', lang)),
        content: Text(AppStrings.tr('delete_recipe_confirm', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.tr('cancel', lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              widget.state.removeRecipe(recipe.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.tr('recipe_deleted_msg', lang),
                  ),
                ),
              );
            },
            child: Text(AppStrings.tr('delete_btn', lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(Recipe recipe) {
    final path = recipe.imageUrl.trim();
    if (path.isNotEmpty) {
      if (path.startsWith('data:image')) {
        try {
          final base64Str = path.split(',').last;
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackHeader(),
          );
        } catch (_) {
          return _buildFallbackHeader();
        }
      }
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackHeader(),
        );
      }
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackHeader(),
      );
    }
    return _buildFallbackHeader();
  }

  Widget _buildFallbackHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 72,
          color: Colors.white54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final recipe = _recipe;
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final lang = widget.state.languageCode;
        final isAdmin = widget.state.isAdmin;
        final scaleFactor = _currentServings / recipe.defaultServings;
        final steps = recipe.getLocalizedSteps(lang);
        final timerProgress = _totalSeconds > 0
            ? (_remainingSeconds / _totalSeconds)
            : 0.0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: recipe.isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      widget.state.toggleFavorite(recipe.id);
                    },
                  ),

                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                      tooltip: AppStrings.tr('edit_recipe', lang),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeFormScreen(
                              state: widget.state,
                              existingRecipe: recipe,
                            ),
                          ),
                        );
                        if (mounted && _recipe != null) {
                          _resetCookingTimer(
                            _recipe!.prepTimeMinutes,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      tooltip: AppStrings.tr('delete_btn', lang),
                      onPressed: () =>
                          _confirmDelete(context, recipe),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.getLocalizedTitle(lang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 6, color: Colors.black54),
                      ],
                    ),
                  ),
                  background: _buildHeaderBackground(recipe),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.schedule,
                              size: 16,
                            ),
                            label: Text(
                              '${recipe.prepTimeMinutes} ${AppStrings.tr('minutes', lang)}',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.bolt, size: 16),
                            label: Text(
                              recipe.getLocalizedDifficulty(lang),
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.local_fire_department,
                              size: 16,
                            ),
                            label: Text('${recipe.calories} kcal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.35),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppStrings.tr(
                                        'timer_card_title',
                                        lang,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(
                                      _remainingSeconds,
                                    ),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: _isTimerRunning
                                          ? Colors.orange[800]
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: timerProgress,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isTimerRunning
                                    ? AppStrings.tr(
                                        'timer_running_status',
                                        lang,
                                      )
                                    : AppStrings.tr(
                                        'timer_paused_status',
                                        lang,
                                      ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _toggleCookingTimer,
                                      icon: Icon(
                                        _isTimerRunning
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      label: Text(
                                        _isTimerRunning
                                            ? AppStrings.tr(
                                                'timer_pause',
                                                lang,
                                              )
                                            : (_remainingSeconds <
                                                      _totalSeconds
                                                  ? AppStrings.tr(
                                                      'timer_resume',
                                                      lang,
                                                    )
                                                  : AppStrings.tr(
                                                      'timer_start',
                                                      lang,
                                                    )),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _resetCookingTimer(
                                          recipe.prepTimeMinutes,
                                        ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 18,
                                    ),
                                    label: Text(
                                      AppStrings.tr(
                                        'timer_reset',
                                        lang,
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppStrings.tr('servings', lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '$_currentServings ${AppStrings.tr('people', lang)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _currentServings.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: '$_currentServings',
                                onChanged: (val) {
                                  setState(
                                    () => _currentServings = val
                                        .round(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          leading: const Icon(
                            Icons.shopping_basket_outlined,
                          ),
                          title: Text(
                            AppStrings.tr('ingredients_title', lang),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          children: recipe.ingredients.map((ing) {
                            final scaled = ing.copyWithScaledAmount(
                              scaleFactor,
                            );
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.fiber_manual_record,
                                size: 10,
                              ),
                              title: Text(
                                scaled.getLocalizedName(lang),
                              ),
                              trailing: Text(
                                '${scaled.amount} ${scaled.getLocalizedUnit(lang)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        AppStrings.tr('steps_title', lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stepper(
                        physics: const NeverScrollableScrollPhysics(),
                        currentStep: _currentStep.clamp(
                          0,
                          steps.length - 1,
                        ),
                        onStepTapped: (step) =>
                            setState(() => _currentStep = step),
                        onStepContinue: () {
                          if (_currentStep < steps.length - 1) {
                            setState(() => _currentStep += 1);
                          } else {
                            _pauseTimer();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogCtx) => AlertDialog(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 48,
                                ),
                                title: Text(
                                  AppStrings.tr('done_cooking', lang),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                content: Text(
                                  'Bạn đã hoàn thành toàn bộ ${steps.length} bước chế biến món "${recipe.getLocalizedTitle(lang)}". Hệ thống sẽ thoát ra màn hình Công thức.',
                                  textAlign: TextAlign.center,
                                ),
                                actionsAlignment:
                                    MainAxisAlignment.center,
                                actions: [
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pop(
                                        dialogCtx,
                                      );
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text(
                                      'Thoát ra màn hình Công thức',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep -= 1);
                          }
                        },
                        steps: List.generate(steps.length, (idx) {
                          return Step(
                            title: Text(
                              '${AppStrings.tr('step_prefix', lang)} ${idx + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(steps[idx]),
                            ),
                            isActive: _currentStep >= idx,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}