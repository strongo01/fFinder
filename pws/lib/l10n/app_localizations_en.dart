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
  String get enterWaistCircumference => 'Enter your waist circumference (cm)';

  @override
  String get enterValidWaistCircumference => 'Please enter a valid waist circumference';

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
  String get absiHigh => 'high risk';

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

  @override
  String get sportAddTitle => 'Add Sport';

  @override
  String get newSportActivity => 'New sportactivity';

  @override
  String get labelSport => 'Sport';

  @override
  String get chooseSport => 'Choose a sport';

  @override
  String get customSportName => 'Name of sport';

  @override
  String get enterSportName => 'Enter a sport name';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get invalidDuration => 'Enter a valid duration';

  @override
  String get caloriesBurned => 'Calories burned';

  @override
  String get invalidCalories => 'Enter a valid number of calories';

  @override
  String get save => 'Save';

  @override
  String get encryptionKeyNotFound => 'Encryption key not found.';

  @override
  String get noSportsYet => 'No sport activities yet.';

  @override
  String get durationLabel => 'Duration';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get minutesShort => 'min';

  @override
  String get intensityLevel => 'Intensity';

  @override
  String get intensityLight => 'Light';

  @override
  String get intensityNormal => 'Normal';

  @override
  String get intensityHard => 'Hard';

  @override
  String get intensityVeryHard => 'Very hard';

  @override
  String get userNotLoggedIn => 'User not logged in.';

  @override
  String get sportAdded => 'Sport activity added';

  @override
  String get sportRunning => 'Running';

  @override
  String get sportCycling => 'Cycling';

  @override
  String get sportSwimming => 'Swimming';

  @override
  String get sportWalking => 'Walking';

  @override
  String get sportFitness => 'Fitness';

  @override
  String get sportFootball => 'Football';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportOther => 'Other';

  @override
  String get deleteSportTitle => 'Delete sport activity?';

  @override
  String get deleteSportContent => 'Are you sure you want to delete this sport activity?';

  @override
  String get sportDeleted => 'Sport activity deleted';

  @override
  String get editSportTitle => 'Edit Sport Activity';

  @override
  String get sportUpdated => 'Sport activity updated';

  @override
  String get notLoggedIn => 'Not logged in.';

  @override
  String get addSportTitle => 'Add Sport Activity';

  @override
  String get sportLabel => 'Sport Activity';

  @override
  String get customSportLabel => 'Custom Sport Name';

  @override
  String get customSportRequired => 'Custom sport name is required.';

  @override
  String get logSportTitle => 'Log Sport Activity';

  @override
  String get intensityHeavy => 'Heavy';

  @override
  String get intensityVeryHeavy => 'Very Heavy';

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get enterValidDuration => 'Please enter a valid duration.';

  @override
  String get caloriesBurnedLabel => 'Calories Burned';

  @override
  String get enterValidCalories => 'Please enter a valid number of calories.';

  @override
  String get durationShort => 'dur.';

  @override
  String get caloriesShort => 'cal';

  @override
  String get saveSportFailedPrefix => 'Save sport activity failed: ';

  @override
  String get unsavedChangesContent => 'You have unsaved changes. Are you sure you want to leave without saving?';

  @override
  String get searchFood => 'Search food';

  @override
  String get searchFoodDescription => 'Search for food to add to your daily log.';

  @override
  String get scanProduct => 'Scan product';

  @override
  String get scanProductDescription => 'Scan a product to quickly add nutritional information to your day.';

  @override
  String get recentProducts => 'Recent Products';

  @override
  String get recentProductsDescription => 'View and quickly add products you\'ve recently used.';

  @override
  String get favoriteProducts => 'Favorite Products';

  @override
  String get favoriteProductsDescription => 'Here you can view all your favorite products.';

  @override
  String get myProducts => 'My Products';

  @override
  String get myProductsDescription => 'Here you can add your own products that cannot be found.';

  @override
  String get meals => 'Meals';

  @override
  String get mealsDescription => 'Here you can view and log meals; meals consist of multiple products.';

  @override
  String get mealsAdd => 'Add meals';

  @override
  String get mealsAddDescription => 'Tap this plus to create meals from multiple products so you can add frequently eaten meals faster.';

  @override
  String get mealsLog => 'Log meals';

  @override
  String get mealsLogDescription => 'Tap this cart to add meals to the logs.';

  @override
  String get enterMoreChars => 'Enter at least 2 characters.';

  @override
  String get errorFetch => 'Error fetching';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get noImageSelected => 'No image selected.';

  @override
  String get aiNoIngredientsFound => 'No result from AI.';

  @override
  String aiIngredientsPrompt(Object ingredient) {
    return 'What ingredients do you see here? Answer in English. Ignore marketing terms, product names, and non-relevant words like \'zero\', \'light\', etc. Answer only with actual ingredients that are in the product. Answer only if the image shows a food product. Respond as: $ingredient, $ingredient, ...';
  }

  @override
  String get aiIngredientsFound => 'Ingredients found:';

  @override
  String get aiIngredientsDescription => 'The AI recognized the following ingredients:';

  @override
  String get addMeal => 'Compose meal';

  @override
  String get errorAI => 'AI analysis error:';

  @override
  String get amount => 'Amount';

  @override
  String get search => 'Search';

  @override
  String get loadMore => 'Load more products...';

  @override
  String get errorNoBarcode => 'No barcode found for this product.';

  @override
  String get amountInGrams => 'Amount (g)';

  @override
  String get errorUserDEKMissing => 'Could not retrieve encryption key.';

  @override
  String get errorNoIngredientsAdded => 'Add at least one product.';

  @override
  String get mealSavedSuccessfully => 'Meal saved successfully!';

  @override
  String get saveMeal => 'Save meal';

  @override
  String get errorFetchRecentsProducts => 'Error fetching recent products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get add => 'Add';

  @override
  String get addFoodItem => 'What would you like to add?';

  @override
  String get addProduct => 'Add product';

  @override
  String get addMealT => 'Add meal';

  @override
  String get recents => 'Recent';

  @override
  String get favorites => 'Favorites';

  @override
  String get searchingProducts => 'Start typing to search.';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get addNewProduct => 'Would you like to add a product yourself?';

  @override
  String get errorInvalidBarcode => 'No barcode found for this product.';

  @override
  String get loadMoreResults => 'Load more products…';

  @override
  String get notTheDesiredResults => 'Add a new product';

  @override
  String get addNewProductT => 'Add New Product';

  @override
  String get errorProductNameRequired => 'Name is required';

  @override
  String get brandName => 'Brand';

  @override
  String get quantity => 'Quantity (e.g. 100g, 250ml)';

  @override
  String get nutritionalValuesPer100g => 'Nutritional values per 100g or ml';

  @override
  String get calories => 'Energy (kcal)';

  @override
  String get errorCaloriesRequired => 'Calories are required';

  @override
  String get fat => 'Fat';

  @override
  String get saturatedFat => '  - of which saturated';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get sugars => '  - of which sugars';

  @override
  String get fiber => 'Fiber';

  @override
  String get proteins => 'Proteins';

  @override
  String get salt => 'Salt';

  @override
  String get errorEncryptionKeyMissing => 'Error: Could not retrieve encryption key.';

  @override
  String get saveProduct => 'Save';

  @override
  String get unknown => 'Unknown';

  @override
  String get unnamedProduct => 'Unnamed product';

  @override
  String get logInToSeeRecents => 'Log in to see your recent products.';

  @override
  String get noRecentProductsFound => 'No recent products found.';

  @override
  String get errorLoadingRecentProducts => 'An error occurred.';

  @override
  String get logInToSeeFavorites => 'Log in to see your favorite products.';

  @override
  String get noFavoriteProductsFound => 'No favorite products found.';

  @override
  String get errorLoadingFavoriteProducts => 'An error occurred.';

  @override
  String get logInToSeeMyProducts => 'Log in to see your products.';

  @override
  String get noMyProductsFound => 'You haven\'t created any products yet.';

  @override
  String get errorLoadingMyProducts => 'An error occurred.';

  @override
  String get unknownBrand => 'No brand';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get sure => 'Are you sure you want to ';

  @override
  String get willBeDeleted => ' will be deleted?';

  @override
  String get deleted => 'deleted';

  @override
  String get logInToSeeMeals => 'Log in to see your meals.';

  @override
  String get errorLoadingMeals => 'An error occurred.';

  @override
  String get mealExample => 'Example meal';

  @override
  String get createOwnMealsFirst => 'Click + to create your first meal';

  @override
  String get logMeal => 'Log meal';

  @override
  String get createMealsBeforeLogging => 'This is an example. Create your own meal first.';

  @override
  String get unnamedMeal => 'Unnamed meal';

  @override
  String get sureMeal => 'Are you sure that your meal ';

  @override
  String get meal => 'Meal ';

  @override
  String get encryptionKeyError => 'Could not retrieve encryption key.';

  @override
  String get mealNoIngredients => 'This meal has no ingredients.';

  @override
  String get mealLoggedSuccessfully => ' added to your log.';

  @override
  String get errorSaveMeal => 'Error saving meal:';

  @override
  String get sectie => 'Section';

  @override
  String get log => 'Log';

  @override
  String get mealAddAtLeastOneIngredient => 'Add at least one product.';

  @override
  String get editMeal => 'Edit meal';

  @override
  String get addNewMeal => 'Create new meal';

  @override
  String get mealName => 'Meal name';

  @override
  String get pleaseEnterMealName => 'Name is required';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get searchProductHint => 'Type to search or scan barcode';

  @override
  String get selectProduct => 'Select product';

  @override
  String get scanBarcode => 'Scan barcode for this product';

  @override
  String get searchForBarcode => 'Searching by barcode...';

  @override
  String get errorFetchingProductData => 'Product not found on OpenFoodFacts';

  @override
  String get productNotFound => 'No product data found';

  @override
  String get errorBarcodeFind => 'Error during barcode search: ';

  @override
  String get errorFetchingProductDataBarcode => 'No barcode found for this product.';

  @override
  String get addIngredient => 'Add another product';

  @override
  String get editMyProduct => 'Edit product';

  @override
  String get productName => 'Product name';

  @override
  String get productNameRequired => 'Name is required';

  @override
  String get caloriesRequired => 'Calories are required';

  @override
  String get errorUserDEKNotFound => 'Could not retrieve encryption key.';

  @override
  String get unknownProduct => 'Unknown product';

  @override
  String get brand => 'Brand';

  @override
  String get servingSize => 'Serving size';

  @override
  String get nutritionalValuesPer100mlg => 'Nutritional values per 100g/ml';

  @override
  String get saveMyProduct => 'Save my product';

  @override
  String get amountFor => 'Amount for ';

  @override
  String get amountGML => 'Amount (gram or milliliter)';

  @override
  String get gramsMillilitersAbbreviation => 'g/ml';

  @override
  String get invalidAmount => 'Enter a valid amount.';

  @override
  String get addedToLog => ' added to your log.';

  @override
  String get errorSaving => 'Error saving: ';

  @override
  String get photoAnalyzing => 'Analyzing photo...';

  @override
  String get ingredientsIdentifying => 'Identifying ingredients...';

  @override
  String get nutritionalValuesEstimating => 'Estimating nutritional values...';

  @override
  String get patientlyWaiting => 'Please wait...';

  @override
  String get almostDone => 'Almost done...';

  @override
  String get processingWithAI => 'Processing with AI...';

  @override
  String get selectMealType => 'Select mealtype';

  @override
  String get section => 'Section';

  @override
  String get saveNameTooltip => 'Save';

  @override
  String get noChangesTooltip => 'No changes';

  @override
  String get fillRequiredKcal => 'Fill in all required fields (kcal).';

  @override
  String get additivesLabel => 'Additives';

  @override
  String get allergensLabel => 'Allergens';

  @override
  String get mealAmountLabel => 'Amount for meal';

  @override
  String get addToMealButton => 'Add to meal';

  @override
  String get enterAmount => 'Enter an amount';

  @override
  String get unitLabel => 'Unit';

  @override
  String get gramLabel => 'Gram (g)';

  @override
  String get milliliterLabel => 'Milliliter (ml)';

  @override
  String get errorLoadingLocal => 'Error fetching local data: ';

  @override
  String get errorFetching => 'Error fetching: ';

  @override
  String get nameSaved => 'Name saved';

  @override
  String get enterValue => 'Missing value';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get done => 'Done';

  @override
  String get logs => 'Logs';

  @override
  String get add_food_label => 'Add food';

  @override
  String get add_drink_label => 'Add drink';

  @override
  String get add_sport_label => 'Add sport';

  @override
  String get tutorial_date_title => 'Change date';

  @override
  String get tutorial_date_text => 'Tap here to choose a date or quickly jump to today.';

  @override
  String get tutorial_barcode_title => 'Scan barcode';

  @override
  String get tutorial_barcode_text => 'Tap here to scan a product and quickly add it to your day.';

  @override
  String get tutorial_settings_title => 'Settings';

  @override
  String get tutorial_settings_text => 'Use this page to adjust your personal information, notification times, or other settings.';

  @override
  String get tutorial_feedback_title => 'Feedback';

  @override
  String get tutorial_feedback_text => 'You can provide feedback about the app here. Is something not working or is there a feature you\'d like to see? We\'d love to hear from you!';

  @override
  String get tutorial_calorie_title => 'Calorie overview';

  @override
  String get tutorial_calorie_text => 'Here you can see a summary of your calorie intake for the day.';

  @override
  String get tutorial_mascot_title => 'Reppy';

  @override
  String get tutorial_mascot_text => 'Reppy provides personal motivation and tips!';

  @override
  String get tutorial_water_title => 'Drinks';

  @override
  String get tutorial_water_text => 'Track how much you drink each day here. The circle shows how much you still need to drink to reach your goal.';

  @override
  String get tutorial_additems_title => 'Add items';

  @override
  String get tutorial_additems_text => 'Use this button to quickly add meals, drinks, or sports.';

  @override
  String get tutorial_meals_title => 'Meals';

  @override
  String get tutorial_meals_text => 'View your meals and edit them by tapping on them.';

  @override
  String get updateAvailable => 'A new update is available! Update the app via TestFlight for Apple or the Google Play Store for Android.';

  @override
  String get announcement_default => 'Announcement';

  @override
  String get water_goal_dialog_title => 'Set water goal';

  @override
  String get water_goal_dialog_label => 'Goal (ml)';

  @override
  String get enter_valid_number => 'Enter a valid number';

  @override
  String get water_goal_updated => 'Water goal updated';

  @override
  String get error_saving_water_goal => 'Error saving water goal: ';

  @override
  String get calorie_goal_dialog_title => 'Set calorie goal';

  @override
  String get calorie_goal_dialog_label => 'Daily goal (kcal)';

  @override
  String get calorie_goal_updated => 'Calorie goal updated';

  @override
  String get error_saving_prefix => 'Save failed: ';

  @override
  String get eaten => 'Eaten';

  @override
  String get remaining => 'Remaining';

  @override
  String get over_goal => 'Above goal';

  @override
  String get calories_over_goal => 'kcal over goal';

  @override
  String get calories_remaining => 'kcal left';

  @override
  String get calories_consumed => 'kcal consumed';

  @override
  String get carbs => 'Carbs';

  @override
  String get fats => 'Fats';

  @override
  String get unit => 'Unit';

  @override
  String get edit_amount_dialog_title_ml => 'Edit amount (ml)';

  @override
  String get edit_amount_dialog_title_g => 'Edit amount (g)';

  @override
  String get edit_amount_label_ml => 'Amount (ml)';

  @override
  String get edit_amount_label_g => 'Amount (g)';

  @override
  String get totalConsumed => 'Total consumed';

  @override
  String get youHave => 'You have';

  @override
  String get motivational_default_1 => 'Keep it up, well done!';

  @override
  String get motivational_default_2 => 'Tap me for a new message!';

  @override
  String get motivational_default_3 => 'Every step counts!';

  @override
  String get motivational_default_4 => 'You\'re doing great!';

  @override
  String get motivational_default_5 => 'Did you know fFinder stands for FoodFinder?';

  @override
  String get motivational_default_6 => 'You log better than 97% of people... probably.';

  @override
  String get motivational_noEntries_1 => 'Ready to log your day?';

  @override
  String get motivational_noEntries_2 => 'A new day, new opportunities!';

  @override
  String get motivational_noEntries_3 => 'Let\'s get started!';

  @override
  String get motivational_noEntries_4 => 'Every healthy day starts with one entry.';

  @override
  String get motivational_noEntries_5 => 'Your first meal is hiding. Try searching for it!';

  @override
  String get motivational_drinksOnly_1 => 'Good that you logged drinks already! What\'s your first meal?';

  @override
  String get motivational_drinksOnly_2 => 'Hydration is a good start. Time to add something to eat as well.';

  @override
  String get motivational_drinksOnly_3 => 'Nice! What\'s your first bite?';

  @override
  String get motivational_overGoal_1 => 'Goal reached! Take it easy now.';

  @override
  String get motivational_overGoal_2 => 'Wow, you\'re over your goal!';

  @override
  String get motivational_overGoal_3 => 'Well done, tomorrow is another day.';

  @override
  String get motivational_overGoal_4 => 'Great work today, really!';

  @override
  String get motivational_almostGoal_1 => 'You\'re almost there!';

  @override
  String get motivational_almostGoal_2 => 'Just a little bit more!';

  @override
  String get motivational_almostGoal_3 => 'Almost reached your calorie goal!';

  @override
  String get motivational_almostGoal_4 => 'Good job! Watch the last step.';

  @override
  String get motivational_almostGoal_5 => 'You\'re doing fantastic, almost there!';

  @override
  String get motivational_belowHalf_1 => 'You\'re off to a great start, keep going!';

  @override
  String get motivational_belowHalf_2 => 'The first half is done, stay focused!';

  @override
  String get motivational_belowHalf_3 => 'Keep logging your meals and drinks.';

  @override
  String get motivational_belowHalf_4 => 'You\'re doing great, keep it up!';

  @override
  String get motivational_lowWater_1 => 'Don\'t forget to drink today!';

  @override
  String get motivational_lowWater_2 => 'A sip of water is a good start.';

  @override
  String get motivational_lowWater_3 => 'Hot or cold, water is always good!';

  @override
  String get motivational_lowWater_4 => 'Hydration is important!';

  @override
  String get motivational_lowWater_5 => 'A glass of water can do wonders.';

  @override
  String get motivational_lowWater_6 => 'Take a break? Drink a little water.';

  @override
  String get entry_updated => 'Entry updated';

  @override
  String get errorUpdatingEntry => 'Error updating entry: ';

  @override
  String get errorLoadingData => 'Error loading data: ';

  @override
  String get not_logged_in => 'Not logged in.';

  @override
  String get noEntriesForDate => 'No entries yet.';

  @override
  String get thinking => 'Thinking...';

  @override
  String get sports => 'Sportactivity';

  @override
  String get totalBurned => 'Total burned: ';

  @override
  String get unknownSport => 'Unknown sport';

  @override
  String get errorDeletingSport => 'Error deleting sport: ';

  @override
  String get errorDeleting => 'Error deleting: ';

  @override
  String get errorCalculating => 'Error: Original values are not complete to recalculate.';

  @override
  String get appleCancelled => 'You cancelled the Apple sign-in.';

  @override
  String get appleFailed => 'Apple sign-in failed. Please try again later.';

  @override
  String get appleInvalidResponse => 'Invalid response received from Apple.';

  @override
  String get appleNotHandled => 'Apple could not handle the request.';

  @override
  String get appleUnknown => 'An unknown error occurred with Apple.';

  @override
  String get appleGenericError => 'An error occurred while signing in with Apple.';

  @override
  String get signInAccountExists => 'An account already exists with this email. Please sign in using a different method.';

  @override
  String get signInCancelled => 'Sign-in was cancelled.';

  @override
  String get unknownGoogleSignIn => 'An unknown error occurred during Google sign-in.';

  @override
  String get unknownGitHubSignIn => 'An unknown error occurred during GitHub sign-in.';

  @override
  String get unknownAppleSignIn => 'An unknown error occurred during Apple sign-in.';

  @override
  String get unknownErrorEnglish => 'Unknown error';

  @override
  String get passwordErrorMinLength => 'At least 6 characters';

  @override
  String get passwordErrorUpper => 'one uppercase letter';

  @override
  String get passwordErrorLower => 'one lowercase letter';

  @override
  String get passwordErrorDigit => 'one digit';

  @override
  String get passwordMissingPartsPrefix => 'Your password is missing: ';

  @override
  String get userNotFoundCreateAccount => 'No account found for this email. Click below to create an account.';

  @override
  String get wrongPasswordOrEmail => 'Incorrect password or email. Please try again. If you don\'t have an account, click below to create one.';

  @override
  String get emailAlreadyInUse => 'This email is already in use. Try signing in.';

  @override
  String get weakPasswordMessage => 'The password must be at least 6 characters long.';

  @override
  String get invalidEmailMessage => 'The entered email address is invalid.';

  @override
  String get authGenericError => 'An authentication error occurred. Please try again later.';

  @override
  String get resetPasswordEnterEmailInstruction => 'Enter your email to reset your password.';

  @override
  String get resetPasswordEmailSentTitle => 'Email sent';

  @override
  String get resetPasswordEmailSentContent => 'An email has been sent to reset your password. Note: this email may end up in your spam folder. Sender: noreply@pwsmt-fd851.firebaseapp.com';

  @override
  String get okLabel => 'OK';

  @override
  String get genericError => 'An error occurred.';

  @override
  String get userNotFoundForEmail => 'No account found for this email.';

  @override
  String get loginWelcomeBack => 'Welcome back!';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get registerSubtitle => 'Register to get started';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'name@example.com';

  @override
  String get loginEnterEmail => 'Enter email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginMin6Chars => 'Min 6 chars';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButtonLogin => 'Login';

  @override
  String get loginButtonRegister => 'Register';

  @override
  String get loginOrContinueWith => 'Or continue with';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithGitHub => 'Sign in with GitHub';

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get loginNoAccountQuestion => 'Don\'t have an account?';

  @override
  String get loginHaveAccountQuestion => 'Already have an account?';

  @override
  String get loginCreateAccountAction => 'Create an account';

  @override
  String get loginLoginAction => 'Login';

  @override
  String get onboardingEnterFirstName => 'Enter your first name';

  @override
  String get onboardingSelectBirthDate => 'Select your birth date';

  @override
  String get onboardingEnterHeight => 'Enter your height (cm)';

  @override
  String get onboardingEnterWeight => 'Enter your weight (kg)';

  @override
  String get onboardingEnterTargetWeight => 'Enter your target weight (kg)';

  @override
  String get onboardingEnterValidWeight => 'Please enter a valid weight';

  @override
  String get onboardingEnterValidHeight => 'Please enter a valid height';

  @override
  String get heightBetween => 'Height must be between ';

  @override
  String get and => ' and ';

  @override
  String get liggen => ' cm.';

  @override
  String get weightBetween => 'Weight must be between ';

  @override
  String get kgLiggen => ' kg.';

  @override
  String get tailleBetween => 'Waist circumference must be between ';

  @override
  String get cmLiggen => ' cm.';

  @override
  String get onboardingEnterValidTargetWeight => 'Please enter a valid target weight';

  @override
  String get targetBetween => 'Target weight must be between ';

  @override
  String get absiVeryLow => 'very low risk';

  @override
  String get absiLow => 'low risk';

  @override
  String get absiAverage => 'average risk';

  @override
  String get absiElevated => 'elevated risk';

  @override
  String get healthWeight => 'Healthy weight for you: ';

  @override
  String get healthyBMI => 'Healthy BMI: ';

  @override
  String get onboardingWeightRangeUnder2 => 'For children under 2 years old, weight-for-length percentiles are usually used instead of BMI.';

  @override
  String get onboardingWeightRangeUnder2Note => 'Use WHO/CDC weight-for-length charts.';

  @override
  String get onboarding_datePickerDone => 'Done';

  @override
  String get lmsDataUnavailable => 'LMS data unavailable for this age/sex.';

  @override
  String get lmsCheckAssets => 'Check assets or enter the target weight manually.';

  @override
  String get lmsDataErrorPrefix => 'Could not use LMS data:';

  @override
  String get lmsAssetMissing => 'Check that the asset is present (assets/cdc/bmiagerev.csv).';

  @override
  String get healthyWeightForYou => 'Healthy weight for you:';

  @override
  String get onboarding_firstNameTitle => 'What is your first name?';

  @override
  String get onboarding_labelFirstName => 'First name';

  @override
  String get onboarding_genderTitle => 'What is your gender?';

  @override
  String get onboarding_genderOptionMan => 'Male';

  @override
  String get onboarding_genderOptionWoman => 'Female';

  @override
  String get onboarding_genderOptionOther => 'Other';

  @override
  String get onboarding_genderOptionPreferNot => 'Prefer not to say';

  @override
  String get onboarding_birthDateTitle => 'What is your birth date?';

  @override
  String get onboarding_noDateChosen => 'No date chosen';

  @override
  String get onboarding_chooseDate => 'Choose date';

  @override
  String get onboarding_heightTitle => 'What is your height (cm)?';

  @override
  String get onboarding_labelHeight => 'Height in cm';

  @override
  String get onboarding_weightTitle => 'What is your weight (kg)?';

  @override
  String get onboarding_labelWeight => 'Weight in kg';

  @override
  String get onboarding_waistTitle => 'What is your waist circumference (cm)?';

  @override
  String get onboarding_labelWaist => 'Waist circumference in cm';

  @override
  String get onboarding_unknownWaist => 'I don\'t know';

  @override
  String get onboarding_sleepTitle => 'How many hours do you sleep on average per night?';

  @override
  String get onboarding_activityTitle => 'How active are you on a daily basis?';

  @override
  String get onboarding_targetWeightTitle => 'What is your target weight?';

  @override
  String get onboarding_labelTargetWeight => 'Target weight in kg';

  @override
  String get onboarding_goalTitle => 'What is your goal?';

  @override
  String get onboarding_notificationsTitle => 'Would you like to receive notifications?';

  @override
  String get onboarding_notificationsDescription => 'You can enable notifications for meal reminders so you never forget to eat and log your meals.';

  @override
  String get onboarding_notificationsEnable => 'Enable notifications';

  @override
  String get finish => 'Finish';

  @override
  String get notificationPermissionDenied => 'Notification permission was denied.';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get deleteAccountProviderReauthRequired => 'To delete your account, please re-authenticate using your original sign-in method and try again.';

  @override
  String get enterPasswordLabel => 'Password';

  @override
  String get confirmButtonLabel => 'Confirm';

  @override
  String get googleSignInCancelledMessage => 'Google sign-in was cancelled by the user.';

  @override
  String get googleMissingIdToken => 'Could not obtain idToken from Google.';

  @override
  String get appleNullIdentityTokenMessage => 'Apple returned a null identityToken.';
}
