import 'package:catalyst_flutter_app/Core/Components/html_preview_lockup.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const doubleAssets =
      'https://app.catalyst-app.org/assets/assets/png/catalyst_logo.png';
  const singleAssets =
      'https://app.catalyst-app.org/assets/png/catalyst_logo.png';

  test('rewrites both public lockup URLs and leaves other HTML', () {
    const html = '''
<img src="$doubleAssets" alt="a" />
<img src="$singleAssets" alt="b" />
<p>keep</p>
''';

    final result = htmlWithBundledMailLockup(html, 'data:image/png;base64,QQ==');

    expect(result, contains('src="data:image/png;base64,QQ=="'));
    expect(result, isNot(contains('app.catalyst-app.org')));
    expect(result, contains('<p>keep</p>'));
  });

  test('htmlPreviewSrcdoc embeds the bundled PNG', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const html = '<img src="$doubleAssets" />';
    final srcdoc = await htmlPreviewSrcdoc(html);
    final data = await rootBundle.load(mailLockupAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final expected = pngDataUri(bytes);

    expect(srcdoc, contains('<img src="$expected" />'));
    expect(expected, startsWith('data:image/png;base64,'));
    expect(bytes[0], 0x89);
  });
}
