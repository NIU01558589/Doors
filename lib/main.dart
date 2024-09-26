import 'package:fita3_frontend/screen_space.dart';
import 'package:flutter/material.dart';
import 'tutorial_acs/screen_partition.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'Language.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Language(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final language = Provider.of<Language>(context);

    return MaterialApp(

      supportedLocales: [
        const Locale('en'),
        const Locale('es'),
        const Locale('ca'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

      ],
      locale: language.locale,
      debugShowCheckedModeBanner: false,
      // removes the debug banner that hides the home button
      title: 'ACS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFEDE7F6), // instead of deepPurple
          brightness: Brightness.light,),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 20), // size of hello
        ),
        // see https://docs.flutter.dev/cookbook/design/themes
      ),
      home: const ScreenPartition(id: "ROOT"),
    );
  }
}

