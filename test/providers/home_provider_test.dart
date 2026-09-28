import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/providers/home_provider.dart';

import '../helpers/fake_wordpress_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWordPressApi api;
  late HomeProvider provider;

  setUpAll(() async {
    api = await FakeWordPressApi.install();
  });

  setUp(() {
    api.reset();
    provider = HomeProvider();
  });

  List<int> ids() => provider.posts.map((p) => p.id).toList();

  group('Estado inicial', () {
    test('sin posts, sin carga y sin errores', () {
      expect(provider.posts, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.isLoadingMore, false);
      expect(provider.errorMessage, isNull);
      expect(provider.loadMoreError, isNull);
      expect(provider.hasMore, false);
    });

    test('maxPostsInMemory es 200', () {
      expect(HomeProvider.maxPostsInMemory, 200);
    });
  });

  group('fetchPosts', () {
    test('carga la primera página', () async {
      api.setUpPages(3);

      await provider.fetchPosts();

      expect(ids(), [9, 8, 7]);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
      expect(api.requests.map(FakeWordPressApi.pageOf), [1]);
    });

    test('isLoading es true mientras espera la respuesta', () async {
      api.setUpPages(1);
      api.gate = Completer<void>();

      final future = provider.fetchPosts();
      expect(provider.isLoading, true);
      expect(provider.errorMessage, isNull);

      api.gate!.complete();
      await future;
      expect(provider.isLoading, false);
    });

    test('notifica al iniciar y al terminar', () async {
      api.setUpPages(1);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.fetchPosts();

      expect(notifications, 2);
    });

    test(
      'guarda el mensaje de error en español si la petición falla',
      () async {
        api.pages[1] = const FakePage.dioError(
          DioExceptionType.connectionTimeout,
        );

        await provider.fetchPosts();

        expect(
          provider.errorMessage,
          contains('No se pudo conectar al servidor'),
        );
        expect(provider.posts, isEmpty);
        expect(provider.isLoading, false);
      },
    );

    test('un fetch exitoso limpia el error anterior', () async {
      api.pages[1] = const FakePage.status(500);
      await provider.fetchPosts();
      expect(provider.errorMessage, isNotNull);

      api.setUpPages(1);
      await provider.fetchPosts(refresh: true);

      expect(provider.errorMessage, isNull);
      expect(ids(), [3, 2, 1]);
    });

    test('refresh reemplaza los posts y vuelve a la página 1', () async {
      api.setUpPages(3);
      await provider.fetchPosts();
      await provider.loadMore();
      expect(ids(), [9, 8, 7, 6, 5, 4]);

      api.pages[1] = const FakePage.posts([10, 9, 8]);
      await provider.fetchPosts(refresh: true);

      expect(ids(), [10, 9, 8]);
      expect(FakeWordPressApi.pageOf(api.requests.last), 1);

      // Tras el refresh, la siguiente página vuelve a ser la 2
      await provider.loadMore();
      expect(FakeWordPressApi.pageOf(api.requests.last), 2);
    });
  });

  group('hasMore', () {
    test('es true si quedan páginas en el servidor', () async {
      api.setUpPages(2);
      await provider.fetchPosts();

      expect(provider.hasMore, true);
    });

    test('es false en la última página', () async {
      api.setUpPages(1);
      await provider.fetchPosts();

      expect(provider.hasMore, false);
    });

    test(
      'es false al alcanzar maxPostsInMemory aunque queden páginas',
      () async {
        api.pages[1] = FakePage.posts([
          for (var id = HomeProvider.maxPostsInMemory; id > 0; id--) id,
        ]);
        api.totalPagesHeader = '10';

        await provider.fetchPosts();

        expect(provider.posts.length, HomeProvider.maxPostsInMemory);
        expect(provider.hasMore, false);

        await provider.loadMore();
        expect(api.requests.length, 1, reason: 'no debe pedir más páginas');
      },
    );
  });

  group('loadMore', () {
    test('no hace nada si no hay más páginas', () async {
      await provider.loadMore();

      expect(provider.posts, isEmpty);
      expect(api.requests, isEmpty);
    });

    test('agrega la siguiente página', () async {
      api.setUpPages(3);
      await provider.fetchPosts();

      await provider.loadMore();

      expect(ids(), [9, 8, 7, 6, 5, 4]);
      expect(api.requests.map(FakeWordPressApi.pageOf), [1, 2]);
      expect(provider.hasMore, true);

      await provider.loadMore();
      expect(ids(), [9, 8, 7, 6, 5, 4, 3, 2, 1]);
      expect(provider.hasMore, false);
    });

    test('isLoadingMore es true mientras espera la respuesta', () async {
      api.setUpPages(2);
      await provider.fetchPosts();
      api.gate = Completer<void>();

      final future = provider.loadMore();
      expect(provider.isLoadingMore, true);

      api.gate!.complete();
      await future;
      expect(provider.isLoadingMore, false);
    });

    test('ignora llamadas mientras ya está cargando', () async {
      api.setUpPages(3);
      await provider.fetchPosts();
      api.gate = Completer<void>();

      final first = provider.loadMore();
      final second = provider.loadMore();
      api.gate!.complete();
      await Future.wait([first, second]);

      expect(api.requests.map(FakeWordPressApi.pageOf), [1, 2]);
      expect(provider.posts.length, 6);
    });

    test('descarta posts repetidos al desplazarse la paginación', () async {
      // Se publicó un post nuevo: la página 2 repite el último de la página 1
      api.pages[1] = const FakePage.posts([10, 9, 8]);
      api.pages[2] = const FakePage.posts([8, 7, 6]);
      api.totalPagesHeader = '3';

      await provider.fetchPosts();
      await provider.loadMore();

      expect(ids(), [10, 9, 8, 7, 6]);
    });

    test('guarda el error sin perder los posts y permite reintentar', () async {
      api.setUpPages(2);
      api.pages[2] = const FakePage.dioError(DioExceptionType.receiveTimeout);
      await provider.fetchPosts();

      await provider.loadMore();

      expect(provider.loadMoreError, contains('No se pudo conectar'));
      expect(
        provider.errorMessage,
        isNull,
        reason: 'el error de loadMore no reemplaza la lista',
      );
      expect(ids(), [6, 5, 4]);

      api.pages[2] = const FakePage.posts([3, 2, 1]);
      await provider.loadMore();

      expect(provider.loadMoreError, isNull);
      expect(ids(), [6, 5, 4, 3, 2, 1]);
    });

    test('fetchPosts limpia loadMoreError', () async {
      api.setUpPages(2);
      api.pages[2] = const FakePage.status(500);
      await provider.fetchPosts();
      await provider.loadMore();
      expect(provider.loadMoreError, isNotNull);

      await provider.fetchPosts(refresh: true);

      expect(provider.loadMoreError, isNull);
    });
  });
}
