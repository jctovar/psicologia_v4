import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/screens/home_screen.dart';
import 'package:suayed/widgets/empty_state.dart';
import 'package:suayed/widgets/post_card.dart';
import 'package:suayed/widgets/shimmer_placeholder.dart';

import '../helpers/fake_wordpress_api.dart';

void main() {
  late FakeWordPressApi api;
  late HomeProvider provider;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    api = await FakeWordPressApi.install();
  });

  setUp(() {
    api.reset();
    provider = HomeProvider();
  });

  /// Monta HomeScreen con el provider de la prueba. Usa un tema sin
  /// google_fonts para no depender de la carga de fuentes.
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<HomeProvider>.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen(title: 'Iztacala')),
      ),
    );
  }

  /// Avanza el reloj simulado y reconstruye hasta que [busy] sea false.
  /// Las peticiones iniciadas dentro de testWidgets solo progresan con pump.
  Future<void> settle(WidgetTester tester, bool Function() busy) async {
    for (var i = 0; i < 100 && busy(); i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(busy(), false, reason: 'la petición no terminó');
    await tester.pump();
  }

  /// Ejecuta [action] del provider y espera a que termine de cargar.
  Future<void> run(WidgetTester tester, Future<void> Function() action) async {
    var done = false;
    action().whenComplete(() => done = true);
    await settle(tester, () => !done);
  }

  testWidgets('muestra placeholders mientras carga la primera página', (
    tester,
  ) async {
    api.setUpPages(1);
    api.gate = Completer<void>();

    await pumpHome(tester);
    final future = provider.fetchPosts();
    await tester.pump();

    expect(find.byType(PostCardShimmer), findsWidgets);
    expect(find.byType(PostCard), findsNothing);

    api.gate!.complete();
    await settle(tester, () => provider.isLoading);
    await future;
    expect(find.byType(PostCardShimmer), findsNothing);
  });

  testWidgets('muestra los posts al cargar', (tester) async {
    api.setUpPages(1);

    await pumpHome(tester);
    await run(tester, provider.fetchPosts);

    expect(find.byType(PostCard), findsWidgets);
    expect(find.text('POST 3'), findsOneWidget);
  });

  testWidgets('muestra el error y reintenta con refresh', (tester) async {
    api.pages[1] = const FakePage.dioError(DioExceptionType.connectionTimeout);

    await pumpHome(tester);
    await run(tester, provider.fetchPosts);

    expect(find.byType(ErrorState), findsOneWidget);
    expect(
      find.textContaining('No se pudo conectar al servidor'),
      findsOneWidget,
    );

    api.setUpPages(1);
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pump();
    await settle(tester, () => provider.isLoading);

    expect(find.byType(ErrorState), findsNothing);
    expect(find.text('POST 3'), findsOneWidget);
    expect(
      api.requests.last.getCacheOptions()?.policy,
      CachePolicy.refresh,
      reason: 'el reintento debe pedir datos frescos (refresh)',
    );
  });

  testWidgets('al llegar al final carga la siguiente página', (tester) async {
    api.setUpPages(2);

    await pumpHome(tester);
    await run(tester, provider.fetchPosts);
    expect(api.requests.map(FakeWordPressApi.pageOf), [1]);

    // Desplazar hasta el final dispara loadMore desde el ScrollController
    await tester.drag(find.byType(GridView), const Offset(0, -5000));
    await tester.pump();
    await tester.pump();
    await settle(tester, () => provider.isLoadingMore);

    expect(api.requests.map(FakeWordPressApi.pageOf), [1, 2]);
    expect(provider.posts.length, 6);
  });

  testWidgets(
    'si falla la siguiente página muestra "Reintentar" y no reintenta '
    'al hacer scroll',
    (tester) async {
      api.setUpPages(2);
      api.pages[2] = const FakePage.status(500);

      await pumpHome(tester);
      await run(tester, provider.fetchPosts);
      await run(tester, provider.loadMore);

      await tester.drag(find.byType(GridView), const Offset(0, -5000));
      await tester.pump();

      expect(find.text('No se pudieron cargar más noticias.'), findsOneWidget);
      expect(api.requests.map(FakeWordPressApi.pageOf), [
        1,
        2,
      ], reason: 'el scroll no debe reintentar tras un error');

      // Reintento manual
      api.pages[2] = const FakePage.posts([3, 2, 1]);
      await tester.tap(find.widgetWithText(TextButton, 'Reintentar'));
      await tester.pump();
      await settle(tester, () => provider.isLoadingMore);

      expect(find.text('No se pudieron cargar más noticias.'), findsNothing);
      expect(provider.posts.length, 6);
    },
  );
}
