import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('fr'),
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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @useSystemLocale.
  ///
  /// In en, this message translates to:
  /// **'Use System Locale'**
  String get useSystemLocale;

  /// No description provided for @activityLow.
  ///
  /// In en, this message translates to:
  /// **'Low activity: sedentary work, little movement, no sports'**
  String get activityLow;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Light activity: 1–3x/week light training or daily 30–45 min walking'**
  String get activityLight;

  /// No description provided for @activityMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate activity: 3–5x/week exercise or active job'**
  String get activityMedium;

  /// No description provided for @activityVery.
  ///
  /// In en, this message translates to:
  /// **'Very active: 6–7x/week intense training or physically heavy work'**
  String get activityVery;

  /// No description provided for @activityExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme activity: pro training 2x/day or extreme manual work'**
  String get activityExtreme;

  /// No description provided for @goalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLose;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get goalMaintain;

  /// No description provided for @goalGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain weight (muscle)'**
  String get goalGainMuscle;

  /// No description provided for @goalGainGeneral.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get goalGainGeneral;

  /// No description provided for @createAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Announcement'**
  String get createAnnouncementTitle;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @messageValidationError.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty.'**
  String get messageValidationError;

  /// No description provided for @announcementPublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Announcement published successfully!'**
  String get announcementPublishedSuccess;

  /// No description provided for @publishButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButtonLabel;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have made changes that have not been saved yet. Are you sure you want to exit without saving?'**
  String get unsavedChangesMessage;

  /// No description provided for @discardButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButtonLabel;

  /// No description provided for @cancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @tutorialRestartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tutorial has been restarted!'**
  String get tutorialRestartedMessage;

  /// No description provided for @deleteAnnouncementTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Announcement'**
  String get deleteAnnouncementTooltip;

  /// No description provided for @duplicateRequestError.
  ///
  /// In en, this message translates to:
  /// **'There is already a pending request for this value.'**
  String get duplicateRequestError;

  /// No description provided for @requestSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Decryption request submitted for approval.'**
  String get requestSubmittedSuccess;

  /// No description provided for @requestSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Request submission failed'**
  String get requestSubmissionFailed;

  /// No description provided for @requestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found'**
  String get requestNotFound;

  /// No description provided for @cannotApproveOwnRequest.
  ///
  /// In en, this message translates to:
  /// **'You cannot approve your own request.'**
  String get cannotApproveOwnRequest;

  /// No description provided for @dekNotFoundForUser.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve encryption key.'**
  String get dekNotFoundForUser;

  /// No description provided for @requestApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request approved.'**
  String get requestApprovedSuccess;

  /// No description provided for @requestApprovalFailed.
  ///
  /// In en, this message translates to:
  /// **'Request approval failed'**
  String get requestApprovalFailed;

  /// No description provided for @cannotRejectOwnRequest.
  ///
  /// In en, this message translates to:
  /// **'You cannot reject your own request.'**
  String get cannotRejectOwnRequest;

  /// No description provided for @requestRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get requestRejectedSuccess;

  /// No description provided for @requestRejectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Request rejection failed'**
  String get requestRejectionFailed;

  /// No description provided for @pleaseEnterUid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a UID'**
  String get pleaseEnterUid;

  /// No description provided for @pleaseEnterEncryptedJson.
  ///
  /// In en, this message translates to:
  /// **'Please enter the encrypted JSON'**
  String get pleaseEnterEncryptedJson;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests.'**
  String get noPendingRequests;

  /// No description provided for @forUid.
  ///
  /// In en, this message translates to:
  /// **'For UID'**
  String get forUid;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @encryptedJsonLabel.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Value:'**
  String get encryptedJsonLabel;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @confirmSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmSignOutTitle;

  /// No description provided for @confirmSignOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOutMessage;

  /// No description provided for @confirmDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Account'**
  String get confirmDeleteAccountTitle;

  /// No description provided for @confirmDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get confirmDeleteAccountMessage;

  /// No description provided for @deletionCodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Type the code below to confirm:'**
  String get deletionCodeInstruction;

  /// No description provided for @enterDeletionCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterDeletionCodeLabel;

  /// No description provided for @deletionCodeMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Code does not match, please try again.'**
  String get deletionCodeMismatchError;

  /// No description provided for @deleteAccountButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButtonLabel;

  /// No description provided for @settingsSavedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessMessage;

  /// No description provided for @settingsSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings save failed'**
  String get settingsSaveFailedMessage;

  /// No description provided for @profileLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get profileLoadFailedMessage;

  /// No description provided for @deleteAccountRecentLoginError.
  ///
  /// In en, this message translates to:
  /// **'Please log in again and try deleting your account.'**
  String get deleteAccountRecentLoginError;

  /// No description provided for @deleteAccountFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed'**
  String get deleteAccountFailedMessage;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty.'**
  String get titleValidationError;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @appCredits.
  ///
  /// In en, this message translates to:
  /// **'ABSI Data Attribution'**
  String get appCredits;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the rapport!'**
  String get reportThanks;

  /// No description provided for @errorSending.
  ///
  /// In en, this message translates to:
  /// **'Error sending'**
  String get errorSending;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report items'**
  String get reportTitle;

  /// No description provided for @categoryFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Functionality'**
  String get categoryFunctionality;

  /// No description provided for @itemFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get itemFeatures;

  /// No description provided for @itemFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Functionality'**
  String get itemFunctionality;

  /// No description provided for @itemUsability.
  ///
  /// In en, this message translates to:
  /// **'Usability'**
  String get itemUsability;

  /// No description provided for @itemClarity.
  ///
  /// In en, this message translates to:
  /// **'Clarity'**
  String get itemClarity;

  /// No description provided for @itemAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get itemAccuracy;

  /// No description provided for @itemNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get itemNavigation;

  /// No description provided for @categoryPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get categoryPerformance;

  /// No description provided for @itemSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get itemSpeed;

  /// No description provided for @itemLoadingTimes.
  ///
  /// In en, this message translates to:
  /// **'Loading times'**
  String get itemLoadingTimes;

  /// No description provided for @itemStability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get itemStability;

  /// No description provided for @categoryInterfaceDesign.
  ///
  /// In en, this message translates to:
  /// **'Interface & Design'**
  String get categoryInterfaceDesign;

  /// No description provided for @itemLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get itemLayout;

  /// No description provided for @itemColorsTheme.
  ///
  /// In en, this message translates to:
  /// **'Colors & Theme'**
  String get itemColorsTheme;

  /// No description provided for @itemIconsDesign.
  ///
  /// In en, this message translates to:
  /// **'Icons & Design'**
  String get itemIconsDesign;

  /// No description provided for @itemReadability.
  ///
  /// In en, this message translates to:
  /// **'Readability'**
  String get itemReadability;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// No description provided for @itemErrors.
  ///
  /// In en, this message translates to:
  /// **'Error messages'**
  String get itemErrors;

  /// No description provided for @itemExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation & Instructions'**
  String get itemExplanation;

  /// No description provided for @categoryAppParts.
  ///
  /// In en, this message translates to:
  /// **'App Parts'**
  String get categoryAppParts;

  /// No description provided for @itemDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get itemDashboard;

  /// No description provided for @itemLogin.
  ///
  /// In en, this message translates to:
  /// **'Login / Registration'**
  String get itemLogin;

  /// No description provided for @itemWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get itemWeight;

  /// No description provided for @itemStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get itemStatistics;

  /// No description provided for @itemCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get itemCalendar;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @itemGeneralSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'General satisfaction'**
  String get itemGeneralSatisfaction;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Provide feedback'**
  String get feedbackTitle;

  /// No description provided for @viewAllFeedback.
  ///
  /// In en, this message translates to:
  /// **'View all feedback'**
  String get viewAllFeedback;

  /// No description provided for @viewAllRapportFeedback.
  ///
  /// In en, this message translates to:
  /// **'View all report feedback'**
  String get viewAllRapportFeedback;

  /// No description provided for @openRapportButton.
  ///
  /// In en, this message translates to:
  /// **'Tap to fill out the report!\nNote: this is an extensive questionnaire. Only fill it out after you have tested the app for several days.'**
  String get openRapportButton;

  /// No description provided for @feedbackIntro.
  ///
  /// In en, this message translates to:
  /// **'You can provide feedback here at any time.'**
  String get feedbackIntro;

  /// No description provided for @choiceBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get choiceBug;

  /// No description provided for @choiceFeature.
  ///
  /// In en, this message translates to:
  /// **'New feature'**
  String get choiceFeature;

  /// No description provided for @choiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get choiceLanguage;

  /// No description provided for @choiceLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get choiceLayout;

  /// No description provided for @choiceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get choiceOther;

  /// No description provided for @languageSectionInstruction.
  ///
  /// In en, this message translates to:
  /// **'Specify which language is affected and describe the error. The default language is the one selected in the app.'**
  String get languageSectionInstruction;

  /// No description provided for @dropdownLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language the feedback refers to'**
  String get dropdownLabelLanguage;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to tell us?'**
  String get messageHint;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get enterMessage;

  /// No description provided for @emailHintOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailHintOptional;

  /// No description provided for @allFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'All feedback'**
  String get allFeedbackTitle;

  /// No description provided for @noFeedbackFound.
  ///
  /// In en, this message translates to:
  /// **'No feedback found.'**
  String get noFeedbackFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurred;

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get noMessage;

  /// No description provided for @unknownType.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownType;

  /// No description provided for @appLanguagePrefix.
  ///
  /// In en, this message translates to:
  /// **'App: '**
  String get appLanguagePrefix;

  /// No description provided for @reportedLanguagePrefix.
  ///
  /// In en, this message translates to:
  /// **'Reported: '**
  String get reportedLanguagePrefix;

  /// No description provided for @submittedOnPrefix.
  ///
  /// In en, this message translates to:
  /// **'Submitted on: '**
  String get submittedOnPrefix;

  /// No description provided for @uidLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'UID: '**
  String get uidLabelPrefix;

  /// No description provided for @couldNotOpenMailAppPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not open mail app: '**
  String get couldNotOpenMailAppPrefix;

  /// No description provided for @allRapportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'All report feedback'**
  String get allRapportFeedbackTitle;

  /// No description provided for @noRapportFeedbackFound.
  ///
  /// In en, this message translates to:
  /// **'No report feedback found.'**
  String get noRapportFeedbackFound;

  /// No description provided for @rapportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Report feedback'**
  String get rapportFeedbackTitle;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weight'**
  String get weightTitle;

  /// No description provided for @weightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust your weight and view your BMI.'**
  String get weightSubtitle;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @targetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Target weight (kg)'**
  String get targetWeightLabel;

  /// No description provided for @weightSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight slider'**
  String get weightSliderLabel;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveWeight.
  ///
  /// In en, this message translates to:
  /// **'Save weight'**
  String get saveWeight;

  /// No description provided for @saveWaist.
  ///
  /// In en, this message translates to:
  /// **'Save waist'**
  String get saveWaist;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Weight + goals saved'**
  String get saveSuccess;

  /// No description provided for @saveFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Save failed:'**
  String get saveFailedPrefix;

  /// No description provided for @weightLoadErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not load user data:'**
  String get weightLoadErrorPrefix;

  /// No description provided for @bmiTitle.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmiTitle;

  /// No description provided for @bmiInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data to calculate BMI. Enter your height and weight.'**
  String get bmiInsufficient;

  /// No description provided for @yourBmiPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your BMI:'**
  String get yourBmiPrefix;

  /// No description provided for @waistAbsiTitle.
  ///
  /// In en, this message translates to:
  /// **'Waist / ABSI'**
  String get waistAbsiTitle;

  /// No description provided for @waistLabel.
  ///
  /// In en, this message translates to:
  /// **'Waist circumference (cm)'**
  String get waistLabel;

  /// No description provided for @absiInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data to calculate ABSI. Enter waist, height and weight.'**
  String get absiInsufficient;

  /// No description provided for @yourAbsiPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your ABSI:'**
  String get yourAbsiPrefix;

  /// No description provided for @absiLowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low risk'**
  String get absiLowRisk;

  /// No description provided for @absiMedium.
  ///
  /// In en, this message translates to:
  /// **'Average risk'**
  String get absiMedium;

  /// No description provided for @choiceWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get choiceWeight;

  /// No description provided for @choiceWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get choiceWaist;

  /// No description provided for @choiceTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get choiceTable;

  /// No description provided for @choiceChart.
  ///
  /// In en, this message translates to:
  /// **'Chart (per month)'**
  String get choiceChart;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements saved yet.'**
  String get noMeasurements;

  /// No description provided for @noWaistMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No waist measurements saved yet.'**
  String get noWaistMeasurements;

  /// No description provided for @tableMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements table'**
  String get tableMeasurementsTitle;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get deleteConfirmContent;

  /// No description provided for @deleteConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmDelete;

  /// No description provided for @measurementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted'**
  String get measurementDeleted;

  /// No description provided for @chartTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Chart –'**
  String get chartTitlePrefix;

  /// No description provided for @chartTooFew.
  ///
  /// In en, this message translates to:
  /// **'Not enough measurements in this month for a chart.'**
  String get chartTooFew;

  /// No description provided for @chartAxesLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizontal: days of the month, Vertical: value'**
  String get chartAxesLabel;

  /// No description provided for @estimateNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to compute a trend.'**
  String get estimateNotEnoughData;

  /// No description provided for @estimateOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Well done! You are at your target weight.'**
  String get estimateOnTarget;

  /// No description provided for @estimateNoTrend.
  ///
  /// In en, this message translates to:
  /// **'No trend to compute yet.'**
  String get estimateNoTrend;

  /// No description provided for @estimateStable.
  ///
  /// In en, this message translates to:
  /// **'Your weight is fairly stable; no reliable trend.'**
  String get estimateStable;

  /// No description provided for @estimateWrongDirection.
  ///
  /// In en, this message translates to:
  /// **'With the current trend you are moving away from your target weight.'**
  String get estimateWrongDirection;

  /// No description provided for @estimateInsufficientInfo.
  ///
  /// In en, this message translates to:
  /// **'Insufficient trend information to make a realistic estimate.'**
  String get estimateInsufficientInfo;

  /// No description provided for @estimateUnlikelyWithin10Years.
  ///
  /// In en, this message translates to:
  /// **'Based on the current trend it\'s unlikely you\'ll reach your target within 10 years.'**
  String get estimateUnlikelyWithin10Years;

  /// No description provided for @estimateUncertaintyHigh.
  ///
  /// In en, this message translates to:
  /// **'Warning: very large fluctuations make this estimate unreliable.'**
  String get estimateUncertaintyHigh;

  /// No description provided for @estimateUncertaintyMedium.
  ///
  /// In en, this message translates to:
  /// **'Warning: considerable fluctuations make this estimate uncertain.'**
  String get estimateUncertaintyMedium;

  /// No description provided for @estimateUncertaintyLow.
  ///
  /// In en, this message translates to:
  /// **'Note: some variation — estimate may differ.'**
  String get estimateUncertaintyLow;

  /// No description provided for @estimateBasisRecent.
  ///
  /// In en, this message translates to:
  /// **'based on the past month'**
  String get estimateBasisRecent;

  /// No description provided for @estimateBasisAll.
  ///
  /// In en, this message translates to:
  /// **'based on all measurements'**
  String get estimateBasisAll;

  /// No description provided for @estimateResultPrefix.
  ///
  /// In en, this message translates to:
  /// **'If you continue like this (), you\'ll reach your target weight in about'**
  String get estimateResultPrefix;

  /// No description provided for @bmiVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very underweight'**
  String get bmiVeryLow;

  /// No description provided for @bmiLow.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiLow;

  /// No description provided for @bmiGood.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get bmiGood;

  /// No description provided for @bmiHigh.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiHigh;

  /// No description provided for @bmiVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiVeryHigh;

  /// No description provided for @thanksFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksFeedback;

  /// No description provided for @absiVeryLowRisk.
  ///
  /// In en, this message translates to:
  /// **'Very low risk'**
  String get absiVeryLowRisk;

  /// No description provided for @absiIncreasedRisk.
  ///
  /// In en, this message translates to:
  /// **'Increased risk'**
  String get absiIncreasedRisk;

  /// No description provided for @recipesSwipeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Swipe to save or skip recipes.'**
  String get recipesSwipeInstruction;

  /// No description provided for @recipesNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more recipes.'**
  String get recipesNoMore;

  /// No description provided for @recipesSavedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Saved: '**
  String get recipesSavedPrefix;

  /// No description provided for @recipesSkippedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Skipped: '**
  String get recipesSkippedPrefix;

  /// No description provided for @recipesDetailId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get recipesDetailId;

  /// No description provided for @recipesDetailPreparationTime.
  ///
  /// In en, this message translates to:
  /// **'Preparation time'**
  String get recipesDetailPreparationTime;

  /// No description provided for @recipesDetailTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get recipesDetailTotalTime;

  /// No description provided for @recipesDetailKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get recipesDetailKcal;

  /// No description provided for @recipesDetailFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get recipesDetailFat;

  /// No description provided for @recipesDetailSaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated fat'**
  String get recipesDetailSaturatedFat;

  /// No description provided for @recipesDetailCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get recipesDetailCarbs;

  /// No description provided for @recipesDetailProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get recipesDetailProtein;

  /// No description provided for @recipesDetailFibers.
  ///
  /// In en, this message translates to:
  /// **'Fibers'**
  String get recipesDetailFibers;

  /// No description provided for @recipesDetailSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get recipesDetailSalt;

  /// No description provided for @recipesDetailPersons.
  ///
  /// In en, this message translates to:
  /// **'Persons'**
  String get recipesDetailPersons;

  /// No description provided for @recipesDetailDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get recipesDetailDifficulty;

  /// No description provided for @recipesPrepreparation.
  ///
  /// In en, this message translates to:
  /// **'Pre-preparation'**
  String get recipesPrepreparation;

  /// No description provided for @recipesIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipesIngredients;

  /// No description provided for @recipesSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipesSteps;

  /// No description provided for @recipesKitchens.
  ///
  /// In en, this message translates to:
  /// **'Kitchens'**
  String get recipesKitchens;

  /// No description provided for @recipesCourses.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get recipesCourses;

  /// No description provided for @recipesRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get recipesRequirements;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @tea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tea;

  /// No description provided for @soda.
  ///
  /// In en, this message translates to:
  /// **'Soda'**
  String get soda;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @coffeeBlack.
  ///
  /// In en, this message translates to:
  /// **'Black coffee'**
  String get coffeeBlack;

  /// No description provided for @espresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get espresso;

  /// No description provided for @ristretto.
  ///
  /// In en, this message translates to:
  /// **'Ristretto'**
  String get ristretto;

  /// No description provided for @lungo.
  ///
  /// In en, this message translates to:
  /// **'Lungo'**
  String get lungo;

  /// No description provided for @americano.
  ///
  /// In en, this message translates to:
  /// **'Americano'**
  String get americano;

  /// No description provided for @coffeeWithMilk.
  ///
  /// In en, this message translates to:
  /// **'Coffee with milk'**
  String get coffeeWithMilk;

  /// No description provided for @coffeeWithMilkSugar.
  ///
  /// In en, this message translates to:
  /// **'Coffee with milk and sugar'**
  String get coffeeWithMilkSugar;

  /// No description provided for @cappuccino.
  ///
  /// In en, this message translates to:
  /// **'Cappuccino'**
  String get cappuccino;

  /// No description provided for @latte.
  ///
  /// In en, this message translates to:
  /// **'Latte'**
  String get latte;

  /// No description provided for @flatWhite.
  ///
  /// In en, this message translates to:
  /// **'Flat white'**
  String get flatWhite;

  /// No description provided for @macchiato.
  ///
  /// In en, this message translates to:
  /// **'Macchiato'**
  String get macchiato;

  /// No description provided for @latteMacchiato.
  ///
  /// In en, this message translates to:
  /// **'Latte macchiato'**
  String get latteMacchiato;

  /// No description provided for @icedCoffee.
  ///
  /// In en, this message translates to:
  /// **'Iced coffee'**
  String get icedCoffee;

  /// No description provided for @otherCoffee.
  ///
  /// In en, this message translates to:
  /// **'Other coffee'**
  String get otherCoffee;

  /// No description provided for @newDrinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Drink'**
  String get newDrinkTitle;

  /// No description provided for @chooseDrink.
  ///
  /// In en, this message translates to:
  /// **'Choose a drink'**
  String get chooseDrink;

  /// No description provided for @chooseCoffeeType.
  ///
  /// In en, this message translates to:
  /// **'Choose coffee type'**
  String get chooseCoffeeType;

  /// No description provided for @drinkNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Drink name'**
  String get drinkNameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @amountMlLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMlLabel;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @kcalPer100Label.
  ///
  /// In en, this message translates to:
  /// **'Kcal per 100 ml'**
  String get kcalPer100Label;

  /// No description provided for @barcodeSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search by barcode'**
  String get barcodeSearchTooltip;

  /// No description provided for @kcalRequired.
  ///
  /// In en, this message translates to:
  /// **'Kcal value is required'**
  String get kcalRequired;

  /// No description provided for @addDrinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add drink'**
  String get addDrinkTitle;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @addAndLogButton.
  ///
  /// In en, this message translates to:
  /// **'Add and log'**
  String get addAndLogButton;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @scanPasteBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan / paste barcode'**
  String get scanPasteBarcode;

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode (EAN/GTIN)'**
  String get barcodeLabel;

  /// No description provided for @enterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get enterBarcode;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @noKcalFoundPrefix.
  ///
  /// In en, this message translates to:
  /// **'No kcal value found for barcode '**
  String get noKcalFoundPrefix;

  /// No description provided for @foundPrefix.
  ///
  /// In en, this message translates to:
  /// **'Found: '**
  String get foundPrefix;

  /// No description provided for @kcalPer100Unit.
  ///
  /// In en, this message translates to:
  /// **' kcal per 100g/ml'**
  String get kcalPer100Unit;

  /// No description provided for @whenDrankTitle.
  ///
  /// In en, this message translates to:
  /// **'When consumed?'**
  String get whenDrankTitle;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @loginToLog.
  ///
  /// In en, this message translates to:
  /// **'Log in to log'**
  String get loginToLog;

  /// No description provided for @editDrinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit drink'**
  String get editDrinkTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get added;

  /// No description provided for @sportAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sport'**
  String get sportAddTitle;

  /// No description provided for @newSportActivity.
  ///
  /// In en, this message translates to:
  /// **'New sportactivity'**
  String get newSportActivity;

  /// No description provided for @labelSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get labelSport;

  /// No description provided for @chooseSport.
  ///
  /// In en, this message translates to:
  /// **'Choose a sport'**
  String get chooseSport;

  /// No description provided for @customSportName.
  ///
  /// In en, this message translates to:
  /// **'Name of sport'**
  String get customSportName;

  /// No description provided for @enterSportName.
  ///
  /// In en, this message translates to:
  /// **'Enter a sport name'**
  String get enterSportName;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @invalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid duration'**
  String get invalidDuration;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get caloriesBurned;

  /// No description provided for @invalidCalories.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of calories'**
  String get invalidCalories;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @encryptionKeyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Encryption key not found.'**
  String get encryptionKeyNotFound;

  /// No description provided for @noSportsYet.
  ///
  /// In en, this message translates to:
  /// **'No sport activities yet.'**
  String get noSportsYet;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @intensityLevel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLevel;

  /// No description provided for @intensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get intensityLight;

  /// No description provided for @intensityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get intensityNormal;

  /// No description provided for @intensityHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get intensityHard;

  /// No description provided for @intensityVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very hard'**
  String get intensityVeryHard;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get userNotLoggedIn;

  /// No description provided for @sportAdded.
  ///
  /// In en, this message translates to:
  /// **'Sport activity added'**
  String get sportAdded;

  /// No description provided for @sportRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sportRunning;

  /// No description provided for @sportCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportCycling;

  /// No description provided for @sportSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportSwimming;

  /// No description provided for @sportWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get sportWalking;

  /// No description provided for @sportFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get sportFitness;

  /// No description provided for @sportFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get sportFootball;

  /// No description provided for @sportTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get sportYoga;

  /// No description provided for @sportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportOther;

  /// No description provided for @deleteSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete sport activity?'**
  String get deleteSportTitle;

  /// No description provided for @deleteSportContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sport activity?'**
  String get deleteSportContent;

  /// No description provided for @sportDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sport activity deleted'**
  String get sportDeleted;

  /// No description provided for @editSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sport Activity'**
  String get editSportTitle;

  /// No description provided for @sportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sport activity updated'**
  String get sportUpdated;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get notLoggedIn;

  /// No description provided for @addSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sport Activity'**
  String get addSportTitle;

  /// No description provided for @sportLabel.
  ///
  /// In en, this message translates to:
  /// **'Sport Activity'**
  String get sportLabel;

  /// No description provided for @customSportLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Sport Name'**
  String get customSportLabel;

  /// No description provided for @customSportRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom sport name is required.'**
  String get customSportRequired;

  /// No description provided for @logSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Sport Activity'**
  String get logSportTitle;

  /// No description provided for @intensityHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get intensityHeavy;

  /// No description provided for @intensityVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very Heavy'**
  String get intensityVeryHeavy;

  /// No description provided for @intensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLabel;

  /// No description provided for @enterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration.'**
  String get enterValidDuration;

  /// No description provided for @caloriesBurnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurnedLabel;

  /// No description provided for @enterValidCalories.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of calories.'**
  String get enterValidCalories;

  /// No description provided for @durationShort.
  ///
  /// In en, this message translates to:
  /// **'dur.'**
  String get durationShort;

  /// No description provided for @caloriesShort.
  ///
  /// In en, this message translates to:
  /// **'cal'**
  String get caloriesShort;

  /// No description provided for @saveSportFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Save sport activity failed: '**
  String get saveSportFailedPrefix;

  /// No description provided for @unsavedChangesContent.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave without saving?'**
  String get unsavedChangesContent;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food'**
  String get searchFood;

  /// No description provided for @searchFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for food to add to your daily log.'**
  String get searchFoodDescription;

  /// No description provided for @scanProduct.
  ///
  /// In en, this message translates to:
  /// **'Scan product'**
  String get scanProduct;

  /// No description provided for @scanProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan a product to quickly add nutritional information to your day.'**
  String get scanProductDescription;

  /// No description provided for @recentProducts.
  ///
  /// In en, this message translates to:
  /// **'Recent Products'**
  String get recentProducts;

  /// No description provided for @recentProductsDescription.
  ///
  /// In en, this message translates to:
  /// **'View and quickly add products you\'ve recently used.'**
  String get recentProductsDescription;

  /// No description provided for @favoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favorite Products'**
  String get favoriteProducts;

  /// No description provided for @favoriteProductsDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can view all your favorite products.'**
  String get favoriteProductsDescription;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @myProductsDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can add your own products that cannot be found.'**
  String get myProductsDescription;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @mealsDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can view and log meals; meals consist of multiple products.'**
  String get mealsDescription;

  /// No description provided for @mealsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add meals'**
  String get mealsAdd;

  /// No description provided for @mealsAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap this plus to create meals from multiple products so you can add frequently eaten meals faster.'**
  String get mealsAddDescription;

  /// No description provided for @mealsLog.
  ///
  /// In en, this message translates to:
  /// **'Log meals'**
  String get mealsLog;

  /// No description provided for @mealsLogDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap this cart to add meals to the logs.'**
  String get mealsLogDescription;

  /// No description provided for @enterMoreChars.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters.'**
  String get enterMoreChars;

  /// No description provided for @errorFetch.
  ///
  /// In en, this message translates to:
  /// **'Error fetching'**
  String get errorFetch;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get noImageSelected;

  /// No description provided for @aiNoIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No result from AI.'**
  String get aiNoIngredientsFound;

  /// No description provided for @aiIngredientsPrompt.
  ///
  /// In en, this message translates to:
  /// **'What ingredients do you see here? Answer in English. Ignore marketing terms, product names, and non-relevant words like \'zero\', \'light\', etc. Answer only with actual ingredients that are in the product. Answer only if the image shows a food product. Respond as: {ingredient}, {ingredient}, ...'**
  String aiIngredientsPrompt(Object ingredient);

  /// No description provided for @aiIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'Ingredients found:'**
  String get aiIngredientsFound;

  /// No description provided for @aiIngredientsDescription.
  ///
  /// In en, this message translates to:
  /// **'The AI recognized the following ingredients:'**
  String get aiIngredientsDescription;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Compose meal'**
  String get addMeal;

  /// No description provided for @errorAI.
  ///
  /// In en, this message translates to:
  /// **'AI analysis error:'**
  String get errorAI;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more products...'**
  String get loadMore;

  /// No description provided for @errorNoBarcode.
  ///
  /// In en, this message translates to:
  /// **'No barcode found for this product.'**
  String get errorNoBarcode;

  /// No description provided for @amountInGrams.
  ///
  /// In en, this message translates to:
  /// **'Amount (g)'**
  String get amountInGrams;

  /// No description provided for @errorUserDEKMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve encryption key.'**
  String get errorUserDEKMissing;

  /// No description provided for @errorNoIngredientsAdded.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product.'**
  String get errorNoIngredientsAdded;

  /// No description provided for @mealSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal saved successfully!'**
  String get mealSavedSuccessfully;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get saveMeal;

  /// No description provided for @errorFetchRecentsProducts.
  ///
  /// In en, this message translates to:
  /// **'Error fetching recent products'**
  String get errorFetchRecentsProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addFoodItem.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get addFoodItem;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @addMealT.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMealT;

  /// No description provided for @recents.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recents;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @searchingProducts.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search.'**
  String get searchingProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @addNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Would you like to add a product yourself?'**
  String get addNewProduct;

  /// No description provided for @errorInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'No barcode found for this product.'**
  String get errorInvalidBarcode;

  /// No description provided for @loadMoreResults.
  ///
  /// In en, this message translates to:
  /// **'Load more products…'**
  String get loadMoreResults;

  /// No description provided for @notTheDesiredResults.
  ///
  /// In en, this message translates to:
  /// **'Add a new product'**
  String get notTheDesiredResults;

  /// No description provided for @addNewProductT.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProductT;

  /// No description provided for @errorProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get errorProductNameRequired;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity (e.g. 100g, 250ml)'**
  String get quantity;

  /// No description provided for @nutritionalValuesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Nutritional values per 100g or ml'**
  String get nutritionalValuesPer100g;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Energy (kcal)'**
  String get calories;

  /// No description provided for @errorCaloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Calories are required'**
  String get errorCaloriesRequired;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @saturatedFat.
  ///
  /// In en, this message translates to:
  /// **'  - of which saturated'**
  String get saturatedFat;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @sugars.
  ///
  /// In en, this message translates to:
  /// **'  - of which sugars'**
  String get sugars;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @proteins.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteins;

  /// No description provided for @salt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt;

  /// No description provided for @errorEncryptionKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not retrieve encryption key.'**
  String get errorEncryptionKeyMissing;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProduct;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unnamedProduct.
  ///
  /// In en, this message translates to:
  /// **'Unnamed product'**
  String get unnamedProduct;

  /// No description provided for @logInToSeeRecents.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your recent products.'**
  String get logInToSeeRecents;

  /// No description provided for @noRecentProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No recent products found.'**
  String get noRecentProductsFound;

  /// No description provided for @errorLoadingRecentProducts.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorLoadingRecentProducts;

  /// No description provided for @logInToSeeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your favorite products.'**
  String get logInToSeeFavorites;

  /// No description provided for @noFavoriteProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No favorite products found.'**
  String get noFavoriteProductsFound;

  /// No description provided for @errorLoadingFavoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorLoadingFavoriteProducts;

  /// No description provided for @logInToSeeMyProducts.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your products.'**
  String get logInToSeeMyProducts;

  /// No description provided for @noMyProductsFound.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any products yet.'**
  String get noMyProductsFound;

  /// No description provided for @errorLoadingMyProducts.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorLoadingMyProducts;

  /// No description provided for @unknownBrand.
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get unknownBrand;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to '**
  String get sure;

  /// No description provided for @willBeDeleted.
  ///
  /// In en, this message translates to:
  /// **' will be deleted?'**
  String get willBeDeleted;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @logInToSeeMeals.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your meals.'**
  String get logInToSeeMeals;

  /// No description provided for @errorLoadingMeals.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorLoadingMeals;

  /// No description provided for @mealExample.
  ///
  /// In en, this message translates to:
  /// **'Example meal'**
  String get mealExample;

  /// No description provided for @createOwnMealsFirst.
  ///
  /// In en, this message translates to:
  /// **'Click + to create your first meal'**
  String get createOwnMealsFirst;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log meal'**
  String get logMeal;

  /// No description provided for @createMealsBeforeLogging.
  ///
  /// In en, this message translates to:
  /// **'This is an example. Create your own meal first.'**
  String get createMealsBeforeLogging;

  /// No description provided for @unnamedMeal.
  ///
  /// In en, this message translates to:
  /// **'Unnamed meal'**
  String get unnamedMeal;

  /// No description provided for @sureMeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that your meal '**
  String get sureMeal;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal '**
  String get meal;

  /// No description provided for @encryptionKeyError.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve encryption key.'**
  String get encryptionKeyError;

  /// No description provided for @mealNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'This meal has no ingredients.'**
  String get mealNoIngredients;

  /// No description provided for @mealLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **' added to your log.'**
  String get mealLoggedSuccessfully;

  /// No description provided for @errorSaveMeal.
  ///
  /// In en, this message translates to:
  /// **'Error saving meal:'**
  String get errorSaveMeal;

  /// No description provided for @sectie.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get sectie;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @mealAddAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product.'**
  String get mealAddAtLeastOneIngredient;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get editMeal;

  /// No description provided for @addNewMeal.
  ///
  /// In en, this message translates to:
  /// **'Create new meal'**
  String get addNewMeal;

  /// No description provided for @mealName.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealName;

  /// No description provided for @pleaseEnterMealName.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get pleaseEnterMealName;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @searchProductHint.
  ///
  /// In en, this message translates to:
  /// **'Type to search or scan barcode'**
  String get searchProductHint;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get selectProduct;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode for this product'**
  String get scanBarcode;

  /// No description provided for @searchForBarcode.
  ///
  /// In en, this message translates to:
  /// **'Searching by barcode...'**
  String get searchForBarcode;

  /// No description provided for @errorFetchingProductData.
  ///
  /// In en, this message translates to:
  /// **'Product not found on OpenFoodFacts'**
  String get errorFetchingProductData;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'No product data found'**
  String get productNotFound;

  /// No description provided for @errorBarcodeFind.
  ///
  /// In en, this message translates to:
  /// **'Error during barcode search: '**
  String get errorBarcodeFind;

  /// No description provided for @errorFetchingProductDataBarcode.
  ///
  /// In en, this message translates to:
  /// **'No barcode found for this product.'**
  String get errorFetchingProductDataBarcode;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add another product'**
  String get addIngredient;

  /// No description provided for @editMyProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editMyProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get productNameRequired;

  /// No description provided for @caloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Calories are required'**
  String get caloriesRequired;

  /// No description provided for @errorUserDEKNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve encryption key.'**
  String get errorUserDEKNotFound;

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get unknownProduct;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get servingSize;

  /// No description provided for @nutritionalValuesPer100mlg.
  ///
  /// In en, this message translates to:
  /// **'Nutritional values per 100g/ml'**
  String get nutritionalValuesPer100mlg;

  /// No description provided for @saveMyProduct.
  ///
  /// In en, this message translates to:
  /// **'Save my product'**
  String get saveMyProduct;

  /// No description provided for @amountFor.
  ///
  /// In en, this message translates to:
  /// **'Amount for '**
  String get amountFor;

  /// No description provided for @amountGML.
  ///
  /// In en, this message translates to:
  /// **'Amount (gram or milliliter)'**
  String get amountGML;

  /// No description provided for @gramsMillilitersAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'g/ml'**
  String get gramsMillilitersAbbreviation;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get invalidAmount;

  /// No description provided for @addedToLog.
  ///
  /// In en, this message translates to:
  /// **' added to your log.'**
  String get addedToLog;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: '**
  String get errorSaving;

  /// No description provided for @photoAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photo...'**
  String get photoAnalyzing;

  /// No description provided for @ingredientsIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying ingredients...'**
  String get ingredientsIdentifying;

  /// No description provided for @nutritionalValuesEstimating.
  ///
  /// In en, this message translates to:
  /// **'Estimating nutritional values...'**
  String get nutritionalValuesEstimating;

  /// No description provided for @patientlyWaiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get patientlyWaiting;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done...'**
  String get almostDone;

  /// No description provided for @processingWithAI.
  ///
  /// In en, this message translates to:
  /// **'Processing with AI...'**
  String get processingWithAI;

  /// No description provided for @selectMealType.
  ///
  /// In en, this message translates to:
  /// **'Select mealtype'**
  String get selectMealType;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @saveNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveNameTooltip;

  /// No description provided for @noChangesTooltip.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get noChangesTooltip;

  /// No description provided for @fillRequiredKcal.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields (kcal).'**
  String get fillRequiredKcal;

  /// No description provided for @additivesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additives'**
  String get additivesLabel;

  /// No description provided for @allergensLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergensLabel;

  /// No description provided for @mealAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount for meal'**
  String get mealAmountLabel;

  /// No description provided for @addToMealButton.
  ///
  /// In en, this message translates to:
  /// **'Add to meal'**
  String get addToMealButton;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @gramLabel.
  ///
  /// In en, this message translates to:
  /// **'Gram (g)'**
  String get gramLabel;

  /// No description provided for @milliliterLabel.
  ///
  /// In en, this message translates to:
  /// **'Milliliter (ml)'**
  String get milliliterLabel;

  /// No description provided for @errorLoadingLocal.
  ///
  /// In en, this message translates to:
  /// **'Error fetching local data: '**
  String get errorLoadingLocal;

  /// No description provided for @errorFetching.
  ///
  /// In en, this message translates to:
  /// **'Error fetching: '**
  String get errorFetching;

  /// No description provided for @nameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get nameSaved;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Missing value'**
  String get enterValue;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @add_food_label.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get add_food_label;

  /// No description provided for @add_drink_label.
  ///
  /// In en, this message translates to:
  /// **'Add drink'**
  String get add_drink_label;

  /// No description provided for @add_sport_label.
  ///
  /// In en, this message translates to:
  /// **'Add sport'**
  String get add_sport_label;

  /// No description provided for @tutorial_date_title.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get tutorial_date_title;

  /// No description provided for @tutorial_date_text.
  ///
  /// In en, this message translates to:
  /// **'Tap here to choose a date or quickly jump to today.'**
  String get tutorial_date_text;

  /// No description provided for @tutorial_barcode_title.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get tutorial_barcode_title;

  /// No description provided for @tutorial_barcode_text.
  ///
  /// In en, this message translates to:
  /// **'Tap here to scan a product and quickly add it to your day.'**
  String get tutorial_barcode_text;

  /// No description provided for @tutorial_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tutorial_settings_title;

  /// No description provided for @tutorial_settings_text.
  ///
  /// In en, this message translates to:
  /// **'Use this page to adjust your personal information, notification times, or other settings.'**
  String get tutorial_settings_text;

  /// No description provided for @tutorial_feedback_title.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get tutorial_feedback_title;

  /// No description provided for @tutorial_feedback_text.
  ///
  /// In en, this message translates to:
  /// **'You can provide feedback about the app here. Is something not working or is there a feature you\'d like to see? We\'d love to hear from you!'**
  String get tutorial_feedback_text;

  /// No description provided for @tutorial_calorie_title.
  ///
  /// In en, this message translates to:
  /// **'Calorie overview'**
  String get tutorial_calorie_title;

  /// No description provided for @tutorial_calorie_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can see a summary of your calorie intake for the day.'**
  String get tutorial_calorie_text;

  /// No description provided for @tutorial_mascot_title.
  ///
  /// In en, this message translates to:
  /// **'Reppy'**
  String get tutorial_mascot_title;

  /// No description provided for @tutorial_mascot_text.
  ///
  /// In en, this message translates to:
  /// **'Reppy provides personal motivation and tips!'**
  String get tutorial_mascot_text;

  /// No description provided for @tutorial_water_title.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get tutorial_water_title;

  /// No description provided for @tutorial_water_text.
  ///
  /// In en, this message translates to:
  /// **'Track how much you drink each day here. The circle shows how much you still need to drink to reach your goal.'**
  String get tutorial_water_text;

  /// No description provided for @tutorial_additems_title.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get tutorial_additems_title;

  /// No description provided for @tutorial_additems_text.
  ///
  /// In en, this message translates to:
  /// **'Use this button to quickly add meals, drinks, or sports.'**
  String get tutorial_additems_text;

  /// No description provided for @tutorial_meals_title.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tutorial_meals_title;

  /// No description provided for @tutorial_meals_text.
  ///
  /// In en, this message translates to:
  /// **'View your meals and edit them by tapping on them.'**
  String get tutorial_meals_text;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new update is available! Update the app via TestFlight for Apple or the Google Play Store for Android.'**
  String get updateAvailable;

  /// No description provided for @announcement_default.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement_default;

  /// No description provided for @water_goal_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Set water goal'**
  String get water_goal_dialog_title;

  /// No description provided for @water_goal_dialog_label.
  ///
  /// In en, this message translates to:
  /// **'Goal (ml)'**
  String get water_goal_dialog_label;

  /// No description provided for @enter_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enter_valid_number;

  /// No description provided for @water_goal_updated.
  ///
  /// In en, this message translates to:
  /// **'Water goal updated'**
  String get water_goal_updated;

  /// No description provided for @error_saving_water_goal.
  ///
  /// In en, this message translates to:
  /// **'Error saving water goal: '**
  String get error_saving_water_goal;

  /// No description provided for @calorie_goal_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Set calorie goal'**
  String get calorie_goal_dialog_title;

  /// No description provided for @calorie_goal_dialog_label.
  ///
  /// In en, this message translates to:
  /// **'Daily goal (kcal)'**
  String get calorie_goal_dialog_label;

  /// No description provided for @calorie_goal_updated.
  ///
  /// In en, this message translates to:
  /// **'Calorie goal updated'**
  String get calorie_goal_updated;

  /// No description provided for @error_saving_prefix.
  ///
  /// In en, this message translates to:
  /// **'Save failed: '**
  String get error_saving_prefix;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @over_goal.
  ///
  /// In en, this message translates to:
  /// **'Above goal'**
  String get over_goal;

  /// No description provided for @calories_over_goal.
  ///
  /// In en, this message translates to:
  /// **'kcal over goal'**
  String get calories_over_goal;

  /// No description provided for @calories_remaining.
  ///
  /// In en, this message translates to:
  /// **'kcal left'**
  String get calories_remaining;

  /// No description provided for @calories_consumed.
  ///
  /// In en, this message translates to:
  /// **'kcal consumed'**
  String get calories_consumed;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @edit_amount_dialog_title_ml.
  ///
  /// In en, this message translates to:
  /// **'Edit amount (ml)'**
  String get edit_amount_dialog_title_ml;

  /// No description provided for @edit_amount_dialog_title_g.
  ///
  /// In en, this message translates to:
  /// **'Edit amount (g)'**
  String get edit_amount_dialog_title_g;

  /// No description provided for @edit_amount_label_ml.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get edit_amount_label_ml;

  /// No description provided for @edit_amount_label_g.
  ///
  /// In en, this message translates to:
  /// **'Amount (g)'**
  String get edit_amount_label_g;

  /// No description provided for @totalConsumed.
  ///
  /// In en, this message translates to:
  /// **'Total consumed'**
  String get totalConsumed;

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get youHave;

  /// No description provided for @motivational_default_1.
  ///
  /// In en, this message translates to:
  /// **'Keep it up, well done!'**
  String get motivational_default_1;

  /// No description provided for @motivational_default_2.
  ///
  /// In en, this message translates to:
  /// **'Tap me for a new message!'**
  String get motivational_default_2;

  /// No description provided for @motivational_default_3.
  ///
  /// In en, this message translates to:
  /// **'Every step counts!'**
  String get motivational_default_3;

  /// No description provided for @motivational_default_4.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivational_default_4;

  /// No description provided for @motivational_default_5.
  ///
  /// In en, this message translates to:
  /// **'Did you know fFinder stands for FoodFinder?'**
  String get motivational_default_5;

  /// No description provided for @motivational_default_6.
  ///
  /// In en, this message translates to:
  /// **'You log better than 97% of people... probably.'**
  String get motivational_default_6;

  /// No description provided for @motivational_noEntries_1.
  ///
  /// In en, this message translates to:
  /// **'Ready to log your day?'**
  String get motivational_noEntries_1;

  /// No description provided for @motivational_noEntries_2.
  ///
  /// In en, this message translates to:
  /// **'A new day, new opportunities!'**
  String get motivational_noEntries_2;

  /// No description provided for @motivational_noEntries_3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started!'**
  String get motivational_noEntries_3;

  /// No description provided for @motivational_noEntries_4.
  ///
  /// In en, this message translates to:
  /// **'Every healthy day starts with one entry.'**
  String get motivational_noEntries_4;

  /// No description provided for @motivational_noEntries_5.
  ///
  /// In en, this message translates to:
  /// **'Your first meal is hiding. Try searching for it!'**
  String get motivational_noEntries_5;

  /// No description provided for @motivational_drinksOnly_1.
  ///
  /// In en, this message translates to:
  /// **'Good that you logged drinks already! What\'s your first meal?'**
  String get motivational_drinksOnly_1;

  /// No description provided for @motivational_drinksOnly_2.
  ///
  /// In en, this message translates to:
  /// **'Hydration is a good start. Time to add something to eat as well.'**
  String get motivational_drinksOnly_2;

  /// No description provided for @motivational_drinksOnly_3.
  ///
  /// In en, this message translates to:
  /// **'Nice! What\'s your first bite?'**
  String get motivational_drinksOnly_3;

  /// No description provided for @motivational_overGoal_1.
  ///
  /// In en, this message translates to:
  /// **'Goal reached! Take it easy now.'**
  String get motivational_overGoal_1;

  /// No description provided for @motivational_overGoal_2.
  ///
  /// In en, this message translates to:
  /// **'Wow, you\'re over your goal!'**
  String get motivational_overGoal_2;

  /// No description provided for @motivational_overGoal_3.
  ///
  /// In en, this message translates to:
  /// **'Well done, tomorrow is another day.'**
  String get motivational_overGoal_3;

  /// No description provided for @motivational_overGoal_4.
  ///
  /// In en, this message translates to:
  /// **'Great work today, really!'**
  String get motivational_overGoal_4;

  /// No description provided for @motivational_almostGoal_1.
  ///
  /// In en, this message translates to:
  /// **'You\'re almost there!'**
  String get motivational_almostGoal_1;

  /// No description provided for @motivational_almostGoal_2.
  ///
  /// In en, this message translates to:
  /// **'Just a little bit more!'**
  String get motivational_almostGoal_2;

  /// No description provided for @motivational_almostGoal_3.
  ///
  /// In en, this message translates to:
  /// **'Almost reached your calorie goal!'**
  String get motivational_almostGoal_3;

  /// No description provided for @motivational_almostGoal_4.
  ///
  /// In en, this message translates to:
  /// **'Good job! Watch the last step.'**
  String get motivational_almostGoal_4;

  /// No description provided for @motivational_almostGoal_5.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing fantastic, almost there!'**
  String get motivational_almostGoal_5;

  /// No description provided for @motivational_belowHalf_1.
  ///
  /// In en, this message translates to:
  /// **'You\'re off to a great start, keep going!'**
  String get motivational_belowHalf_1;

  /// No description provided for @motivational_belowHalf_3.
  ///
  /// In en, this message translates to:
  /// **'Keep logging your meals and drinks.'**
  String get motivational_belowHalf_3;

  /// No description provided for @motivational_belowHalf_4.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great, keep it up!'**
  String get motivational_belowHalf_4;

  /// No description provided for @motivational_lowWater_1.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to drink today!'**
  String get motivational_lowWater_1;

  /// No description provided for @motivational_lowWater_2.
  ///
  /// In en, this message translates to:
  /// **'A sip of water is a good start.'**
  String get motivational_lowWater_2;

  /// No description provided for @motivational_lowWater_3.
  ///
  /// In en, this message translates to:
  /// **'Hot or cold, water is always good!'**
  String get motivational_lowWater_3;

  /// No description provided for @motivational_lowWater_4.
  ///
  /// In en, this message translates to:
  /// **'Hydration is important!'**
  String get motivational_lowWater_4;

  /// No description provided for @motivational_lowWater_5.
  ///
  /// In en, this message translates to:
  /// **'A glass of water can do wonders.'**
  String get motivational_lowWater_5;

  /// No description provided for @motivational_lowWater_6.
  ///
  /// In en, this message translates to:
  /// **'Take a break? Drink a little water.'**
  String get motivational_lowWater_6;

  /// No description provided for @entry_updated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get entry_updated;

  /// No description provided for @errorUpdatingEntry.
  ///
  /// In en, this message translates to:
  /// **'Error updating entry: '**
  String get errorUpdatingEntry;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: '**
  String get errorLoadingData;

  /// No description provided for @not_logged_in.
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get not_logged_in;

  /// No description provided for @noEntriesForDate.
  ///
  /// In en, this message translates to:
  /// **'No entries yet.'**
  String get noEntriesForDate;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sportactivity'**
  String get sports;

  /// No description provided for @totalBurned.
  ///
  /// In en, this message translates to:
  /// **'Total burned: '**
  String get totalBurned;

  /// No description provided for @unknownSport.
  ///
  /// In en, this message translates to:
  /// **'Unknown sport'**
  String get unknownSport;

  /// No description provided for @errorDeletingSport.
  ///
  /// In en, this message translates to:
  /// **'Error deleting sport: '**
  String get errorDeletingSport;

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: '**
  String get errorDeleting;

  /// No description provided for @errorCalculating.
  ///
  /// In en, this message translates to:
  /// **'Error: Original values are not complete to recalculate.'**
  String get errorCalculating;

  /// No description provided for @appleCancelled.
  ///
  /// In en, this message translates to:
  /// **'You cancelled the Apple sign-in.'**
  String get appleCancelled;

  /// No description provided for @appleFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again later.'**
  String get appleFailed;

  /// No description provided for @appleInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response received from Apple.'**
  String get appleInvalidResponse;

  /// No description provided for @appleNotHandled.
  ///
  /// In en, this message translates to:
  /// **'Apple could not handle the request.'**
  String get appleNotHandled;

  /// No description provided for @appleUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred with Apple.'**
  String get appleUnknown;

  /// No description provided for @appleGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing in with Apple.'**
  String get appleGenericError;

  /// No description provided for @signInAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Please sign in using a different method.'**
  String get signInAccountExists;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get signInCancelled;

  /// No description provided for @unknownGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred during Google sign-in.'**
  String get unknownGoogleSignIn;

  /// No description provided for @unknownGitHubSignIn.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred during GitHub sign-in.'**
  String get unknownGitHubSignIn;

  /// No description provided for @unknownAppleSignIn.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred during Apple sign-in.'**
  String get unknownAppleSignIn;

  /// No description provided for @unknownErrorEnglish.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownErrorEnglish;

  /// No description provided for @passwordErrorMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordErrorMinLength;

  /// No description provided for @passwordErrorUpper.
  ///
  /// In en, this message translates to:
  /// **'one uppercase letter'**
  String get passwordErrorUpper;

  /// No description provided for @passwordErrorLower.
  ///
  /// In en, this message translates to:
  /// **'one lowercase letter'**
  String get passwordErrorLower;

  /// No description provided for @passwordErrorDigit.
  ///
  /// In en, this message translates to:
  /// **'one digit'**
  String get passwordErrorDigit;

  /// No description provided for @passwordMissingPartsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your password is missing: '**
  String get passwordMissingPartsPrefix;

  /// No description provided for @userNotFoundCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email. Click below to create an account.'**
  String get userNotFoundCreateAccount;

  /// No description provided for @wrongPasswordOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password or email. Please try again. If you don\'t have an account, click below to create one.'**
  String get wrongPasswordOrEmail;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Try signing in.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters long.'**
  String get weakPasswordMessage;

  /// No description provided for @invalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'The entered email address is invalid.'**
  String get invalidEmailMessage;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'An authentication error occurred. Please try again later.'**
  String get authGenericError;

  /// No description provided for @resetPasswordEnterEmailInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password.'**
  String get resetPasswordEnterEmailInstruction;

  /// No description provided for @resetPasswordEmailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get resetPasswordEmailSentTitle;

  /// No description provided for @resetPasswordEmailSentContent.
  ///
  /// In en, this message translates to:
  /// **'An email has been sent to reset your password. Note: this email may end up in your spam folder. Sender: noreply@pwsmt-fd851.firebaseapp.com'**
  String get resetPasswordEmailSentContent;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericError;

  /// No description provided for @userNotFoundForEmail.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email.'**
  String get userNotFoundForEmail;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginWelcomeBack;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to get started'**
  String get registerSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get loginEnterEmail;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginMin6Chars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 chars'**
  String get loginMin6Chars;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButtonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonLogin;

  /// No description provided for @loginButtonRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginButtonRegister;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithGitHub.
  ///
  /// In en, this message translates to:
  /// **'Sign in with GitHub'**
  String get loginWithGitHub;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get loginWithApple;

  /// No description provided for @loginNoAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccountQuestion;

  /// No description provided for @loginHaveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get loginHaveAccountQuestion;

  /// No description provided for @loginCreateAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccountAction;

  /// No description provided for @loginLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLoginAction;

  /// No description provided for @onboardingEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get onboardingEnterFirstName;

  /// No description provided for @onboardingSelectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get onboardingSelectBirthDate;

  /// No description provided for @onboardingEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height (cm)'**
  String get onboardingEnterHeight;

  /// No description provided for @onboardingEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight (kg)'**
  String get onboardingEnterWeight;

  /// No description provided for @onboardingEnterTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your target weight (kg)'**
  String get onboardingEnterTargetWeight;

  /// No description provided for @onboardingEnterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get onboardingEnterValidWeight;

  /// No description provided for @onboardingEnterValidHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height'**
  String get onboardingEnterValidHeight;

  /// No description provided for @heightBetween.
  ///
  /// In en, this message translates to:
  /// **'Height must be between '**
  String get heightBetween;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @liggen.
  ///
  /// In en, this message translates to:
  /// **' cm.'**
  String get liggen;

  /// No description provided for @weightBetween.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between '**
  String get weightBetween;

  /// No description provided for @kgLiggen.
  ///
  /// In en, this message translates to:
  /// **' kg.'**
  String get kgLiggen;

  /// No description provided for @enterWaistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Enter your waist circumference (cm)'**
  String get enterWaistCircumference;

  /// No description provided for @enterValidWaistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid waist circumference'**
  String get enterValidWaistCircumference;

  /// No description provided for @tailleBetween.
  ///
  /// In en, this message translates to:
  /// **'Waist circumference must be between '**
  String get tailleBetween;

  /// No description provided for @cmLiggen.
  ///
  /// In en, this message translates to:
  /// **' cm.'**
  String get cmLiggen;

  /// No description provided for @onboardingEnterValidTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target weight'**
  String get onboardingEnterValidTargetWeight;

  /// No description provided for @targetBetween.
  ///
  /// In en, this message translates to:
  /// **'Target weight must be between '**
  String get targetBetween;

  /// No description provided for @absiVeryLow.
  ///
  /// In en, this message translates to:
  /// **'very low risk'**
  String get absiVeryLow;

  /// No description provided for @absiLow.
  ///
  /// In en, this message translates to:
  /// **'low risk'**
  String get absiLow;

  /// No description provided for @absiAverage.
  ///
  /// In en, this message translates to:
  /// **'average risk'**
  String get absiAverage;

  /// No description provided for @absiElevated.
  ///
  /// In en, this message translates to:
  /// **'elevated risk'**
  String get absiElevated;

  /// No description provided for @absiHigh.
  ///
  /// In en, this message translates to:
  /// **'high risk'**
  String get absiHigh;

  /// No description provided for @healthWeight.
  ///
  /// In en, this message translates to:
  /// **'Healthy weight for you: '**
  String get healthWeight;

  /// No description provided for @healthyBMI.
  ///
  /// In en, this message translates to:
  /// **'Healthy BMI: '**
  String get healthyBMI;

  /// No description provided for @onboardingWeightRangeUnder2.
  ///
  /// In en, this message translates to:
  /// **'For children under 2 years old, weight-for-length percentiles are usually used instead of BMI.'**
  String get onboardingWeightRangeUnder2;

  /// No description provided for @onboardingWeightRangeUnder2Note.
  ///
  /// In en, this message translates to:
  /// **'Use WHO/CDC weight-for-length charts.'**
  String get onboardingWeightRangeUnder2Note;

  /// No description provided for @onboarding_datePickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboarding_datePickerDone;

  /// No description provided for @lmsDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'LMS data unavailable for this age/sex.'**
  String get lmsDataUnavailable;

  /// No description provided for @lmsCheckAssets.
  ///
  /// In en, this message translates to:
  /// **'Check assets or enter the target weight manually.'**
  String get lmsCheckAssets;

  /// No description provided for @lmsDataErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not use LMS data:'**
  String get lmsDataErrorPrefix;

  /// No description provided for @lmsAssetMissing.
  ///
  /// In en, this message translates to:
  /// **'Check that the asset is present (assets/cdc/bmiagerev.csv).'**
  String get lmsAssetMissing;

  /// No description provided for @healthyWeightForYou.
  ///
  /// In en, this message translates to:
  /// **'Healthy weight for you:'**
  String get healthyWeightForYou;

  /// No description provided for @onboarding_firstNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your first name?'**
  String get onboarding_firstNameTitle;

  /// No description provided for @onboarding_labelFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get onboarding_labelFirstName;

  /// No description provided for @onboarding_genderTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your gender?'**
  String get onboarding_genderTitle;

  /// No description provided for @onboarding_genderOptionMan.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboarding_genderOptionMan;

  /// No description provided for @onboarding_genderOptionWoman.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboarding_genderOptionWoman;

  /// No description provided for @onboarding_genderOptionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboarding_genderOptionOther;

  /// No description provided for @onboarding_genderOptionPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get onboarding_genderOptionPreferNot;

  /// No description provided for @onboarding_birthDateTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your birth date?'**
  String get onboarding_birthDateTitle;

  /// No description provided for @onboarding_noDateChosen.
  ///
  /// In en, this message translates to:
  /// **'No date chosen'**
  String get onboarding_noDateChosen;

  /// No description provided for @onboarding_chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get onboarding_chooseDate;

  /// No description provided for @onboarding_heightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your height (cm)?'**
  String get onboarding_heightTitle;

  /// No description provided for @onboarding_labelHeight.
  ///
  /// In en, this message translates to:
  /// **'Height in cm'**
  String get onboarding_labelHeight;

  /// No description provided for @onboarding_weightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your weight (kg)?'**
  String get onboarding_weightTitle;

  /// No description provided for @onboarding_labelWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight in kg'**
  String get onboarding_labelWeight;

  /// No description provided for @onboarding_waistTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your waist circumference (cm)?'**
  String get onboarding_waistTitle;

  /// No description provided for @onboarding_labelWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist circumference in cm'**
  String get onboarding_labelWaist;

  /// No description provided for @onboarding_unknownWaist.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get onboarding_unknownWaist;

  /// No description provided for @onboarding_sleepTitle.
  ///
  /// In en, this message translates to:
  /// **'How many hours do you sleep on average per night?'**
  String get onboarding_sleepTitle;

  /// No description provided for @onboarding_activityTitle.
  ///
  /// In en, this message translates to:
  /// **'How active are you on a daily basis?'**
  String get onboarding_activityTitle;

  /// No description provided for @onboarding_targetWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your target weight?'**
  String get onboarding_targetWeightTitle;

  /// No description provided for @onboarding_labelTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight in kg'**
  String get onboarding_labelTargetWeight;

  /// No description provided for @onboarding_goalTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get onboarding_goalTitle;

  /// No description provided for @onboarding_notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Would you like to receive notifications?'**
  String get onboarding_notificationsTitle;

  /// No description provided for @onboarding_notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can enable notifications for meal reminders so you never forget to eat and log your meals.'**
  String get onboarding_notificationsDescription;

  /// No description provided for @onboarding_notificationsEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboarding_notificationsEnable;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was denied.'**
  String get notificationPermissionDenied;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @deleteAccountProviderReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, please re-authenticate using your original sign-in method and try again.'**
  String get deleteAccountProviderReauthRequired;

  /// No description provided for @enterPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get enterPasswordLabel;

  /// No description provided for @confirmButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButtonLabel;

  /// No description provided for @googleSignInCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled by the user.'**
  String get googleSignInCancelledMessage;

  /// No description provided for @googleMissingIdToken.
  ///
  /// In en, this message translates to:
  /// **'Could not obtain idToken from Google.'**
  String get googleMissingIdToken;

  /// No description provided for @appleNullIdentityTokenMessage.
  ///
  /// In en, this message translates to:
  /// **'Apple returned a null identityToken.'**
  String get appleNullIdentityTokenMessage;

  /// No description provided for @deleteSportMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sport activity?'**
  String get deleteSportMessage;

  /// No description provided for @notificationBreakfastTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for breakfast!'**
  String get notificationBreakfastTitle;

  /// No description provided for @notificationBreakfastBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day right with a nutritious breakfast. Don\'t forget to log it!'**
  String get notificationBreakfastBody;

  /// No description provided for @notificationLunchTitle.
  ///
  /// In en, this message translates to:
  /// **'Lunch time!'**
  String get notificationLunchTitle;

  /// No description provided for @notificationLunchBody.
  ///
  /// In en, this message translates to:
  /// **'Refuel for the afternoon. Don\'t forget to log your lunch!'**
  String get notificationLunchBody;

  /// No description provided for @notificationDinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal!'**
  String get notificationDinnerTitle;

  /// No description provided for @notificationDinnerBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your dinner and remember to log it!'**
  String get notificationDinnerBody;

  /// No description provided for @heightRange.
  ///
  /// In en, this message translates to:
  /// **'Height must be between 50 and 300 cm.'**
  String get heightRange;

  /// No description provided for @weightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 20 and 800 kg.'**
  String get weightRange;

  /// No description provided for @waistRange.
  ///
  /// In en, this message translates to:
  /// **'Waist must be between 30 and 200 cm.'**
  String get waistRange;

  /// No description provided for @targetWeightRange.
  ///
  /// In en, this message translates to:
  /// **'Target weight must be between 20 and 800 kg.'**
  String get targetWeightRange;

  /// No description provided for @sportsCaloriesInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Sports Activities'**
  String get sportsCaloriesInfoTitle;

  /// No description provided for @sportsCaloriesInfoTextOn.
  ///
  /// In en, this message translates to:
  /// **'Your daily goal is based on your activity level. Calories from sports are now added to your daily total.'**
  String get sportsCaloriesInfoTextOn;

  /// No description provided for @sportsCaloriesInfoTextOff.
  ///
  /// In en, this message translates to:
  /// **'Your daily goal is based on your activity level. Calories from sports are not added to your daily total by default. You can change this in the settings.'**
  String get sportsCaloriesInfoTextOff;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @waterWarningSevere.
  ///
  /// In en, this message translates to:
  /// **'Warning: do not drink too much. Far above your goal can be dangerous!'**
  String get waterWarningSevere;

  /// No description provided for @includeSportsCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Include sports calories'**
  String get includeSportsCaloriesLabel;

  /// No description provided for @includeSportsCaloriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add calories burned through sports to your daily total (off by default, because activity is already included via your activity level).'**
  String get includeSportsCaloriesSubtitle;

  /// No description provided for @setAppVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Set app version'**
  String get setAppVersionTitle;

  /// No description provided for @setAppVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modify the version field in Firestore'**
  String get setAppVersionSubtitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @versionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Version updated:'**
  String get versionUpdated;

  /// No description provided for @bmiForChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Child BMI Info'**
  String get bmiForChildrenTitle;

  /// No description provided for @bmiForChildrenExplanation.
  ///
  /// In en, this message translates to:
  /// **'The BMI for children is calculated based on age, sex, height, and weight. Instead of fixed cutoffs, this app uses BMI percentiles, making the assessment better suited to children\'s growth. Small differences with other BMI charts are normal.'**
  String get bmiForChildrenExplanation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'nl': return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
