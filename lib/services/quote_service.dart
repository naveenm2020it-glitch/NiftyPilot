import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';
import '../utils/date_utils_ext.dart';

class QuoteService {
  static const _kShownIds = 'dp_shown_quote_ids';
  static const _kTodayDate = 'dp_quote_date';
  static const _kTodayQuoteId = 'dp_quote_id';

  static const List<QuoteModel> _quotes = [
    QuoteModel(
      id: 1,
      textEn: 'Discipline is choosing between what you want now and what you want most.',
      textTa: 'ஒழுக்கம் என்பது இப்போது விரும்புவதற்கும், மிக முக்கியமாக விரும்புவதற்கும் இடையேயான தேர்வாகும்.',
      author: 'Abraham Lincoln',
    ),
    QuoteModel(
      id: 2,
      textEn: 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      textTa: 'நாம் தொடர்ந்து செய்வதே நாமாவோம். எனவே சிறப்பு என்பது ஒரு செயலல்ல, அது ஒரு பழக்கம்.',
      author: 'Aristotle',
    ),
    QuoteModel(
      id: 3,
      textEn: 'Simplicity is about subtracting the obvious and adding the meaningful.',
      textTa: 'எளிமை என்பது தேவையற்றதைக் கழித்து, அர்த்தமுள்ளதைச் சேர்ப்பதாகும்.',
      author: 'John Maeda',
    ),
    QuoteModel(
      id: 4,
      textEn: 'Focus on being productive instead of busy.',
      textTa: 'பரபரப்பாக இருப்பதை விட, பயனுள்ளதாக இருப்பதில் கவனம் செலுத்துங்கள்.',
      author: 'Tim Ferriss',
    ),
    QuoteModel(
      id: 5,
      textEn: 'Small daily improvements over time lead to stunning results.',
      textTa: 'தினசரி சிறிய முன்னேற்றங்கள் காலப்போக்கில் பிரமிக்க வைக்கும் வெற்றியைத் தரும்.',
      author: 'Robin Sharma',
    ),
    QuoteModel(
      id: 6,
      textEn: 'You do not rise to the level of your goals. You fall to the level of your systems.',
      textTa: 'நீங்கள் உங்கள் இலக்குகளின் உயரத்திற்கு உயர்வதில்லை; உங்கள் பழக்கங்களின் நிலைக்கே செல்கிறீர்கள்.',
      author: 'James Clear',
    ),
    QuoteModel(
      id: 7,
      textEn: 'The secret of getting ahead is getting started.',
      textTa: 'முன்னேறுவதற்கான ரகசியம், இப்போதே தொடங்குவதுதான்.',
      author: 'Mark Twain',
    ),
    QuoteModel(
      id: 8,
      textEn: 'Calmness of mind is one of the beautiful jewels of wisdom.',
      textTa: 'மன அமைதி என்பது ஞானத்தின் மிக அழகான அணிகலன்களில் ஒன்றாகும்.',
      author: 'James Allen',
    ),
    QuoteModel(
      id: 9,
      textEn: 'Do what you can, with what you have, where you are.',
      textTa: 'நீங்கள் இருக்கும் இடத்தில், உங்களிடம் உள்ளதைக் கொண்டு, உங்களால் முடிந்ததைச் செய்யுங்கள்.',
      author: 'Theodore Roosevelt',
    ),
    QuoteModel(
      id: 10,
      textEn: 'Action is the foundational key to all success.',
      textTa: 'செயல்பாடே அனைத்து வெற்றிகளுக்கும் அடிப்படைத் திறவுகோல்.',
      author: 'Pablo Picasso',
    ),
    QuoteModel(
      id: 11,
      textEn: 'Lost time is never found again.',
      textTa: 'இழந்த நேரம் மீண்டும் ஒருபோதும் கிடைப்பதில்லை.',
      author: 'Benjamin Franklin',
    ),
    QuoteModel(
      id: 12,
      textEn: 'What you do today can improve all your tomorrows.',
      textTa: 'இன்று நீங்கள் செய்யும் செயல் உங்கள் நாளைய நாட்கள் அனைத்தையும் மேம்படுத்தும்.',
      author: 'Ralph Marston',
    ),
    QuoteModel(
      id: 13,
      textEn: 'Start where you are. Use what you have. Do what you can.',
      textTa: 'இருக்கும் இடத்திலிருந்து தொடங்குங்கள். உள்ளதைப் பயன்படுத்துங்கள்.',
      author: 'Arthur Ashe',
    ),
    QuoteModel(
      id: 14,
      textEn: 'Success is the sum of small efforts, repeated day in and day out.',
      textTa: 'வெற்றி என்பது தினமும் மீண்டும் மீண்டும் செய்யப்படும் சிறிய முயற்சிகளின் கூட்டுத்தொகையாகும்.',
      author: 'Robert Collier',
    ),
    QuoteModel(
      id: 15,
      textEn: 'Where focus goes, energy flows.',
      textTa: 'எங்கே கவனம் செல்கிறதோ, அங்கே ஆற்றல் பாய்கிறது.',
      author: 'Tony Robbins',
    ),
    QuoteModel(
      id: 16,
      textEn: 'Be patient with yourself. Self-growth is tender; it is holy ground.',
      textTa: 'உங்களிடம் பொறுமையாக இருங்கள். சுய வளர்ச்சி என்பது மென்மையானது.',
      author: 'Stephen Covey',
    ),
    QuoteModel(
      id: 17,
      textEn: 'A year from now you may wish you had started today.',
      textTa: 'ஒரு வருடம் கழித்து, இன்று தொடங்கியிருக்கலாமே என்று நீங்கள் நினைக்கலாம்.',
      author: 'Karen Lamb',
    ),
    QuoteModel(
      id: 18,
      textEn: 'Clarity precedes mastery.',
      textTa: 'தெளிவே நிபுணத்துவத்திற்கு முன்னோடி.',
      author: 'Robin Sharma',
    ),
    QuoteModel(
      id: 19,
      textEn: 'One thing at a time. Most important thing first. Start now.',
      textTa: 'ஒரு நேரத்தில் ஒரு செயல். மிக முக்கியமானதை முதலில் செய்யுங்கள்.',
      author: 'Caroline Webb',
    ),
    QuoteModel(
      id: 20,
      textEn: 'The best way to predict the future is to create it.',
      textTa: 'எதிர்காலத்தைக் கணிப்பதற்கான சிறந்த வழி அதை உருவாக்குவதே.',
      author: 'Peter Drucker',
    ),
  ];

  Future<QuoteModel> getDailyQuote({bool forceNext = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateUtilsExt.toDateKey(DateTime.now());
    final savedDate = prefs.getString(_kTodayDate);
    final savedId = prefs.getInt(_kTodayQuoteId);

    if (!forceNext && savedDate == todayKey && savedId != null) {
      final existing = _quotes.where((q) => q.id == savedId).firstOrNull;
      if (existing != null) return existing;
    }

    final shownRaw = prefs.getStringList(_kShownIds) ?? [];
    final shownIds = shownRaw.map((e) => int.tryParse(e) ?? -1).toSet();

    var candidates = _quotes.where((q) => !shownIds.contains(q.id)).toList();
    if (candidates.isEmpty) {
      shownIds.clear();
      candidates = List<QuoteModel>.from(_quotes);
    }

    final selected = candidates[Random().nextInt(candidates.length)];
    shownIds.add(selected.id);

    await prefs.setString(_kTodayDate, todayKey);
    await prefs.setInt(_kTodayQuoteId, selected.id);
    await prefs.setStringList(_kShownIds, shownIds.map((e) => e.toString()).toList());

    return selected;
  }
}
