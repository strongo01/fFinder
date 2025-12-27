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

  @override
  String get language => 'Language';

  @override
  String get useSystemLocale => 'Use System Locale';

  @override
  String get activityLow => 'Low activity: sedentary work, little movement, no sports';

  @override
  String get activityLight => 'Light activity: 1–3x/week light training or daily 30–45 min walking';

  @override
  String get activityMedium => 'Moderate activity: 3–5x/week exercise or active job';

  @override
  String get activityVery => 'Very active: 6–7x/week intense training or physically heavy work';

  @override
  String get activityExtreme => 'Extreme activity: pro training 2x/day or extreme manual work';

  @override
  String get goalLose => 'Lose weight';

  @override
  String get goalMaintain => 'Maintain weight';

  @override
  String get goalGainMuscle => 'Gain weight (muscle)';

  @override
  String get goalGainGeneral => 'Gain weight';

  @override
  String get createAnnouncementTitle => 'Create New Announcement';

  @override
  String get messageLabel => 'Message';

  @override
  String get messageValidationError => 'Message cannot be empty.';

  @override
  String get announcementPublishedSuccess => 'Announcement published successfully!';

  @override
  String get publishButtonLabel => 'Publish';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have made changes that have not been saved yet. Are you sure you want to exit without saving?';

  @override
  String get discardButtonLabel => 'Discard';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get tutorialRestartedMessage => 'Tutorial has been restarted!';

  @override
  String get deleteAnnouncementTooltip => 'Delete Announcement';

  @override
  String get duplicateRequestError => 'There is already a pending request for this value.';

  @override
  String get requestSubmittedSuccess => 'Decryption request submitted for approval.';

  @override
  String get requestSubmissionFailed => 'Request submission failed';

  @override
  String get requestNotFound => 'Request not found';

  @override
  String get cannotApproveOwnRequest => 'You cannot approve your own request.';

  @override
  String get dekNotFoundForUser => 'Could not retrieve encryption key.';

  @override
  String get requestApprovedSuccess => 'Request approved.';

  @override
  String get requestApprovalFailed => 'Request approval failed';

  @override
  String get cannotRejectOwnRequest => 'You cannot reject your own request.';

  @override
  String get requestRejectedSuccess => 'Request rejected.';

  @override
  String get requestRejectionFailed => 'Request rejection failed';

  @override
  String get pleaseEnterUid => 'Please enter a UID';

  @override
  String get pleaseEnterEncryptedJson => 'Please enter the encrypted JSON';

  @override
  String get submit => 'Submit';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get loading => 'Loading...';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get noPendingRequests => 'No pending requests.';

  @override
  String get forUid => 'For UID';

  @override
  String get requestedBy => 'Requested by';

  @override
  String get encryptedJsonLabel => 'Encrypted Value:';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get confirmSignOutTitle => 'Confirm Sign Out';

  @override
  String get confirmSignOutMessage => 'Are you sure you want to sign out?';

  @override
  String get confirmDeleteAccountTitle => 'Confirm Delete Account';

  @override
  String get confirmDeleteAccountMessage => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deletionCodeInstruction => 'Type the code below to confirm:';

  @override
  String get enterDeletionCodeLabel => 'Enter the 6-digit code';

  @override
  String get deletionCodeMismatchError => 'Code does not match, please try again.';

  @override
  String get deleteAccountButtonLabel => 'Delete Account';

  @override
  String get settingsSavedSuccessMessage => 'Settings saved successfully';

  @override
  String get settingsSaveFailedMessage => 'Settings save failed';

  @override
  String get profileLoadFailedMessage => 'Could not load profile';

  @override
  String get deleteAccountRecentLoginError => 'Please log in again and try deleting your account.';

  @override
  String get deleteAccountFailedMessage => 'Account deletion failed';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleValidationError => 'Title cannot be empty.';

  @override
  String get untitled => 'Untitled';

  @override
  String get appCredits => 'ABSI Data Attribution';

  @override
  String get reportThanks => 'Thanks for the rapport!';

  @override
  String get errorSending => 'Error sending';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get reportTitle => 'Report items';

  @override
  String get categoryFunctionality => 'Functionality';

  @override
  String get itemFeatures => 'Features';

  @override
  String get itemFunctionality => 'Functionality';

  @override
  String get itemUsability => 'Usability';

  @override
  String get itemClarity => 'Clarity';

  @override
  String get itemAccuracy => 'Accuracy';

  @override
  String get itemNavigation => 'Navigation';

  @override
  String get categoryPerformance => 'Performance';

  @override
  String get itemSpeed => 'Speed';

  @override
  String get itemLoadingTimes => 'Loading times';

  @override
  String get itemStability => 'Stability';

  @override
  String get categoryInterfaceDesign => 'Interface & Design';

  @override
  String get itemLayout => 'Layout';

  @override
  String get itemColorsTheme => 'Colors & Theme';

  @override
  String get itemIconsDesign => 'Icons & Design';

  @override
  String get itemReadability => 'Readability';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get itemErrors => 'Error messages';

  @override
  String get itemExplanation => 'Explanation & Instructions';

  @override
  String get categoryAppParts => 'App Parts';

  @override
  String get itemDashboard => 'Dashboard';

  @override
  String get itemLogin => 'Login / Registration';

  @override
  String get itemWeight => 'Weight';

  @override
  String get itemStatistics => 'Statistics';

  @override
  String get itemCalendar => 'Calendar';

  @override
  String get categoryOther => 'Other';

  @override
  String get itemGeneralSatisfaction => 'General satisfaction';

  @override
  String get send => 'Send';

  @override
  String get feedbackTitle => 'Provide feedback';

  @override
  String get viewAllFeedback => 'View all feedback';

  @override
  String get viewAllRapportFeedback => 'View all report feedback';

  @override
  String get openRapportButton => 'Tap to fill out the report!\nNote: this is an extensive questionnaire. Only fill it out after you have tested the app for several days.';

  @override
  String get feedbackIntro => 'You can provide feedback here at any time.';

  @override
  String get choiceBug => 'Bug';

  @override
  String get choiceFeature => 'New feature';

  @override
  String get choiceLanguage => 'Language';

  @override
  String get choiceLayout => 'Layout';

  @override
  String get choiceOther => 'Other';

  @override
  String get languageSectionInstruction => 'Specify which language is affected and describe the error. The default language is the one selected in the app.';

  @override
  String get dropdownLabelLanguage => 'Language the feedback refers to';

  @override
  String get messageHint => 'What would you like to tell us?';

  @override
  String get enterMessage => 'Enter a message';

  @override
  String get emailHintOptional => 'Email (optional)';

  @override
  String get allFeedbackTitle => 'All feedback';

  @override
  String get noFeedbackFound => 'No feedback found.';

  @override
  String get errorOccurred => 'An error occurred.';

  @override
  String get noMessage => 'No message';

  @override
  String get unknownType => 'Unknown';

  @override
  String get appLanguagePrefix => 'App: ';

  @override
  String get reportedLanguagePrefix => 'Reported: ';

  @override
  String get submittedOnPrefix => 'Submitted on: ';

  @override
  String get uidLabelPrefix => 'UID: ';

  @override
  String get couldNotOpenMailAppPrefix => 'Could not open mail app: ';

  @override
  String get allRapportFeedbackTitle => 'All report feedback';

  @override
  String get noRapportFeedbackFound => 'No report feedback found.';

  @override
  String get rapportFeedbackTitle => 'Report feedback';

  @override
  String get weightTitle => 'Your weight';

  @override
  String get weightSubtitle => 'Adjust your weight and view your BMI.';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get targetWeightLabel => 'Target weight (kg)';

  @override
  String get weightSliderLabel => 'Weight slider';

  @override
  String get saving => 'Saving...';

  @override
  String get saveWeight => 'Save weight';

  @override
  String get saveWaist => 'Save waist';

  @override
  String get saveSuccess => 'Weight + goals saved';

  @override
  String get saveFailedPrefix => 'Save failed:';

  @override
  String get weightLoadErrorPrefix => 'Could not load user data:';

  @override
  String get bmiTitle => 'BMI';

  @override
  String get bmiInsufficient => 'Insufficient data to calculate BMI. Enter your height and weight.';

  @override
  String get yourBmiPrefix => 'Your BMI:';

  @override
  String get waistAbsiTitle => 'Waist / ABSI';

  @override
  String get waistLabel => 'Waist circumference (cm)';

  @override
  String get absiInsufficient => 'Insufficient data to calculate ABSI. Enter waist, height and weight.';

  @override
  String get yourAbsiPrefix => 'Your ABSI:';

  @override
  String get absiLowRisk => 'Low risk';

  @override
  String get absiMedium => 'Average risk';

  @override
  String get absiHigh => 'High risk';

  @override
  String get choiceWeight => 'Weight';

  @override
  String get choiceWaist => 'Waist';

  @override
  String get choiceTable => 'Table';

  @override
  String get choiceChart => 'Chart (per month)';

  @override
  String get noMeasurements => 'No measurements saved yet.';

  @override
  String get noWaistMeasurements => 'No waist measurements saved yet.';

  @override
  String get tableMeasurementsTitle => 'Measurements table';

  @override
  String get deleteConfirmTitle => 'Delete?';

  @override
  String get deleteConfirmContent => 'Are you sure you want to delete this measurement?';

  @override
  String get deleteConfirmDelete => 'Delete';

  @override
  String get measurementDeleted => 'Measurement deleted';

  @override
  String get chartTitlePrefix => 'Chart –';

  @override
  String get chartTooFew => 'Not enough measurements in this month for a chart.';

  @override
  String get chartAxesLabel => 'Horizontal: days of the month, Vertical: value';

  @override
  String get estimateNotEnoughData => 'Not enough data to compute a trend.';

  @override
  String get estimateOnTarget => 'Well done! You are at your target weight.';

  @override
  String get estimateNoTrend => 'No trend to compute yet.';

  @override
  String get estimateStable => 'Your weight is fairly stable; no reliable trend.';

  @override
  String get estimateWrongDirection => 'With the current trend you are moving away from your target weight.';

  @override
  String get estimateInsufficientInfo => 'Insufficient trend information to make a realistic estimate.';

  @override
  String get estimateUnlikelyWithin10Years => 'Based on the current trend it\'s unlikely you\'ll reach your target within 10 years.';

  @override
  String get estimateUncertaintyHigh => 'Warning: very large fluctuations make this estimate unreliable.';

  @override
  String get estimateUncertaintyMedium => 'Warning: considerable fluctuations make this estimate uncertain.';

  @override
  String get estimateUncertaintyLow => 'Note: some variation — estimate may differ.';

  @override
  String get estimateBasisRecent => 'based on the past month';

  @override
  String get estimateBasisAll => 'based on all measurements';

  @override
  String get estimateResultPrefix => 'If you continue like this (), you\'ll reach your target weight in about';

  @override
  String get bmiVeryLow => 'Very underweight';

  @override
  String get bmiLow => 'Underweight';

  @override
  String get bmiGood => 'Healthy';

  @override
  String get bmiHigh => 'Overweight';

  @override
  String get bmiVeryHigh => 'Obese';

  @override
  String get thanksFeedback => 'Thanks for your feedback!';

  @override
  String get absiVeryLowRisk => 'Very low risk';

  @override
  String get absiIncreasedRisk => 'Increased risk';

  @override
  String get recipesSwipeInstruction => 'Swipe to save or skip recipes.';

  @override
  String get recipesNoMore => 'No more recipes.';

  @override
  String get recipesSavedPrefix => 'Saved: ';

  @override
  String get recipesSkippedPrefix => 'Skipped: ';

  @override
  String get recipesDetailId => 'ID';

  @override
  String get recipesDetailPreparationTime => 'Preparation time';

  @override
  String get recipesDetailTotalTime => 'Total time';

  @override
  String get recipesDetailKcal => 'Calories';

  @override
  String get recipesDetailFat => 'Fat';

  @override
  String get recipesDetailSaturatedFat => 'Saturated fat';

  @override
  String get recipesDetailCarbs => 'Carbs';

  @override
  String get recipesDetailProtein => 'Protein';

  @override
  String get recipesDetailFibers => 'Fibers';

  @override
  String get recipesDetailSalt => 'Salt';

  @override
  String get recipesDetailPersons => 'Persons';

  @override
  String get recipesDetailDifficulty => 'Difficulty';

  @override
  String get recipesPrepreparation => 'Pre-preparation';

  @override
  String get recipesIngredients => 'Ingredients';

  @override
  String get recipesSteps => 'Steps';

  @override
  String get recipesKitchens => 'Kitchens';

  @override
  String get recipesCourses => 'Course';

  @override
  String get recipesRequirements => 'Requirements';

  @override
  String get water => 'Water';

  @override
  String get coffee => 'Coffee';

  @override
  String get tea => 'Tea';

  @override
  String get soda => 'Soda';

  @override
  String get other => 'Other';

  @override
  String get coffeeBlack => 'Black coffee';

  @override
  String get espresso => 'Espresso';

  @override
  String get ristretto => 'Ristretto';

  @override
  String get lungo => 'Lungo';

  @override
  String get americano => 'Americano';

  @override
  String get coffeeWithMilk => 'Coffee with milk';

  @override
  String get coffeeWithMilkSugar => 'Coffee with milk and sugar';

  @override
  String get cappuccino => 'Cappuccino';

  @override
  String get latte => 'Latte';

  @override
  String get flatWhite => 'Flat white';

  @override
  String get macchiato => 'Macchiato';

  @override
  String get latteMacchiato => 'Latte macchiato';

  @override
  String get icedCoffee => 'Iced coffee';

  @override
  String get otherCoffee => 'Other coffee';

  @override
  String get newDrinkTitle => 'Add New Drink';

  @override
  String get chooseDrink => 'Choose a drink';

  @override
  String get chooseCoffeeType => 'Choose coffee type';

  @override
  String get drinkNameLabel => 'Drink name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get amountMlLabel => 'Amount (ml)';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get kcalPer100Label => 'Kcal per 100 ml';

  @override
  String get barcodeSearchTooltip => 'Search by barcode';

  @override
  String get kcalRequired => 'Kcal value is required';

  @override
  String get addDrinkTitle => 'Add drink';

  @override
  String get addButton => 'Add';

  @override
  String get addAndLogButton => 'Add and log';

  @override
  String get searchButton => 'Search';

  @override
  String get scanPasteBarcode => 'Scan / paste barcode';

  @override
  String get barcodeLabel => 'Barcode (EAN/GTIN)';

  @override
  String get enterBarcode => 'Enter barcode';

  @override
  String get searching => 'Searching...';

  @override
  String get noKcalFoundPrefix => 'No kcal value found for barcode ';

  @override
  String get foundPrefix => 'Found: ';

  @override
  String get kcalPer100Unit => ' kcal per 100g/ml';

  @override
  String get whenDrankTitle => 'When consumed?';

  @override
  String get snack => 'Snack';

  @override
  String get loginToLog => 'Log in to log';

  @override
  String get editDrinkTitle => 'Edit drink';

  @override
  String get nameLabel => 'Name';

  @override
  String get delete => 'Delete';

  @override
  String get saveButton => 'Save';

  @override
  String get added => 'added';
}
