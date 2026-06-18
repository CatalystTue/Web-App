import 'package:catalyst_flutter_app/Features/app_settings/data/repo/app_settings_repo_impl.dart';
import 'package:catalyst_flutter_app/Features/app_settings/presentation/controller/app_settings_controller.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/idea_card/data/repo/idea_card_repo_impl.dart';
import 'package:catalyst_flutter_app/Features/idea_card/presentation/controller/idea_card_controller.dart';
import 'package:catalyst_flutter_app/Features/matches/data/repo/matches_repo_impl.dart';
import 'package:catalyst_flutter_app/Features/matches/presentation/controller/matches_controller.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/data/repo/swipe_cards_repo_impl.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/presentation/controller/swipe_cards_controller.dart';

import 'package:get/get.dart';

class BaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseViewModel>(() => BaseViewModel());

    Get.lazyPut<IdeaCardController>(
        () => IdeaCardController(repo: IdeaCardRepositoryImpl()));

    Get.lazyPut<AppSettingsController>(
        () => AppSettingsController(repo: AppSettingsRepositoryImpl()));

    Get.lazyPut<SwipeCardsController>(
        () => SwipeCardsController(repo: SwipeCardsRepositoryImpl()));

    Get.lazyPut<MatchesController>(
        () => MatchesController(repo: MatchesRepositoryImpl()));
  }
}
