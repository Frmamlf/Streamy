import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Streamy'**
  String get appTitle;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search screen title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Ad blocking settings title
  ///
  /// In en, this message translates to:
  /// **'Ad Blocking'**
  String get adBlocking;

  /// Source management screen title
  ///
  /// In en, this message translates to:
  /// **'Source Management'**
  String get sourceManagement;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search for movies...'**
  String get searchMovies;

  /// Message when no search results are found
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Downloads screen title
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// Downloading tab title
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// Completed tab title
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Failed tab title
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Providers screen title
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providers;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Watch now button text
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// Cast section title
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// Director label
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// Year label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Description section title
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Similar movies section title
  ///
  /// In en, this message translates to:
  /// **'Similar Movies'**
  String get similarMovies;

  /// Video sources section title
  ///
  /// In en, this message translates to:
  /// **'Video Sources'**
  String get videoSources;

  /// Video quality label
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// Video format label
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// Network filtering setting
  ///
  /// In en, this message translates to:
  /// **'Network Filtering'**
  String get networkFiltering;

  /// Cosmetic filtering setting
  ///
  /// In en, this message translates to:
  /// **'Cosmetic Filtering'**
  String get cosmeticFiltering;

  /// Script blocking setting
  ///
  /// In en, this message translates to:
  /// **'Script Blocking'**
  String get scriptBlocking;

  /// Cookie notices blocking setting
  ///
  /// In en, this message translates to:
  /// **'Block Cookie Notices'**
  String get cookieNotices;

  /// Social widgets blocking setting
  ///
  /// In en, this message translates to:
  /// **'Block Social Widgets'**
  String get socialWidgets;

  /// Tracking blocking setting
  ///
  /// In en, this message translates to:
  /// **'Block Tracking'**
  String get tracking;

  /// Custom patterns section title
  ///
  /// In en, this message translates to:
  /// **'Custom Patterns'**
  String get customPatterns;

  /// Allowed domains section title
  ///
  /// In en, this message translates to:
  /// **'Allowed Domains'**
  String get allowedDomains;

  /// Add pattern button text
  ///
  /// In en, this message translates to:
  /// **'Add Pattern'**
  String get addPattern;

  /// Add domain button text
  ///
  /// In en, this message translates to:
  /// **'Add Domain'**
  String get addDomain;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Export settings button text
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// Import settings button text
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// Import coming soon message
  ///
  /// In en, this message translates to:
  /// **'Import functionality coming soon'**
  String get importComingSoon;

  /// Settings exported success message
  ///
  /// In en, this message translates to:
  /// **'Settings exported successfully'**
  String get settingsExported;

  /// Export failed message
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// Web sources section title
  ///
  /// In en, this message translates to:
  /// **'Web Sources'**
  String get webSources;

  /// Add source button text
  ///
  /// In en, this message translates to:
  /// **'Add Source'**
  String get addSource;

  /// Source name input label
  ///
  /// In en, this message translates to:
  /// **'Source Name'**
  String get sourceName;

  /// Source URL input label
  ///
  /// In en, this message translates to:
  /// **'Source URL'**
  String get sourceUrl;

  /// Enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
