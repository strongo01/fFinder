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
}
