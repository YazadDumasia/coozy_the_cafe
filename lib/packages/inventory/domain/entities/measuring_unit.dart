import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

enum MeasuringUnit {
  unit(name: 'Unit'),
  piece(name: 'Piece'),
  dozen(name: 'Dozen'),
  pack(name: 'Pack'),
  box(name: 'Box'),
  cup(name: 'Cup'),
  slice(name: 'Slice'),
  can(name: 'Can'),
  bottle(name: 'Bottle'),
  jar(name: 'Jar'),
  bag(name: 'Bag'),
  bundle(name: 'Bundle'),
  milligram(name: 'Milligram'),
  gram(name: 'Gram'),
  kilogram(name: 'Kilogram'),
  liter(name: 'Liter'),
  milliliter(name: 'Milliliter'),
  ounce(name: 'Ounce'),
  pound(name: 'Pound'),
  gallon(name: 'Gallon'),
  pint(name: 'Pint'),
  quart(name: 'Quart');

  final String name;

  const MeasuringUnit({required this.name});

  /// The localization key from [shared.LocaleKeys] for this unit.
  String get localeKey {
    switch (this) {
      case MeasuringUnit.unit:
        return shared.LocaleKeys.menuItemPageUnitUnit;
      case MeasuringUnit.piece:
        return shared.LocaleKeys.menuItemPageUnitPiece;
      case MeasuringUnit.dozen:
        return shared.LocaleKeys.menuItemPageUnitDozen;
      case MeasuringUnit.pack:
        return shared.LocaleKeys.menuItemPageUnitPack;
      case MeasuringUnit.box:
        return shared.LocaleKeys.menuItemPageUnitBox;
      case MeasuringUnit.cup:
        return shared.LocaleKeys.menuItemPageUnitCup;
      case MeasuringUnit.slice:
        return shared.LocaleKeys.menuItemPageUnitSlice;
      case MeasuringUnit.can:
        return shared.LocaleKeys.menuItemPageUnitCan;
      case MeasuringUnit.bottle:
        return shared.LocaleKeys.menuItemPageUnitBottle;
      case MeasuringUnit.jar:
        return shared.LocaleKeys.menuItemPageUnitJar;
      case MeasuringUnit.bag:
        return shared.LocaleKeys.menuItemPageUnitBag;
      case MeasuringUnit.bundle:
        return shared.LocaleKeys.menuItemPageUnitBundle;
      case MeasuringUnit.milligram:
        return shared.LocaleKeys.menuItemPageUnitMilligram;
      case MeasuringUnit.gram:
        return shared.LocaleKeys.menuItemPageUnitGram;
      case MeasuringUnit.kilogram:
        return shared.LocaleKeys.menuItemPageUnitKilogram;
      case MeasuringUnit.liter:
        return shared.LocaleKeys.menuItemPageUnitLiter;
      case MeasuringUnit.milliliter:
        return shared.LocaleKeys.menuItemPageUnitMilliliter;
      case MeasuringUnit.ounce:
        return shared.LocaleKeys.menuItemPageUnitOunce;
      case MeasuringUnit.pound:
        return shared.LocaleKeys.menuItemPageUnitPound;
      case MeasuringUnit.gallon:
        return shared.LocaleKeys.menuItemPageUnitGallon;
      case MeasuringUnit.pint:
        return shared.LocaleKeys.menuItemPageUnitPint;
      case MeasuringUnit.quart:
        return shared.LocaleKeys.menuItemPageUnitQuart;
    }
  }

  /// Finds a [MeasuringUnit] matching [input] by its name (case-insensitive).
  static MeasuringUnit? fromString(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final normalized = input.trim().toLowerCase();
    for (final unit in MeasuringUnit.values) {
      if (unit.name.toLowerCase() == normalized) {
        return unit;
      }
    }
    return null;
  }
}
