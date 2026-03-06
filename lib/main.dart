import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'core/auth_service.dart';
import 'core/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/app_language_provider.dart';
import 'core/iot_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FreshFarmApp());
}

class FreshFarmApp extends StatelessWidget {
  const FreshFarmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => IoTService()),
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, langProvider, child) {
          final authService = context.read<AuthService>();
          final router = AppRouter.createRouter(authService);

          return MaterialApp.router(
            title: 'Fresh Farm',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
            locale: langProvider.appLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ar', ''), // Arabic
              Locale('fr', ''), // French
            ],
          );
        },
      ),
    );
  }
}
