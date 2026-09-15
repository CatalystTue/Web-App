import 'package:catalyst_flutter_app/Features/admin_auth/admin_asset_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a single path-safe file name', () {
    expect(isValidAdminAssetName('logo.png'), isTrue);
    expect(isValidAdminAssetName('affiliations.csv'), isTrue);
    expect(isValidAdminAssetName('a'), isTrue);
  });

  test('rejects empty, dots, hidden, and path separators', () {
    expect(isValidAdminAssetName(''), isFalse);
    expect(isValidAdminAssetName('.'), isFalse);
    expect(isValidAdminAssetName('..'), isFalse);
    expect(isValidAdminAssetName('.env'), isFalse);
    expect(isValidAdminAssetName('foo/bar'), isFalse);
    expect(isValidAdminAssetName(r'foo\bar'), isFalse);
  });
}
