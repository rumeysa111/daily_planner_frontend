import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📌 Riverpod'u ekledik!
import 'package:intl/date_symbol_data_local.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/core/theme/app_theme.dart';
import 'package:mytodo_app/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/remote_config_service.dart';
import 'domain/presentation/pages/auth/login_page.dart'; // 📌 Login sayfasını çağırıyoruz

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final remoteConfig = RemoteConfigService();
    await remoteConfig.initialize().catchError((error) {
      print('Remote config error handled: $error');
      // Hata olsa bile uygulamanın çalışmasına izin ver
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    runApp(
      ProviderScope(
        child: MyApp(isLoggenIn: token != null),
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Firebase başlatılamazsa bile uygulamayı çalıştır
    runApp(
      ProviderScope(
        child: MyApp(isLoggenIn: false),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggenIn;
  MyApp({required this.isLoggenIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
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
