import 'package:get/get.dart';

import '../../domain/matches_repo.dart';

class MatchesController extends GetxController {
  late MatchesRepository repo;
  int totalCards = 9;

  MatchesController({
    required this.repo,
  });
}
