import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kikoeta_app/services/kt_service.dart';

void main() {
  test('preemption uses the authenticated versioned job API', () async {
    final service = KtService(
      '127.0.0.1:2370',
      username: 'user',
      password: 'pass',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/jobs/abc123/preempt');
        expect(
          request.headers['authorization'],
          'Basic ${base64Encode(utf8.encode('user:pass'))}',
        );
        expect(jsonDecode(request.body), isEmpty);
        return http.Response('{"job_id":"abc123","status":"pausing"}', 200);
      }),
    );
    addTearDown(service.close);
    expect((await service.preempt('abc123'))['status'], 'pausing');
  });

  test(
    'unsupported preemption is reported instead of falling back to cancel',
    () async {
      var requests = 0;
      final service = KtService(
        '127.0.0.1:2370',
        client: MockClient((request) async {
          requests++;
          expect(request.url.path.endsWith('/preempt'), isTrue);
          return http.Response('{"error":"unsupported"}', 404);
        }),
      );
      addTearDown(service.close);
      await expectLater(
        service.preempt('abc123'),
        throwsA(isA<KtServiceException>()),
      );
      expect(requests, 1);
    },
  );
}
