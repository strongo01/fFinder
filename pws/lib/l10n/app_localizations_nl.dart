// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get recipesTitle => 'Recepten';

  @override
  String get recipesSubtitle => 'Vind en beheer je favoriete recepten';

  @override
  String get encryptionKeyLoadError => 'Kon de encryptiesleutel niet laden.';

  @override
  String get encryptionKeyLoadSaveError => 'Kon de encryptiesleutel niet laden voor opslaan.';

  @override
  String get encryptedJson => 'Versleutelde JSON (nonce/cipher/tag)';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get mealNotifications => 'Maaltijdherinneringen';

  @override
  String get enableMealNotifications => 'Herinneringen inschakelen';

  @override
  String get breakfast => 'Ontbijt';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Avondeten';

  @override
  String get enableGifs => 'Mascotte animatie (GIF) tonen';

  @override
  String get restartTutorial => 'Uitleg opnieuw starten';

  @override
  String get personalInfo => 'Persoonlijke gegevens';

  @override
  String get personalInfoDescription => 'Pas je gewicht, lengte, doel en activiteit aan.';

  @override
  String get currentWeightKg => 'Huidig gewicht (kg)';

  @override
  String get enterCurrentWeight => 'Vul je huidige gewicht in';

  @override
  String get enterValidWeight => 'Voer een geldig gewicht in';

  @override
  String get heightCm => 'Lengte (cm)';

  @override
  String get enterHeight => 'Vul je lengte in';

  @override
  String get enterHeightBetween100And250 => 'Voer een lengte tussen 100 en 250 cm in';

  @override
  String get waistCircumferenceCm => 'Tailleomtrek (cm)';

  @override
  String get enterWaistCircumference => 'Vul je tailleomtrek in';

  @override
  String get enterValidWaistCircumference => 'Voer een tailleomtrek tussen 30 en 200 cm in';

  @override
  String get targetWeightKg => 'Doelgewicht (kg)';

  @override
  String get enterTargetWeight => 'Vul je doelgewicht in';

  @override
  String get enterValidTargetWeight => 'Voer een geldig doelgewicht in';

  @override
  String get sleepHoursPerNight => 'Slaap (uur per nacht)';

  @override
  String get hours => 'uur';

  @override
  String get activityLevel => 'Activiteitsniveau';

  @override
  String get goal => 'Doel';

  @override
  String get savingSettings => 'Opslaan...';

  @override
  String get saveSettings => 'Instellingen opslaan';

  @override
  String get adminAnnouncements => 'Admin Acties';

  @override
  String get createAnnouncement => 'Nieuw bericht maken';

  @override
  String get createAnnouncementSubtitle => 'Publiceer een bericht voor alle gebruikers';

  @override
  String get manageAnnouncements => 'Berichten beheren';

  @override
  String get manageAnnouncementsSubtitle => 'Bekijk, deactiveer of verwijder berichten';

  @override
  String get decryptValues => 'Decrypten';

  @override
  String get decryptValuesSubtitle => 'Decrypt waardes voor gebruiker als ze account willen overzetten .';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get deletingAccount => 'Account verwijderen...';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get credits => 'Credits';

  @override
  String get creditsAbsiDataAttribution => 'Deze dataset wordt gebruikt voor het berekenen van ABSI Z-scores en categorieën in deze app.';

  @override
  String get absiAttribution => 'Body Shape Index (ABSI) referentietabel is gebaseerd op:\n\nY. Krakauer, Nir; C. Krakauer, Jesse (2015).\nTable S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\nPLOS ONE. Dataset.\nhttps://doi.org/10.1371/journal.pone.0039504.s001\n\nDeze dataset wordt gebruikt voor het berekenen van ABSI Z-scores en categorieën in deze app.';

  @override
  String get date => 'Datum';

  @override
  String get close => 'Sluiten';

  @override
  String get editAnnouncement => 'Bericht bewerken';

  @override
  String get title => 'Titel';

  @override
  String get titleCannotBeEmpty => 'Titel mag niet leeg zijn.';

  @override
  String get message => 'Bericht';

  @override
  String get messageCannotBeEmpty => 'Bericht mag niet leeg zijn.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get announcementUpdated => 'Bericht bijgewerkt.';

  @override
  String get saveChanges => 'Wijzigingen opslaan';

  @override
  String get announcementDeleted => 'Bericht verwijderd.';

  @override
  String get errorLoadingAnnouncements => 'Er is een fout opgetreden.';

  @override
  String get noAnnouncementsFound => 'Geen berichten gevonden.';

  @override
  String get unknownDate => 'Onbekende datum';

  @override
  String get createdAt => 'Gemaakt op';

  @override
  String get active => 'Actief';

  @override
  String get inactive => 'Inactief';

  @override
  String get activate => 'Activeren';

  @override
  String get deactivate => 'Deactiveren';

  @override
  String get editAnnouncementTooltip => 'Bewerk bericht';

  @override
  String get language => 'Taal';

  @override
  String get useSystemLocale => 'Systeemtaal gebruiken';

  @override
  String get activityLow => 'Weinig actief: zittend werk, nauwelijks beweging, geen sport';

  @override
  String get activityLight => 'Licht actief: 1–3x per week lichte training of dagelijks 30–45 min wandelen';

  @override
  String get activityMedium => 'Gemiddeld actief: 3–5x per week sporten of een actief beroep (horeca, zorg, postbezorger)';

  @override
  String get activityVery => 'Zeer actief: 6–7x per week intensieve training of fysiek zwaar werk (bouw, magazijn)';

  @override
  String get activityExtreme => 'Extreem actief: topsporttraining 2× per dag of extreem fysiek zwaar werk (militair, bosbouw)';

  @override
  String get goalLose => 'Afvallen';

  @override
  String get goalMaintain => 'Op gewicht blijven';

  @override
  String get goalGainMuscle => 'Aankomen (spiermassa)';

  @override
  String get goalGainGeneral => 'Aankomen (algemeen)';

  @override
  String get createAnnouncementTitle => 'Nieuw bericht publiceren';

  @override
  String get messageLabel => 'Bericht';

  @override
  String get messageValidationError => 'Bericht mag niet leeg zijn.';

  @override
  String get announcementPublishedSuccess => 'Bericht succesvol gepubliceerd!';

  @override
  String get publishButtonLabel => 'Publiceren';

  @override
  String get unsavedChangesTitle => 'Niet-opgeslagen wijzigingen';

  @override
  String get unsavedChangesMessage => 'Je hebt wijzigingen aangebracht die nog niet zijn opgeslagen. Weet je zeker dat je wilt afsluiten zonder op te slaan?';

  @override
  String get discardButtonLabel => 'Negeer wijzigingen';

  @override
  String get cancelButtonLabel => 'Annuleren';

  @override
  String get unknownUser => 'Onbekende gebruiker';

  @override
  String get tutorialRestartedMessage => 'Uitleg is opnieuw gestart!';

  @override
  String get deleteAnnouncementTooltip => 'Verwijderen';

  @override
  String get duplicateRequestError => 'Er bestaat al een openstaande aanvraag voor deze waarde.';

  @override
  String get requestSubmittedSuccess => 'Decryptie-aanvraag ingediend voor goedkeuring.';

  @override
  String get requestSubmissionFailed => 'Indienen van aanvraag mislukt';

  @override
  String get requestNotFound => 'Aanvraag niet gevonden';

  @override
  String get cannotApproveOwnRequest => 'Je kunt je eigen aanvraag niet goedkeuren.';

  @override
  String get dekNotFoundForUser => 'Kon encryptiesleutel niet ophalen.';

  @override
  String get requestApprovedSuccess => 'Aanvraag goedgekeurd.';

  @override
  String get requestApprovalFailed => 'Goedkeuren mislukt';

  @override
  String get cannotRejectOwnRequest => 'Je kunt je eigen aanvraag niet afkeuren.';

  @override
  String get requestRejectedSuccess => 'Aanvraag afgekeurd.';

  @override
  String get requestRejectionFailed => 'Afkeuren mislukt';

  @override
  String get pleaseEnterUid => 'Vul een UID in';

  @override
  String get pleaseEnterEncryptedJson => 'Plak de versleutelde JSON';

  @override
  String get submit => 'Indienen';

  @override
  String get submitRequest => 'Aanvraag indienen';

  @override
  String get loading => 'Laden...';

  @override
  String get pendingRequests => 'Openstaande aanvragen';

  @override
  String get noPendingRequests => 'Geen aanvragen gevonden.';

  @override
  String get forUid => 'Voor UID';

  @override
  String get requestedBy => 'Aangevraagd door';

  @override
  String get encryptedJsonLabel => 'Versleutelde waarde:';

  @override
  String get reject => 'Afkeuren';

  @override
  String get approve => 'Goedkeuren';

  @override
  String get confirmSignOutTitle => 'Uitloggen';

  @override
  String get confirmSignOutMessage => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get confirmDeleteAccountTitle => 'Account verwijderen';

  @override
  String get confirmDeleteAccountMessage => 'Weet je zeker dat je je account wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get deletionCodeInstruction => 'Typ onderstaande code over om te bevestigen:';

  @override
  String get enterDeletionCodeLabel => 'Voer de 6-cijferige code in';

  @override
  String get deletionCodeMismatchError => 'Code klopt niet, probeer het opnieuw.';

  @override
  String get deleteAccountButtonLabel => 'Verwijderen';

  @override
  String get settingsSavedSuccessMessage => 'Instellingen opgeslagen';

  @override
  String get settingsSaveFailedMessage => 'Opslaan mislukt';

  @override
  String get profileLoadFailedMessage => 'Kon profiel niet laden';

  @override
  String get deleteAccountRecentLoginError => 'Log opnieuw in en probeer het nog eens om je account te verwijderen.';

  @override
  String get deleteAccountFailedMessage => 'Verwijderen mislukt';

  @override
  String get titleLabel => 'Titel';

  @override
  String get titleValidationError => 'Titel mag niet leeg zijn.';

  @override
  String get untitled => 'Geen titel';

  @override
  String get appCredits => 'ABSI Data Attribution';

  @override
  String get reportThanks => 'Bedankt voor je rapport!';

  @override
  String get errorSending => 'Fout bij verzenden';

  @override
  String get commentOptional => 'Opmerking bij  (optioneel)';

  @override
  String get reportTitle => 'Rapporteer onderdelen';

  @override
  String get categoryFunctionality => 'Functionaliteit';

  @override
  String get itemFeatures => 'Functies';

  @override
  String get itemFunctionality => 'Functionaliteit';

  @override
  String get itemUsability => 'Gebruiksgemak';

  @override
  String get itemClarity => 'Overzichtelijkheid';

  @override
  String get itemAccuracy => 'Nauwkeurigheid';

  @override
  String get itemNavigation => 'Navigatie';

  @override
  String get categoryPerformance => 'Performance';

  @override
  String get itemSpeed => 'Snelheid';

  @override
  String get itemLoadingTimes => 'Laadtijden';

  @override
  String get itemStability => 'Stabiliteit';

  @override
  String get categoryInterfaceDesign => 'Interface & Design';

  @override
  String get itemLayout => 'Layout';

  @override
  String get itemColorsTheme => 'Kleuren & Thema';

  @override
  String get itemIconsDesign => 'Iconen & Design';

  @override
  String get itemReadability => 'Leesbaarheid';

  @override
  String get categoryCommunication => 'Communicatie';

  @override
  String get itemErrors => 'Foutmeldingen';

  @override
  String get itemExplanation => 'Uitleg & Instructies';

  @override
  String get categoryAppParts => 'App Onderdelen';

  @override
  String get itemDashboard => 'Dashboard';

  @override
  String get itemLogin => 'Inloggen / Registratie';

  @override
  String get itemWeight => 'Gewicht';

  @override
  String get itemStatistics => 'Statistieken';

  @override
  String get itemCalendar => 'Kalender';

  @override
  String get categoryOther => 'Overig';

  @override
  String get itemGeneralSatisfaction => 'Algemene Tevredenheid';

  @override
  String get send => 'Versturen';

  @override
  String get feedbackTitle => 'Geef je feedback';

  @override
  String get viewAllFeedback => 'Bekijk alle feedback';

  @override
  String get viewAllRapportFeedback => 'Bekijk alle rapport feedback';

  @override
  String get openRapportButton => 'Tik om het rapport in te vullen!\nLet op: dit is een uitgebreide vragenlijst. Vul deze pas in als je de app meerdere dagen goed hebt getest.';

  @override
  String get feedbackIntro => 'Hier kan je elk moment je feedback geven.';

  @override
  String get choiceBug => 'Bug';

  @override
  String get choiceFeature => 'Nieuwe functie';

  @override
  String get choiceLanguage => 'Taal';

  @override
  String get choiceLayout => 'Layout';

  @override
  String get choiceOther => 'Anders';

  @override
  String get languageSectionInstruction => 'Geef aan welke taal het betreft en omschrijf de fout. De standaard taal is de taal die je in de app hebt geselecteerd.';

  @override
  String get dropdownLabelLanguage => 'Taal waarop feedback betrekking heeft';

  @override
  String get messageHint => 'Wat wil je ons vertellen?';

  @override
  String get enterMessage => 'Voer een bericht in';

  @override
  String get emailHintOptional => 'E-mail (optioneel)';

  @override
  String get allFeedbackTitle => 'Alle Feedback';

  @override
  String get noFeedbackFound => 'Geen feedback gevonden.';

  @override
  String get errorOccurred => 'Er is een fout opgetreden.';

  @override
  String get noMessage => 'Geen bericht';

  @override
  String get unknownType => 'Onbekend';

  @override
  String get appLanguagePrefix => 'App: ';

  @override
  String get reportedLanguagePrefix => 'Gerapporteerd: ';

  @override
  String get submittedOnPrefix => 'Ingezonden op: ';

  @override
  String get uidLabelPrefix => 'UID: ';

  @override
  String get couldNotOpenMailAppPrefix => 'Kon de mail-app niet openen: ';

  @override
  String get allRapportFeedbackTitle => 'Alle Rapport Feedback';

  @override
  String get noRapportFeedbackFound => 'Geen rapport feedback gevonden.';

  @override
  String get rapportFeedbackTitle => 'Rapport feedback';

  @override
  String get weightTitle => 'Je gewicht';

  @override
  String get weightSubtitle => 'Pas je gewicht aan en bekijk je BMI.';

  @override
  String get weightLabel => 'Gewicht (kg)';

  @override
  String get targetWeightLabel => 'Streefgewicht (kg)';

  @override
  String get weightSliderLabel => 'Gewicht slider';

  @override
  String get saving => 'Opslaan...';

  @override
  String get saveWeight => 'Gewicht opslaan';

  @override
  String get saveWaist => 'Taille opslaan';

  @override
  String get saveSuccess => 'Gewicht + doelen opgeslagen';

  @override
  String get saveFailedPrefix => 'Opslaan mislukt:';

  @override
  String get weightLoadErrorPrefix => 'Kon gebruikersdata niet laden:';

  @override
  String get bmiTitle => 'BMI';

  @override
  String get bmiInsufficient => 'Onvoldoende gegevens om BMI te berekenen. Vul je lengte en gewicht in.';

  @override
  String get yourBmiPrefix => 'Jouw BMI:';

  @override
  String get waistAbsiTitle => 'Taille / ABSI';

  @override
  String get waistLabel => 'Tailleomtrek (cm)';

  @override
  String get absiInsufficient => 'Onvoldoende gegevens om ABSI te berekenen. Vul taille, lengte en gewicht in.';

  @override
  String get yourAbsiPrefix => 'Jouw ABSI:';

  @override
  String get absiLowRisk => 'Laag risico';

  @override
  String get absiMedium => 'Gemiddeld risico';

  @override
  String get absiHigh => 'Hoog risico';

  @override
  String get choiceWeight => 'Gewicht';

  @override
  String get choiceWaist => 'Taille';

  @override
  String get choiceTable => 'Tabel';

  @override
  String get choiceChart => 'Grafiek (per maand)';

  @override
  String get noMeasurements => 'Nog geen metingen opgeslagen.';

  @override
  String get noWaistMeasurements => 'Nog geen taillemetingen opgeslagen.';

  @override
  String get tableMeasurementsTitle => 'Tabel metingen';

  @override
  String get deleteConfirmTitle => 'Verwijderen?';

  @override
  String get deleteConfirmContent => 'Weet je zeker dat je deze meting wilt verwijderen?';

  @override
  String get deleteConfirmDelete => 'Verwijderen';

  @override
  String get measurementDeleted => 'Meting verwijderd';

  @override
  String get chartTitlePrefix => 'Grafiek –';

  @override
  String get chartTooFew => 'Nog te weinig metingen in deze maand voor een grafiek.';

  @override
  String get chartAxesLabel => 'Horizontaal: dagen van de maand, Verticaal: waarde';

  @override
  String get estimateNotEnoughData => 'Niet genoeg data om een trend te berekenen.';

  @override
  String get estimateOnTarget => 'Goed zo! Je bent op je streefgewicht.';

  @override
  String get estimateNoTrend => 'Nog geen trend te berekenen.';

  @override
  String get estimateStable => 'Je gewicht is redelijk stabiel, geen betrouwbare trend.';

  @override
  String get estimateWrongDirection => 'Met de huidige trend beweeg je van je streefgewicht af.';

  @override
  String get estimateInsufficientInfo => 'Er is onvoldoende trendinformatie om een realistische inschatting te maken.';

  @override
  String get estimateUnlikelyWithin10Years => 'Op basis van de huidige trend is het onwaarschijnlijk dat je je streefgewicht binnen 10 jaar bereikt.';

  @override
  String get estimateUncertaintyHigh => 'Let op: zeer grote schommelingen maken deze schatting onbetrouwbaar.';

  @override
  String get estimateUncertaintyMedium => 'Let op: flinke schommelingen maken deze schatting onzeker.';

  @override
  String get estimateUncertaintyLow => 'Opmerking: enige variatie — schatting kan afwijken.';

  @override
  String get estimateBasisRecent => 'op basis van de afgelopen maand';

  @override
  String get estimateBasisAll => 'op basis van alle metingen';

  @override
  String get estimateResultPrefix => 'Als je zo doorgaat (), bereik je je streefgewicht over ongeveer';

  @override
  String get bmiVeryLow => 'Veel te laag';

  @override
  String get bmiLow => 'Laag';

  @override
  String get bmiGood => 'Goed';

  @override
  String get bmiHigh => 'Te hoog';

  @override
  String get bmiVeryHigh => 'Veel te hoog';

  @override
  String get thanksFeedback => 'Bedankt voor je feedback!';

  @override
  String get absiVeryLowRisk => 'Zeer laag risico';

  @override
  String get absiIncreasedRisk => 'Verhoogd risico';

  @override
  String get recipesSwipeInstruction => 'Veeg om recepten te bewaren of over te slaan.';

  @override
  String get recipesNoMore => 'Geen recepten meer.';

  @override
  String get recipesSavedPrefix => 'Opgeslagen: ';

  @override
  String get recipesSkippedPrefix => 'Overgeslagen: ';

  @override
  String get recipesDetailId => 'ID';

  @override
  String get recipesDetailPreparationTime => 'Bereidingstijd';

  @override
  String get recipesDetailTotalTime => 'Totale tijd';

  @override
  String get recipesDetailKcal => 'Calorieën';

  @override
  String get recipesDetailFat => 'Vet';

  @override
  String get recipesDetailSaturatedFat => 'Verzadigd vet';

  @override
  String get recipesDetailCarbs => 'Koolhydraten';

  @override
  String get recipesDetailProtein => 'Eiwit';

  @override
  String get recipesDetailFibers => 'Vezels';

  @override
  String get recipesDetailSalt => 'Zout';

  @override
  String get recipesDetailPersons => 'Personen';

  @override
  String get recipesDetailDifficulty => 'Moeilijkheid';

  @override
  String get recipesPrepreparation => 'Voorbereiding';

  @override
  String get recipesIngredients => 'Ingrediënten';

  @override
  String get recipesSteps => 'Bereidingsstappen';

  @override
  String get recipesKitchens => 'Keukens';

  @override
  String get recipesCourses => 'Gang';

  @override
  String get recipesRequirements => 'Benodigdheden';

  @override
  String get water => 'Water';

  @override
  String get coffee => 'Koffie';

  @override
  String get tea => 'Thee';

  @override
  String get soda => 'Frisdrank';

  @override
  String get other => 'Anders';

  @override
  String get coffeeBlack => 'Koffie zwart';

  @override
  String get espresso => 'Espresso';

  @override
  String get ristretto => 'Ristretto';

  @override
  String get lungo => 'Lungo';

  @override
  String get americano => 'Americano';

  @override
  String get coffeeWithMilk => 'Koffie met melk';

  @override
  String get coffeeWithMilkSugar => 'Koffie met melk + suiker';

  @override
  String get cappuccino => 'Cappuccino';

  @override
  String get latte => 'Latte';

  @override
  String get flatWhite => 'Flat White';

  @override
  String get macchiato => 'Macchiato';

  @override
  String get latteMacchiato => 'Latte Macchiato';

  @override
  String get icedCoffee => 'Iced Coffee';

  @override
  String get otherCoffee => 'Andere koffie';

  @override
  String get newDrinkTitle => 'Nieuw Drankje Toevoegen';

  @override
  String get chooseDrink => 'Kies een drankje';

  @override
  String get chooseCoffeeType => 'Kies koffiesoort';

  @override
  String get drinkNameLabel => 'Naam van drankje';

  @override
  String get nameRequired => 'Naam is verplicht';

  @override
  String get amountMlLabel => 'Hoeveelheid (ml)';

  @override
  String get amountRequired => 'Hoeveelheid is verplicht';

  @override
  String get enterNumber => 'Voer een getal in';

  @override
  String get kcalPer100Label => 'Kcal per 100 ml';

  @override
  String get barcodeSearchTooltip => 'Zoek op barcode';

  @override
  String get kcalRequired => 'Kcal-waarde is verplicht';

  @override
  String get addDrinkTitle => 'Drankje toevoegen';

  @override
  String get addButton => 'Toevoegen';

  @override
  String get addAndLogButton => 'Toevoegen en loggen';

  @override
  String get searchButton => 'Zoeken';

  @override
  String get scanPasteBarcode => 'Scan / plak barcode';

  @override
  String get barcodeLabel => 'Barcode (EAN/GTIN)';

  @override
  String get enterBarcode => 'Voer barcode in';

  @override
  String get searching => 'Zoeken...';

  @override
  String get noKcalFoundPrefix => 'Geen kcal-waarde gevonden voor barcode ';

  @override
  String get foundPrefix => 'Gevonden: ';

  @override
  String get kcalPer100Unit => ' kcal per 100g/ml';

  @override
  String get whenDrankTitle => 'Wanneer gedronken?';

  @override
  String get snack => 'Tussendoor';

  @override
  String get loginToLog => 'Log in om te loggen';

  @override
  String get editDrinkTitle => 'Drankje aanpassen';

  @override
  String get nameLabel => 'Naam';

  @override
  String get delete => 'Verwijderen';

  @override
  String get saveButton => 'Opslaan';

  @override
  String get added => 'toegevoegd';

  @override
  String get sportAddTitle => 'Sport toevoegen';

  @override
  String get newSportActivity => 'Nieuwe sportactiviteit';

  @override
  String get labelSport => 'Sport';

  @override
  String get chooseSport => 'Kies een sport';

  @override
  String get customSportName => 'Naam van sport';

  @override
  String get enterSportName => 'Voer een sportnaam in';

  @override
  String get durationMinutes => 'Duur (minuten)';

  @override
  String get invalidDuration => 'Voer een geldige duur in';

  @override
  String get caloriesBurned => 'Calorieën verbrand';

  @override
  String get invalidCalories => 'Voer een geldig aantal calorieën in';

  @override
  String get save => 'Opslaan';

  @override
  String get encryptionKeyNotFound => 'Encryptiesleutel niet gevonden.';

  @override
  String get noSportsYet => 'Nog geen sportactiviteiten.';

  @override
  String get durationLabel => 'Duur (minuten)';

  @override
  String get caloriesLabel => 'Calorieën';

  @override
  String get minutesShort => 'minuten';

  @override
  String get intensityLevel => 'Intensiteit';

  @override
  String get intensityLight => 'Licht';

  @override
  String get intensityNormal => 'Normaal';

  @override
  String get intensityHard => 'Zwaar';

  @override
  String get intensityVeryHard => 'Zeer zwaar';

  @override
  String get userNotLoggedIn => 'Niet ingelogd.';

  @override
  String get sportAdded => 'Sportactiviteit toegevoegd';

  @override
  String get sportRunning => 'Hardlopen';

  @override
  String get sportCycling => 'Fietsen';

  @override
  String get sportSwimming => 'Zwemmen';

  @override
  String get sportWalking => 'Wandelen';

  @override
  String get sportFitness => 'Fitness';

  @override
  String get sportFootball => 'Voetbal';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportOther => 'Overig';

  @override
  String get deleteSportTitle => 'Sportactiviteit verwijderen';

  @override
  String get deleteSportContent => 'Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get sportDeleted => 'Sportactiviteit verwijderd';

  @override
  String get editSportTitle => 'Sportactiviteit bewerken';

  @override
  String get sportUpdated => 'Sportactiviteit bijgewerkt';

  @override
  String get notLoggedIn => 'Niet ingelogd';

  @override
  String get addSportTitle => 'Sport toevoegen';

  @override
  String get sportLabel => 'Sport';

  @override
  String get customSportLabel => 'Naam van sport';

  @override
  String get customSportRequired => 'Voer een sportnaam in';

  @override
  String get logSportTitle => 'Sportactiviteit loggen';

  @override
  String get intensityHeavy => 'Zwaar';

  @override
  String get intensityVeryHeavy => 'Zeer zwaar';

  @override
  String get intensityLabel => 'Intensiteit';

  @override
  String get enterValidDuration => 'Voer een geldige duur in';

  @override
  String get caloriesBurnedLabel => 'Calorieën verbrand';

  @override
  String get enterValidCalories => 'Voer een geldig aantal calorieën in';

  @override
  String get durationShort => 'Duur:';

  @override
  String get caloriesShort => 'Calorieën:';

  @override
  String get saveSportFailedPrefix => 'Opslaan mislukt:';

  @override
  String get unsavedChangesContent => 'Je hebt niet-opgeslagen wijzigingen. Weet je zeker dat je deze wilt negeren?';

  @override
  String get searchFood => 'Voedsel zoeken';

  @override
  String get searchFoodDescription => 'Zoek naar voedsel om toe te voegen aan je dagelijkse log.';

  @override
  String get scanProduct => 'Product scannen';

  @override
  String get scanProductDescription => 'Scan een product om snel voedingsinformatie toe te voegen aan je dag.';

  @override
  String get recentProducts => 'Recente Producten';

  @override
  String get recentProductsDescription => 'Bekijk en voeg snel producten toe die je recent hebt gebruikt.';

  @override
  String get favoriteProducts => 'Favoriete Producten';

  @override
  String get favoriteProductsDescription => 'Hier kan je al je favorieten producten bekijken.';

  @override
  String get myProducts => 'Mijn Producten';

  @override
  String get myProductsDescription => 'Hier kan je zelf producten toevoegen die niet gevonden kunnen worden.';

  @override
  String get meals => 'Maaltijden';

  @override
  String get mealsDescription => 'Hier kan je maaltijden zien en loggen, maaltijden bestaan uit meerdere producten.';

  @override
  String get mealsAdd => 'Maaltijden toevoegen';

  @override
  String get mealsAddDescription => 'Tik op dit plusje om maaltijden te maken uit meerdere producten, zodat je sneller vaak gegeten maaltijden kan toevoegen.';

  @override
  String get mealsLog => 'Maaltijden loggen';

  @override
  String get mealsLogDescription => 'Tik op dit winkelwagentje om maaltijden toe te voegen aan de logs.';

  @override
  String get enterMoreChars => 'Voer minimaal 2 tekens in.';

  @override
  String get errorFetch => 'Fout bij ophalen';

  @override
  String get takePhoto => 'Maak een foto';

  @override
  String get chooseFromGallery => 'Kies uit galerij';

  @override
  String get noImageSelected => 'Geen afbeelding geselecteerd.';

  @override
  String get aiNoIngredientsFound => 'Geen resultaat van AI.';

  @override
  String aiIngredientsPrompt(Object ingredient) {
    return 'Wat voor ingrediënten zie je hier? Antwoord in het Nederlands. Negeer marketingtermen, productnamen, en niet-relevante woorden zoals \'zero\', \'light\', etc. Antwoord alleen met daadwerkelijke ingrediënten die in het product zitten. Antwoord alleen als het plaatje een voedselproduct toont. Antwoord als: $ingredient, $ingredient, ...';
  }

  @override
  String get aiIngredientsFound => 'Gevonden ingrediënten:';

  @override
  String get aiIngredientsDescription => 'De AI heeft de volgende ingrediënten herkend:';

  @override
  String get addMeal => 'Maaltijd samenstellen';

  @override
  String get errorAI => 'Fout bij AI-analyse:';

  @override
  String get amount => 'Hoeveelheid';

  @override
  String get search => 'Zoek';

  @override
  String get loadMore => 'Meer producten laden...';

  @override
  String get errorNoBarcode => 'Geen barcode gevonden voor dit product.';

  @override
  String get amountInGrams => 'Hoeveelheid (g)';

  @override
  String get errorUserDEKMissing => 'Kon encryptiesleutel niet ophalen.';

  @override
  String get errorNoIngredientsAdded => 'Voeg minimaal één product toe.';

  @override
  String get mealSavedSuccessfully => 'Maaltijd opgeslagen!';

  @override
  String get saveMeal => 'Maaltijd opslaan';

  @override
  String get errorFetchRecentsProducts => 'Fout bij ophalen recente producten';

  @override
  String get searchProducts => 'Zoek producten...';

  @override
  String get add => 'Toevoegen';

  @override
  String get addFoodItem => 'Wat wil je toevoegen?';

  @override
  String get addProduct => 'Product toevoegen';

  @override
  String get addMealT => 'Maaltijd toevoegen';

  @override
  String get recents => 'Recent';

  @override
  String get favorites => 'Favorieten';

  @override
  String get searchingProducts => 'Begin met typen om te zoeken.';

  @override
  String get noProductsFound => 'Geen producten gevonden.';

  @override
  String get addNewProduct => 'Wilt u zelf een product toevoegen?';

  @override
  String get errorInvalidBarcode => 'Geen barcode gevonden voor dit product.';

  @override
  String get loadMoreResults => 'Meer producten laden…';

  @override
  String get notTheDesiredResults => 'Voeg een nieuw product toe';

  @override
  String get addNewProductT => 'Nieuw Product Toevoegen';

  @override
  String get errorProductNameRequired => 'Naam is verplicht';

  @override
  String get brandName => 'Merk';

  @override
  String get quantity => 'Hoeveelheid (bijv. 100g, 250ml)';

  @override
  String get nutritionalValuesPer100g => 'Voedingswaarden per 100g of ml';

  @override
  String get calories => 'Energie (kcal)';

  @override
  String get errorCaloriesRequired => 'Calorieën zijn verplicht';

  @override
  String get fat => 'Vetten';

  @override
  String get saturatedFat => '  - Waarvan verzadigd';

  @override
  String get carbohydrates => 'Koolhydraten';

  @override
  String get sugars => '  - Waarvan suikers';

  @override
  String get fiber => 'Vezels';

  @override
  String get proteins => 'Eiwitten';

  @override
  String get salt => 'Zout';

  @override
  String get errorEncryptionKeyMissing => 'Fout: Kon encryptiesleutel niet ophalen.';

  @override
  String get saveProduct => 'Opslaan';

  @override
  String get unknown => 'Onbekend';

  @override
  String get unnamedProduct => 'Onbekende naam';

  @override
  String get logInToSeeRecents => 'Log in om je recente producten te zien.';

  @override
  String get noRecentProductsFound => 'Geen recente producten gevonden.';

  @override
  String get errorLoadingRecentProducts => 'Er is een fout opgetreden.';

  @override
  String get logInToSeeFavorites => 'Log in om je favoriete producten te zien.';

  @override
  String get noFavoriteProductsFound => 'Geen favoriete producten gevonden.';

  @override
  String get errorLoadingFavoriteProducts => 'Er is een fout opgetreden.';

  @override
  String get logInToSeeMyProducts => 'Log in om je producten te zien.';

  @override
  String get noMyProductsFound => 'Je hebt nog geen producten aangemaakt.';

  @override
  String get errorLoadingMyProducts => 'Er is een fout opgetreden.';

  @override
  String get unknownBrand => 'Geen merk';

  @override
  String get confirmDeletion => 'Bevestig verwijdering';

  @override
  String get sure => 'Weet je zeker dat je ';

  @override
  String get willBeDeleted => ' wilt verwijderen?';

  @override
  String get deleted => 'verwijderd';

  @override
  String get logInToSeeMeals => 'Log in om je maaltijden te zien.';

  @override
  String get errorLoadingMeals => 'Er is een fout opgetreden.';

  @override
  String get mealExample => 'Voorbeeld Maaltijd';

  @override
  String get createOwnMealsFirst => 'Klik op + om je eerste maaltijd te maken';

  @override
  String get logMeal => 'Log maaltijd';

  @override
  String get createMealsBeforeLogging => 'Dit is een voorbeeld. Maak eerst een eigen maaltijd aan.';

  @override
  String get unnamedMeal => 'Onbekende maaltijd';

  @override
  String get sureMeal => 'Weet je zeker dat je maaltijd ';

  @override
  String get meal => 'Maaltijd ';

  @override
  String get encryptionKeyError => 'Kon encryptiesleutel niet ophalen.';

  @override
  String get mealNoIngredients => 'Deze maaltijd heeft geen ingrediënten.';

  @override
  String get mealLoggedSuccessfully => ' toegevoegd aan je logboek.';

  @override
  String get errorSaveMeal => 'Fout bij opslaan van maaltijd:';

  @override
  String get sectie => 'Sectie';

  @override
  String get log => 'Log';

  @override
  String get mealAddAtLeastOneIngredient => 'Voeg minimaal één product toe.';

  @override
  String get editMeal => 'Maaltijd bewerken';

  @override
  String get addNewMeal => 'Nieuwe maaltijd samenstellen';

  @override
  String get mealName => 'Naam van maaltijd';

  @override
  String get pleaseEnterMealName => 'Naam is verplicht';

  @override
  String get ingredients => 'Ingrediënten';

  @override
  String get searchProductHint => 'Typ om te zoeken of scan barcode';

  @override
  String get selectProduct => 'Kies product';

  @override
  String get scanBarcode => 'Scan barcode voor dit product';

  @override
  String get searchForBarcode => 'Zoeken op barcode...';

  @override
  String get errorFetchingProductData => 'Product niet gevonden op OpenFoodFacts';

  @override
  String get productNotFound => 'Geen productgegevens gevonden';

  @override
  String get errorBarcodeFind => 'Fout bij barcode-zoekactie: ';

  @override
  String get errorFetchingProductDataBarcode => 'Geen barcode gevonden voor dit product.';

  @override
  String get addIngredient => 'Voeg nog een product toe';

  @override
  String get editMyProduct => 'Product Bewerken';

  @override
  String get productName => 'Productnaam';

  @override
  String get productNameRequired => 'Naam is verplicht';

  @override
  String get caloriesRequired => 'Calorieën zijn verplicht';

  @override
  String get errorUserDEKNotFound => 'Kon encryptiesleutel niet ophalen.';

  @override
  String get unknownProduct => 'Onbekend Product';

  @override
  String get brand => 'Merk';

  @override
  String get servingSize => 'Portiegrootte';

  @override
  String get nutritionalValuesPer100mlg => 'Voedingswaarden per 100g/ml';

  @override
  String get saveMyProduct => 'Mijn Product Opslaan';

  @override
  String get amountFor => 'Hoeveelheid voor ';

  @override
  String get amountGML => 'Hoeveelheid (gram of milliliter)';

  @override
  String get gramsMillilitersAbbreviation => 'g/ml';

  @override
  String get invalidAmount => 'Voer een geldige hoeveelheid in.';

  @override
  String get addedToLog => ' toegevoegd aan je logboek.';

  @override
  String get errorSaving => 'Fout bij opslaan: ';

  @override
  String get photoAnalyzing => 'Foto analyseren...';

  @override
  String get ingredientsIdentifying => 'Ingrediënten identificeren...';

  @override
  String get nutritionalValuesEstimating => 'Voedingsinformatie schatten...';

  @override
  String get patientlyWaiting => 'Even geduld a.u.b...';

  @override
  String get almostDone => 'Bijna klaar...';

  @override
  String get processingWithAI => 'Bezig met AI-verwerking...';

  @override
  String get selectMealType => 'Selecteer maaltijdtype';

  @override
  String get section => 'Sectie';

  @override
  String get saveNameTooltip => 'Opslaan';

  @override
  String get noChangesTooltip => 'Geen wijzigingen';

  @override
  String get fillRequiredKcal => 'Vul alle verplichte velden in (kcal).';

  @override
  String get additivesLabel => 'Additieven';

  @override
  String get allergensLabel => 'Allergenen';

  @override
  String get mealAmountLabel => 'Hoeveelheid voor maaltijd';

  @override
  String get addToMealButton => 'Voeg toe aan maaltijd';

  @override
  String get enterAmount => 'Voer een hoeveelheid in';

  @override
  String get unitLabel => 'Eenheid';

  @override
  String get gramLabel => 'Gram (g)';

  @override
  String get milliliterLabel => 'Milliliter (ml)';

  @override
  String get errorLoadingLocal => 'Fout bij laden lokale gegevens: ';

  @override
  String get errorFetching => 'Fout bij ophalen: ';

  @override
  String get nameSaved => 'Naam opgeslagen';

  @override
  String get enterValue => 'Waarde mist';

  @override
  String get requiredField => 'Verplicht veld';

  @override
  String get invalidNumber => 'Ongeldig nummer';

  @override
  String get today => 'Vandaag';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get done => 'Gereed';

  @override
  String get logs => 'Logs';

  @override
  String get add_food_label => 'Voedsel toevoegen';

  @override
  String get add_drink_label => 'Drankje toevoegen';

  @override
  String get add_sport_label => 'Sport toevoegen';

  @override
  String get tutorial_date_title => 'Datum wisselen';

  @override
  String get tutorial_date_text => 'Tik hier om een datum te kiezen of snel naar vandaag te springen.';

  @override
  String get tutorial_barcode_title => 'Barcode scannen';

  @override
  String get tutorial_barcode_text => 'Tik hier om een product te scannen en snel toe te voegen aan je dag.';

  @override
  String get tutorial_settings_title => 'Instellingen';

  @override
  String get tutorial_settings_text => 'Deze pagina is om je gegevens aan te passen, de tijd van de meldingen of andere instellingen te wijzigen';

  @override
  String get tutorial_feedback_title => 'Feedback';

  @override
  String get tutorial_feedback_text => 'Hier kun je feedback geven over de app. Werkt iets niet of iets wat je graaf nog wilt zien in de app? We horen het graag van je!';

  @override
  String get tutorial_calorie_title => 'Calorieën overzicht';

  @override
  String get tutorial_calorie_text => 'Hier zie je een samenvatting van je calorie-inname voor de dag.';

  @override
  String get tutorial_mascot_title => 'Reppy';

  @override
  String get tutorial_mascot_text => 'Reppy geeft persoonlijke motivatie en tips!';

  @override
  String get tutorial_water_title => 'Drinken';

  @override
  String get tutorial_water_text => 'Houd hier bij hoeveel je per dag drinkt. De cirkel laat zien hoeveel je nog moet drinken om je doel te bereiken.';

  @override
  String get tutorial_additems_title => 'Items toevoegen';

  @override
  String get tutorial_additems_text => 'Gebruik deze knop om snel maaltijden, drankjes of sport toe te voegen.';

  @override
  String get tutorial_meals_title => 'Maaltijden';

  @override
  String get tutorial_meals_text => 'Bekijk je maaltijden en wijzig ze door erop te tikken.';

  @override
  String get updateAvailable => 'Er is een nieuwe update uit! Update de app via testFlight voor Apple of via Google Play Store voor Android.';

  @override
  String get announcement_default => 'Mededeling';

  @override
  String get water_goal_dialog_title => 'Waterdoel instellen';

  @override
  String get water_goal_dialog_label => 'Doel (ml)';

  @override
  String get enter_valid_number => 'Voer een geldig getal in';

  @override
  String get water_goal_updated => 'Waterdoel bijgewerkt';

  @override
  String get error_saving_water_goal => 'Fout bij opslaan waterdoel: ';

  @override
  String get calorie_goal_dialog_title => 'Caloriedoel instellen';

  @override
  String get calorie_goal_dialog_label => 'Dagelijks doel (kcal)';

  @override
  String get calorie_goal_updated => 'Calorieëndoel bijgewerkt';

  @override
  String get error_saving_prefix => 'Opslaan mislukt: ';

  @override
  String get eaten => 'Genoten';

  @override
  String get remaining => 'Resterend';

  @override
  String get over_goal => 'Boven doel';

  @override
  String get calories_over_goal => 'kcal boven doel';

  @override
  String get calories_remaining => 'kcal resterend';

  @override
  String get calories_consumed => 'kcal geconsumeerd';

  @override
  String get carbs => 'Koolhydraten';

  @override
  String get fats => 'Vetten';

  @override
  String get unit => 'Eenheid';

  @override
  String get edit_amount_dialog_title_ml => 'Hoeveelheid aanpassen (ml)';

  @override
  String get edit_amount_dialog_title_g => 'Hoeveelheid aanpassen (g)';

  @override
  String get edit_amount_label_ml => 'Hoeveelheid (ml)';

  @override
  String get edit_amount_label_g => 'Hoeveelheid (g)';

  @override
  String get totalConsumed => 'Totaal inname';

  @override
  String get youHave => 'Je hebt';

  @override
  String get motivational_default_1 => 'Goed bezig, ga zo door!';

  @override
  String get motivational_default_2 => 'Als je op mij tikt krijg je een nieuw tekstje!';

  @override
  String get motivational_default_3 => 'Elke stap telt!';

  @override
  String get motivational_default_4 => 'Je doet het geweldig!';

  @override
  String get motivational_default_5 => 'Wist je dat fFinder een afkorting is voor FoodFinder?';

  @override
  String get motivational_default_6 => 'Je logt beter dan 97% van de mensen... waarschijnlijk.';

  @override
  String get motivational_noEntries_1 => 'Klaar om je dag te loggen?';

  @override
  String get motivational_noEntries_2 => 'Een nieuwe dag, nieuwe kansen!';

  @override
  String get motivational_noEntries_3 => 'Laten we beginnen!';

  @override
  String get motivational_noEntries_4 => 'Elke gezonde dag start met één invoer.';

  @override
  String get motivational_noEntries_5 => 'Je eerste maaltijd zit verstopt. Zoek hem even op!';

  @override
  String get motivational_drinksOnly_1 => 'Goed dat je al drinken hebt gelogd! Wat wordt je eerste maaltijd?';

  @override
  String get motivational_drinksOnly_2 => 'Hydratatie is een goed begin. Tijd om ook wat te eten.';

  @override
  String get motivational_drinksOnly_3 => 'Lekker bezig! Wat wordt je eerste hapje?';

  @override
  String get motivational_overGoal_1 => 'Doel bereikt! Rustig aan nu.';

  @override
  String get motivational_overGoal_2 => 'Wow, je zit boven je doel!';

  @override
  String get motivational_overGoal_3 => 'Goed bezig, morgen weer een dag.';

  @override
  String get motivational_overGoal_4 => 'Goed bezig vandaag, echt waar!';

  @override
  String get motivational_almostGoal_1 => 'Je bent er bijna!';

  @override
  String get motivational_almostGoal_2 => 'Nog een klein stukje te gaan!';

  @override
  String get motivational_almostGoal_3 => 'Bijna je caloriedoel bereikt!';

  @override
  String get motivational_almostGoal_4 => 'Goed bezig! Let op de laatste stap.';

  @override
  String get motivational_almostGoal_5 => 'Je doet het fantastisch, bijna daar!';

  @override
  String get motivational_belowHalf_1 => 'Je bent goed op weg, ga zo door!';

  @override
  String get motivational_belowHalf_2 => 'De eerste helft zit erop, houd de focus!';

  @override
  String get motivational_belowHalf_3 => 'Blijf je maaltijden en drankjes loggen.';

  @override
  String get motivational_belowHalf_4 => 'Je doet het geweldig, blijf volhouden!';

  @override
  String get motivational_lowWater_1 => 'Vergeet niet te drinken vandaag!';

  @override
  String get motivational_lowWater_2 => 'Een slokje water is een goed begin.';

  @override
  String get motivational_lowWater_3 => 'Warm of koud, water is altijd goed!';

  @override
  String get motivational_lowWater_4 => 'Hydratatie is belangrijk!';

  @override
  String get motivational_lowWater_5 => 'Een glas water kan wonderen doen.';

  @override
  String get motivational_lowWater_6 => 'Even pauze? Drink een beetje water.';

  @override
  String get entry_updated => 'Hoeveelheid bijgewerkt';

  @override
  String get errorUpdatingEntry => 'Fout bij bijwerken hoeveelheid: ';

  @override
  String get errorLoadingData => 'Fout bij laden gegevens: ';

  @override
  String get not_logged_in => 'Niet ingelogd';

  @override
  String get noEntriesForDate => 'Geen logs voor deze datum.';

  @override
  String get thinking => 'Even nadenken...';

  @override
  String get sports => 'Sportactiviteiten';

  @override
  String get totalBurned => 'Totaal verbrand: ';

  @override
  String get unknownSport => 'Onbekende sport';

  @override
  String get errorDeletingSport => 'Fout bij verwijderen sportactiviteit: ';

  @override
  String get errorDeleting => 'Fout bij verwijderen: ';

  @override
  String get errorCalculating => 'Fout: Originele productgegevens zijn onvolledig om te herberekenen.';
}
