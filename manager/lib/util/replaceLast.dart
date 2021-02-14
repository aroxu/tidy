String replaceLast(String string, String substring, String replacement) {
  int index = string.lastIndexOf(substring);
  if (index == -1) return string;
  return string.substring(0, index) +
      replacement +
      string.substring(index + substring.length);
}
