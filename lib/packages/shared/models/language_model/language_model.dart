class LanguageModel {
  LanguageModel({
    this.name,
    this.code,
    this.file,
    this.isRTL,
    this.countryCode,
  });
  final String? name;
  final String? code;
  final String? file;
  final bool? isRTL;
  final String? countryCode;

  static List<LanguageModel> getLanguages() {
    return <LanguageModel>[
      LanguageModel(
        name: 'English',
        code: 'en',
        file: 'locale_en.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'English (United States)',
        code: 'en',
        countryCode: 'US',
        file: 'locale_en_us.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'English (United Kingdom)',
        code: 'en',
        countryCode: 'GB',
        file: 'locale_en_gb.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'English (India)',
        code: 'en',
        countryCode: 'IN',
        file: 'locale_en_in.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'English (Australia)',
        code: 'en',
        countryCode: 'AU',
        file: 'locale_en_au.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Spanish (Spain)',
        code: 'es',
        countryCode: 'ES',
        file: 'locale_es_es.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Spanish (Mexico)',
        code: 'es',
        countryCode: 'MX',
        file: 'locale_es_mx.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'French (France)',
        code: 'fr',
        countryCode: 'FR',
        file: 'locale_fr_fr.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'French (Canada)',
        code: 'fr',
        countryCode: 'CA',
        file: 'locale_fr_ca.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Arabic (Saudi Arabia)',
        code: 'ar',
        countryCode: 'SA',
        file: 'locale_ar_sa.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Arabic (Egypt)',
        code: 'ar',
        countryCode: 'EG',
        file: 'locale_ar_eg.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Afrikaans',
        code: 'af',
        file: 'locale_af.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Amharic',
        code: 'am',
        file: 'locale_am.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Arabic',
        code: 'ar',
        file: 'locale_ar.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Azerbaijani',
        code: 'az',
        file: 'locale_az.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Belarusian',
        code: 'be',
        file: 'locale_be.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Bulgarian',
        code: 'bg',
        file: 'locale_bg.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Bengali Bangla',
        code: 'bn',
        file: 'locale_bn.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Bosnian',
        code: 'bs',
        file: 'locale_bs.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Catalan Valencian',
        code: 'ca',
        file: 'locale_ca.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Czech',
        code: 'cs',
        file: 'locale_cs.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Danish',
        code: 'da',
        file: 'locale_da.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'German',
        code: 'de',
        file: 'locale_de.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Modern Greek',
        code: 'el',
        file: 'locale_el.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Spanish Castilian',
        code: 'es',
        file: 'locale_es.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Estonian',
        code: 'et',
        file: 'locale_et.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Basque',
        code: 'eu',
        file: 'locale_eu.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Persian',
        code: 'fa',
        file: 'locale_fa.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Finnish',
        code: 'fi',
        file: 'locale_fi.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Filipino Pilipino',
        code: 'fil',
        file: 'locale_fil.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'French',
        code: 'fr',
        file: 'locale_fr.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Galician',
        code: 'gl',
        file: 'locale_gl.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Gujarati',
        code: 'gu',
        file: 'locale_gu.json',
        isRTL: false,
        countryCode: 'IN', // Gujarati is primarily used in India
      ),
      LanguageModel(
        name: 'Hebrew',
        code: 'he',
        file: 'locale_he.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Hindi',
        code: 'hi',
        file: 'locale_hi.json',
        isRTL: false,
        countryCode: 'IN', // Hindi is primary language of India
      ),
      LanguageModel(
        name: 'Croatian',
        code: 'hr',
        file: 'locale_hr.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Hungarian',
        code: 'hu',
        file: 'locale_hu.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Armenian',
        code: 'hy',
        file: 'locale_hy.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Indonesian',
        code: 'id',
        file: 'locale_id.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Icelandic',
        code: 'is',
        file: 'locale_is.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Italian',
        code: 'it',
        file: 'locale_it.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Japanese',
        code: 'ja',
        file: 'locale_ja.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Georgian',
        code: 'ka',
        file: 'locale_ka.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Kazakh',
        code: 'kk',
        file: 'locale_kk.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Khmer Central Khmer',
        code: 'km',
        file: 'locale_km.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Kannada',
        code: 'kn',
        file: 'locale_kn.json',
        isRTL: false,
        countryCode: 'IN', // Kannada is primarily used in India
      ),
      LanguageModel(
        name: 'Korean',
        code: 'ko',
        file: 'locale_ko.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Kirghiz Kyrgyz',
        code: 'ky',
        file: 'locale_ky.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Lao',
        code: 'lo',
        file: 'locale_lo.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Lithuanian',
        code: 'lt',
        file: 'locale_lt.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Latvian',
        code: 'lv',
        file: 'locale_lv.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Macedonian',
        code: 'mk',
        file: 'locale_mk.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Malayalam',
        code: 'ml',
        file: 'locale_ml.json',
        isRTL: false,
        countryCode: 'IN', // Malayalam is primarily used in India
      ),
      LanguageModel(
        name: 'Mongolian',
        code: 'mn',
        file: 'locale_mn.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Marathi',
        code: 'mr',
        file: 'locale_mr.json',
        isRTL: false,
        countryCode: 'IN', // Marathi is primarily used in India
      ),
      LanguageModel(
        name: 'Malay',
        code: 'ms',
        file: 'locale_ms.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Burmese',
        code: 'my',
        file: 'locale_my.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Norwegian Bokmål',
        code: 'nb',
        file: 'locale_nb.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Nepali',
        code: 'ne',
        file: 'locale_ne.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Dutch Flemish',
        code: 'nl',
        file: 'locale_nl.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Panjabi Punjabi',
        code: 'pa',
        file: 'locale_pa.json',
        isRTL: false,
        countryCode: 'IN', // Punjabi is primarily used in India
      ),
      LanguageModel(
        name: 'Polish',
        code: 'pl',
        file: 'locale_pl.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Pushto Pashto',
        code: 'ps',
        file: 'locale_ps.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Portuguese',
        code: 'pt',
        file: 'locale_pt.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Romanian Moldavian Moldovan',
        code: 'ro',
        file: 'locale_ro.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Russian',
        code: 'ru',
        file: 'locale_ru.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Sinhala Sinhalese',
        code: 'si',
        file: 'locale_si.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Slovak',
        code: 'sk',
        file: 'locale_sk.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Slovenian',
        code: 'sl',
        file: 'locale_sl.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Albanian',
        code: 'sq',
        file: 'locale_sq.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Serbian',
        code: 'sr',
        file: 'locale_sr.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Swedish',
        code: 'sv',
        file: 'locale_sv.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Swahili',
        code: 'sw',
        file: 'locale_sw.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Tamil',
        code: 'ta',
        file: 'locale_ta.json',
        isRTL: false,
        countryCode: 'IN', // Tamil is primarily used in India
      ),
      LanguageModel(
        name: 'Telugu',
        code: 'te',
        file: 'locale_te.json',
        isRTL: false,
        countryCode: 'IN', // Telugu is primarily used in India
      ),
      LanguageModel(
        name: 'Thai',
        code: 'th',
        file: 'locale_th.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Tagalog',
        code: 'tl',
        file: 'locale_tl.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Turkish',
        code: 'tr',
        file: 'locale_tr.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Ukrainian',
        code: 'uk',
        file: 'locale_uk.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Urdu',
        code: 'ur',
        file: 'locale_ur.json',
        isRTL: true,
      ),
      LanguageModel(
        name: 'Uzbek',
        code: 'uz',
        file: 'locale_uz.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Vietnamese',
        code: 'vi',
        file: 'locale_vi.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Chinese',
        code: 'zh',
        file: 'locale_zh.json',
        isRTL: false,
      ),
      LanguageModel(
        name: 'Zulu',
        code: 'zu',
        file: 'locale_zu.json',
        isRTL: false,
      ),
    ];
  }

  static List<String> validateMissingFiles() {
    final List<String> missingFiles = <String>[];
    for (LanguageModel language in getLanguages()) {
      if (language.file != null && !_doesFileExist(language.file!)) {
        missingFiles.add(language.file!);
      }
    }
    return missingFiles;
  }

  static bool _doesFileExist(String fileName) {
    // This list contains all the valid locale files that exist in assets/locale/
    const Set<String> existingFiles = <String>{
      'locale_af.json',
      'locale_am.json',
      'locale_ar_eg.json',
      'locale_ar_sa.json',
      'locale_ar.json',
      'locale_az.json',
      'locale_be.json',
      'locale_bg.json',
      'locale_bn.json',
      'locale_bs.json',
      'locale_ca.json',
      'locale_cs.json',
      'locale_da.json',
      'locale_de.json',
      'locale_el.json',
      'locale_en_au.json',
      'locale_en_gb.json',
      'locale_en_in.json',
      'locale_en_us.json',
      'locale_en.json',
      'locale_es_es.json',
      'locale_es_mx.json',
      'locale_es.json',
      'locale_et.json',
      'locale_eu.json',
      'locale_fa.json',
      'locale_fi.json',
      'locale_fil.json',
      'locale_fr_ca.json',
      'locale_fr_fr.json',
      'locale_fr.json',
      'locale_gl.json',
      'locale_gu.json',
      // Add any other files that exist in your assets/locale folder
    };
    return existingFiles.contains(fileName);
  }

  @override
  String toString() {
    return 'LanguageModel{name: $name, code: $code, file: $file, isRTL: $isRTL, countryCode: $countryCode}';
  }
}
