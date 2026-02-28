class OCRParser {
  static String extractName(String text) {
    final lines = text.split('\n');

    for (var line in lines) {
      final cleaned = line.trim();

      if (cleaned.length > 3 &&
          !cleaned.toLowerCase().contains("government") &&
          !cleaned.toLowerCase().contains("india") &&
          !cleaned.contains(RegExp(r'\d')) &&
          !cleaned.contains("@") &&
          !cleaned.toLowerCase().contains("www")) {
        return cleaned;
      }
    }

    return "";
  }

  // static String extractPhone(String text) {
  //   final reg = RegExp(r'(\+?\d[\d\s-]{8,}\d)');
  //   return reg.firstMatch(text)?.group(0) ?? "";
  // }
  String extractPhone(String text) {
    final reg = RegExp(r'\b\d{8,15}\b');
    return reg.firstMatch(text)?.group(0) ?? "";
  }

  // String extractEmail(String text) {
  //   text = text.toUpperCase();
  //
  //   // Step 1: If normal email exists
  //   final normal = RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}');
  //   final normalMatch = normal.firstMatch(text);
  //   if (normalMatch != null) {
  //     return normalMatch.group(0) ?? "";
  //   }
  //
  //   // Step 2: If email is written after "EMAIL:"
  //   if (text.contains("EMAIL:")) {
  //     final parts = text.split("EMAIL:");
  //     if (parts.length > 1) {
  //       final afterEmail = parts[1].trim();
  //
  //       // take first word after EMAIL:
  //       final emailWord = afterEmail.split(" ").first;
  //
  //       if (emailWord.contains(".COM")) {
  //         return emailWord;
  //       }
  //     }
  //   }
  //
  //   // Step 3: Fallback: detect any word ending with .COM
  //   final dotCom = RegExp(r'\b[A-Z0-9._%+-]+\.COM\b');
  //   final match = dotCom.firstMatch(text);
  //   if (match != null) {
  //     return match.group(0) ?? "";
  //   }
  //
  //   return "";
  // }
  String extractEmail(String text) {
    final words = text.split(RegExp(r'\s+'));

    for (var word in words) {
      if (word.toUpperCase().endsWith(".COM")) {
        return word.trim();
      }
    }

    return "";
  }
  // static String extractEmail(String text) {
  //   final reg = RegExp(r'\S+@\S+\.\S+');
  //   return reg.firstMatch(text)?.group(0) ?? "";
  // }

  String extractWebsite(String text) {
    final reg = RegExp(r'www\.[^\s]+');
    final match = reg.firstMatch(text);

    if (match != null) {
      return match.group(0) ?? "";
    }

    return "";
  }

  static String extractCompany(String text) {
    final lines = text.split('\n');
    if (lines.length > 1) {
      return lines[1];
    }
    return "";
  }
}
