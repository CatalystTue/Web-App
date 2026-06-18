import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Features/auth/domain/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final service = AuthenticationService();

  @override
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    return await service.login({
      'username': username,
      'password': password,
    });
  }
}
