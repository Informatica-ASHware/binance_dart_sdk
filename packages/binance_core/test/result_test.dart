import 'package:binance_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success stores value correctly', () {
      const result = Result<int, String>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);

      final value = result.fold(
        onSuccess: (v) => v,
        onFailure: (e) => throw Exception('Should not be failure'),
      );
      expect(value, equals(42));
    });

    test('Failure stores error correctly', () {
      const result = Result<int, String>.failure('error');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);

      final error = result.fold(
        onSuccess: (v) => throw Exception('Should not be success'),
        onFailure: (e) => e,
      );
      expect(error, equals('error'));
    });

    test('Equality works correctly', () {
      expect(
        const Result<int, String>.success(42),
        equals(const Result<int, String>.success(42)),
      );
      expect(
        const Result<int, String>.failure('error'),
        equals(const Result<int, String>.failure('error')),
      );
      expect(
        const Result<int, String>.success(42),
        isNot(equals(const Result<int, String>.success(43))),
      );
      expect(
        const Result<int, String>.failure('error'),
        isNot(equals(const Result<int, String>.failure('error2'))),
      );
      expect(
        const Result<int, String>.success(42),
        isNot(equals(const Result<int, String>.failure('error'))),
      );
    });

    test('hashCode works', () {
      expect(const Success<int, String>(42).hashCode, equals(42.hashCode));
      expect(const Failure<int, String>('err').hashCode, equals('err'.hashCode));
    });
  });
}
