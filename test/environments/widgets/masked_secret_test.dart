import 'package:flutter_test/flutter_test.dart';

// Logic extracted from _EnvironmentRowState._looksLikeSecret for unit testing
bool _looksLikeSecret(String key) {
  final lower = key.toLowerCase();
  return lower.contains('key') ||
      lower.contains('token') ||
      lower.contains('secret') ||
      lower.contains('pass') ||
      lower.contains('pwd') ||
      lower.contains('auth') ||
      lower.contains('credential');
}

void main() {
  group('_looksLikeSecret', () {
    test('returns true for key containing "key"', () {
      expect(_looksLikeSecret('API_KEY'), isTrue);
      expect(_looksLikeSecret('api_key'), isTrue);
    });

    test('returns true for key containing "token"', () {
      expect(_looksLikeSecret('ACCESS_TOKEN'), isTrue);
    });

    test('returns true for key containing "secret"', () {
      expect(_looksLikeSecret('CLIENT_SECRET'), isTrue);
    });

    test('returns true for key containing "pass"', () {
      expect(_looksLikeSecret('DB_PASSWORD'), isTrue);
    });

    test('returns true for key containing "pwd"', () {
      expect(_looksLikeSecret('DB_PWD'), isTrue);
    });

    test('returns true for key containing "auth"', () {
      expect(_looksLikeSecret('AUTH_HEADER'), isTrue);
    });

    test('returns true for key containing "credential"', () {
      expect(_looksLikeSecret('GCP_CREDENTIAL'), isTrue);
    });

    test('returns false for plain non-sensitive keys', () {
      expect(_looksLikeSecret('BASE_URL'), isFalse);
      expect(_looksLikeSecret('TIMEOUT'), isFalse);
      expect(_looksLikeSecret('MAX_RETRIES'), isFalse);
      expect(_looksLikeSecret('HOST'), isFalse);
    });

    test('is case insensitive', () {
      expect(_looksLikeSecret('Api_Key'), isTrue);
      expect(_looksLikeSecret('Bearer_Token'), isTrue);
      expect(_looksLikeSecret('SECRET_WORD'), isTrue);
    });
  });
}
