import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize date formatting
    await initializeDateFormatting('tr_TR', null);

    // Initialize Remote Config after Firebase
    final remoteConfig = RemoteConfigService();
    await remoteConfig.initialize().catchError((error) {
      print('Remote config error handled: $error');
    });
    

    // Check authentication status
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    print('Auth token status: ${token != null ? 'exists' : 'not found'}');

    runApp(
      ProviderScope(
        child: MyApp(
          isLoggenIn: token != null,
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    
    // Fallback to run app without initialization
    runApp(
      ProviderScope(
        
        child: MyApp(
          
          isLoggenIn: false,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggenIn;
  
  const MyApp({
    required this.isLoggenIn,
    Key? key,
  }) : super(key: key);

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
      // Changed initial route to always show login first
      initialRoute: !isLoggenIn 
      ?  AppRoutes.onboarding
      : AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
