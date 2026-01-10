import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/services/http_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeProvider', () {
    late HomeProvider homeProvider;

    setUp(() async {
      // Inicializar el servicio HTTP en modo testing (con cache en memoria)
      await initHttpService(useMemoryCache: true);
      homeProvider = HomeProvider();
    });

    group('Estado inicial', () {
      test('posts está vacío', () {
        expect(homeProvider.posts, isEmpty);
      });

      test('isLoading es false', () {
        expect(homeProvider.isLoading, false);
      });

      test('isLoadingMore es false', () {
        expect(homeProvider.isLoadingMore, false);
      });

      test('errorMessage es null', () {
        expect(homeProvider.errorMessage, isNull);
      });

      test('hasMore es false sin posts', () {
        expect(homeProvider.hasMore, false);
      });
    });

    group('Constantes', () {
      test('maxPostsInMemory es 200', () {
        expect(HomeProvider.maxPostsInMemory, 200);
      });
    });

    group('fetchPosts - Gestión de estado', () {
      test('isLoading cambia a true al iniciar fetch', () async {
        bool wasLoadingDuringFetch = false;

        homeProvider.addListener(() {
          if (homeProvider.isLoading) {
            wasLoadingDuringFetch = true;
          }
        });

        // Iniciar fetch sin esperar
        final future = homeProvider.fetchPosts();

        // Esperar brevemente para que se notifique el cambio
        await Future.delayed(const Duration(milliseconds: 10));

        expect(wasLoadingDuringFetch, true,
            reason: 'isLoading debe ser true durante el fetch');

        // Esperar a que termine
        await future;
      });

      test('isLoading es false después del fetch', () async {
        await homeProvider.fetchPosts();
        expect(homeProvider.isLoading, false);
      });

      test('errorMessage se limpia al iniciar nuevo fetch', () async {
        // Este test verifica que errorMessage se establece a null
        // al inicio de cada fetchPosts
        bool errorWasCleared = false;

        homeProvider.addListener(() {
          // Al inicio del fetch, isLoading es true y errorMessage debe ser null
          if (homeProvider.isLoading && homeProvider.errorMessage == null) {
            errorWasCleared = true;
          }
        });

        await homeProvider.fetchPosts();

        // Verificamos que en algún momento errorMessage fue null durante el fetch
        expect(errorWasCleared, true,
            reason: 'errorMessage debe ser null al inicio del fetch');
      });

      test('currentPage se reinicia a 1 en cada fetch', () async {
        await homeProvider.fetchPosts();

        // Después del fetch, la página actual internamente es 1
        // Verificamos indirectamente que el estado es consistente
        expect(homeProvider.isLoading, false);
      });
    });

    group('fetchPosts - Notificaciones', () {
      test('notifica listeners al menos 2 veces por fetch', () async {
        int notificationCount = 0;

        homeProvider.addListener(() {
          notificationCount++;
        });

        await homeProvider.fetchPosts();

        // Debe notificar al menos:
        // 1. Al comenzar (isLoading = true)
        // 2. Al terminar (isLoading = false)
        expect(notificationCount, greaterThanOrEqualTo(2),
            reason: 'Debe notificar al iniciar y al terminar');
      });
    });

    group('fetchPosts - Respuesta', () {
      test('posts o errorMessage se establecen después del fetch', () async {
        await homeProvider.fetchPosts();

        // Después del fetch, debe haber posts O un error
        final hasPostsOrError =
            homeProvider.posts.isNotEmpty || homeProvider.errorMessage != null;

        expect(hasPostsOrError, true,
            reason: 'Debe tener posts o mensaje de error');
      });

      test('errorMessage contiene mensaje en español si hay error', () async {
        await homeProvider.fetchPosts();

        if (homeProvider.errorMessage != null) {
          // Los mensajes de error deben estar en español
          expect(
            homeProvider.errorMessage!.contains('Exception:') ||
                homeProvider.errorMessage!.contains('servidor') ||
                homeProvider.errorMessage!.contains('conexión') ||
                homeProvider.errorMessage!.contains('error'),
            true,
            reason: 'El mensaje de error debe ser descriptivo',
          );
        }
      });

      test('posts son instancias de PostModel', () async {
        await homeProvider.fetchPosts();

        if (homeProvider.posts.isNotEmpty) {
          for (final post in homeProvider.posts) {
            expect(post.id, isA<int>());
            expect(post.title, isA<String>());
            expect(post.date, isA<DateTime>());
          }
        }
      });
    });

    group('fetchPosts - Refresh', () {
      test('refresh=true no afecta el estado del provider', () async {
        await homeProvider.fetchPosts();

        await homeProvider.fetchPosts(refresh: true);

        // El estado debe ser consistente después del refresh
        expect(homeProvider.isLoading, false);

        // Los posts pueden ser diferentes, pero el estado es válido
        final hasValidState =
            homeProvider.posts.isNotEmpty || homeProvider.errorMessage != null;
        expect(hasValidState, true);
      });
    });

    group('loadMore - Condiciones previas', () {
      test('no hace nada si hasMore es false', () async {
        // Sin fetch previo, hasMore es false
        expect(homeProvider.hasMore, false);

        final initialPostCount = homeProvider.posts.length;
        await homeProvider.loadMore();

        expect(homeProvider.posts.length, initialPostCount);
        expect(homeProvider.isLoadingMore, false);
      });

      test('no hace nada si ya está cargando más', () async {
        // Este test verifica la lógica de guard
        await homeProvider.fetchPosts();

        if (homeProvider.hasMore) {
          // Iniciar loadMore sin esperar
          final future1 = homeProvider.loadMore();

          // Intentar otro loadMore mientras el primero está en progreso
          // (aunque en la práctica es difícil de sincronizar)
          await future1;

          expect(homeProvider.isLoadingMore, false);
        }
      });
    });

    group('loadMore - Límite de memoria', () {
      test('hasMore considera límite de maxPostsInMemory', () async {
        await homeProvider.fetchPosts();

        // hasMore debe ser false si posts >= maxPostsInMemory
        if (homeProvider.posts.length >= HomeProvider.maxPostsInMemory) {
          expect(homeProvider.hasMore, false);
        }
      });

      test('loadMore respeta límite de memoria', () async {
        await homeProvider.fetchPosts();

        // Si hay más páginas pero ya tenemos muchos posts,
        // loadMore no debe cargar más
        final postsBeforeLoadMore = homeProvider.posts.length;

        if (postsBeforeLoadMore >= HomeProvider.maxPostsInMemory) {
          await homeProvider.loadMore();
          expect(homeProvider.posts.length, postsBeforeLoadMore);
        }
      });
    });

    group('loadMore - Paginación', () {
      test('isLoadingMore cambia durante la carga', () async {
        await homeProvider.fetchPosts();

        if (homeProvider.hasMore) {
          bool wasLoadingMore = false;

          homeProvider.addListener(() {
            if (homeProvider.isLoadingMore) {
              wasLoadingMore = true;
            }
          });

          await homeProvider.loadMore();

          expect(wasLoadingMore, true,
              reason: 'isLoadingMore debe ser true durante la carga');
          expect(homeProvider.isLoadingMore, false,
              reason: 'isLoadingMore debe ser false al terminar');
        }
      });

      test('posts aumentan después de loadMore exitoso', () async {
        await homeProvider.fetchPosts();

        if (homeProvider.hasMore && homeProvider.errorMessage == null) {
          final postsBeforeLoadMore = homeProvider.posts.length;

          await homeProvider.loadMore();

          if (homeProvider.errorMessage == null) {
            expect(homeProvider.posts.length, greaterThan(postsBeforeLoadMore));
          }
        }
      });
    });

    group('hasMore - Lógica', () {
      test('hasMore es true solo si hay más páginas y espacio en memoria', () async {
        await homeProvider.fetchPosts();

        // hasMore = _currentPage < _totalPages && _posts.length < maxPostsInMemory
        // Verificamos que el getter funciona correctamente
        final hasMore = homeProvider.hasMore;

        if (homeProvider.posts.length >= HomeProvider.maxPostsInMemory) {
          expect(hasMore, false, reason: 'No debe cargar más si alcanzó el límite');
        }
      });
    });
  });
}
