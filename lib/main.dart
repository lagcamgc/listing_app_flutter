import 'package:firebase_auth/firebase_auth.dart';
import 'package:listing_app_flutter/firebase_options.dart';
import 'package:listing_app_flutter/screens/detail_screen.dart';
import 'package:listing_app_flutter/screens/insert_and_edit_screen.dart';
import 'package:listing_app_flutter/screens/menu_frame.dart';
import 'package:listing_app_flutter/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


    usePathUrlStrategy();
    runApp(const MyApp()); // starting point of app
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
        supportedLocales: [
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          FormBuilderLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        routerConfig: GoRouter(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const WelcomeScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'menu',
                  builder: (BuildContext context, GoRouterState state) {
                    return const MenuFrame();
                  },
                ),
                GoRoute(
                  path: 'insert/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return InsertAndEditScreen(id: state.pathParameters['id'].toString());
                  },
                ),
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return DetailScreen(id: state.pathParameters['id'].toString());
                  },
                ),
              ],
            ),
          ],
        )
    );
  }
}

