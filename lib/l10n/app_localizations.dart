import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh Farm'**
  String get appTitle;

  /// No description provided for @autoMode.
  ///
  /// In en, this message translates to:
  /// **'AUTO MODE'**
  String get autoMode;

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'MANUAL MODE'**
  String get manualMode;

  /// No description provided for @liveSensors.
  ///
  /// In en, this message translates to:
  /// **'Live Sensors'**
  String get liveSensors;

  /// No description provided for @actuatorsRelays.
  ///
  /// In en, this message translates to:
  /// **'Actuators & Relays'**
  String get actuatorsRelays;

  /// No description provided for @sensorTemp.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get sensorTemp;

  /// No description provided for @sensorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get sensorHumidity;

  /// No description provided for @sensorEC.
  ///
  /// In en, this message translates to:
  /// **'EC Level'**
  String get sensorEC;

  /// No description provided for @sensorPH.
  ///
  /// In en, this message translates to:
  /// **'pH Level'**
  String get sensorPH;

  /// No description provided for @sensorWaterLevel.
  ///
  /// In en, this message translates to:
  /// **'Water Level'**
  String get sensorWaterLevel;

  /// No description provided for @sensorLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get sensorLight;

  /// No description provided for @sensorSubstrate.
  ///
  /// In en, this message translates to:
  /// **'Substrate Moisture'**
  String get sensorSubstrate;

  /// No description provided for @controlLedLights.
  ///
  /// In en, this message translates to:
  /// **'LED Lights'**
  String get controlLedLights;

  /// No description provided for @controlWaterPump.
  ///
  /// In en, this message translates to:
  /// **'Water Pump'**
  String get controlWaterPump;

  /// No description provided for @controlCoolingSystem.
  ///
  /// In en, this message translates to:
  /// **'Cooling System'**
  String get controlCoolingSystem;

  /// No description provided for @controlVentilationFans.
  ///
  /// In en, this message translates to:
  /// **'Ventilation Fans'**
  String get controlVentilationFans;

  /// No description provided for @controlRefillValve.
  ///
  /// In en, this message translates to:
  /// **'Refill Valve'**
  String get controlRefillValve;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @aiHub.
  ///
  /// In en, this message translates to:
  /// **'AI Hub'**
  String get aiHub;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @tabSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get tabSensors;

  /// No description provided for @tabControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get tabControls;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get roleSuperAdmin;

  /// No description provided for @roleEngineer.
  ///
  /// In en, this message translates to:
  /// **'Engineer'**
  String get roleEngineer;

  /// No description provided for @roleWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get roleWorker;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In to continue'**
  String get signInTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get invalidCredentials;

  /// No description provided for @tempDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature Details'**
  String get tempDetailsTitle;

  /// No description provided for @targetRange.
  ///
  /// In en, this message translates to:
  /// **'Target Range'**
  String get targetRange;

  /// No description provided for @autoCoolingActive.
  ///
  /// In en, this message translates to:
  /// **'Auto-Cooling Active: Fans & Cooler ON'**
  String get autoCoolingActive;

  /// No description provided for @autoCoolingStandby.
  ///
  /// In en, this message translates to:
  /// **'Auto-Cooling Standby: Temp Optimal'**
  String get autoCoolingStandby;

  /// No description provided for @manualControlOnly.
  ///
  /// In en, this message translates to:
  /// **'Manual Mode: Auto-logic disabled'**
  String get manualControlOnly;

  /// No description provided for @minTemp.
  ///
  /// In en, this message translates to:
  /// **'Min: {value}°C'**
  String minTemp(Object value);

  /// No description provided for @maxTemp.
  ///
  /// In en, this message translates to:
  /// **'Max: {value}°C'**
  String maxTemp(Object value);

  /// No description provided for @currentTemp.
  ///
  /// In en, this message translates to:
  /// **'Current Temperature'**
  String get currentTemp;

  /// No description provided for @tabProjectStatus.
  ///
  /// In en, this message translates to:
  /// **'Project Status'**
  String get tabProjectStatus;

  /// No description provided for @tabGreenhouses.
  ///
  /// In en, this message translates to:
  /// **'Greenhouses'**
  String get tabGreenhouses;

  /// No description provided for @tabWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Workforce'**
  String get tabWorkforce;

  /// No description provided for @investorHub.
  ///
  /// In en, this message translates to:
  /// **'Investor Hub'**
  String get investorHub;

  /// No description provided for @marketReadiness.
  ///
  /// In en, this message translates to:
  /// **'Market Readiness'**
  String get marketReadiness;

  /// No description provided for @estimatedYield.
  ///
  /// In en, this message translates to:
  /// **'Estimated Yield'**
  String get estimatedYield;

  /// No description provided for @activeOperations.
  ///
  /// In en, this message translates to:
  /// **'Active Operations'**
  String get activeOperations;

  /// No description provided for @periodicReports.
  ///
  /// In en, this message translates to:
  /// **'Periodic Reports'**
  String get periodicReports;

  /// No description provided for @greenhouseManagement.
  ///
  /// In en, this message translates to:
  /// **'Greenhouse Management'**
  String get greenhouseManagement;

  /// No description provided for @cropType.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropType;

  /// No description provided for @plantingDate.
  ///
  /// In en, this message translates to:
  /// **'Planting Date'**
  String get plantingDate;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @climateHealth.
  ///
  /// In en, this message translates to:
  /// **'Climate Health'**
  String get climateHealth;

  /// No description provided for @workforceManagement.
  ///
  /// In en, this message translates to:
  /// **'Workforce Management'**
  String get workforceManagement;

  /// No description provided for @totalPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Total Personnel'**
  String get totalPersonnel;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'Active Tasks'**
  String get activeTasks;

  /// No description provided for @salariesOverview.
  ///
  /// In en, this message translates to:
  /// **'Salaries Overview'**
  String get salariesOverview;

  /// No description provided for @reportedIssues.
  ///
  /// In en, this message translates to:
  /// **'Reported Issues'**
  String get reportedIssues;

  /// No description provided for @assignTask.
  ///
  /// In en, this message translates to:
  /// **'Assign Task'**
  String get assignTask;

  /// No description provided for @tabUserRequests.
  ///
  /// In en, this message translates to:
  /// **'User Requests'**
  String get tabUserRequests;

  /// No description provided for @loginMode.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginMode;

  /// No description provided for @registerMode.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerMode;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval Pending'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending admin approval. Please wait.'**
  String get pendingMessage;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @selectGreenhouses.
  ///
  /// In en, this message translates to:
  /// **'Assign Greenhouses'**
  String get selectGreenhouses;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @taskPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskPending;

  /// No description provided for @taskInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get taskInProgress;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @reportBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Report Breakdown'**
  String get reportBreakdown;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get reportDescription;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendReport;

  /// No description provided for @incidentReported.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully'**
  String get incidentReported;

  /// No description provided for @aiInsightPerfect.
  ///
  /// In en, this message translates to:
  /// **'Condition: Excellent. All systems optimal.'**
  String get aiInsightPerfect;

  /// No description provided for @aiInsightGood.
  ///
  /// In en, this message translates to:
  /// **'Condition: Good. Minor adjustments recommended.'**
  String get aiInsightGood;

  /// No description provided for @aiInsightWarning.
  ///
  /// In en, this message translates to:
  /// **'Condition: Warning. One or more parameters outside ideal range.'**
  String get aiInsightWarning;

  /// No description provided for @aiInsightDanger.
  ///
  /// In en, this message translates to:
  /// **'Condition: Critical! Immediate action required.'**
  String get aiInsightDanger;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @trend24h.
  ///
  /// In en, this message translates to:
  /// **'24h Sensor Trend'**
  String get trend24h;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
