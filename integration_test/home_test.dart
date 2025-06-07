import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reworkmobile/view/lesson/LessonKategori.dart';
import 'package:reworkmobile/view/home/home.dart';
import 'package:reworkmobile/view/voice%20to%20text/voice_to_text.dart';

class TestHttpOverrides extends HttpOverrides {
  final Map<Uri, String> mockResponses;

  TestHttpOverrides(this.mockResponses);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(mockResponses);
  }
}

class _MockHttpClient implements HttpClient {
  final Map<Uri, String> mockResponses;

  _MockHttpClient(this.mockResponses);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest(url, mockResponses);
  }

  // Implement abstract members with dummy or no-op if needed
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final Uri url;
  final Map<Uri, String> mockResponses;
  late final _MockHttpClientResponse response;

  _MockHttpClientRequest(this.url, this.mockResponses) {
    final body = mockResponses[url] ?? '{}';
    response = _MockHttpClientResponse(body);
  }

  @override
  Future<HttpClientResponse> close() async {
    return response;
  }

  // Implement other methods as no-op or dummy
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final String body;

  _MockHttpClientResponse(this.body);

  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final bytes = utf8.encode(body);
    final stream = Stream<List<int>>.fromIterable([bytes]);
    return stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // Implement other members with dummy
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Dummy data untuk response user profile & berita
  final userProfileResponse = jsonEncode({
    "name": "Test User",
    "imageUrl": "",
  });

  final beritaResponse = jsonEncode([
    {
      "title": "Berita 1",
      "description": "Deskripsi Berita 1",
      "image": "https://example.com/image1.jpg",
    },
    {
      "title": "Berita 2",
      "description": "Deskripsi Berita 2",
      "image": "https://example.com/image2.jpg",
    },
  ]);

  // Buat map Uri ke response sesuai endpoint yang dipanggil ApiService
  final mockResponses = {
    Uri.parse('https://your.api.url/user_profile_endpoint'):
        userProfileResponse,
    Uri.parse('https://your.api.url/berita_endpoint'): beritaResponse,
  };

  setUp(() {
    // Pasang HttpOverrides sebelum test jalan
    HttpOverrides.global = TestHttpOverrides(mockResponses);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('Tombol Voice to Text dan Lesson navigasi bekerja',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.pumpAndSettle();

    // Temukan tombol Voice to Text (label text)
    final voiceToTextButton = find.text('Voice to Text');
    expect(voiceToTextButton, findsOneWidget);

    // Ketuk tombol Voice to Text
    await tester.tap(voiceToTextButton);
    await tester.pumpAndSettle();

    // Cek apakah pindah ke halaman VoiceToTextScreen
    expect(find.byType(VoiceToTextScreen), findsOneWidget);

    // Kembali ke HomeScreen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Temukan tombol Lesson
    final lessonButton = find.text('Lesson');
    expect(lessonButton, findsOneWidget);

    // Ketuk tombol Lesson
    await tester.tap(lessonButton);
    await tester.pumpAndSettle();

    // Cek apakah pindah ke halaman Lessonkategori
    expect(find.byType(Lessonkategori), findsOneWidget);
  });
}
