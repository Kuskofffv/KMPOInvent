import 'package:core/util/extension/extensions.dart';
import 'package:edit_distance/edit_distance.dart';

const _minNormalizedDistance = 0.1;

class TextSearchHelper {
  TextSearchHelper._();

  static final _jaroWinkler = JaroWinkler();

  static bool containsInList(List<String?> texts, String? query) {
    if (query.isNullOrEmpty() || texts.isNullOrEmpty()) {
      return true;
    }

    final queryWords = [query];

    return queryWords.any((element) => texts.any((text) {
          if (text.isNullOrEmpty()) {
            return false;
          }
          return containsWord(text!, element);
        }));
  }

  static bool contains(String text, String? query) {
    if (query.isNullOrEmpty()) {
      return true;
    }

    final queryWords = [query];

    return queryWords.any((element) => containsWord(text, element));
  }

  static bool containsWord(String text, String? query) {
    if (query.isNullOrEmpty()) {
      return true;
    }
    return text.containsIgnoreCase(query);
  }

  // ignore: unused_element
  static bool containsWordFuzzy(String text, String? query) {
    if (query.isNullOrEmpty()) {
      return true;
    }

    final words = text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final result1 = words.firstWhereOrNull((element) {
          final result = _jaroWinkler.normalizedDistance(element, query!);
          return result <= _minNormalizedDistance;
        }) !=
        null;
    final result2 = text.containsIgnoreCase(query);

    return result1 || result2;
  }
}
