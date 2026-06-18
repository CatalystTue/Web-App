import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';

class BaseModel {
  int _currentNavigationbarIndex = 1;
  int get currentNavigationbarIndex => _currentNavigationbarIndex;
  void updateNavigationIndex(int index) => _currentNavigationbarIndex = index;

  List<StackUserModel> stackUsers = [];
  bool isLoadingStackUsers = false;
}
