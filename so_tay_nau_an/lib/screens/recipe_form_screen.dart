import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_strings.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../state/app_state_controller.dart';

class RecipeFormScreen extends StatefulWidget {
  final AppStateController state;
  final Recipe? existingRecipe;

  const RecipeFormScreen({
    super.key,
    required this.state,
    this.existingRecipe,
  });

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleViCtrl;
  late TextEditingController _titleEnCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _prepTimeCtrl;
  late TextEditingController _caloriesCtrl;
  late TextEditingController _ingredientsViCtrl;
  late TextEditingController _ingredientsEnCtrl;
  late TextEditingController _stepsViCtrl;
  late TextEditingController _stepsEnCtrl;

  String? _pickedImageBase64;
  String? _pickedFileName;

  String _categoryId = 'main';
  String _difficulty = 'easy';
  bool _isVegetarian = false;

  bool get _isEditing => widget.existingRecipe != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRecipe;
    _titleViCtrl = TextEditingController(
      text: existing?.titleVi ?? '',
    );
    _titleEnCtrl = TextEditingController(
      text: existing?.titleEn ?? '',
    );

    final existingImg = existing?.imageUrl ?? '';
    if (existingImg.startsWith('data:image')) {
      _pickedImageBase64 = existingImg;
      _pickedFileName = 'anh_da_chon_tu_may.png';
      _imageUrlCtrl = TextEditingController(text: '');
    } else {
      _imageUrlCtrl = TextEditingController(text: existingImg);
    }

    _prepTimeCtrl = TextEditingController(
      text: (existing?.prepTimeMinutes ?? 25).toString(),
    );
    _caloriesCtrl = TextEditingController(
      text: (existing?.calories ?? 350).toString(),
    );
    _ingredientsViCtrl = TextEditingController(
      text: existing != null
          ? existing.ingredients.map((i) => i.nameVi).join('\n')
          : '',
    );
    _ingredientsEnCtrl = TextEditingController(
      text: existing != null
          ? existing.ingredients.map((i) => i.nameEn).join('\n')
          : '',
    );
    _stepsViCtrl = TextEditingController(
      text: existing != null ? existing.stepsVi.join('\n') : '',
    );
    _stepsEnCtrl = TextEditingController(
      text: existing != null ? existing.stepsEn.join('\n') : '',
    );

    if (existing != null) {
      _categoryId = existing.categoryId;
      _isVegetarian = existing.isVegetarian;
      if (existing.difficultyEn.toLowerCase() == 'medium') {
        _difficulty = 'medium';
      } else if (existing.difficultyEn.toLowerCase() == 'hard') {
        _difficulty = 'hard';
      } else {
        _difficulty = 'easy';
      }
    }
  }

  @override
  void dispose() {
    _titleViCtrl.dispose();
    _titleEnCtrl.dispose();
    _imageUrlCtrl.dispose();
    _prepTimeCtrl.dispose();
    _caloriesCtrl.dispose();
    _ingredientsViCtrl.dispose();
    _ingredientsEnCtrl.dispose();
    _stepsViCtrl.dispose();
    _stepsEnCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromDevice() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String =
            'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _pickedImageBase64 = base64String;
          _pickedFileName = pickedFile.name;
          _imageUrlCtrl.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở thư mục ảnh: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageBase64 != null &&
        _pickedImageBase64!.startsWith('data:image')) {
      try {
        final base64Str = _pickedImageBase64!.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }

    final urlText = _imageUrlCtrl.text.trim();
    if (urlText.startsWith('http')) {
      return Image.network(
        urlText,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('Không tải được ảnh xem trước từ URL này'),
        ),
      );
    }

    return Image.asset(
      urlText,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Center(child: Text('Đường dẫn tệp: $urlText')),
    );
  }

  void _saveForm() {
    final lang = widget.state.languageCode;
    if (!_formKey.currentState!.validate()) return;

    final ingViLines = _ingredientsViCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final ingEnLines = _ingredientsEnCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final parsedIngredients = List.generate(ingViLines.length, (
      index,
    ) {
      final viName = ingViLines[index];
      final enName = index < ingEnLines.length
          ? ingEnLines[index]
          : viName;
      return Ingredient(
        id: 'ing_${DateTime.now().millisecondsSinceEpoch}_$index',
        nameVi: viName,
        nameEn: enName,
        amount: 1,
        unitVi: 'phần',
        unitEn: 'portion',
      );
    });

    final stepViLines = _stepsViCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final stepEnLines = _stepsEnCtrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final finalStepsEn = List.generate(stepViLines.length, (index) {
      return index < stepEnLines.length
          ? stepEnLines[index]
          : stepViLines[index];
    });

    String diffVi = 'Dễ';
    String diffEn = 'Easy';
    if (_difficulty == 'medium') {
      diffVi = 'Trung bình';
      diffEn = 'Medium';
    } else if (_difficulty == 'hard') {
      diffVi = 'Khó';
      diffEn = 'Hard';
    }

    final finalImageUrl =
        (_pickedImageBase64 != null && _pickedImageBase64!.isNotEmpty)
        ? _pickedImageBase64!
        : _imageUrlCtrl.text.trim();

    final recipeObj = Recipe(
      id:
          widget.existingRecipe?.id ??
          'r_${DateTime.now().millisecondsSinceEpoch}',
      titleVi: _titleViCtrl.text.trim(),
      titleEn: _titleEnCtrl.text.trim().isEmpty
          ? _titleViCtrl.text.trim()
          : _titleEnCtrl.text.trim(),
      categoryId: _categoryId,
      imageUrl: finalImageUrl,
      prepTimeMinutes: int.tryParse(_prepTimeCtrl.text) ?? 25,
      difficultyVi: diffVi,
      difficultyEn: diffEn,
      defaultServings: widget.existingRecipe?.defaultServings ?? 2,
      calories: int.tryParse(_caloriesCtrl.text) ?? 300,
      isVegetarian: _isVegetarian,
      isFavorite: widget.existingRecipe?.isFavorite ?? false,
      ingredients: parsedIngredients,
      stepsVi: stepViLines,
      stepsEn: finalStepsEn,
    );

    if (_isEditing) {
      widget.state.updateRecipe(recipeObj);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr('form_updated_msg', lang)),
        ),
      );
    } else {
      widget.state.addRecipe(recipeObj);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr('form_saved_msg', lang)),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.languageCode;
    final hasImage =
        (_pickedImageBase64 != null &&
            _pickedImageBase64!.isNotEmpty) ||
        _imageUrlCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppStrings.tr('edit_recipe', lang)
              : AppStrings.tr('add_recipe', lang),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleViCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_title_vi', lang),
                border: const OutlineInputBorder(),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? AppStrings.tr('form_error', lang)
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleEnCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_title_en', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Hình ảnh món ăn (Dán URL bất kỳ hoặc Chọn ảnh trong máy)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _pickImageFromDevice,
                          icon: const Icon(
                            Icons.upload_file,
                            size: 18,
                          ),
                          label: const Text('Chọn ảnh trong máy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      onChanged: (val) {
                        setState(() {
                          if (val.trim().isNotEmpty) {
                            _pickedImageBase64 = null;
                            _pickedFileName = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Đường dẫn URL ảnh (https://...)',
                        hintText:
                            'Dán link ảnh bất kỳ (https://...) vào đây',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_pickedFileName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Đã chọn ảnh từ máy: $_pickedFileName',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _pickedImageBase64 = null;
                                _pickedFileName = null;
                              });
                            },
                            child: const Text('Xóa ảnh'),
                          ),
                        ],
                      ),
                    ],
                    if (hasImage) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: _buildImagePreview(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr('form_category', lang),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'main',
                        child: Text(AppStrings.tr('cat_main', lang)),
                      ),
                      DropdownMenuItem(
                        value: 'soup',
                        child: Text(AppStrings.tr('cat_soup', lang)),
                      ),
                      DropdownMenuItem(
                        value: 'dessert',
                        child: Text(
                          AppStrings.tr('cat_dessert', lang),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _categoryId = val ?? 'main'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _difficulty,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr(
                        'form_difficulty',
                        lang,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'easy',
                        child: Text(AppStrings.tr('diff_easy', lang)),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text(
                          AppStrings.tr('diff_medium', lang),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'hard',
                        child: Text(AppStrings.tr('diff_hard', lang)),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _difficulty = val ?? 'easy'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr(
                        'form_prep_time',
                        lang,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr('form_calories', lang),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppStrings.tr('form_is_veg', lang)),
              value: _isVegetarian,
              onChanged: (val) => setState(() => _isVegetarian = val),
            ),
            const Divider(height: 24),
            TextFormField(
              controller: _ingredientsViCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_ingredients_vi', lang),
                border: const OutlineInputBorder(),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? AppStrings.tr('form_error', lang)
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsEnCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_ingredients_en', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const Divider(height: 24),
            TextFormField(
              controller: _stepsViCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_steps_vi', lang),
                border: const OutlineInputBorder(),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? AppStrings.tr('form_error', lang)
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stepsEnCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppStrings.tr('form_steps_en', lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saveForm,
              icon: const Icon(Icons.save),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _isEditing
                      ? AppStrings.tr('form_update', lang)
                      : AppStrings.tr('form_save', lang),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}