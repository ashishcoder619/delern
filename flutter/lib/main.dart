import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/decks_list/decks_list.dart';
import 'package:delern_flutter/views/edit_deck/edit_deck.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/onboarding/onboarding.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:pedantic/pedantic.dart';

class App extends StatelessWidget {
  static final _analyticsNavigatorObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

  @override
  Widget build(BuildContext context) {
    var title = 'Delern';
    assert((title = 'Delern DEBUG') != null);
    return MaterialApp(
      // Produce collections of localized values
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        // This list limits what locales Global Localizations delegates above
        // will support. The first element of this list is a fallback locale.
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      navigatorObservers: [
        _analyticsNavigatorObserver,
        FlutterSentryNavigatorObserver(
            breadcrumbs: FlutterSentry.instance.breadcrumbs),
      ],
      title: title,
      // SignInWidget must be above Navigator to provide CurrentUserWidget.of().
      builder: (context, child) =>
          Onboarding(afterOnboardingBuilder: () => AuthWidget(child: child)),
      theme: ThemeData(
          scaffoldBackgroundColor: app_styles.kScaffoldBackgroundColor,
          primarySwatch: app_styles.kPrimarySwatch,
          accentColor: app_styles.kAccentColor),
      routes: {
        EditDeck.routeName: (_) => const EditDeck(),
        CardCreateUpdate.routeNameNew: (_) => const CardCreateUpdate(),
        CardCreateUpdate.routeNameEdit: (_) => const CardCreateUpdate(),
        CardPreview.routeName: (_) => const CardPreview(),
        CardsIntervalLearning.routeName: (_) => const CardsIntervalLearning(),
      },
      home: const DecksList(),
    );
  }
}

Future<void> main() => FlutterSentry.wrap(
      () async {
        unawaited(FirebaseDatabase.instance.setPersistenceEnabled(true));
        unawaited(FirebaseAnalytics().logAppOpen());
        runApp(App());
      },
      dsn: 'https://e6b5021448e14a49803b2c734621deae@sentry.io/1867466',
    );
