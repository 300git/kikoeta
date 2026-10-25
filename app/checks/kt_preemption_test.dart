import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kikoeta_app/services/kt_service.dart';

void main() {
  for (final status in [
    'queued',
    'running',
    'pausing',
    'cancelling',
    'completed',
  ]) {
    test(
      'retry reattaches to $status KT job instead of submitting a duplicate',
      () async {
        final requests = <String>[];
        final service = KtService(
          '127.0.0.1:2370',
          client: MockClient((request) async {
            requests.add('${request.method} ${request.url.path}');
            return http.Response(
              jsonEncode({'job_id': 'original', 'status': status}),
              200,
            );
          }),
        );
        addTearDown(service.close);
        final result = await service.startOrRecoverJob(
          const [],
          existingJobId: 'original',
        );
        expect(result['job_id'], 'original');
        expect(result['status'], status);
        expect(requests, ['GET /api/v1/jobs/original']);
      },
    );
  }

  test('retry resumes a paused KT task by ID', () async {
    final requests = <String>[];
    final service = KtService(
      '127.0.0.1:2370',
      client: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({
            'job_id': 'original',
            'status': request.method == 'GET' ? 'paused' : 'running',
          }),
          200,
        );
      }),
    );
    addTearDown(service.close);
    await service.startOrRecoverJob(const [], existingJobId: 'original');
    expect(requests, [
      'GET /api/v1/jobs/original',
      'POST /api/v1/jobs/original/resume',
    ]);
  });

  for (final status in ['failed', 'cancelled', 'missing']) {
    test('retry creates a fresh KT task after $status attempt', () async {
      final requests = <String>[];
      final service = KtService(
        '127.0.0.1:2370',
        client: MockClient((request) async {
          requests.add('${request.method} ${request.url.path}');
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({'job_id': 'old', 'status': status}),
              status == 'missing' ? 404 : 200,
            );
          }
          final body = jsonDecode(request.body);
          expect(body['cache']['work_id'], 'RJ111111');
          expect(body['files'].single['name'], 'one.mp3');
          expect(body['resume_existing'], isFalse);
          return http.Response('{"job_id":"new","status":"running"}', 201);
        }),
      );
      addTearDown(service.close);
      final result = await service.startOrRecoverJob(
        [
          const KtSourceFile(
            url: 'https://example.com/one.mp3',
            name: 'one.mp3',
          ),
        ],
        existingJobId: 'old',
        cacheWorkId: 'RJ111111',
        cacheTrackPaths: ['one.mp3'],
      );
      expect(result['job_id'], 'new');
      expect(requests, ['GET /api/v1/jobs/old', 'POST /api/v1/jobs']);
    });
  }

  test(
    'retry does not resubmit if the previous task status is unreachable',
    () async {
      final requests = <String>[];
      final service = KtService(
        '127.0.0.1:2370',
        client: MockClient((request) async {
          requests.add(request.method);
          throw http.ClientException('offline');
        }),
      );
      addTearDown(service.close);
      await expectLater(
        service.startOrRecoverJob(const [], existingJobId: 'original'),
        throwsA(isA<http.ClientException>()),
      );
      expect(requests, ['GET']);
    },
  );

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
