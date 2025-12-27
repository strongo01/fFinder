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

  /// No description provided for @absiHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get absiHigh;

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
