class Ingredient {
  final String id;
  final String nameVi;
  final String nameEn;
  final double amount;
  final String unitVi;
  final String unitEn;
  bool isChecked;

  Ingredient({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.amount,
    required this.unitVi,
    required this.unitEn,
    this.isChecked = false,
  });

  String getLocalizedName(String langCode) {
    return langCode == 'en' ? nameEn : nameVi;
  }

  String getLocalizedUnit(String langCode) {
    return langCode == 'en' ? unitEn : unitVi;
  }

  Ingredient copyWithScaledAmount(double factor) {
    return Ingredient(
      id: id,
      nameVi: nameVi,
      nameEn: nameEn,
      amount: double.parse((amount * factor).toStringAsFixed(1)),
      unitVi: unitVi,
      unitEn: unitEn,
      isChecked: isChecked,
    );
  }
}