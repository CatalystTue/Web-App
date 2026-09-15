enum ServiceType { get, post, put, patch, delete }

enum UserStatus { loggedIn, loggedOut }

enum SwipeOutcome {
  interest('interest'),
  noInterest('no_interest'),
  know('know');

  const SwipeOutcome(this.apiValue);
  final String apiValue;

  static SwipeOutcome? tryParse(String? value) {
    switch (value) {
      case 'interest':
        return SwipeOutcome.interest;
      case 'no_interest':
        return SwipeOutcome.noInterest;
      case 'know':
        return SwipeOutcome.know;
      default:
        return null;
    }
  }
}
