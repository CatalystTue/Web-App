import 'package:catalyst_flutter_app/Features/app_settings/presentation/app_settings_screen.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/presentation/admin_auth_screen.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/presentation/binding/admin_auth_binding.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/presentation/admin_welcome_screen.dart';
import 'package:catalyst_flutter_app/Features/auth/presentation/auth_screen.dart';
import 'package:catalyst_flutter_app/Features/auth/presentation/binding/auth_binding.dart';
import 'package:catalyst_flutter_app/Features/Base/Binding/base_binding.dart';
import 'package:catalyst_flutter_app/Features/Base/base_view.dart';
import 'package:catalyst_flutter_app/Features/create_new_idea_card/presentation/binding/create_new_idea_card_binding.dart';
import 'package:catalyst_flutter_app/Features/create_new_idea_card/presentation/create_new_idea_card_screen.dart';
import 'package:catalyst_flutter_app/Features/initform/presentation/binding/initform_binding.dart';
import 'package:catalyst_flutter_app/Features/initform/presentation/initform_screen.dart';
import 'package:catalyst_flutter_app/Features/initform/presentation/llm_choice_screen.dart';
import 'package:catalyst_flutter_app/Features/idea_card/presentation/idea_card_screen.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';

import 'package:catalyst_flutter_app/Features/register/presentation/binding/register_binding.dart';
import 'package:catalyst_flutter_app/Features/register/presentation/register_screen.dart';
import 'package:catalyst_flutter_app/Features/recover_account/presentation/binding/recover_account_binding.dart';
import 'package:catalyst_flutter_app/Features/recover_account/presentation/recover_account_screen.dart';
import 'package:catalyst_flutter_app/Features/reset_password/presentation/reset_password_screen.dart';
import 'package:catalyst_flutter_app/Features/verify/presentation/verify_screen.dart';

import 'package:catalyst_flutter_app/Features/splash_screen/presentation/splash_view.dart';

import 'package:get/get.dart';

class AppRoutes {
  final splash = '/';
  final base = '/base';
  final register = '/register';
  final ideaCard = '/idea-card';
  final auth = '/auth';
  final settings = '/settings';
  final createNewIdeaCard = '/create-new-idea-card';
  final verify = '/verify';
  final recoverAccount = '/recover-account';
  final resetPassword = '/reset-password';
  final admin = '/admin';
  final adminWelcome = '/admin-welcome';
  final initform = '/initform';
  final llmChoice = '/llm-choice';
  final stackedCards = '/stacked-cards';

  List<GetPage> get pages {
    return [
      GetPage(
        name: splash,
        page: () => SplashView(),
      ),
      GetPage(
        name: base,
        binding: BaseBinding(),
        page: () => const AppBaseView(),
      ),
      GetPage(
        name: register,
        binding: RegisterBinding(),
        page: () => const RegisterScreen(),
      ),
      GetPage(
        name: ideaCard,
        binding: BaseBinding(),
        page: () => const IdeaCardScreen(),
      ),
      GetPage(
        name: auth,
        binding: AuthBinding(),
        page: () => const AuthScreen(),
      ),
      GetPage(
        name: settings,
        binding: BaseBinding(),
        page: () => const AppSettingsScreen(),
      ),
      GetPage(
        name: createNewIdeaCard,
        binding: CreateNewIdeaCardBinding(),
        page: () => const CreateNewIdeaCardScreen(),
      ),
      GetPage(
        name: verify,
        page: () => const VerifyScreen(),
      ),
      GetPage(
        name: recoverAccount,
        binding: RecoverAccountBinding(),
        page: () => const RecoverAccountScreen(),
      ),
      GetPage(
        name: resetPassword,
        page: () => const ResetPasswordScreen(),
      ),
      GetPage(
        name: admin,
        binding: AdminAuthBinding(),
        page: () => const AdminAuthScreen(),
      ),
      GetPage(
        name: adminWelcome,
        page: () => const AdminWelcomeScreen(),
      ),
      GetPage(
        name: initform,
        binding: InitFormBinding(),
        page: () => const InitFormScreen(),
      ),
      GetPage(
        name: llmChoice,
        page: () => const LlmChoiceScreen(),
      ),
      GetPage(
        name: stackedCards,
        page: () => const StackedCardsScreen(users: []),
      ),
    ];
  }
}
