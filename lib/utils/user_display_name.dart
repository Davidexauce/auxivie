/// Nettoyage du nom affiché (bug historique : concaténation avec experience = 0).
String sanitizeUserDisplayName(String name, {int? experience}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.length < 2 || !trimmed.endsWith('0')) return trimmed;
  final charBefore = trimmed[trimmed.length - 2];
  if (RegExp(r'[0-9]').hasMatch(charBefore)) return trimmed;
  final without = trimmed.substring(0, trimmed.length - 1);
  if (without.isEmpty || without.endsWith(' ')) return trimmed;
  return without;
}

String buildUserDisplayName({
  required String name,
  String? firstName,
  String? lastName,
  int? experience,
}) {
  final fn = firstName?.trim() ?? '';
  final ln = lastName?.trim() ?? '';
  String result;
  if (fn.isNotEmpty && ln.isNotEmpty) {
    result = '$fn $ln';
  } else if (fn.isNotEmpty) {
    result = fn;
  } else if (ln.isNotEmpty) {
    result = ln;
  } else {
    result = name.trim();
  }
  return sanitizeUserDisplayName(result, experience: experience);
}
