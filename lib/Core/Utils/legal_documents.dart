import 'legal_documents_stub.dart'
    if (dart.library.html) 'legal_documents_web.dart';

class LegalDocuments {
  LegalDocuments._();

  static const termsOfUse = 'legal/terms_of_use.pdf';
  static const privacyNotice = 'legal/privacy_notice.pdf';

  static void openTermsOfUse() => openLegalDocument(termsOfUse);

  static void openPrivacyNotice() => openLegalDocument(privacyNotice);
}
