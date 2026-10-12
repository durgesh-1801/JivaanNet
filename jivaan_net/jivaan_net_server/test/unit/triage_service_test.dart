import 'package:jivaan_net_server/src/triage/deterministic_triage_service.dart';
import 'package:test/test.dart';

void main() {
  group('DeterministicTriageService', () {
    test('returns critical for life-threatening keywords', () {
      expect(
        DeterministicTriageService.classify(
          description: 'Victim trapped under collapsed building',
        ),
        equals('critical'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Person unconscious after wall collapse',
        ),
        equals('critical'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Cardiac arrest reported at community hall',
        ),
        equals('critical'),
      );
    });

    test('returns high for urgent medical or hazard keywords', () {
      expect(
        DeterministicTriageService.classify(
          description: 'Severe injury with broken bone from falling branch',
        ),
        equals('high'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Active house fire spreading rapidly',
        ),
        equals('high'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Flash flooding entering ground floor rooms',
        ),
        equals('high'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Landslide blocked main exit route',
        ),
        equals('high'),
      );
    });

    test('returns low for supply or non-life-threatening requests', () {
      expect(
        DeterministicTriageService.classify(
          description: 'Clean drinking water needed and blanket supplies',
        ),
        equals('low'),
      );
      expect(
        DeterministicTriageService.classify(
          description: 'Family is safe, general query about relief camp',
        ),
        equals('low'),
      );
    });

    test(
      'returns conservative default (medium) for null or unclassified text',
      () {
        expect(
          DeterministicTriageService.classify(description: null),
          equals(DeterministicTriageService.defaultPriority),
        );
        expect(
          DeterministicTriageService.classify(description: ''),
          equals(DeterministicTriageService.defaultPriority),
        );
        expect(
          DeterministicTriageService.classify(
            description: 'Signal received from sector 7 near post office',
          ),
          equals('medium'),
        );
      },
    );

    test('is deterministic and produces repeatable output', () {
      const sample = 'Trapped in vehicle after bridge collapse';
      final run1 = DeterministicTriageService.classify(description: sample);
      final run2 = DeterministicTriageService.classify(description: sample);
      expect(run1, equals(run2));
      expect(run1, equals('critical'));
    });
  });
}
