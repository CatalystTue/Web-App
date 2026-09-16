import 'package:catalyst_flutter_app/Features/initform/presentation/controller/initform_controller.dart';
import 'package:catalyst_flutter_app/Features/initform/presentation/initform_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('initform shows description and bullet-point helpers',
      (tester) async {
    Get.put(InitFormController());
    await tester.pumpWidget(
      const GetMaterialApp(home: InitFormScreen()),
    );

    expect(
      find.text('Write a short description of your research interests.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You can also give a description in brief bullet points, and the AI will draft a full one for you.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Instead of writing a description yourself, enter a few keywords and AI will draft one for you.',
      ),
      findsNothing,
    );
    expect(find.text('Bullet points'), findsOneWidget);
    expect(find.text('Keywords'), findsNothing);
  });
}
