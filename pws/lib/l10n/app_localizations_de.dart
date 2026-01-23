// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get recipesTitle => 'Rezepte';

  @override
  String get recipesSubtitle => 'Finden und verwalten Sie Ihre Lieblingsrezepte';

  @override
  String get encryptionKeyLoadError => 'Verschlüsselungsschlüssel konnte nicht geladen werden.';

  @override
  String get encryptionKeyLoadSaveError => 'Verschlüsselungsschlüssel konnte zum Speichern nicht geladen werden.';

  @override
  String get encryptedJson => 'Verschlüsseltes JSON (nonce/cipher/tag)';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get mealNotifications => 'Mahlzeiterinnerungen';

  @override
  String get enableMealNotifications => 'Erinnerungen aktivieren';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get enableGifs => 'Maskottchen-Animation (GIF) anzeigen';

  @override
  String get restartTutorial => 'Tutorial neu starten';

  @override
  String get personalInfo => 'Persönliche Daten';

  @override
  String get personalInfoDescription => 'Passen Sie Ihr Gewicht, Ihre Körpergröße, Ihr Ziel und Ihre Aktivität an.';

  @override
  String get currentWeightKg => 'Aktuelles Gewicht (kg)';

  @override
  String get enterCurrentWeight => 'Geben Sie Ihr aktuelles Gewicht ein';

  @override
  String get enterValidWeight => 'Geben Sie ein gültiges Gewicht ein';

  @override
  String get heightCm => 'Größe (cm)';

  @override
  String get enterHeight => 'Geben Sie Ihre Größe ein';

  @override
  String get enterHeightBetween100And250 => 'Geben Sie eine Größe zwischen 100 und 250 cm ein';

  @override
  String get waistCircumferenceCm => 'Taillenumfang (cm)';

  @override
  String get targetWeightKg => 'Zielgewicht (kg)';

  @override
  String get enterTargetWeight => 'Geben Sie Ihr Zielgewicht ein';

  @override
  String get enterValidTargetWeight => 'Geben Sie ein gültiges Zielgewicht ein';

  @override
  String get sleepHoursPerNight => 'Schlaf (Stunden pro Nacht)';

  @override
  String get hours => 'Stunden';

  @override
  String get activityLevel => 'Aktivitätsniveau';

  @override
  String get goal => 'Ziel';

  @override
  String get savingSettings => 'Speichern...';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get adminAnnouncements => 'Admin-Aktionen';

  @override
  String get createAnnouncement => 'Neue Nachricht erstellen';

  @override
  String get createAnnouncementSubtitle => 'Veröffentlichen Sie eine Nachricht für alle Benutzer';

  @override
  String get manageAnnouncements => 'Nachrichten verwalten';

  @override
  String get manageAnnouncementsSubtitle => 'Nachrichten anzeigen, deaktivieren oder löschen';

  @override
  String get decryptValues => 'Entschlüsseln';

  @override
  String get decryptValuesSubtitle => 'Werte für den Benutzer entschlüsseln, falls dieser sein Konto übertragen möchte.';

  @override
  String get account => 'Konto';

  @override
  String get signOut => 'Abmelden';

  @override
  String get deletingAccount => 'Konto wird gelöscht...';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get credits => 'Credits';

  @override
  String get creditsAbsiDataAttribution => 'Dieses Datenset wird verwendet, um ABSI-Z-Scores und -Kategorien in dieser App zu berechnen.';

  @override
  String get absiAttribution => 'Die Referenztabelle des Body Shape Index (ABSI) basiert auf:\n\nY. Krakauer, Nir; C. Krakauer, Jesse (2015).\nTable S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\nPLOS ONE. Dataset.\nhttps://doi.org/10.1371/journal.pone.0039504.s001\n\nDieses Datenset wird verwendet, um ABSI-Z-Scores und -Kategorien in dieser App zu berechnen.';

  @override
  String get date => 'Datum';

  @override
  String get close => 'Schließen';

  @override
  String get editAnnouncement => 'Nachricht bearbeiten';

  @override
  String get title => 'Titel';

  @override
  String get titleCannotBeEmpty => 'Der Titel darf nicht leer sein.';

  @override
  String get message => 'Nachricht';

  @override
  String get messageCannotBeEmpty => 'Die Nachricht darf nicht leer sein.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get announcementUpdated => 'Nachricht aktualisiert.';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get announcementDeleted => 'Nachricht gelöscht.';

  @override
  String get errorLoadingAnnouncements => 'Ein Fehler ist aufgetreten.';

  @override
  String get noAnnouncementsFound => 'Keine Nachrichten gefunden.';

  @override
  String get unknownDate => 'Unbekanntes Datum';

  @override
  String get createdAt => 'Erstellt am';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get activate => 'Aktivieren';

  @override
  String get deactivate => 'Deaktivieren';

  @override
  String get editAnnouncementTooltip => 'Nachricht bearbeiten';

  @override
  String get language => 'Sprache';

  @override
  String get useSystemLocale => 'Systemsprache verwenden';

  @override
  String get activityLow => 'Wenig aktiv: sitzende Tätigkeit, kaum Bewegung, kein Sport';

  @override
  String get activityLight => 'Leicht aktiv: 1–3x pro Woche leichtes Training oder täglich 30–45 Min. Spaziergang';

  @override
  String get activityMedium => 'Mäßig aktiv: 3–5x pro Woche Sport oder ein aktiver Beruf (Gastronomie, Pflege, Postbote)';

  @override
  String get activityVery => 'Sehr aktiv: 6–7x pro Woche intensives Training oder körperlich schwere Arbeit (Bau, Lager)';

  @override
  String get activityExtreme => 'Extrem aktiv: Leistungssporttraining 2× täglich oder extrem körperlich anspruchsvolle Arbeit (Militär, Forstwirtschaft)';

  @override
  String get goalLose => 'Abnehmen';

  @override
  String get goalMaintain => 'Gewicht halten';

  @override
  String get goalGainMuscle => 'Zunehmen (Muskelmasse)';

  @override
  String get goalGainGeneral => 'Zunehmen (allgemein)';

  @override
  String get createAnnouncementTitle => 'Neue Nachricht veröffentlichen';

  @override
  String get messageLabel => 'Nachricht';

  @override
  String get messageValidationError => 'Die Nachricht darf nicht leer sein.';

  @override
  String get announcementPublishedSuccess => 'Nachricht erfolgreich veröffentlicht!';

  @override
  String get publishButtonLabel => 'Veröffentlichen';

  @override
  String get unsavedChangesTitle => 'Nicht gespeicherte Änderungen';

  @override
  String get unsavedChangesMessage => 'Sie haben Änderungen vorgenommen, die noch nicht gespeichert sind. Sind Sie sicher, dass Sie ohne Speichern schließen möchten?';

  @override
  String get discardButtonLabel => 'Änderungen verwerfen';

  @override
  String get cancelButtonLabel => 'Abbrechen';

  @override
  String get unknownUser => 'Unbekannter Benutzer';

  @override
  String get tutorialRestartedMessage => 'Das Tutorial wurde neu gestartet!';

  @override
  String get deleteAnnouncementTooltip => 'Löschen';

  @override
  String get duplicateRequestError => 'Für diesen Wert existiert bereits eine offene Anfrage.';

  @override
  String get requestSubmittedSuccess => 'Entschlüsselungsanfrage zur Genehmigung eingereicht.';

  @override
  String get requestSubmissionFailed => 'Einreichen der Anfrage fehlgeschlagen';

  @override
  String get requestNotFound => 'Anfrage nicht gefunden';

  @override
  String get cannotApproveOwnRequest => 'Sie können Ihre eigene Anfrage nicht genehmigen.';

  @override
  String get dekNotFoundForUser => 'Verschlüsselungsschlüssel konnte nicht abgerufen werden.';

  @override
  String get requestApprovedSuccess => 'Anfrage genehmigt.';

  @override
  String get requestApprovalFailed => 'Genehmigung fehlgeschlagen';

  @override
  String get cannotRejectOwnRequest => 'Sie können Ihre eigene Anfrage nicht ablehnen.';

  @override
  String get requestRejectedSuccess => 'Anfrage abgelehnt.';

  @override
  String get requestRejectionFailed => 'Ablehnung fehlgeschlagen';

  @override
  String get pleaseEnterUid => 'Bitte geben Sie eine UID ein';

  @override
  String get pleaseEnterEncryptedJson => 'Fügen Sie das verschlüsselte JSON ein';

  @override
  String get submit => 'Absenden';

  @override
  String get submitRequest => 'Anfrage absenden';

  @override
  String get loading => 'Lädt...';

  @override
  String get pendingRequests => 'Offene Anfragen';

  @override
  String get noPendingRequests => 'Keine Anfragen gefunden.';

  @override
  String get forUid => 'Für UID';

  @override
  String get requestedBy => 'Angefragt von';

  @override
  String get encryptedJsonLabel => 'Verschlüsselter Wert:';

  @override
  String get reject => 'Ablehnen';

  @override
  String get approve => 'Genehmigen';

  @override
  String get confirmSignOutTitle => 'Abmelden';

  @override
  String get confirmSignOutMessage => 'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get confirmDeleteAccountTitle => 'Konto löschen';

  @override
  String get confirmDeleteAccountMessage => 'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deletionCodeInstruction => 'Geben Sie den folgenden Code zur Bestätigung ein:';

  @override
  String get enterDeletionCodeLabel => 'Geben Sie den 6-stelligen Code ein';

  @override
  String get deletionCodeMismatchError => 'Code stimmt nicht überein, bitte versuchen Sie es erneut.';

  @override
  String get deleteAccountButtonLabel => 'Löschen';

  @override
  String get settingsSavedSuccessMessage => 'Einstellungen gespeichert';

  @override
  String get settingsSaveFailedMessage => 'Speichern fehlgeschlagen';

  @override
  String get profileLoadFailedMessage => 'Profil konnte nicht geladen werden';

  @override
  String get deleteAccountRecentLoginError => 'Melden Sie sich erneut an und versuchen Sie es erneut, um Ihr Konto zu löschen.';

  @override
  String get deleteAccountFailedMessage => 'Löschen fehlgeschlagen';

  @override
  String get titleLabel => 'Titel';

  @override
  String get titleValidationError => 'Der Titel darf nicht leer sein.';

  @override
  String get untitled => 'Ohne Titel';

  @override
  String get appCredits => 'ABSI Datenzuordnung';

  @override
  String get reportThanks => 'Danke für Ihren Bericht!';

  @override
  String get errorSending => 'Fehler beim Senden';

  @override
  String get commentOptional => 'Kommentar (optional)';

  @override
  String get reportTitle => 'Elemente melden';

  @override
  String get categoryFunctionality => 'Funktionalität';

  @override
  String get itemFeatures => 'Funktionen';

  @override
  String get itemFunctionality => 'Funktionalität';

  @override
  String get itemUsability => 'Benutzerfreundlichkeit';

  @override
  String get itemClarity => 'Übersichtlichkeit';

  @override
  String get itemAccuracy => 'Genauigkeit';

  @override
  String get itemNavigation => 'Navigation';

  @override
  String get categoryPerformance => 'Leistung';

  @override
  String get itemSpeed => 'Geschwindigkeit';

  @override
  String get itemLoadingTimes => 'Ladezeiten';

  @override
  String get itemStability => 'Stabilität';

  @override
  String get categoryInterfaceDesign => 'Schnittstelle & Design';

  @override
  String get itemLayout => 'Layout';

  @override
  String get itemColorsTheme => 'Farben & Thema';

  @override
  String get itemIconsDesign => 'Symbole & Design';

  @override
  String get itemReadability => 'Lesbarkeit';

  @override
  String get categoryCommunication => 'Kommunikation';

  @override
  String get itemErrors => 'Fehlermeldungen';

  @override
  String get itemExplanation => 'Erklärungen & Anweisungen';

  @override
  String get categoryAppParts => 'App-Teile';

  @override
  String get itemDashboard => 'Dashboard';

  @override
  String get itemLogin => 'Anmeldung / Registrierung';

  @override
  String get itemWeight => 'Gewicht';

  @override
  String get itemStatistics => 'Statistiken';

  @override
  String get itemCalendar => 'Kalender';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get itemGeneralSatisfaction => 'Allgemeine Zufriedenheit';

  @override
  String get send => 'Senden';

  @override
  String get feedbackTitle => 'Geben Sie Ihr Feedback';

  @override
  String get viewAllFeedback => 'Alle Rückmeldungen ansehen';

  @override
  String get viewAllRapportFeedback => 'Alle Berichtsrückmeldungen ansehen';

  @override
  String get openRapportButton => 'Tippen Sie, um den Bericht auszufüllen!\nHinweis: Dies ist ein ausführlicher Fragebogen. Füllen Sie ihn nur aus, wenn Sie die App mehrere Tage gründlich getestet haben.';

  @override
  String get feedbackIntro => 'Hier können Sie jederzeit Ihr Feedback geben.';

  @override
  String get choiceBug => 'Fehler';

  @override
  String get choiceFeature => 'Neue Funktion';

  @override
  String get choiceLanguage => 'Sprache';

  @override
  String get choiceLayout => 'Layout';

  @override
  String get choiceOther => 'Andere';

  @override
  String get languageSectionInstruction => 'Geben Sie an, welche Sprache betroffen ist, und beschreiben Sie den Fehler. Die Standardsprache ist die in der App ausgewählte Sprache.';

  @override
  String get dropdownLabelLanguage => 'Sprache, auf die sich das Feedback bezieht';

  @override
  String get messageHint => 'Was möchten Sie uns mitteilen?';

  @override
  String get enterMessage => 'Geben Sie eine Nachricht ein';

  @override
  String get emailHintOptional => 'E-Mail (optional)';

  @override
  String get allFeedbackTitle => 'Alle Rückmeldungen';

  @override
  String get noFeedbackFound => 'Keine Rückmeldungen gefunden.';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten.';

  @override
  String get noMessage => 'Keine Nachricht';

  @override
  String get unknownType => 'Unbekannt';

  @override
  String get appLanguagePrefix => 'App: ';

  @override
  String get reportedLanguagePrefix => 'Gemeldet: ';

  @override
  String get submittedOnPrefix => 'Eingereicht am: ';

  @override
  String get uidLabelPrefix => 'UID: ';

  @override
  String get couldNotOpenMailAppPrefix => 'Mail-App konnte nicht geöffnet werden: ';

  @override
  String get allRapportFeedbackTitle => 'Alle Berichtsrückmeldungen';

  @override
  String get noRapportFeedbackFound => 'Keine Berichtsrückmeldungen gefunden.';

  @override
  String get rapportFeedbackTitle => 'Berichtsrückmeldungen';

  @override
  String get weightTitle => 'Ihr Gewicht';

  @override
  String get weightSubtitle => 'Passen Sie Ihr Gewicht an und sehen Sie Ihren BMI ein.';

  @override
  String get weightLabel => 'Gewicht (kg)';

  @override
  String get targetWeightLabel => 'Zielgewicht (kg)';

  @override
  String get weightSliderLabel => 'Gewichts-Slider';

  @override
  String get saving => 'Speichern...';

  @override
  String get saveWeight => 'Gewicht speichern';

  @override
  String get saveWaist => 'Taillenumfang speichern';

  @override
  String get saveSuccess => 'Gewicht + Ziele gespeichert';

  @override
  String get saveFailedPrefix => 'Speichern fehlgeschlagen:';

  @override
  String get weightLoadErrorPrefix => 'Benutzerdaten konnten nicht geladen werden:';

  @override
  String get bmiTitle => 'BMI';

  @override
  String get bmiInsufficient => 'Nicht genügend Daten, um den BMI zu berechnen. Bitte geben Sie Ihre Größe und Ihr Gewicht ein.';

  @override
  String get yourBmiPrefix => 'Ihr BMI:';

  @override
  String get waistAbsiTitle => 'Taillenumfang / ABSI';

  @override
  String get waistLabel => 'Taillenumfang (cm)';

  @override
  String get absiInsufficient => 'Nicht genügend Daten, um ABSI zu berechnen. Bitte geben Sie Taillenumfang, Größe und Gewicht ein.';

  @override
  String get yourAbsiPrefix => 'Ihr ABSI:';

  @override
  String get absiLowRisk => 'Geringes Risiko';

  @override
  String get absiMedium => 'Mittleres Risiko';

  @override
  String get choiceWeight => 'Gewicht';

  @override
  String get choiceWaist => 'Taille';

  @override
  String get choiceTable => 'Tabelle';

  @override
  String get choiceChart => 'Diagramm (pro Monat)';

  @override
  String get noMeasurements => 'Noch keine Messungen gespeichert.';

  @override
  String get noWaistMeasurements => 'Noch keine Taillenmessungen gespeichert.';

  @override
  String get tableMeasurementsTitle => 'Messungstabelle';

  @override
  String get deleteConfirmTitle => 'Löschen?';

  @override
  String get deleteConfirmContent => 'Sind Sie sicher, dass Sie diese Messung löschen möchten?';

  @override
  String get deleteConfirmDelete => 'Löschen';

  @override
  String get measurementDeleted => 'Messung gelöscht';

  @override
  String get chartTitlePrefix => 'Diagramm –';

  @override
  String get chartTooFew => 'Zu wenige Messungen in diesem Monat für ein Diagramm.';

  @override
  String get chartAxesLabel => 'Horizontal: Tage des Monats, Vertikal: Wert';

  @override
  String get estimateNotEnoughData => 'Nicht genug Daten, um einen Trend zu berechnen.';

  @override
  String get estimateOnTarget => 'Gut gemacht! Sie sind auf Ihrem Zielgewicht.';

  @override
  String get estimateNoTrend => 'Noch kein Trend zu berechnen.';

  @override
  String get estimateStable => 'Ihr Gewicht ist relativ stabil, kein verlässlicher Trend.';

  @override
  String get estimateWrongDirection => 'Mit dem aktuellen Trend bewegen Sie sich vom Zielgewicht weg.';

  @override
  String get estimateInsufficientInfo => 'Es gibt nicht genügend Trendinformationen, um eine realistische Schätzung vorzunehmen.';

  @override
  String get estimateUnlikelyWithin10Years => 'Aufgrund des aktuellen Trends ist es unwahrscheinlich, dass Sie Ihr Zielgewicht innerhalb von 10 Jahren erreichen.';

  @override
  String get estimateUncertaintyHigh => 'Achtung: Große Schwankungen machen diese Schätzung unzuverlässig.';

  @override
  String get estimateUncertaintyMedium => 'Achtung: Starke Schwankungen machen diese Schätzung unsicher.';

  @override
  String get estimateUncertaintyLow => 'Hinweis: Leichte Schwankungen — die Schätzung kann abweichen.';

  @override
  String get estimateBasisRecent => 'basierend auf dem letzten Monat';

  @override
  String get estimateBasisAll => 'basierend auf allen Messungen';

  @override
  String get estimateResultPrefix => 'Wenn Sie so weitermachen (), erreichen Sie Ihr Zielgewicht in etwa';

  @override
  String get bmiVeryLow => 'Viel zu niedrig';

  @override
  String get bmiLow => 'Niedrig';

  @override
  String get bmiGood => 'Gesund';

  @override
  String get bmiHigh => 'Zu hoch';

  @override
  String get bmiVeryHigh => 'Viel zu hoch';

  @override
  String get thanksFeedback => 'Danke für Ihr Feedback!';

  @override
  String get absiVeryLowRisk => 'Sehr geringes Risiko';

  @override
  String get absiIncreasedRisk => 'Erhöhtes Risiko';

  @override
  String get recipesSwipeInstruction => 'Wischen, um Rezepte zu speichern oder zu überspringen.';

  @override
  String get recipesNoMore => 'Keine Rezepte mehr.';

  @override
  String get recipesSavedPrefix => 'Gespeichert: ';

  @override
  String get recipesSkippedPrefix => 'Übersprungen: ';

  @override
  String get recipesDetailId => 'ID';

  @override
  String get recipesDetailPreparationTime => 'Zubereitungszeit';

  @override
  String get recipesDetailTotalTime => 'Gesamtzeit';

  @override
  String get recipesDetailKcal => 'Kalorien';

  @override
  String get recipesDetailFat => 'Fett';

  @override
  String get recipesDetailSaturatedFat => 'Gesättigte Fettsäuren';

  @override
  String get recipesDetailCarbs => 'Kohlenhydrate';

  @override
  String get recipesDetailProtein => 'Eiweiß';

  @override
  String get recipesDetailFibers => 'Ballaststoffe';

  @override
  String get recipesDetailSalt => 'Salz';

  @override
  String get recipesDetailPersons => 'Personen';

  @override
  String get recipesDetailDifficulty => 'Schwierigkeitsgrad';

  @override
  String get recipesPrepreparation => 'Vorbereitung';

  @override
  String get recipesIngredients => 'Zutaten';

  @override
  String get recipesSteps => 'Zubereitungsschritte';

  @override
  String get recipesSearchHint => 'Nach Zutat oder Gericht suchen...';

  @override
  String get recipesErrorNoRecommendations => 'Serverfehler: Keine Empfehlungen erhalten';

  @override
  String get recipesError502 => 'Server aktuell nicht erreichbar (502). Später erneut versuchen.';

  @override
  String get recipesErrorLoading => 'Fehler beim Laden: ';

  @override
  String recipesNoResultsFound(String query) {
    return 'Keine Rezepte für \"$query\" gefunden';
  }

  @override
  String get recipesErrorLoadingDetails => 'Details der gefundenen Rezepte konnten nicht geladen werden';

  @override
  String get recipesErrorSearchFailed => 'Suche fehlgeschlagen: ';

  @override
  String get recipesErrorNoMoreRecipes => 'Serverfehler: Keine weiteren Rezepte verfügbar';

  @override
  String get recipesNoMoreSearchResults => 'Du hast alle Ergebnisse für diese Suche angesehen.';

  @override
  String get recipesRetry => 'Erneut versuchen';

  @override
  String get recipesDetailCharacteristics => 'Merkmale';

  @override
  String get recipesDetailRequirements => 'Anforderungen';

  @override
  String recipesErrorServer(String status) {
    return 'Serverfehler ($status)';
  }

  @override
  String get recipesKitchens => 'Küchen';

  @override
  String get recipesCourses => 'Gang';

  @override
  String get recipesRequirements => 'Benötigte Utensilien';

  @override
  String get water => 'Wasser';

  @override
  String get coffee => 'Kaffee';

  @override
  String get tea => 'Tee';

  @override
  String get soda => 'Limonade';

  @override
  String get other => 'Andere';

  @override
  String get coffeeBlack => 'Schwarzer Kaffee';

  @override
  String get espresso => 'Espresso';

  @override
  String get ristretto => 'Ristretto';

  @override
  String get lungo => 'Lungo';

  @override
  String get americano => 'Americano';

  @override
  String get coffeeWithMilk => 'Kaffee mit Milch';

  @override
  String get coffeeWithMilkSugar => 'Kaffee mit Milch + Zucker';

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
  String get icedCoffee => 'Eiskaffee';

  @override
  String get otherCoffee => 'Anderer Kaffee';

  @override
  String get newDrinkTitle => 'Neues Getränk hinzufügen';

  @override
  String get chooseDrink => 'Wählen Sie ein Getränk';

  @override
  String get chooseCoffeeType => 'Wählen Sie die Kaffeesorte';

  @override
  String get drinkNameLabel => 'Name des Getränks';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get amountMlLabel => 'Menge (ml)';

  @override
  String get amountRequired => 'Menge ist erforderlich';

  @override
  String get enterNumber => 'Geben Sie eine Zahl ein';

  @override
  String get kcalPer100Label => 'kcal pro 100 ml';

  @override
  String get barcodeSearchTooltip => 'Nach Barcode suchen';

  @override
  String get kcalRequired => 'kcal-Wert ist erforderlich';

  @override
  String get addDrinkTitle => 'Getränk hinzufügen';

  @override
  String get addButton => 'Hinzufügen';

  @override
  String get addAndLogButton => 'Hinzufügen und protokollieren';

  @override
  String get searchButton => 'Suchen';

  @override
  String get scanPasteBarcode => 'Barcode scannen/einfügen';

  @override
  String get barcodeLabel => 'Barcode (EAN/GTIN)';

  @override
  String get enterBarcode => 'Barcode eingeben';

  @override
  String get searching => 'Suche...';

  @override
  String get noKcalFoundPrefix => 'Kein kcal-Wert für Barcode gefunden ';

  @override
  String get foundPrefix => 'Gefunden: ';

  @override
  String get kcalPer100Unit => ' kcal pro 100g/ml';

  @override
  String get whenDrankTitle => 'Wann konsumiert?';

  @override
  String get snack => 'Zwischenmahlzeit';

  @override
  String get loginToLog => 'Melden Sie sich an, um zu protokollieren';

  @override
  String get editDrinkTitle => 'Getränk bearbeiten';

  @override
  String get nameLabel => 'Name';

  @override
  String get delete => 'Löschen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get added => 'hinzugefügt';

  @override
  String get sportAddTitle => 'Sport hinzufügen';

  @override
  String get newSportActivity => 'Neue Sportaktivität';

  @override
  String get labelSport => 'Sport';

  @override
  String get chooseSport => 'Wählen Sie eine Sportart';

  @override
  String get customSportName => 'Name der Sportart';

  @override
  String get enterSportName => 'Geben Sie einen Sportnamen ein';

  @override
  String get durationMinutes => 'Dauer (Minuten)';

  @override
  String get invalidDuration => 'Geben Sie eine gültige Dauer ein';

  @override
  String get caloriesBurned => 'Verbrannte Kalorien';

  @override
  String get invalidCalories => 'Geben Sie eine gültige Kalorienanzahl ein';

  @override
  String get save => 'Speichern';

  @override
  String get encryptionKeyNotFound => 'Verschlüsselungsschlüssel nicht gefunden.';

  @override
  String get noSportsYet => 'Noch keine Sportaktivitäten.';

  @override
  String get durationLabel => 'Dauer (Minuten)';

  @override
  String get caloriesLabel => 'Kalorien';

  @override
  String get minutesShort => 'Minuten';

  @override
  String get intensityLevel => 'Intensitätsstufe';

  @override
  String get intensityLight => 'Leicht';

  @override
  String get intensityNormal => 'Normal';

  @override
  String get intensityHard => 'Anstrengend';

  @override
  String get intensityVeryHard => 'Sehr anstrengend';

  @override
  String get userNotLoggedIn => 'Nicht angemeldet.';

  @override
  String get sportAdded => 'Sportaktivität hinzugefügt';

  @override
  String get sportRunning => 'Laufen';

  @override
  String get sportCycling => 'Radfahren';

  @override
  String get sportSwimming => 'Schwimmen';

  @override
  String get sportWalking => 'Gehen';

  @override
  String get sportFitness => 'Fitness';

  @override
  String get sportFootball => 'Fußball';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportOther => 'Andere';

  @override
  String get deleteSportTitle => 'Sportaktivität löschen';

  @override
  String get deleteSportContent => 'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get sportDeleted => 'Sportaktivität gelöscht';

  @override
  String get editSportTitle => 'Sportaktivität bearbeiten';

  @override
  String get sportUpdated => 'Sportaktivität aktualisiert';

  @override
  String get notLoggedIn => 'Nicht angemeldet';

  @override
  String get addSportTitle => 'Sport hinzufügen';

  @override
  String get sportLabel => 'Sport';

  @override
  String get customSportLabel => 'Name der Sportart';

  @override
  String get customSportRequired => 'Geben Sie einen Sportnamen ein';

  @override
  String get logSportTitle => 'Sportaktivität protokollieren';

  @override
  String get intensityHeavy => 'Anstrengend';

  @override
  String get intensityVeryHeavy => 'Sehr anstrengend';

  @override
  String get intensityLabel => 'Intensität';

  @override
  String get enterValidDuration => 'Geben Sie eine gültige Dauer ein';

  @override
  String get caloriesBurnedLabel => 'Verbrannte Kalorien';

  @override
  String get enterValidCalories => 'Geben Sie eine gültige Kalorienanzahl ein';

  @override
  String get durationShort => 'Dauer:';

  @override
  String get caloriesShort => 'Kalorien:';

  @override
  String get saveSportFailedPrefix => 'Speichern fehlgeschlagen:';

  @override
  String get unsavedChangesContent => 'Sie haben nicht gespeicherte Änderungen. Sind Sie sicher, dass Sie diese verwerfen möchten?';

  @override
  String get searchFood => 'Lebensmittel suchen';

  @override
  String get searchFoodDescription => 'Suchen Sie nach Lebensmitteln, um sie Ihrem Tag hinzuzufügen.';

  @override
  String get scanProduct => 'Barcode scannen';

  @override
  String get scanProductDescription => 'Tippen Sie hier, um ein Produkt zu scannen und schnell zu Ihrem Tag hinzuzufügen.';

  @override
  String get recentProducts => 'Kürzliche Produkte';

  @override
  String get recentProductsDescription => 'Hier sehen Sie alle Produkte, die Sie kürzlich hinzugefügt haben.';

  @override
  String get favoriteProducts => 'Favoriten';

  @override
  String get favoriteProductsDescription => 'Hier können Sie alle Ihre Favoriten ansehen.';

  @override
  String get myProducts => 'Meine Produkte';

  @override
  String get myProductsDescription => 'Hier können Sie eigene Produkte hinzufügen, die nicht gefunden werden.';

  @override
  String get meals => 'Mahlzeiten';

  @override
  String get mealsDescription => 'Hier können Sie Mahlzeiten ansehen und protokollieren; Mahlzeiten bestehen aus mehreren Produkten.';

  @override
  String get mealsAdd => 'Mahlzeiten hinzufügen';

  @override
  String get mealsAddDescription => 'Tippen Sie auf das +, um Mahlzeiten aus mehreren Produkten zu erstellen, damit Sie häufig gegessene Mahlzeiten schneller hinzufügen können.';

  @override
  String get mealsLog => 'Mahlzeiten protokollieren';

  @override
  String get mealsLogDescription => 'Tippen Sie auf den Einkaufswagen, um Mahlzeiten den Protokollen hinzuzufügen.';

  @override
  String get enterMoreChars => 'Geben Sie mindestens 2 Zeichen ein.';

  @override
  String get errorFetch => 'Fehler beim Abrufen';

  @override
  String get takePhoto => 'Foto machen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt.';

  @override
  String get aiNoIngredientsFound => 'Kein Ergebnis von der KI.';

  @override
  String aiIngredientsPrompt(Object ingredient) {
    return 'Welche Zutaten sehen Sie hier? Antworten Sie auf Niederländisch. Ignorieren Sie Marketingbegriffe, Produktnamen und nicht relevante Wörter wie \'zero\', \'light\' usw. Antworten Sie nur mit tatsächlichen Zutaten, die im Produkt enthalten sind. Antworten Sie nur, wenn das Bild ein Lebensmittelprodukt zeigt. Antworten Sie als: $ingredient, $ingredient, ...';
  }

  @override
  String get aiIngredientsFound => 'Gefundene Zutaten:';

  @override
  String get aiIngredientsDescription => 'Die KI hat die folgenden Zutaten erkannt:';

  @override
  String get addMeal => 'Mahlzeit zusammenstellen';

  @override
  String get errorAI => 'Fehler bei KI-Analyse:';

  @override
  String get amount => 'Menge';

  @override
  String get search => 'Suchen';

  @override
  String get loadMore => 'Mehr Produkte laden...';

  @override
  String get errorNoBarcode => 'Für dieses Produkt wurde kein Barcode gefunden.';

  @override
  String get amountInGrams => 'Menge (g)';

  @override
  String get errorUserDEKMissing => 'Verschlüsselungsschlüssel konnte nicht abgerufen werden.';

  @override
  String get errorNoIngredientsAdded => 'Fügen Sie mindestens ein Produkt hinzu.';

  @override
  String get mealSavedSuccessfully => 'Mahlzeit gespeichert!';

  @override
  String get saveMeal => 'Mahlzeit speichern';

  @override
  String get errorFetchRecentsProducts => 'Fehler beim Abrufen kürzlicher Produkte';

  @override
  String get searchProducts => 'Produkte suchen...';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addFoodItem => 'Was möchten Sie hinzufügen?';

  @override
  String get addProduct => 'Produkt hinzufügen';

  @override
  String get addMealT => 'Mahlzeit hinzufügen';

  @override
  String get recents => 'Kürzlich';

  @override
  String get favorites => 'Favoriten';

  @override
  String get searchingProducts => 'Beginnen Sie zu tippen, um zu suchen.';

  @override
  String get noProductsFound => 'Keine Produkte gefunden.';

  @override
  String get addNewProduct => 'Möchten Sie selbst ein Produkt hinzufügen?';

  @override
  String get errorInvalidBarcode => 'Für dieses Produkt wurde kein Barcode gefunden.';

  @override
  String get loadMoreResults => 'Mehr Produkte laden…';

  @override
  String get notTheDesiredResults => 'Fügen Sie ein neues Produkt hinzu';

  @override
  String get addNewProductT => 'Neues Produkt hinzufügen';

  @override
  String get errorProductNameRequired => 'Name ist erforderlich';

  @override
  String get brandName => 'Marke';

  @override
  String get quantity => 'Menge (z. B. 100g, 250ml)';

  @override
  String get nutritionalValuesPer100g => 'Nährwerte pro 100g oder ml';

  @override
  String get calories => 'Energie (kcal)';

  @override
  String get errorCaloriesRequired => 'Kalorien sind erforderlich';

  @override
  String get fat => 'Fette';

  @override
  String get saturatedFat => '  - Davon gesättigt';

  @override
  String get carbohydrates => 'Kohlenhydrate';

  @override
  String get sugars => '  - Davon Zucker';

  @override
  String get fiber => 'Ballaststoffe';

  @override
  String get proteins => 'Eiweiß';

  @override
  String get salt => 'Salz';

  @override
  String get errorEncryptionKeyMissing => 'Fehler: Verschlüsselungsschlüssel konnte nicht abgerufen werden.';

  @override
  String get saveProduct => 'Speichern';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get unnamedProduct => 'Unbekannter Name';

  @override
  String get logInToSeeRecents => 'Melden Sie sich an, um Ihre kürzlichen Produkte zu sehen.';

  @override
  String get noRecentProductsFound => 'Keine kürzlichen Produkte gefunden.';

  @override
  String get errorLoadingRecentProducts => 'Ein Fehler ist aufgetreten.';

  @override
  String get logInToSeeFavorites => 'Melden Sie sich an, um Ihre Favoriten zu sehen.';

  @override
  String get noFavoriteProductsFound => 'Keine Favoriten gefunden.';

  @override
  String get errorLoadingFavoriteProducts => 'Ein Fehler ist aufgetreten.';

  @override
  String get logInToSeeMyProducts => 'Melden Sie sich an, um Ihre Produkte zu sehen.';

  @override
  String get noMyProductsFound => 'Sie haben noch keine Produkte erstellt.';

  @override
  String get errorLoadingMyProducts => 'Ein Fehler ist aufgetreten.';

  @override
  String get unknownBrand => 'Keine Marke';

  @override
  String get confirmDeletion => 'Löschen bestätigen';

  @override
  String get sure => 'Sind Sie sicher, dass Sie ';

  @override
  String get willBeDeleted => ' löschen möchten?';

  @override
  String get deleted => 'gelöscht';

  @override
  String get logInToSeeMeals => 'Melden Sie sich an, um Ihre Mahlzeiten zu sehen.';

  @override
  String get errorLoadingMeals => 'Ein Fehler ist aufgetreten.';

  @override
  String get mealExample => 'Beispielmahlzeit';

  @override
  String get createOwnMealsFirst => 'Klicken Sie auf +, um Ihre erste Mahlzeit zu erstellen';

  @override
  String get logMeal => 'Mahlzeit protokollieren';

  @override
  String get createMealsBeforeLogging => 'Dies ist ein Beispiel. Erstellen Sie zuerst eine eigene Mahlzeit.';

  @override
  String get unnamedMeal => 'Unbenannte Mahlzeit';

  @override
  String get sureMeal => 'Sind Sie sicher, dass Sie die Mahlzeit ';

  @override
  String get meal => 'Mahlzeit ';

  @override
  String get encryptionKeyError => 'Verschlüsselungsschlüssel konnte nicht abgerufen werden.';

  @override
  String get mealNoIngredients => 'Diese Mahlzeit hat keine Zutaten.';

  @override
  String get mealLoggedSuccessfully => ' wurde Ihrem Tagebuch hinzugefügt.';

  @override
  String get errorSaveMeal => 'Fehler beim Speichern der Mahlzeit:';

  @override
  String get sectie => 'Abschnitt';

  @override
  String get log => 'Protokoll';

  @override
  String get mealAddAtLeastOneIngredient => 'Fügen Sie mindestens ein Produkt hinzu.';

  @override
  String get editMeal => 'Mahlzeit bearbeiten';

  @override
  String get addNewMeal => 'Neue Mahlzeit zusammenstellen';

  @override
  String get mealName => 'Name der Mahlzeit';

  @override
  String get pleaseEnterMealName => 'Name ist erforderlich';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get searchProductHint => 'Tippen, um zu suchen oder Barcode scannen';

  @override
  String get selectProduct => 'Produkt wählen';

  @override
  String get scanBarcode => 'Barcode für dieses Produkt scannen';

  @override
  String get searchForBarcode => 'Nach Barcode suchen...';

  @override
  String get errorFetchingProductData => 'Produkt auf OpenFoodFacts nicht gefunden';

  @override
  String get productNotFound => 'Keine Produktdaten gefunden';

  @override
  String get errorBarcodeFind => 'Fehler bei Barcode-Suche: ';

  @override
  String get errorFetchingProductDataBarcode => 'Für dieses Produkt wurde kein Barcode gefunden.';

  @override
  String get addIngredient => 'Fügen Sie ein weiteres Produkt hinzu';

  @override
  String get editMyProduct => 'Produkt bearbeiten';

  @override
  String get productName => 'Produktname';

  @override
  String get productNameRequired => 'Name ist erforderlich';

  @override
  String get caloriesRequired => 'Kalorien sind erforderlich';

  @override
  String get errorUserDEKNotFound => 'Verschlüsselungsschlüssel konnte nicht abgerufen werden.';

  @override
  String get unknownProduct => 'Unbekanntes Produkt';

  @override
  String get brand => 'Marke';

  @override
  String get servingSize => 'Portionsgröße';

  @override
  String get nutritionalValuesPer100mlg => 'Nährwerte pro 100g/ml';

  @override
  String get saveMyProduct => 'Mein Produkt speichern';

  @override
  String get amountFor => 'Menge für ';

  @override
  String get amountGML => 'Menge (Gramm oder Milliliter)';

  @override
  String get gramsMillilitersAbbreviation => 'g/ml';

  @override
  String get invalidAmount => 'Geben Sie eine gültige Menge ein.';

  @override
  String get addedToLog => ' wurde Ihrem Tagebuch hinzugefügt.';

  @override
  String get errorSaving => 'Fehler beim Speichern: ';

  @override
  String get photoAnalyzing => 'Foto wird analysiert...';

  @override
  String get ingredientsIdentifying => 'Zutaten werden identifiziert...';

  @override
  String get nutritionalValuesEstimating => 'Nährwertinformationen werden geschätzt...';

  @override
  String get patientlyWaiting => 'Bitte warten Sie...';

  @override
  String get almostDone => 'Fast fertig...';

  @override
  String get processingWithAI => 'KI-Verarbeitung läuft...';

  @override
  String get selectMealType => 'Wählen Sie den Mahlzeittyp';

  @override
  String get section => 'Abschnitt';

  @override
  String get saveNameTooltip => 'Speichern';

  @override
  String get noChangesTooltip => 'Keine Änderungen';

  @override
  String get fillRequiredKcal => 'Füllen Sie alle Pflichtfelder aus (kcal).';

  @override
  String get additivesLabel => 'Zusatzstoffe';

  @override
  String get allergensLabel => 'Allergene';

  @override
  String get mealAmountLabel => 'Menge für die Mahlzeit';

  @override
  String get addToMealButton => 'Zur Mahlzeit hinzufügen';

  @override
  String get enterAmount => 'Geben Sie eine Menge ein';

  @override
  String get unitLabel => 'Einheit';

  @override
  String get gramLabel => 'Gramm (g)';

  @override
  String get milliliterLabel => 'Milliliter (ml)';

  @override
  String get errorLoadingLocal => 'Fehler beim Laden lokaler Daten: ';

  @override
  String get errorFetching => 'Fehler beim Abrufen: ';

  @override
  String get nameSaved => 'Name gespeichert';

  @override
  String get enterValue => 'Wert fehlt';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get invalidNumber => 'Ungültige Zahl';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get done => 'Fertig';

  @override
  String get logs => 'Protokolle';

  @override
  String get add_food_label => 'Lebensmittel hinzufügen';

  @override
  String get add_drink_label => 'Getränk hinzufügen';

  @override
  String get add_sport_label => 'Sport hinzufügen';

  @override
  String get tutorial_date_title => 'Datum ändern';

  @override
  String get tutorial_date_text => 'Tippen Sie hier, um ein Datum zu wählen oder schnell zu heute zu springen.';

  @override
  String get tutorial_barcode_title => 'Barcode scannen';

  @override
  String get tutorial_barcode_text => 'Tippen Sie hier, um ein Produkt zu scannen und es schnell zu Ihrem Tag hinzuzufügen.';

  @override
  String get tutorial_settings_title => 'Einstellungen';

  @override
  String get tutorial_settings_text => 'Diese Seite dient dazu, Ihre Daten, die Benachrichtigungszeiten oder andere Einstellungen zu ändern';

  @override
  String get tutorial_feedback_title => 'Feedback';

  @override
  String get tutorial_feedback_text => 'Hier können Sie Feedback zur App geben. Funktioniert etwas nicht oder wünschen Sie eine Funktion? Wir hören gern von Ihnen!';

  @override
  String get tutorial_calorie_title => 'Kalorienübersicht';

  @override
  String get tutorial_calorie_text => 'Hier sehen Sie eine Zusammenfassung Ihrer Kalorienaufnahme für den Tag.';

  @override
  String get tutorial_mascot_title => 'Reppy';

  @override
  String get tutorial_mascot_text => 'Reppy gibt persönliche Motivation und Tipps!';

  @override
  String get tutorial_water_title => 'Getränke';

  @override
  String get tutorial_water_text => 'Verfolgen Sie hier, wie viel Sie pro Tag trinken. Der Kreis zeigt, wie viel Sie noch trinken müssen, um Ihr Ziel zu erreichen.';

  @override
  String get tutorial_additems_title => 'Elemente hinzufügen';

  @override
  String get tutorial_additems_text => 'Verwenden Sie diese Schaltfläche, um schnell Mahlzeiten, Getränke oder Sport hinzuzufügen.';

  @override
  String get tutorial_meals_title => 'Mahlzeiten';

  @override
  String get tutorial_meals_text => 'Sehen Sie Ihre Mahlzeiten ein und ändern Sie sie, indem Sie darauf tippen.';

  @override
  String get updateAvailable => 'Ein neues Update ist verfügbar!';

  @override
  String get announcement_default => 'Mitteilung';

  @override
  String get water_goal_dialog_title => 'Wasserziel festlegen';

  @override
  String get water_goal_dialog_label => 'Ziel (ml)';

  @override
  String get enter_valid_number => 'Geben Sie eine gültige Zahl ein';

  @override
  String get water_goal_updated => 'Wasserziel aktualisiert';

  @override
  String get error_saving_water_goal => 'Fehler beim Speichern des Wasserziels: ';

  @override
  String get calorie_goal_dialog_title => 'Kalorienzielt festlegen';

  @override
  String get calorie_goal_dialog_label => 'Tägliches Ziel (kcal)';

  @override
  String get calorie_goal_updated => 'Kalorienzielt aktualisiert';

  @override
  String get error_saving_prefix => 'Speichern fehlgeschlagen: ';

  @override
  String get eaten => 'Genossen';

  @override
  String get remaining => 'Verbleibend';

  @override
  String get over_goal => 'Über dem Ziel';

  @override
  String get calories_over_goal => 'kcal über dem Ziel';

  @override
  String get calories_remaining => 'kcal verbleibend';

  @override
  String get calories_consumed => 'kcal konsumiert';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fats => 'Fette';

  @override
  String get unit => 'Einheit';

  @override
  String get edit_amount_dialog_title_ml => 'Menge anpassen (ml)';

  @override
  String get edit_amount_dialog_title_g => 'Menge anpassen (g)';

  @override
  String get edit_amount_label_ml => 'Menge (ml)';

  @override
  String get edit_amount_label_g => 'Menge (g)';

  @override
  String get totalConsumed => 'Gesamtaufnahme';

  @override
  String get youHave => 'Sie haben';

  @override
  String get motivational_default_1 => 'Gut gemacht, machen Sie weiter so!';

  @override
  String get motivational_default_2 => 'Tippen Sie auf mich, um einen neuen Spruch zu sehen!';

  @override
  String get motivational_default_3 => 'Jeder Schritt zählt!';

  @override
  String get motivational_default_4 => 'Sie machen das großartig!';

  @override
  String get motivational_default_5 => 'Wussten Sie, dass fFinder eine Abkürzung für FoodFinder ist?';

  @override
  String get motivational_default_6 => 'Sie protokollieren besser als 97 % der Menschen... wahrscheinlich.';

  @override
  String get motivational_noEntries_1 => 'Bereit, Ihren Tag zu protokollieren?';

  @override
  String get motivational_noEntries_2 => 'Ein neuer Tag, neue Möglichkeiten!';

  @override
  String get motivational_noEntries_3 => 'Lassen Sie uns beginnen!';

  @override
  String get motivational_noEntries_4 => 'Jeder gesunde Tag beginnt mit einem Eintrag.';

  @override
  String get motivational_noEntries_5 => 'Ihre erste Mahlzeit ist versteckt. Suchen Sie sie!';

  @override
  String get motivational_drinksOnly_1 => 'Gut, dass Sie bereits Getränke protokolliert haben! Was wird Ihre erste Mahlzeit?';

  @override
  String get motivational_drinksOnly_2 => 'Hydration ist ein guter Anfang. Zeit, auch etwas zu essen.';

  @override
  String get motivational_drinksOnly_3 => 'Weiter so! Was wird Ihr erster Bissen?';

  @override
  String get motivational_overGoal_1 => 'Ziel erreicht! Jetzt entspannen.';

  @override
  String get motivational_overGoal_2 => 'Wow, Sie liegen über Ihrem Ziel!';

  @override
  String get motivational_overGoal_3 => 'Gut gemacht, morgen wieder ein neuer Tag.';

  @override
  String get motivational_overGoal_4 => 'Toll gemacht heute, ehrlich!';

  @override
  String get motivational_almostGoal_1 => 'Sie sind fast da!';

  @override
  String get motivational_almostGoal_2 => 'Noch ein kleines Stück!';

  @override
  String get motivational_almostGoal_3 => 'Fast Ihr Kalorienzielt erreicht!';

  @override
  String get motivational_almostGoal_4 => 'Gut gemacht! Achten Sie auf den letzten Schritt.';

  @override
  String get motivational_almostGoal_5 => 'Sie machen das fantastisch, fast geschafft!';

  @override
  String get motivational_belowHalf_1 => 'Sie sind gut unterwegs, weiter so!';

  @override
  String get motivational_belowHalf_3 => 'Protokollieren Sie weiter Ihre Mahlzeiten und Getränke.';

  @override
  String get motivational_belowHalf_4 => 'Sie machen großartige Arbeit, halten Sie durch!';

  @override
  String get motivational_lowWater_1 => 'Vergessen Sie nicht heute zu trinken!';

  @override
  String get motivational_lowWater_2 => 'Ein Schluck Wasser ist ein guter Anfang.';

  @override
  String get motivational_lowWater_3 => 'Ob warm oder kalt, Wasser ist immer gut!';

  @override
  String get motivational_lowWater_4 => 'Hydration ist wichtig!';

  @override
  String get motivational_lowWater_5 => 'Ein Glas Wasser kann Wunder wirken.';

  @override
  String get motivational_lowWater_6 => 'Zeit für eine Pause? Trinken Sie etwas Wasser.';

  @override
  String get entry_updated => 'Menge aktualisiert';

  @override
  String get errorUpdatingEntry => 'Fehler beim Aktualisieren der Menge: ';

  @override
  String get errorLoadingData => 'Fehler beim Laden der Daten: ';

  @override
  String get not_logged_in => 'Nicht angemeldet';

  @override
  String get noEntriesForDate => 'Keine Protokolle für dieses Datum.';

  @override
  String get thinking => 'Kurz überlegen...';

  @override
  String get sports => 'Sportaktivitäten';

  @override
  String get totalBurned => 'Insgesamt verbrannt: ';

  @override
  String get unknownSport => 'Unbekannte Sportart';

  @override
  String get errorDeletingSport => 'Fehler beim Löschen der Sportaktivität: ';

  @override
  String get errorDeleting => 'Fehler beim Löschen: ';

  @override
  String get errorCalculating => 'Fehler: Ursprüngliche Produktdaten sind unvollständig zum Neuberechnen.';

  @override
  String get appleCancelled => 'Sie haben die Apple-Anmeldung abgebrochen.';

  @override
  String get appleFailed => 'Apple-Anmeldung fehlgeschlagen. Bitte versuchen Sie es später erneut.';

  @override
  String get appleInvalidResponse => 'Ungültige Antwort von Apple erhalten.';

  @override
  String get appleNotHandled => 'Apple konnte die Anfrage nicht verarbeiten.';

  @override
  String get appleUnknown => 'Bei Apple ist ein unbekannter Fehler aufgetreten.';

  @override
  String get appleGenericError => 'Beim Anmelden mit Apple ist ein Fehler aufgetreten.';

  @override
  String get signInAccountExists => 'Für diese E-Mail-Adresse existiert bereits ein Konto. Melden Sie sich mit einer anderen Methode an.';

  @override
  String get signInCancelled => 'Die Anmeldung wurde abgebrochen.';

  @override
  String get unknownGoogleSignIn => 'Beim Anmelden mit Google ist ein unbekannter Fehler aufgetreten.';

  @override
  String get unknownGitHubSignIn => 'Beim Anmelden mit GitHub ist ein unbekannter Fehler aufgetreten.';

  @override
  String get unknownAppleSignIn => 'Beim Anmelden mit Apple ist ein unbekannter Fehler aufgetreten.';

  @override
  String get unknownErrorEnglish => 'Unbekannter Fehler';

  @override
  String get passwordErrorMinLength => 'mindestens 6 Zeichen';

  @override
  String get passwordErrorUpper => 'ein Großbuchstabe';

  @override
  String get passwordErrorLower => 'ein Kleinbuchstabe';

  @override
  String get passwordErrorDigit => 'eine Zahl';

  @override
  String get passwordMissingPartsPrefix => 'Ihr Passwort fehlt: ';

  @override
  String get userNotFoundCreateAccount => 'Kein Konto für diese E-Mail gefunden. Klicken Sie unten, um ein Konto zu erstellen.';

  @override
  String get wrongPasswordOrEmail => 'Falsches Passwort oder E-Mail. Versuchen Sie es erneut. Haben Sie noch kein Konto? Klicken Sie unten, um eines zu erstellen.';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail-Adresse wird bereits verwendet. Versuchen Sie sich anzumelden.';

  @override
  String get weakPasswordMessage => 'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get invalidEmailMessage => 'Die eingegebene E-Mail-Adresse ist ungültig.';

  @override
  String get authGenericError => 'Bei der Authentifizierung ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.';

  @override
  String get resetPasswordEnterEmailInstruction => 'Geben Sie Ihre E-Mail ein, um Ihr Passwort zurückzusetzen.';

  @override
  String get resetPasswordEmailSentTitle => 'E-Mail gesendet';

  @override
  String get resetPasswordEmailSentContent => 'Es wurde eine E-Mail zum Zurücksetzen Ihres Passworts gesendet. Hinweis: Diese E-Mail kann in Ihrem Spam-Ordner landen. Absender: noreply@pwsmt-fd851.firebaseapp.com';

  @override
  String get okLabel => 'OK';

  @override
  String get genericError => 'Ein Fehler ist aufgetreten.';

  @override
  String get userNotFoundForEmail => 'Kein Konto für diese E-Mail gefunden.';

  @override
  String get loginWelcomeBack => 'Willkommen zurück!';

  @override
  String get loginCreateAccount => 'Konto erstellen';

  @override
  String get loginSubtitle => 'Melden Sie sich an, um fortzufahren';

  @override
  String get registerSubtitle => 'Registrieren Sie sich, um zu beginnen';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginEmailHint => 'name@beispiel.com';

  @override
  String get loginEnterEmail => 'E-Mail eingeben';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginMin6Chars => 'Mind. 6 Zeichen';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginButtonLogin => 'Anmelden';

  @override
  String get loginButtonRegister => 'Registrieren';

  @override
  String get loginOrContinueWith => 'Oder fortfahren mit';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get loginWithGitHub => 'Mit GitHub anmelden';

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get loginNoAccountQuestion => 'Noch kein Konto?';

  @override
  String get loginHaveAccountQuestion => 'Haben Sie bereits ein Konto?';

  @override
  String get loginCreateAccountAction => 'Konto erstellen';

  @override
  String get loginLoginAction => 'Anmelden';

  @override
  String get onboardingEnterFirstName => 'Geben Sie Ihren Vornamen ein';

  @override
  String get onboardingSelectBirthDate => 'Wählen Sie Ihr Geburtsdatum';

  @override
  String get onboardingEnterHeight => 'Geben Sie Ihre Größe ein (cm)';

  @override
  String get onboardingEnterWeight => 'Geben Sie Ihr Gewicht ein (kg)';

  @override
  String get onboardingEnterTargetWeight => 'Geben Sie Ihr Wunschgewicht ein (kg)';

  @override
  String get onboardingEnterValidWeight => 'Geben Sie ein gültiges Gewicht ein';

  @override
  String get onboardingEnterValidHeight => 'Geben Sie eine gültige Größe ein';

  @override
  String get heightBetween => 'Größe muss zwischen ';

  @override
  String get and => ' und ';

  @override
  String get liggen => ' cm liegen.';

  @override
  String get weightBetween => 'Gewicht muss zwischen ';

  @override
  String get kgLiggen => ' kg liegen.';

  @override
  String get enterWaistCircumference => 'Geben Sie Ihren Taillenumfang ein (cm)';

  @override
  String get enterValidWaistCircumference => 'Geben Sie einen gültigen Taillenumfang ein';

  @override
  String get tailleBetween => 'Taillenumfang muss zwischen ';

  @override
  String get cmLiggen => ' cm liegen.';

  @override
  String get onboardingEnterValidTargetWeight => 'Geben Sie ein gültiges Wunschgewicht ein';

  @override
  String get targetBetween => 'Wunschgewicht muss zwischen ';

  @override
  String get absiVeryLow => 'sehr geringes Risiko';

  @override
  String get absiLow => 'geringes Risiko';

  @override
  String get absiAverage => 'mittleres Risiko';

  @override
  String get absiElevated => 'erhöhtes Risiko';

  @override
  String get absiHigh => 'hoch Risiko';

  @override
  String get healthWeight => 'Gesundes Gewicht für Sie: ';

  @override
  String get healthyBMI => 'Gesunder BMI: ';

  @override
  String get onboardingWeightRangeUnder2 => 'Bei Kindern unter 2 Jahren wird üblicherweise Perzentile für Gewicht/Länge anstelle des BMI verwendet.';

  @override
  String get onboardingWeightRangeUnder2Note => 'Verwenden Sie WHO/CDC Gewicht-für-Länge-Tabellen.';

  @override
  String get onboarding_datePickerDone => 'Fertig';

  @override
  String get lmsDataUnavailable => 'LMS-Daten für dieses Alter/Geschlecht nicht verfügbar.';

  @override
  String get lmsCheckAssets => 'Überprüfen Sie die Assets oder geben Sie das Wunschgewicht manuell ein.';

  @override
  String get lmsDataErrorPrefix => 'LMS-Daten konnten nicht verwendet werden:';

  @override
  String get lmsAssetMissing => 'Überprüfen Sie, ob das Asset vorhanden ist (assets/cdc/bmiagerev.csv).';

  @override
  String get healthyWeightForYou => 'Gesundes Gewicht für Sie:';

  @override
  String get onboarding_firstNameTitle => 'Wie ist Ihr Vorname?';

  @override
  String get onboarding_labelFirstName => 'Vorname';

  @override
  String get onboarding_genderTitle => 'Welches Geschlecht haben Sie?';

  @override
  String get onboarding_genderOptionMan => 'Männlich';

  @override
  String get onboarding_genderOptionWoman => 'Weiblich';

  @override
  String get onboarding_genderOptionOther => 'Andere';

  @override
  String get onboarding_genderOptionPreferNot => 'Möchte ich lieber nicht angeben';

  @override
  String get onboarding_birthDateTitle => 'Was ist Ihr Geburtsdatum?';

  @override
  String get onboarding_noDateChosen => 'Kein Datum ausgewählt';

  @override
  String get onboarding_chooseDate => 'Datum wählen';

  @override
  String get onboarding_heightTitle => 'Wie groß sind Sie (cm)?';

  @override
  String get onboarding_labelHeight => 'Größe in cm';

  @override
  String get onboarding_weightTitle => 'Wie viel wiegen Sie (kg)?';

  @override
  String get onboarding_labelWeight => 'Gewicht in kg';

  @override
  String get onboarding_waistTitle => 'Wie groß ist Ihr Taillenumfang (cm)?';

  @override
  String get onboarding_labelWaist => 'Taillenumfang in cm';

  @override
  String get onboarding_unknownWaist => 'Ich weiß es nicht';

  @override
  String get onboarding_sleepTitle => 'Wie viele Stunden schlafen Sie durchschnittlich pro Nacht?';

  @override
  String get onboarding_activityTitle => 'Wie aktiv sind Sie täglich?';

  @override
  String get onboarding_targetWeightTitle => 'Was ist Ihr Wunschgewicht?';

  @override
  String get onboarding_labelTargetWeight => 'Wunschgewicht in kg';

  @override
  String get onboarding_goalTitle => 'Was ist Ihr Ziel?';

  @override
  String get onboarding_notificationsTitle => 'Möchten Sie Benachrichtigungen erhalten?';

  @override
  String get onboarding_notificationsDescription => 'Sie können Benachrichtigungen für Mahlzeiterinnerungen aktivieren, damit Sie nie vergessen zu essen und Ihre Nahrungsaufnahme zu protokollieren.';

  @override
  String get onboarding_notificationsEnable => 'Benachrichtigungen aktivieren';

  @override
  String get finish => 'Fertig';

  @override
  String get notificationPermissionDenied => 'Benachrichtigungsberechtigung abgelehnt.';

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get deleteAccountProviderReauthRequired => 'Für das Löschen Ihres Kontos ist eine erneute Authentifizierung erforderlich. Melden Sie sich mit Ihrer ursprünglichen Anmeldemethode an und versuchen Sie es erneut.';

  @override
  String get enterPasswordLabel => 'Passwort';

  @override
  String get confirmButtonLabel => 'Bestätigen';

  @override
  String get googleSignInCancelledMessage => 'Google-Anmeldung vom Benutzer abgebrochen.';

  @override
  String get googleMissingIdToken => 'Konnte kein idToken von Google abrufen.';

  @override
  String get appleNullIdentityTokenMessage => 'Apple hat kein identityToken zurückgegeben.';

  @override
  String get deleteSportMessage => 'Sind Sie sicher, dass Sie diese Sportaktivität löschen möchten?';

  @override
  String get notificationBreakfastTitle => 'Zeit fürs Frühstück!';

  @override
  String get notificationBreakfastBody => 'Beginne deinen Tag mit einem nahrhaften Frühstück. Vergiss nicht, es zu protokollieren!';

  @override
  String get notificationLunchTitle => 'Mittagessen!';

  @override
  String get notificationLunchBody => 'Tanke Energie für den Nachmittag. Vergiss nicht, dein Mittagessen zu protokollieren!';

  @override
  String get notificationDinnerTitle => 'Guten Appetit!';

  @override
  String get notificationDinnerBody => 'Genieße dein Abendessen und denke daran, es zu protokollieren!';

  @override
  String get heightRange => 'Größe muss zwischen 50 und 300 cm liegen.';

  @override
  String get weightRange => 'Gewicht muss zwischen 20 und 800 kg liegen.';

  @override
  String get waistRange => 'Taillenumfang muss zwischen 30 und 200 cm liegen.';

  @override
  String get targetWeightRange => 'Zielgewicht muss zwischen 20 und 800 kg liegen.';

  @override
  String get sportsCaloriesInfoTitle => 'Sportaktivitäten';

  @override
  String get sportsCaloriesInfoTextOn => 'Ihr Tagesziel basiert auf Ihrem Aktivitätsniveau. Sportkalorien werden nun zu Ihrem Tagesgesamtwert hinzugefügt.';

  @override
  String get sportsCaloriesInfoTextOff => 'Ihr Tagesziel basiert auf Ihrem Aktivitätsniveau. Sportkalorien werden standardmäßig nicht zum Tagesgesamtwert hinzugefügt. Sie können dies in den Einstellungen ändern.';

  @override
  String get ok => 'OK';

  @override
  String get waterWarningSevere => 'Achtung: Trinke nicht zu viel. Weit über deinem Ziel kann gefährlich sein!';

  @override
  String get includeSportsCaloriesLabel => 'Sportkalorien einbeziehen';

  @override
  String get includeSportsCaloriesSubtitle => 'Fügen Sie die beim Sport verbrannten Kalorien zum Tagesgesamtwert hinzu (standardmäßig deaktiviert, da die Aktivität bereits über das Aktivitätsniveau berücksichtigt wird).';

  @override
  String get setAppVersionTitle => 'App-Version festlegen';

  @override
  String get setAppVersionSubtitle => 'Ändern Sie das Versionsfeld in Firestore';

  @override
  String get versionLabel => 'Version';

  @override
  String get versionUpdated => 'Version aktualisiert:';

  @override
  String get bmiForChildrenTitle => 'Kinder-BMI Info';

  @override
  String get bmiForChildrenExplanation => 'Der BMI von Kindern wird basierend auf Alter, Geschlecht, Größe und Gewicht berechnet. Anstelle fester Grenzen verwendet diese App BMI-Perzentile, sodass die Bewertung besser zum Wachstum der Kinder passt. Kleine Unterschiede zu anderen BMI-Tabellen sind normal.';

  @override
  String get privacyPolicy => 'Klicken Sie hier, um die Datenschutzerklärung anzusehen';

  @override
  String get privacyAgreement => 'Ich stimme der Datenschutzerklärung zu';

  @override
  String get sourcesName1 => 'Kalorienbedarf Formel';

  @override
  String get sourcesExplain1 => 'Täglicher Energie- und Kalorienbedarf';

  @override
  String get sourcesAttribution1 => 'Mifflin-St Jeor Formel, verwendet zur Schätzung von BMR und TDEE.';

  @override
  String get sourcesUrl1 => 'https://www.healthcarechain.nl/caloriebehoefte-calculator';

  @override
  String get sourcesName2 => 'Protein-, Fett- und Kohlenhydratbedarf';

  @override
  String get sourcesExplain2 => 'Makronährstoffbedarf (Kohlenhydrate, Fette, Proteine)';

  @override
  String get sourcesAttribution2 => 'Richtlinien für Energie aus Makronährstoffen gemäß niederländischen Ernährungsempfehlungen.';

  @override
  String get sourcesUrl2 => 'https://www.ru.nl/sites/default/files/2023-05/1a_basisvoeding_hoofddocument_mei_2021%20%282%29.pdf';

  @override
  String get sourcesName3 => 'BMI';

  @override
  String get sourcesExplain3 => 'Einteilung von Untergewicht, Normalgewicht, Übergewicht und Adipositas.';

  @override
  String get sourcesAttribution3 => 'WHO & CDC (weltweiter Standard für BMI-Klassifikation)';

  @override
  String get sourcesUrl3 => 'https://apps.who.int/nutrition/landscape/help.aspx?helpid=420&menu=0';

  @override
  String get sourcesName4 => 'ABSI';

  @override
  String get sourcesExplain4 => 'Ein besserer Risikoindikator als BMI, basierend auf Taillenumfang, Gewicht und Größe.';

  @override
  String get sourcesAttribution4 => 'Artikel und Informationen zum ABSI-Konzept (Englisch)';

  @override
  String get sourcesUrl4 => 'https://en.wikipedia.org/wiki/Body_shape_index';

  @override
  String get sourcesName5 => 'Kalorienverbrauch beim Sport';

  @override
  String get sourcesExplain5 => 'Geschätzter Energieverbrauch bei körperlicher Aktivität basierend auf MET-Werten, Gewicht und Dauer.';

  @override
  String get sourcesAttribution5 => 'Compendium of Physical Activities, Ainsworth BE et al., 2011';

  @override
  String get sourcesUrl5 => 'https://intuitionlabs.ai/software/cardiac-pulmonary-rehabilitation/metabolic-equivalent-met-calculation/mets-calculator';

  @override
  String get exactAlarmsTitle => 'Exakte Alarme';

  @override
  String get exactAlarmsMessage => 'Damit Erinnerungen an Mahlzeiten genau zur gewählten Zeit angezeigt werden, müssen Sie in den Android‑Einstellungen \"exakte Alarme\" aktivieren. Möchten Sie die Einstellungen jetzt öffnen?';

  @override
  String get exactAlarmsNotNow => 'Nicht jetzt';

  @override
  String get exactAlarmsOpenSettings => 'Einstellungen öffnen';

  @override
  String get disclaimerText => 'Diese App stellt allgemeine Informationen zu Ernährung, Flüssigkeitszufuhr, körperlicher Aktivität und Gewicht auf Grundlage öffentlich zugänglicher Richtlinien und wissenschaftlicher Quellen bereit. Die in dieser App enthaltenen Informationen und Berechnungen dienen ausschließlich zu Informationszwecken und stellen keine medizinische Beratung dar. Diese App ist nicht dazu bestimmt, eine professionelle medizinische Beratung, Diagnose oder Behandlung zu ersetzen. Bei gesundheitlichen Fragen oder Bedenken wenden Sie sich bitte immer an einen Arzt oder eine andere qualifizierte medizinische Fachkraft. Die Nutzung dieser App sowie die Interpretation der dargestellten Daten erfolgen vollständig auf eigene Verantwortung des Nutzers.';

  @override
  String get disclaimer => 'Haftungsausschluss';

  @override
  String get cannotOpenLink => 'Link kann nicht geöffnet werden';

  @override
  String get bronnen => 'Quellen';
}
