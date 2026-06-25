import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';

void main() {
  test('fetchSharedFairytales requests public shared list', () async {
    final api = _FakeMyFairytaleApiClient([
      {
        'id': 7,
        'title': '별빛 모험',
        'format': 'slide',
        'status': 'COMPLETED',
        'language': 'ko',
        'shared': true,
        'thumbnailUrl': null,
        'pageCount': 1,
      },
    ]);
    final service = MyFairytaleService(api: api);

    final items = await service.fetchSharedFairytales();

    expect(api.requestedPath, '/fairytale/shared');
    expect(items.single.id, 7);
    expect(items.single.title, '별빛 모험');
    expect(items.single.shared, isTrue);
  });

  test(
    'fetchSlides requests stored fairytale slides and parses playback metadata',
    () async {
      final api = _FakeMyFairytaleApiClient({
        'id': 7,
        'title': '별빛 모험',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {
            'pageIndex': 1,
            'text': '첫 페이지',
            'imageUrl': 'https://cdn.example.com/page1.png',
            'audioUrl': 'https://cdn.example.com/page1.mp3',
          },
        ],
      });
      final service = MyFairytaleService(api: api);

      final response = await service.fetchSlides(7);

      expect(api.requestedPath, '/fairytale/7/slides');
      expect(response.id, 7);
      expect(response.title, '별빛 모험');
      expect(response.language, 'ko');
      expect(response.voiceType, 'dad');
      expect(
        response.pages.single.audioUrl,
        'https://cdn.example.com/page1.mp3',
      );
    },
  );

  test(
    'fetchSharedSlides requests public shared slides and parses playback metadata',
    () async {
      final api = _FakeMyFairytaleApiClient({
        'id': 7,
        'title': '공유 동화',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {
            'pageIndex': 1,
            'text': '공유 페이지',
            'imageUrl': 'https://cdn.example.com/shared.png',
            'audioUrl': 'https://cdn.example.com/shared.mp3',
          },
        ],
      });
      final service = MyFairytaleService(api: api);

      final response = await service.fetchSharedSlides(7);

      expect(api.requestedPath, '/fairytale/shared/7/slides');
      expect(response.id, 7);
      expect(response.title, '공유 동화');
      expect(response.pages.single.text, '공유 페이지');
    },
  );
}

class _FakeMyFairytaleApiClient implements MyFairytaleApiClient {
  final dynamic response;
  String? requestedPath;

  _FakeMyFairytaleApiClient(this.response);

  @override
  Future<dynamic> get(String path) async {
    requestedPath = path;
    return response;
  }

  @override
  Future<dynamic> post(String path) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(String path) {
    throw UnimplementedError();
  }
}
