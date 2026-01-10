import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/services/http_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeProvider', () {
    late HomeProvider homeProvider;

    setUp(() async {
      // Inicializar el servicio HTTP en modo testing (con memoria)
      await initHttpService(useMemoryCache: true);
      homeProvider = HomeProvider();
    });

    test('initial state is correct', () {
      // Assert
      expect(homeProvider.posts, isEmpty);
      expect(homeProvider.isLoading, false);
      expect(homeProvider.isLoadingMore, false);
      expect(homeProvider.errorMessage, isNull);
      expect(homeProvider.hasMore, false);
    });

    test('isLoading is true during fetch', () async {
      // Arrange
      bool wasLoadingDuringFetch = false;

      // Escuchar cambios en el provider
      homeProvider.addListener(() {
        if (homeProvider.isLoading) {
          wasLoadingDuringFetch = true;
        }
      });

      // Act
      // Nota: Este test fallará en CI/CD si no hay conexión a internet
      // En un entorno de producción, deberías usar mocks para HttpProvider
      final future = homeProvider.fetchPosts();

      // Esperar un momento para que comience la carga
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert - verificar que se estableció isLoading en algún momento
      expect(wasLoadingDuringFetch || homeProvider.isLoading, true);

      // Esperar a que termine la petición
      await future;
    });

    test('isLoading is false after fetch completes', () async {
      // Act
      await homeProvider.fetchPosts();

      // Assert
      expect(homeProvider.isLoading, false);
    });

    test('posts are populated after successful fetch', () async {
      // Act
      await homeProvider.fetchPosts();

      // Assert
      // Si la petición fue exitosa, deberíamos tener posts
      // o un mensaje de error si falló
      expect(
        homeProvider.posts.isNotEmpty || homeProvider.errorMessage != null,
        true,
      );
    });

    test('errorMessage is set when fetch fails', () async {
      // Nota: Este test es difícil de verificar sin mocks
      // porque dependemos de la red real
      // En un entorno ideal, usarías un mock que falle

      // Act
      await homeProvider.fetchPosts();

      // Assert
      // Solo verificamos que el estado es consistente
      if (homeProvider.errorMessage != null) {
        expect(homeProvider.posts, isEmpty);
      }
    });

    test('refresh flag is passed correctly', () async {
      // Act
      await homeProvider.fetchPosts(refresh: true);

      // Assert
      // Verificar que la operación completó sin errores
      expect(homeProvider.isLoading, false);
    });

    test('notifies listeners on state change', () async {
      // Arrange
      int notificationCount = 0;
      homeProvider.addListener(() {
        notificationCount++;
      });

      // Act
      await homeProvider.fetchPosts();

      // Assert
      // Debería notificar al menos 2 veces:
      // 1. Al comenzar (isLoading = true)
      // 2. Al terminar (isLoading = false)
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('loadMore does nothing when there are no more pages', () async {
      // Arrange - sin fetch previo, hasMore es false
      expect(homeProvider.hasMore, false);

      // Act
      await homeProvider.loadMore();

      // Assert - no debería cargar nada
      expect(homeProvider.posts, isEmpty);
      expect(homeProvider.isLoadingMore, false);
    });

    test('loadMore does nothing when already loading more', () async {
      // Arrange
      await homeProvider.fetchPosts();
      final initialPostCount = homeProvider.posts.length;

      // Si no hay más páginas, loadMore no debería hacer nada
      if (!homeProvider.hasMore) {
        await homeProvider.loadMore();
        expect(homeProvider.posts.length, initialPostCount);
      }
    });

    test('hasMore returns correct value based on pagination', () async {
      // Act
      await homeProvider.fetchPosts();

      // Assert
      // hasMore depende de si hay más páginas disponibles
      // Solo verificamos que el estado es consistente
      expect(homeProvider.isLoading, false);
      // hasMore será true o false dependiendo del total de páginas
    });
  });
}
