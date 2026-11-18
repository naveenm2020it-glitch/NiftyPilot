class QuoteModel {
  final int id;
  final String textEn;
  final String textTa;
  final String author;

  const QuoteModel({
    required this.id,
    required this.textEn,
    required this.textTa,
    required this.author,
  });

  String textForLocale(String langCode) => langCode == 'ta' ? textTa : textEn;
}
