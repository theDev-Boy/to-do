/// Security sanitizer and validator for user inputs.
/// Protects against injection attacks and malformed data.
class Sanitizer {
  Sanitizer._();

  /// Maximum lengths for various input fields
  static const int maxTitleLength = 200;
  static const int maxDescriptionLength = 2000;
  static const int maxTagLength = 30;
  static const int maxTagsCount = 20;
  static const int maxSubtaskTitleLength = 150;
  static const int maxSubtasksCount = 50;
  static const int maxSearchQueryLength = 100;

  /// Safely truncate a string to at most [maxLen] characters.
  static String _truncate(String input, int maxLen) {
    if (input.length <= maxLen) return input;
    return input.substring(0, maxLen);
  }

  /// Strip control characters (except newlines and tabs) from a string.
  static String _stripControlChars(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
  }

  /// Sanitize a task title: trim, strip control characters, enforce length.
  static String sanitizeTitle(String input) {
    return _truncate(_stripControlChars(input.trim()), maxTitleLength);
  }

  /// Sanitize a task description: trim, strip control characters, enforce length.
  static String sanitizeDescription(String input) {
    return _truncate(_stripControlChars(input.trim()), maxDescriptionLength);
  }

  /// Sanitize a single tag: lowercase, trim, strip special chars, enforce length.
  /// Returns null if the tag is empty after sanitization.
  static String? sanitizeTag(String input) {
    var tag = input.trim().toLowerCase();
    // Only allow alphanumeric, spaces, hyphens, underscores, periods, hashes, and plus
    tag = tag.replaceAll(RegExp(r'[^\w\s\-\.\#\+]'), '');
    tag = tag.trim();
    if (tag.isEmpty) return null;
    return _truncate(tag, maxTagLength);
  }

  /// Validate a list of tags, returning only the valid unique ones.
  static List<String> sanitizeTags(List<String> tags) {
    final sanitized = tags
        .map((t) => sanitizeTag(t))
        .where((t) => t != null)
        .map((t) => t!)
        .toSet()
        .toList();
    return sanitized.take(maxTagsCount).toList();
  }

  /// Sanitize a subtask title.
  static String sanitizeSubtaskTitle(String input) {
    return _truncate(_stripControlChars(input.trim()), maxSubtaskTitleLength);
  }

  /// Sanitize a search query.
  static String sanitizeSearchQuery(String input) {
    return _truncate(_stripControlChars(input.trim()), maxSearchQueryLength);
  }

  /// Validate that priority is within the valid range [0, 4].
  static int validatePriority(int priority) {
    return priority.clamp(0, 4);
  }

  /// Validate that category index is within the valid range.
  static int validateCategoryIndex(int index, int categoryCount) {
    return index.clamp(0, categoryCount - 1);
  }

  /// Securely encode tags list with a unique delimiter unlikely in user input.
  static String encodeTags(List<String> tags) {
    return tags.join('|||');
  }

  /// Securely decode tags from stored string, handling malformed data.
  static List<String> decodeTags(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw.split('|||').where((t) => t.trim().isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  /// Safely parse a timestamp from JSON, returning null if invalid.
  static DateTime? safeDateTime(dynamic value) {
    if (value is int && value > 0) {
      // Reject unreasonably large or small timestamps (year 1900-2100)
      if (value < -2208988800000 || value > 4102444800000) return null;
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  /// Validate a UUID-like ID string.
  static bool isValidId(String id) {
    if (id.isEmpty || id.length > 64) return false;
    return RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(id);
  }
}
