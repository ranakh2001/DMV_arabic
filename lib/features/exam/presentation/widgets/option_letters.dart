const _arabicLetters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
const _englishLetters = ['A', 'B', 'C', 'D', 'E', 'F'];

/// Localized option marker (أ/ب/ج/د or A/B/C/D) for the option at [index].
String optionLetter(bool isAr, int index) => (isAr ? _arabicLetters : _englishLetters)[index];
