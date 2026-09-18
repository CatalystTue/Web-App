Map<String, String> parseEnv(String source) {
  final values = <String, String>{};
  for (final rawLine in source.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) continue;
    final key = line.substring(0, separator).trim();
    var value = line.substring(separator + 1).trim();
    if (value.length >= 2) {
      final quote = value[0];
      if ((quote == '"' || quote == "'") && value.endsWith(quote)) {
        value = value.substring(1, value.length - 1);
      }
    }
    values[key] = value;
  }
  return values;
}
