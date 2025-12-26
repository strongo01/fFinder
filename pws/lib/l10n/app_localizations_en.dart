// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesSubtitle => 'Find and manage your favorite recipes';

  @override
  String get encryptionKeyLoadError => 'Could not load the encryption key.';

  @override
  String get encryptionKeyLoadSaveError => 'Could not load the encryption key for saving.';

  @override
  String get encryptedJson => 'Encrypted JSON (nonce/cipher/tag)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get mealNotifications => 'Meal Notifications';

  @override
  String get enableMealNotifications => 'Enable Notifications';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get enableGifs => 'Show Mascot Animation (GIF)';

  @override
  String get restartTutorial => 'Restart Tutorial';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoDescription => 'Adjust your weight, height, goal, and activity.';

  @override
  String get currentWeightKg => 'Current Weight (kg)';

  @override
  String get enterCurrentWeight => 'Enter your current weight';

  @override
  String get enterValidWeight => 'Please enter a valid weight';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get enterHeight => 'Enter your height';

  @override
  String get enterHeightBetween100And250 => 'Please enter a height between 100 and 250 cm';

  @override
  String get waistCircumferenceCm => 'Waist Circumference (cm)';

  @override
  String get enterWaistCircumference => 'Enter your waist circumference';

  @override
  String get enterValidWaistCircumference => 'Please enter a waist circumference between 30 and 200 cm';

  @override
  String get targetWeightKg => 'Target Weight (kg)';

  @override
  String get enterTargetWeight => 'Enter your target weight';

  @override
  String get enterValidTargetWeight => 'Please enter a valid target weight';

  @override
  String get sleepHoursPerNight => 'Sleep (hours per night)';

  @override
  String get hours => 'hours';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get goal => 'Goal';

  @override
  String get savingSettings => 'Saving...';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get adminAnnouncements => 'Admin Actions';

  @override
  String get createAnnouncement => 'Create New Announcement';

  @override
  String get createAnnouncementSubtitle => 'Publish an announcement for all users';

  @override
  String get manageAnnouncements => 'Manage Announcements';

  @override
  String get manageAnnouncementsSubtitle => 'View, deactivate, or delete announcements';

  @override
  String get decryptValues => 'Decrypt';

  @override
  String get decryptValuesSubtitle => 'Decrypt values for user if they want to transfer account to another email';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deletingAccount => 'Deleting Account...';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get credits => 'Credits';

  @override
  String get creditsAbsiDataAttribution => 'This dataset is used for calculating ABSI Z-scores and categories in this app.';

  @override
  String get absiAttribution => 'Body Shape Index (ABSI) reference table is based on:\n\nY. Krakauer, Nir; C. Krakauer, Jesse (2015).\nTable S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\nPLOS ONE. Dataset.\nhttps://doi.org/10.1371/journal.pone.0039504.s001\n\nThis dataset is used for calculating ABSI Z-scores and categories in this app.';

  @override
  String get date => 'Date';

  @override
  String get close => 'Close';

  @override
  String get editAnnouncement => 'Edit Announcement';

  @override
  String get title => 'Title';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty.';

  @override
  String get message => 'Message';

  @override
  String get messageCannotBeEmpty => 'Message cannot be empty.';

  @override
  String get cancel => 'Cancel';

  @override
  String get announcementUpdated => 'Announcement updated.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get announcementDeleted => 'Announcement deleted.';

  @override
  String get errorLoadingAnnouncements => 'An error occurred while loading announcements.';

  @override
  String get noAnnouncementsFound => 'No announcements found.';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get createdAt => 'Created at';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get editAnnouncementTooltip => 'Edit Announcement';
}
