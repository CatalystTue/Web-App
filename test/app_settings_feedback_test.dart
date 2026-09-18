import 'package:catalyst_flutter_app/Features/app_settings/presentation/app_settings_screen.dart';
import 'package:catalyst_flutter_app/Features/app_settings/presentation/controller/app_settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('settings lists Feedback with the other rows', (tester) async {
    Get.put(AppSettingsController());
    await tester.pumpWidget(
      const GetMaterialApp(home: AppSettingsScreen()),
    );

    final labels = [
      'Profile',
      'Terms of Use',
      'Privacy Notice',
      'Feedback',
      'Delete Account',
      'Logout',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }

    final feedbackY = tester.getTopLeft(find.text('Feedback')).dy;
    expect(
        tester.getTopLeft(find.text('Privacy Notice')).dy, lessThan(feedbackY));
    expect(tester.getTopLeft(find.text('Delete Account')).dy,
        greaterThan(feedbackY));
  });
}
