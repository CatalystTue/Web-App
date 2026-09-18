import 'package:catalyst_flutter_app/Features/admin_auth/admin_mail_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('naive ISO is UTC, then shown local', () {
    final naive = parseMailPlanNextAt('2026-09-19T22:01:00');
    final zulu = parseMailPlanNextAt('2026-09-19T22:01:00Z');
    expect(naive, isNotNull);
    expect(zulu, isNotNull);
    expect(naive!.toUtc(), zulu!.toUtc());
    expect(naive.toUtc(), DateTime.utc(2026, 9, 19, 22, 1));
  });

  test('offset ISO is not treated as naive UTC', () {
    final offset = parseMailPlanNextAt('2026-09-19T00:01:00+02:00');
    expect(offset, isNotNull);
    expect(offset!.toUtc(), DateTime.utc(2026, 9, 18, 22, 1));
  });

  test('digest PUT body sends calendar date at UTC noon', () {
    final body = digestPlanBody(
      enabled: true,
      repeat: 'monthly',
      nextAt: DateTime(2026, 12, 1, 8, 30),
    );
    expect(body['enabled'], isTrue);
    expect(body['repeat'], 'monthly');
    expect(body['next_at'], '2026-12-01T12:00:00.000Z');
  });

  test('intro PUT body sends calendar date and omits repeat', () {
    final enabled = introPlanBody(
      enabled: true,
      nextAt: DateTime(2026, 12, 1, 8, 30),
    );
    expect(enabled.containsKey('repeat'), isFalse);
    expect(enabled['enabled'], isTrue);
    expect(enabled['next_at'], '2026-12-01T12:00:00.000Z');

    final disabled = introPlanBody(
      enabled: false,
      nextAt: DateTime(2026, 12, 1),
    );
    expect(disabled.containsKey('repeat'), isFalse);
    expect(disabled['next_at'], isNull);
  });

  test('enabled mail date is refused when before today', () {
    final now = DateTime(2026, 9, 18, 18, 0);
    expect(canPutEnabledMailDate(null, now: now), isFalse);
    expect(
      canPutEnabledMailDate(DateTime(2026, 9, 17), now: now),
      isFalse,
    );
    expect(
      canPutEnabledMailDate(DateTime(2026, 9, 18), now: now),
      isTrue,
    );
    expect(
      canPutEnabledMailDate(DateTime(2026, 9, 19), now: now),
      isTrue,
    );
  });

  test('parse maps enabled and monthly repeat from GET JSON', () {
    final plan = AdminMailPlan.parse(<String, dynamic>{
      'enabled': true,
      'repeat': 'monthly',
      'next_at': '2026-09-19T22:01:00',
    });
    expect(plan.enabled, isTrue);
    expect(plan.repeat, 'monthly');
    expect(plan.nextAt!.toUtc(), DateTime.utc(2026, 9, 19, 22, 1));
    expect(normalizeDigestRepeat('nope'), 'daily');
    expect(normalizeDigestRepeat('monthly'), 'monthly');
  });
}
