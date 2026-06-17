import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/endpoints/data/curl_parser.dart';

void main() {
  group('CurlGenerator.generate', () {
    test('GET with no params produces clean URL', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users',
        method: 'GET',
        headers: {},
        params: {},
        body: '',
      );
      expect(result, equals('curl -X GET "https://api.example.com/users"'));
    });

    test('GET with params appends query string', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users',
        method: 'GET',
        headers: {},
        params: {'page': '1', 'size': '20'},
        body: '',
      );
      expect(result, contains('https://api.example.com/users?'));
      expect(result, contains('page=1'));
      expect(result, contains('size=20'));
    });

    test('params appended with & when URL already has query string', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users?tenant=demo',
        method: 'GET',
        headers: {},
        params: {'page': '1'},
        body: '',
      );
      expect(result, contains('https://api.example.com/users?tenant=demo&page=1'));
    });

    test('headers appear as -H flags', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users',
        method: 'GET',
        headers: {'Authorization': 'Bearer token123'},
        params: {},
        body: '',
      );
      expect(result, contains('-H "Authorization: Bearer token123"'));
    });

    test('POST with JSON body uses --data-raw with double-quote escaping', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users',
        method: 'POST',
        headers: {},
        params: {},
        body: '{"name":"John","role":"admin"}',
      );
      expect(result, contains('--data-raw'));
      expect(result, contains(r'\"name\"'));
      expect(result, contains(r'\"John\"'));
    });

    test('GET ignores body even if non-empty', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/users',
        method: 'GET',
        headers: {},
        params: {},
        body: '{"key":"value"}',
      );
      expect(result, isNot(contains('--data-raw')));
      expect(result, isNot(contains('-d')));
    });

    test('params with special characters are URL-encoded', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/search',
        method: 'GET',
        headers: {},
        params: {'q': 'hello world'},
        body: '',
      );
      expect(result, contains('q=hello+world'));
    });

    test('combined: params + headers + POST body', () {
      final result = CurlGenerator.generate(
        url: 'https://api.example.com/orders',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Tenant': 'demo',
        },
        params: {'version': '2'},
        body: '{"sku":"A-1"}',
      );
      expect(result, contains('?version=2'));
      expect(result, contains('-H "Content-Type: application/json"'));
      expect(result, contains('-H "X-Tenant: demo"'));
      expect(result, contains('--data-raw'));
      expect(result, contains(r'\"sku\"'));
    });
  });
}
