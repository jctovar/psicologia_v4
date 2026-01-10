import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // Limpiar SharedPreferences antes de cada test
      SharedPreferences.setMockInitialValues({});
    });

    test('estado inicial es ThemeMode.system', () async {
      // Arrange & Act
      themeProvider = ThemeProvider();

      // Esperar a que se cargue el tema
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isSystemMode, true);
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.isLightMode, false);
    });

    test('isInitialized se vuelve true después de cargar', () async {
      // Arrange & Act
      themeProvider = ThemeProvider();

      // Inicialmente podría no estar inicializado
      expect(themeProvider.isInitialized, isFalse);

      // Esperar a que se inicialice
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(themeProvider.isInitialized, true);
    });

    test('setLightMode cambia el tema a claro', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      themeProvider.setLightMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isLightMode, true);
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.isSystemMode, false);
    });

    test('setDarkMode cambia el tema a oscuro', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.isLightMode, false);
      expect(themeProvider.isSystemMode, false);
    });

    test('setSystemMode cambia el tema a sistema', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      themeProvider.setDarkMode(); // Primero cambiamos a oscuro
      await Future.delayed(const Duration(milliseconds: 50));

      // Act
      themeProvider.setSystemMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isSystemMode, true);
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.isLightMode, false);
    });

    test('toggleTheme alterna entre claro y oscuro', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Act - Primera alternancia (oscuro -> claro)
      themeProvider.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.light);

      // Act - Segunda alternancia (claro -> oscuro)
      themeProvider.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('tema se persiste en SharedPreferences', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Verificar que se guardó en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, ThemeMode.dark.toString());
    });

    test('tema se carga desde SharedPreferences al inicializar', () async {
      // Arrange - Guardar un tema en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', ThemeMode.dark.toString());

      // Act - Crear nuevo provider (debe cargar el tema guardado)
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
    });

    test('notifica a los listeners cuando cambia el tema', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      int notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      // Act
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(notificationCount, greaterThanOrEqualTo(1));
    });

    test('no notifica si el tema no cambia', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));

      int notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      // Act - Intentar establecer el mismo tema
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(notificationCount, 0);
    });

    test('maneja errores de SharedPreferences gracefully', () async {
      // Arrange - Configurar SharedPreferences con un valor inválido
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', 'invalid_theme_mode');

      // Act - Crear provider (debería usar el default)
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Debería usar system como fallback
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isInitialized, true);
    });

    test('todos los ThemeMode values son soportados', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act & Assert - Light
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);

      // Act & Assert - Dark
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Act & Assert - System
      await themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('múltiples cambios de tema se persisten correctamente', () async {
      // Arrange
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - Múltiples cambios
      themeProvider.setLightMode();
      await Future.delayed(const Duration(milliseconds: 50));
      themeProvider.setDarkMode();
      await Future.delayed(const Duration(milliseconds: 50));
      themeProvider.setSystemMode();
      await Future.delayed(const Duration(milliseconds: 50));
      themeProvider.setLightMode();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Verificar el último valor guardado
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, ThemeMode.light.toString());
      expect(themeProvider.themeMode, ThemeMode.light);
    });
  });
}
