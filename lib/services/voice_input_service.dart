class VoiceInputService {
  static final RegExp _amountPattern =
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:taka|tk|bdt|dollar|usd)?', caseSensitive: false);

  static final Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': ['food', 'lunch', 'dinner', 'breakfast', 'snack', 'meal', 'restaurant', 'eat', 'coffee', 'tea', 'drink'],
    'Transportation': ['transport', 'bus', 'taxi', 'uber', 'rickshaw', 'fuel', 'gas', 'petrol', 'ride', 'cng', 'pathao'],
    'Shopping': ['shopping', 'buy', 'purchase', 'shop', 'clothes', 'shoes', 'dress'],
    'Entertainment': ['movie', 'game', 'fun', 'entertainment', 'concert', 'show', 'netflix'],
    'Bills & Utilities': ['bill', 'electricity', 'water', 'gas', 'internet', 'phone', 'mobile', 'utility', 'rent'],
    'Health': ['health', 'medicine', 'doctor', 'hospital', 'medical', 'pharmacy', 'gym'],
    'Education': ['education', 'book', 'course', 'tuition', 'school', 'college', 'university', 'study'],
    'Travel': ['travel', 'trip', 'tour', 'hotel', 'flight', 'vacation'],
    'Personal Care': ['salon', 'haircut', 'beauty', 'cosmetic', 'skincare'],
    'Gifts & Donations': ['gift', 'donation', 'charity', 'donate', 'present'],
  };

  static ParsedVoiceInput parse(String input) {
    final lowerInput = input.toLowerCase().trim();

    // Extract amount
    double? amount;
    final amountMatch = _amountPattern.firstMatch(lowerInput);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!);
    }

    // Extract category
    String? suggestedCategory;
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerInput.contains(keyword)) {
          suggestedCategory = entry.key;
          break;
        }
      }
      if (suggestedCategory != null) break;
    }

    // Extract title - remove amount and common words
    String title = lowerInput
        .replaceAll(_amountPattern, '')
        .replaceAll(RegExp(r'\b(add|spent|spend|for|on|taka|tk|bdt)\b'), '')
        .trim();
    if (title.isEmpty) {
      title = suggestedCategory ?? 'Expense';
    }
    // Capitalize first letter
    title = title[0].toUpperCase() + title.substring(1);

    return ParsedVoiceInput(
      amount: amount,
      title: title,
      suggestedCategory: suggestedCategory,
      rawInput: input,
    );
  }
}

class ParsedVoiceInput {
  final double? amount;
  final String title;
  final String? suggestedCategory;
  final String rawInput;

  const ParsedVoiceInput({
    this.amount,
    required this.title,
    this.suggestedCategory,
    required this.rawInput,
  });

  bool get isValid => amount != null && amount! > 0;
}
