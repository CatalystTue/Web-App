bool isValidAdminAssetName(String name) {
  if (name.isEmpty) return false;
  if (name == '.' || name == '..') return false;
  if (name.startsWith('.')) return false;
  if (name.contains('/') || name.contains(r'\')) return false;
  return true;
}
