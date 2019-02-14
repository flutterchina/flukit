bool isListEqual(List a, List b) {
  if (a == b) return true;
  if (a == null || b == null || a.length != b.length) return false;
  int i = 0;
  return a.every((e) => b[i++] == e);
}
