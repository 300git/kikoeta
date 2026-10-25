import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kikoeta_app/services/kt_service.dart';

void main() {
  test(
    'resume addresses the exact job without uploading the source files',
    () async {
      final service = KtService(
        '127.0.0.1:2370',
        username: 'user',
        password: 'pass',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/jobs/abc123/resume');
          expect(
            request.headers['authorization'],
            'Basic ${base64Encode(utf8.encode('user:pass'))}',
          );
          expect(jsonDecode(request.body), isEmpty);
          return http.Response(
            '{"job_id":"abc123","event_cursor":12,"completed_files":2}',
            200,
          );
        }),
      );
      addTearDown(service.close);
      final resumed = await service.resume('abc123');
      expect(resumed['event_cursor'], 12);
      expect(resumed['completed_files'], 2);
    },
  );

  test('fresh import opts out of matching another paused batch', () async {
    final service = KtService(
      '127.0.0.1:2370',
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/jobs');
        expect(jsonDecode(request.body)['resume_existing'], isFalse);
        return http.Response('{"job_id":"fresh"}', 201);
      }),
    );
    addTearDown(service.close);
    await service.createJob([
      const KtSourceFile(url: 'https://example.com/one.mp3', name: 'one.mp3'),
    ]);
  });

  test(
    'task reference keeps the original server and account after closing',
    () {
      final service = KtService(
        '127.0.0.1:2370',
        username: 'user',
        password: 'pass',
      );
      final reference = service.reference('abc123');
      service.close();
      final resumed = reference.connect();
      addTearDown(resumed.close);
      expect(reference.jobId, 'abc123');
      expect(resumed.endpoint, service.endpoint);
      expect(resumed.username, 'user');
      expect(resumed.password, 'pass');
    },
  );

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
