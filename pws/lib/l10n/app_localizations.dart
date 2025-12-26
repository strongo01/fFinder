import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and manage your favorite recipes'**
  String get recipesSubtitle;

  /// No description provided for @encryptionKeyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the encryption key.'**
  String get encryptionKeyLoadError;

  /// No description provided for @encryptionKeyLoadSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the encryption key for saving.'**
  String get encryptionKeyLoadSaveError;

  /// No description provided for @encryptedJson.
  ///
  /// In en, this message translates to:
  /// **'Encrypted JSON (nonce/cipher/tag)'**
  String get encryptedJson;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @mealNotifications.
  ///
  /// In en, this message translates to:
  /// **'Meal Notifications'**
  String get mealNotifications;

  /// No description provided for @enableMealNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableMealNotifications;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @enableGifs.
  ///
  /// In en, this message translates to:
  /// **'Show Mascot Animation (GIF)'**
  String get enableGifs;

  /// No description provided for @restartTutorial.
  ///
  /// In en, this message translates to:
  /// **'Restart Tutorial'**
  String get restartTutorial;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust your weight, height, goal, and activity.'**
  String get personalInfoDescription;

  /// No description provided for @currentWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get currentWeightKg;

  /// No description provided for @enterCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your current weight'**
  String get enterCurrentWeight;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get enterValidWeight;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterHeight;

  /// No description provided for @enterHeightBetween100And250.
  ///
  /// In en, this message translates to:
  /// **'Please enter a height between 100 and 250 cm'**
  String get enterHeightBetween100And250;

  /// No description provided for @waistCircumferenceCm.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (cm)'**
  String get waistCircumferenceCm;

  /// No description provided for @enterWaistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Enter your waist circumference'**
  String get enterWaistCircumference;

  /// No description provided for @enterValidWaistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Please enter a waist circumference between 30 and 200 cm'**
  String get enterValidWaistCircumference;

  /// No description provided for @targetWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Target Weight (kg)'**
  String get targetWeightKg;

  /// No description provided for @enterTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your target weight'**
  String get enterTargetWeight;

  /// No description provided for @enterValidTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target weight'**
  String get enterValidTargetWeight;

  /// No description provided for @sleepHoursPerNight.
  ///
  /// In en, this message translates to:
  /// **'Sleep (hours per night)'**
  String get sleepHoursPerNight;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @savingSettings.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingSettings;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @adminAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Admin Actions'**
  String get adminAnnouncements;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create New Announcement'**
  String get createAnnouncement;

  /// No description provided for @createAnnouncementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish an announcement for all users'**
  String get createAnnouncementSubtitle;

  /// No description provided for @manageAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Manage Announcements'**
  String get manageAnnouncements;

  /// No description provided for @manageAnnouncementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View, deactivate, or delete announcements'**
  String get manageAnnouncementsSubtitle;

  /// No description provided for @decryptValues.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decryptValues;

  /// No description provided for @decryptValuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decrypt values for user if they want to transfer account to another email'**
  String get decryptValuesSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting Account...'**
  String get deletingAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsAbsiDataAttribution.
  ///
  /// In en, this message translates to:
  /// **'This dataset is used for calculating ABSI Z-scores and categories in this app.'**
  String get creditsAbsiDataAttribution;

  /// No description provided for @absiAttribution.
  ///
  /// In en, this message translates to:
  /// **'Body Shape Index (ABSI) reference table is based on:\n\nY. Krakauer, Nir; C. Krakauer, Jesse (2015).\nTable S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\nPLOS ONE. Dataset.\nhttps://doi.org/10.1371/journal.pone.0039504.s001\n\nThis dataset is used for calculating ABSI Z-scores and categories in this app.'**
  String get absiAttribution;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get editAnnouncement;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty.'**
  String get titleCannotBeEmpty;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty.'**
  String get messageCannotBeEmpty;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @announcementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Announcement updated.'**
  String get announcementUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @announcementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Announcement deleted.'**
  String get announcementDeleted;

  /// No description provided for @errorLoadingAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading announcements.'**
  String get errorLoadingAnnouncements;

  /// No description provided for @noAnnouncementsFound.
  ///
  /// In en, this message translates to:
  /// **'No announcements found.'**
  String get noAnnouncementsFound;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @editAnnouncementTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get editAnnouncementTooltip;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'nl': return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
