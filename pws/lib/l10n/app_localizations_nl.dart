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
  String get dinner => 'Diner';

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
}
