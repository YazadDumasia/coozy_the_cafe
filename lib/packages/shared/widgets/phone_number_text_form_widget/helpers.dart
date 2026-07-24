import '../country_pickers/country.dart';

bool isNumeric(String s) =>
    s.isNotEmpty && int.tryParse(s.replaceAll('+', '')) != null;

String removeDiacritics(String str) {
  const String withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  const String withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

extension CountryExtensions on List<Country> {
  List<Country> stringSearch(String search) {
    search = removeDiacritics(search.toLowerCase());
    return where(
      (country) => isNumeric(search) || search.startsWith('+')
          ? country.phoneCode.contains(search)
          : removeDiacritics(
              country.name.replaceAll('+', '').toLowerCase(),
            ).contains(search),
    ).toList();
  }
}
