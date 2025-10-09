import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/routes/routes.dart';
import 'package:suayed/services/firebase_service.dart';
import 'package:suayed/theme.dart';
import 'package:suayed/utils/analytics.dart';
import 'package:suayed/utils/app_constants.dart';

Future<void> main() async {
  // Ensure widgets are initialized and initialize Firebase services
  await FirebaseService.initialize();

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()..fetchPosts()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Constants.scaffoldMessengerKey,
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: suayedTheme, // This is defined in theme.dart
      initialRoute: Routes.home,
      routes: Routes.getRoutes(context),
      navigatorObservers: [Analytics.observer],
    );
  }
}
