import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/services_helper.dart';

class DigestService extends ServicesHelper {
  Future<Map<String, dynamic>?> consumeDigest({
    required String token,
    required SwipeOutcome outcome,
  }) async {
    final response = await request(
      '$baseURL/digest',
      serviceType: ServiceType.post,
      body: {
        'token': token,
        'outcome': outcome.apiValue,
      },
      requiredDefaultHeader: false,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
