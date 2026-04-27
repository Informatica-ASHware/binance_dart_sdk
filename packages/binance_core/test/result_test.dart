import 'package:ash_binance_api_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result Success', () {
    test('stores value correctly', () {
      const result = Success<int, String>(10);
      expect(result.value, 10);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });
  });

  group('Result Failure', () {
    test('stores error correctly', () {
      const result = Failure<int, String>('error');
      expect(result.error, 'error');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });
  });

  group('Result Equality', () {
    test('works correctly', () {
      const s1 = Success<int, String>(10);
      const s2 = Success<int, String>(10);
      const s3 = Success<int, String>(20);

      const f1 = Failure<int, String>('error');
      const f2 = Failure<int, String>('error');
      const f3 = Failure<int, String>('other error');

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(f1, equals(f2));
      expect(f1, isNot(equals(f3)));
      expect(s1, isNot(equals(f1)));
    });
  });

  group('Result hashCode', () {
    test('works', () {
      const s1 = Success<int, String>(10);
      const s2 = Success<int, String>(10);
      expect(s1.hashCode, equals(s2.hashCode));

      const f1 = Failure<int, String>('error');
      const f2 = Failure<int, String>('error');
      expect(f1.hashCode, equals(f2.hashCode));
    });
  });

  group('Result fold', () {
    test('fold on Success', () {
      const result = Result<int, String>.success(10);
      final value = result.fold(onSuccess: (v) => v * 2, onFailure: (e) => 0);
      expect(value, 20);
    });

    test('fold on Failure', () {
      const result = Result<int, String>.failure('error');
      final value = result.fold(onSuccess: (v) => v * 2, onFailure: (e) => 0);
      expect(value, 0);
    });
  });

  group('Result factory constructors', () {
    test('success factory', () {
      const result = Result<int, String>.success(10);
      expect(result, isA<Success<int, String>>());
      expect(result, equals(const Success<int, String>(10)));
    });

    test('failure factory', () {
      const result = Result<int, String>.failure('error');
      expect(result, isA<Failure<int, String>>());
      expect(result, equals(const Failure<int, String>('error')));
    });
  });
}
