// ignore_for_file: avoid_print, unused_import, unnecessary_const

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📌 Riverpod'u ekledik!
import 'package:intl/date_symbol_data_local.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/core/theme/app_theme.dart';
import 'package:mytodo_app/domain/presentation/providers/theme_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'domain/presentation/views/auth/login_page.dart'; // 📌 Login sayfasını çağırıyoruz

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  try {
  


    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    runApp(
      ProviderScope(
        child: MyApp(isLoggenIn: token != null),
      ),
    );
  } catch (e) {
    runApp(
      const ProviderScope(
        child: const MyApp(isLoggenIn: false),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  final bool isLoggenIn;
  // ignore: use_key_in_widget_constructors
  const MyApp({required this.isLoggenIn});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final isDarkMode=ref.watch(themeProvider);
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      locale: const Locale('tr', 'TR'),
      initialRoute: isLoggenIn
          ? AppRoutes.home
          : AppRoutes
              .onboarding, //uygulama ilk açıldıgında login sayfası gelicek
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
