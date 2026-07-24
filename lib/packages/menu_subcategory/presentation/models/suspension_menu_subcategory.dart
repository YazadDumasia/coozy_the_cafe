import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/shared/widgets/widgets.dart';

class SuspensionMenuSubcategory extends ISuspensionBean {
  final MenuSubcategory subcategory;

  SuspensionMenuSubcategory(this.subcategory);

  @override
  String getSuspensionTag() {
    if (subcategory.name != null && subcategory.name!.isNotEmpty) {
      return subcategory.name![0].toUpperCase();
    }
    return '';
  }
}
