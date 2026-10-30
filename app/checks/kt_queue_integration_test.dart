import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/services/dictation_queue.dart';
import 'package:kikoeta_app/services/kt_service.dart';

void main() {
  test(
    'KT pauses A for B then resumes its exact checkpoint without downloading A again',
    () async {
      final engine = Platform.environment['KT_ENGINE_DIR'] != null
          ? Directory(Platform.environment['KT_ENGINE_DIR']!)
          : Directory.fromUri(
              Directory.current.uri.resolve('../../kikoeta-transl/engine/'),
            );
      final process = await Process.start(
        Platform.environment['KT_PYTHON'] ?? 'python',
        ['-u', 'checks/fixtures/kikoeta_queue_server.py'],
        workingDirectory: engine.path,
      );
      final errors = StringBuffer();
      final stderr = process.stderr
          .transform(utf8.decoder)
          .listen(errors.write);
      addTearDown(() async {
        process.stdin.writeln('stop');
        await process.stdin.flush();
        try {
          await process.exitCode.timeout(const Duration(seconds: 6));
        } on TimeoutException {
          process.kill();
          await process.exitCode;
        }
        await stderr.cancel();
        if (errors.isNotEmpty) {
          // Preserve backend tracebacks if the real HTTP integration fails.
          // ignore: avoid_print
          print(errors.toString());
        }
      });
      final ready = await process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .first
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw StateError(errors.toString()),
          );
      final endpoint = jsonDecode(ready)['endpoint'] as String;
      final service = KtService(endpoint);
      addTearDown(service.close);
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      DictationQueueEntry add(String id, int count) => queue.enqueue(
        work: Work(
          rj: id,
          title: id,
          circle: '',
          va: '',
          age: Age.all,
          dur: '',
          tags: const [],
          grad: 0,
        ),
        tracks: List.generate(
          count,
          (i) => MediaNode(
            title: '$i.mp3',
            type: 'file',
            path: '$i.mp3',
            url: '$endpoint/audio/$id/$i.mp3',
          ),
        ),
      )!;
      final a = add('RJ111111', 5);
      final b = add('RJ222222', 1);
      final blocked = Completer<String>();
      final execution = <String>[];
      final ids = <String>[];
      final run = queue.run((entry) async {
        execution.add(entry.label);
        final created = await service.startOrRecoverJob(
          [
            for (var i = 0; i < entry.tracks.length; i++)
              KtSourceFile(
                url: entry.tracks[i].url!,
                name: ktUploadName(i, entry.tracks[i].title),
              ),
          ],
          existingJobId: entry.backendJob?.jobId,
          cacheWorkId: entry.work.rj,
          cacheTrackPaths: entry.tracks.map((e) => e.path).toList(),
        );
        final id = created['job_id'] as String;
        ids.add(id);
        entry.backendJob = service.reference(id);
        if (entry == a && execution.length == 1) {
          for (var retry = 0; retry < 100; retry++) {
            final state = await service.job(id);
            if (state['completed_files'] == 2) break;
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          expect((await service.job(id))['completed_files'], 2);
          blocked.complete(id);
        } else if (entry == a) {
          expect(created['completed_files'], greaterThanOrEqualTo(2));
        }
        var cursor = (created['event_cursor'] as num).toInt();
        var closed = false;
        while (!closed) {
          final batch = await service.events(id, cursor);
          cursor = batch.cursor;
          closed = batch.closed;
        }
        final job = await service.job(id);
        if (job['status'] == 'paused') {
          expect(job['completed_files'], 2);
          final lyrics = await service.download(
            job['results'][0]['download_urls'][0],
          );
          expect(utf8.decode(lyrics), contains('RJ111111:0'));
          return DictationQueueStatus.pending;
        }
        expect(job['status'], 'completed');
        expect(job['completed_files'], entry.tracks.length);
        return DictationQueueStatus.completed;
      });
      addTearDown(() async {
        queue.stopRequested = true;
        final job = queue.current?.backendJob;
        if (job != null && queue.running) {
          try {
            await service.cancel(job.jobId);
          } catch (_) {
            // A failed server may already be unreachable.
          }
        }
        try {
          await run.timeout(const Duration(seconds: 3));
        } catch (_) {
          // The main test reports the original integration failure.
        }
      });
      final firstId = await blocked.future.timeout(const Duration(seconds: 15));
      expect(queue.jumpAhead(b), isTrue);
      await service.preempt(firstId);
      await run.timeout(const Duration(seconds: 15));
      expect(execution, ['RJ111111', 'RJ222222', 'RJ111111']);
      expect(ids[2], ids[0]);
      final response = await http.get(Uri.parse('$endpoint/test/state'));
      final state = jsonDecode(response.body);
      expect(state['downloads'].length, 6);
      expect(state['jobs'], 2);
      expect(state['calls'], [
        ['RJ111111', 0],
        ['RJ111111', 1],
        ['RJ111111', 2],
        ['RJ222222', 0],
        ['RJ111111', 2],
        ['RJ111111', 3],
        ['RJ111111', 4],
      ]);
      expect(
        queue.entries.every((e) => e.status == DictationQueueStatus.completed),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(seconds: 50)),
  );
}
