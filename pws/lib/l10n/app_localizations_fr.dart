// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get recipesTitle => 'Recettes';

  @override
  String get recipesSubtitle => 'Trouvez et gérez vos recettes favorites';

  @override
  String get encryptionKeyLoadError => 'Impossible de charger la clé de chiffrement.';

  @override
  String get encryptionKeyLoadSaveError => 'Impossible de charger la clé de chiffrement pour l\'enregistrement.';

  @override
  String get encryptedJson => 'JSON chiffré (nonce/cipher/tag)';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get mealNotifications => 'Rappels de repas';

  @override
  String get enableMealNotifications => 'Activer les rappels';

  @override
  String get breakfast => 'Petit-déjeuner';

  @override
  String get lunch => 'Déjeuner';

  @override
  String get dinner => 'Dîner';

  @override
  String get enableGifs => 'Afficher l\'animation de la mascotte (GIF)';

  @override
  String get restartTutorial => 'Recommencer le tutoriel';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get personalInfoDescription => 'Modifiez votre poids, taille, objectif et activité.';

  @override
  String get currentWeightKg => 'Poids actuel (kg)';

  @override
  String get enterCurrentWeight => 'Indiquez votre poids actuel';

  @override
  String get enterValidWeight => 'Veuillez saisir un poids valide';

  @override
  String get heightCm => 'Taille (cm)';

  @override
  String get enterHeight => 'Indiquez votre taille';

  @override
  String get enterHeightBetween100And250 => 'Veuillez saisir une taille entre 100 et 250 cm';

  @override
  String get waistCircumferenceCm => 'Tour de taille (cm)';

  @override
  String get targetWeightKg => 'Poids cible (kg)';

  @override
  String get enterTargetWeight => 'Indiquez votre poids cible';

  @override
  String get enterValidTargetWeight => 'Veuillez saisir un poids cible valide';

  @override
  String get sleepHoursPerNight => 'Sommeil (heures par nuit)';

  @override
  String get hours => 'heures';

  @override
  String get activityLevel => 'Niveau d\'activité';

  @override
  String get goal => 'Objectif';

  @override
  String get savingSettings => 'Enregistrement...';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get adminAnnouncements => 'Actions admin';

  @override
  String get createAnnouncement => 'Créer un message';

  @override
  String get createAnnouncementSubtitle => 'Publier un message pour tous les utilisateurs';

  @override
  String get manageAnnouncements => 'Gérer les messages';

  @override
  String get manageAnnouncementsSubtitle => 'Afficher, désactiver ou supprimer des messages';

  @override
  String get decryptValues => 'Déchiffrer';

  @override
  String get decryptValuesSubtitle => 'Déchiffrer les valeurs pour l\'utilisateur s\'il souhaite transférer son compte.';

  @override
  String get account => 'Compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deletingAccount => 'Suppression du compte...';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get credits => 'Crédits';

  @override
  String get creditsAbsiDataAttribution => 'Cet ensemble de données est utilisé pour le calcul des scores Z ABSI et des catégories dans cette application.';

  @override
  String get absiAttribution => 'La table de référence Body Shape Index (ABSI) est basée sur :\n\nY. Krakauer, Nir ; C. Krakauer, Jesse (2015).\nTable S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\nPLOS ONE. Dataset.\nhttps://doi.org/10.1371/journal.pone.0039504.s001\n\nCet ensemble de données est utilisé pour le calcul des scores Z ABSI et des catégories dans cette application.';

  @override
  String get date => 'Date';

  @override
  String get close => 'Fermer';

  @override
  String get editAnnouncement => 'Modifier le message';

  @override
  String get title => 'Titre';

  @override
  String get titleCannotBeEmpty => 'Le titre ne peut pas être vide.';

  @override
  String get message => 'Message';

  @override
  String get messageCannotBeEmpty => 'Le message ne peut pas être vide.';

  @override
  String get cancel => 'Annuler';

  @override
  String get announcementUpdated => 'Message mis à jour.';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get announcementDeleted => 'Message supprimé.';

  @override
  String get errorLoadingAnnouncements => 'Une erreur est survenue.';

  @override
  String get noAnnouncementsFound => 'Aucun message trouvé.';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String get createdAt => 'Créé le';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get activate => 'Activer';

  @override
  String get deactivate => 'Désactiver';

  @override
  String get editAnnouncementTooltip => 'Modifier le message';

  @override
  String get language => 'Langue';

  @override
  String get useSystemLocale => 'Utiliser la langue du système';

  @override
  String get activityLow => 'Faible activité : travail sédentaire, peu de mouvement, pas de sport';

  @override
  String get activityLight => 'Activité légère : 1–3x par semaine entraînement léger ou 30–45 min de marche quotidienne';

  @override
  String get activityMedium => 'Activité moyenne : sport 3–5x par semaine ou métier actif (restauration, soins, facteur)';

  @override
  String get activityVery => 'Très actif : entraînement intensif 6–7x par semaine ou travail physiquement exigeant (construction, entrepôt)';

  @override
  String get activityExtreme => 'Extrêmement actif : entraînement de haut niveau 2× par jour ou travail physiquement extrême (militaire, sylviculture)';

  @override
  String get goalLose => 'Perdre du poids';

  @override
  String get goalMaintain => 'Maintenir le poids';

  @override
  String get goalGainMuscle => 'Prendre du poids (muscle)';

  @override
  String get goalGainGeneral => 'Prendre du poids (général)';

  @override
  String get createAnnouncementTitle => 'Publier un nouveau message';

  @override
  String get messageLabel => 'Message';

  @override
  String get messageValidationError => 'Le message ne peut pas être vide.';

  @override
  String get announcementPublishedSuccess => 'Message publié avec succès !';

  @override
  String get publishButtonLabel => 'Publier';

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get unsavedChangesMessage => 'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir quitter sans enregistrer ?';

  @override
  String get discardButtonLabel => 'Ignorer les modifications';

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String get tutorialRestartedMessage => 'Le tutoriel a été relancé !';

  @override
  String get deleteAnnouncementTooltip => 'Supprimer';

  @override
  String get duplicateRequestError => 'Il existe déjà une demande en cours pour cette valeur.';

  @override
  String get requestSubmittedSuccess => 'Demande de déchiffrement soumise pour approbation.';

  @override
  String get requestSubmissionFailed => 'Échec de la soumission de la demande';

  @override
  String get requestNotFound => 'Demande non trouvée';

  @override
  String get cannotApproveOwnRequest => 'Vous ne pouvez pas approuver votre propre demande.';

  @override
  String get dekNotFoundForUser => 'Impossible de récupérer la clé de chiffrement.';

  @override
  String get requestApprovedSuccess => 'Demande approuvée.';

  @override
  String get requestApprovalFailed => 'Échec de l\'approbation';

  @override
  String get cannotRejectOwnRequest => 'Vous ne pouvez pas rejeter votre propre demande.';

  @override
  String get requestRejectedSuccess => 'Demande rejetée.';

  @override
  String get requestRejectionFailed => 'Échec du rejet';

  @override
  String get pleaseEnterUid => 'Veuillez saisir un UID';

  @override
  String get pleaseEnterEncryptedJson => 'Collez le JSON chiffré';

  @override
  String get submit => 'Soumettre';

  @override
  String get submitRequest => 'Soumettre la demande';

  @override
  String get loading => 'Chargement...';

  @override
  String get pendingRequests => 'Demandes en attente';

  @override
  String get noPendingRequests => 'Aucune demande trouvée.';

  @override
  String get forUid => 'Pour UID';

  @override
  String get requestedBy => 'Demandé par';

  @override
  String get encryptedJsonLabel => 'Valeur chiffrée :';

  @override
  String get reject => 'Rejeter';

  @override
  String get approve => 'Approuver';

  @override
  String get confirmSignOutTitle => 'Se déconnecter';

  @override
  String get confirmSignOutMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get confirmDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get confirmDeleteAccountMessage => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cela ne peut pas être annulé.';

  @override
  String get deletionCodeInstruction => 'Recopiez le code ci-dessous pour confirmer :';

  @override
  String get enterDeletionCodeLabel => 'Entrez le code à 6 chiffres';

  @override
  String get deletionCodeMismatchError => 'Code incorrect, veuillez réessayer.';

  @override
  String get deleteAccountButtonLabel => 'Supprimer';

  @override
  String get settingsSavedSuccessMessage => 'Paramètres enregistrés';

  @override
  String get settingsSaveFailedMessage => 'Échec de l\'enregistrement';

  @override
  String get profileLoadFailedMessage => 'Impossible de charger le profil';

  @override
  String get deleteAccountRecentLoginError => 'Reconnectez-vous et réessayez pour supprimer votre compte.';

  @override
  String get deleteAccountFailedMessage => 'Échec de la suppression';

  @override
  String get titleLabel => 'Titre';

  @override
  String get titleValidationError => 'Le titre ne peut pas être vide.';

  @override
  String get untitled => 'Sans titre';

  @override
  String get appCredits => 'Attribution des données ABSI';

  @override
  String get reportThanks => 'Merci pour votre rapport !';

  @override
  String get errorSending => 'Erreur lors de l\'envoi';

  @override
  String get commentOptional => 'Commentaire (optionnel)';

  @override
  String get reportTitle => 'Signaler des éléments';

  @override
  String get categoryFunctionality => 'Fonctionnalité';

  @override
  String get itemFeatures => 'Fonctionnalités';

  @override
  String get itemFunctionality => 'Fonctionnalité';

  @override
  String get itemUsability => 'Ergonomie';

  @override
  String get itemClarity => 'Clarté';

  @override
  String get itemAccuracy => 'Précision';

  @override
  String get itemNavigation => 'Navigation';

  @override
  String get categoryPerformance => 'Performance';

  @override
  String get itemSpeed => 'Vitesse';

  @override
  String get itemLoadingTimes => 'Temps de chargement';

  @override
  String get itemStability => 'Stabilité';

  @override
  String get categoryInterfaceDesign => 'Interface & Design';

  @override
  String get itemLayout => 'Disposition';

  @override
  String get itemColorsTheme => 'Couleurs & Thème';

  @override
  String get itemIconsDesign => 'Icônes & Design';

  @override
  String get itemReadability => 'Lisibilité';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get itemErrors => 'Messages d\'erreur';

  @override
  String get itemExplanation => 'Explications & Instructions';

  @override
  String get categoryAppParts => 'Parties de l\'application';

  @override
  String get itemDashboard => 'Tableau de bord';

  @override
  String get itemLogin => 'Connexion / Inscription';

  @override
  String get itemWeight => 'Poids';

  @override
  String get itemStatistics => 'Statistiques';

  @override
  String get itemCalendar => 'Calendrier';

  @override
  String get categoryOther => 'Autre';

  @override
  String get itemGeneralSatisfaction => 'Satisfaction générale';

  @override
  String get send => 'Envoyer';

  @override
  String get feedbackTitle => 'Donnez votre avis';

  @override
  String get viewAllFeedback => 'Voir tous les avis';

  @override
  String get viewAllRapportFeedback => 'Voir tous les avis du rapport';

  @override
  String get openRapportButton => 'Touchez pour remplir le rapport !\nAttention : il s\'agit d\'un questionnaire approfondi. Ne le remplissez que si vous avez testé l\'application plusieurs jours.';

  @override
  String get feedbackIntro => 'Ici, vous pouvez à tout moment donner votre avis.';

  @override
  String get choiceBug => 'Bug';

  @override
  String get choiceFeature => 'Nouvelle fonctionnalité';

  @override
  String get choiceLanguage => 'Langue';

  @override
  String get choiceLayout => 'Disposition';

  @override
  String get choiceOther => 'Autre';

  @override
  String get languageSectionInstruction => 'Indiquez la langue concernée et décrivez l\'erreur. La langue par défaut est celle sélectionnée dans l\'application.';

  @override
  String get dropdownLabelLanguage => 'Langue concernée par le feedback';

  @override
  String get messageHint => 'Que voulez-vous nous dire ?';

  @override
  String get enterMessage => 'Entrez un message';

  @override
  String get emailHintOptional => 'E-mail (optionnel)';

  @override
  String get allFeedbackTitle => 'Tous les avis';

  @override
  String get noFeedbackFound => 'Aucun avis trouvé.';

  @override
  String get errorOccurred => 'Une erreur est survenue.';

  @override
  String get noMessage => 'Aucun message';

  @override
  String get unknownType => 'Inconnu';

  @override
  String get appLanguagePrefix => 'App : ';

  @override
  String get reportedLanguagePrefix => 'Signalé : ';

  @override
  String get submittedOnPrefix => 'Soumis le : ';

  @override
  String get uidLabelPrefix => 'UID : ';

  @override
  String get couldNotOpenMailAppPrefix => 'Impossible d\'ouvrir l\'application mail : ';

  @override
  String get allRapportFeedbackTitle => 'Tous les avis du rapport';

  @override
  String get noRapportFeedbackFound => 'Aucun avis du rapport trouvé.';

  @override
  String get rapportFeedbackTitle => 'Avis du rapport';

  @override
  String get weightTitle => 'Votre poids';

  @override
  String get weightSubtitle => 'Modifiez votre poids et consultez votre IMC.';

  @override
  String get weightLabel => 'Poids (kg)';

  @override
  String get targetWeightLabel => 'Poids cible (kg)';

  @override
  String get weightSliderLabel => 'Curseur de poids';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get saveWeight => 'Enregistrer le poids';

  @override
  String get saveWaist => 'Enregistrer le tour de taille';

  @override
  String get saveSuccess => 'Poids + objectifs enregistrés';

  @override
  String get saveFailedPrefix => 'Échec de l\'enregistrement :';

  @override
  String get weightLoadErrorPrefix => 'Impossible de charger les données utilisateur :';

  @override
  String get bmiTitle => 'IMC';

  @override
  String get bmiInsufficient => 'Données insuffisantes pour calculer l\'IMC. Veuillez saisir votre taille et votre poids.';

  @override
  String get yourBmiPrefix => 'Votre IMC :';

  @override
  String get waistAbsiTitle => 'Tour de taille / ABSI';

  @override
  String get waistLabel => 'Tour de taille (cm)';

  @override
  String get absiInsufficient => 'Données insuffisantes pour calculer l\'ABSI. Veuillez saisir le tour de taille, la taille et le poids.';

  @override
  String get yourAbsiPrefix => 'Votre ABSI :';

  @override
  String get absiLowRisk => 'Faible risque';

  @override
  String get absiMedium => 'Risque moyen';

  @override
  String get choiceWeight => 'Poids';

  @override
  String get choiceWaist => 'Taille';

  @override
  String get choiceTable => 'Table';

  @override
  String get choiceChart => 'Graphique (par mois)';

  @override
  String get noMeasurements => 'Aucune mesure enregistrée pour le moment.';

  @override
  String get noWaistMeasurements => 'Aucune mesure de tour de taille enregistrée.';

  @override
  String get tableMeasurementsTitle => 'Table des mesures';

  @override
  String get deleteConfirmTitle => 'Supprimer ?';

  @override
  String get deleteConfirmContent => 'Êtes-vous sûr de vouloir supprimer cette mesure ?';

  @override
  String get deleteConfirmDelete => 'Supprimer';

  @override
  String get measurementDeleted => 'Mesure supprimée';

  @override
  String get chartTitlePrefix => 'Graphique –';

  @override
  String get chartTooFew => 'Trop peu de mesures ce mois-ci pour afficher un graphique.';

  @override
  String get chartAxesLabel => 'Horizontal : jours du mois, Vertical : valeur';

  @override
  String get estimateNotEnoughData => 'Pas assez de données pour calculer une tendance.';

  @override
  String get estimateOnTarget => 'Bravo ! Vous êtes sur votre poids cible.';

  @override
  String get estimateNoTrend => 'Aucune tendance calculable pour le moment.';

  @override
  String get estimateStable => 'Votre poids est relativement stable, pas de tendance fiable.';

  @override
  String get estimateWrongDirection => 'Avec la tendance actuelle, vous vous éloignez de votre poids cible.';

  @override
  String get estimateInsufficientInfo => 'Informations de tendance insuffisantes pour une estimation réaliste.';

  @override
  String get estimateUnlikelyWithin10Years => 'Avec la tendance actuelle, il est peu probable que vous atteigniez votre poids cible dans les 10 ans.';

  @override
  String get estimateUncertaintyHigh => 'Attention : de grandes fluctuations rendent cette estimation peu fiable.';

  @override
  String get estimateUncertaintyMedium => 'Attention : des fluctuations importantes rendent cette estimation incertaine.';

  @override
  String get estimateUncertaintyLow => 'Remarque : légère variation — l\'estimation peut différer.';

  @override
  String get estimateBasisRecent => 'sur la base du dernier mois';

  @override
  String get estimateBasisAll => 'sur la base de toutes les mesures';

  @override
  String get estimateResultPrefix => 'Si vous continuez ainsi (), vous atteindrez votre poids cible dans environ';

  @override
  String get bmiVeryLow => 'Beaucoup trop bas';

  @override
  String get bmiLow => 'Bas';

  @override
  String get bmiGood => 'Bien';

  @override
  String get bmiHigh => 'Trop élevé';

  @override
  String get bmiVeryHigh => 'Beaucoup trop élevé';

  @override
  String get thanksFeedback => 'Merci pour votre avis !';

  @override
  String get absiVeryLowRisk => 'Très faible risque';

  @override
  String get absiIncreasedRisk => 'Risque accru';

  @override
  String get recipesSwipeInstruction => 'Faites glisser pour enregistrer ou passer les recettes.';

  @override
  String get recipesNoMore => 'Plus de recettes.';

  @override
  String get recipesSavedPrefix => 'Enregistré : ';

  @override
  String get recipesSkippedPrefix => 'Passé : ';

  @override
  String get recipesDetailId => 'ID';

  @override
  String get recipesDetailPreparationTime => 'Temps de préparation';

  @override
  String get recipesDetailTotalTime => 'Temps total';

  @override
  String get recipesDetailKcal => 'Calories';

  @override
  String get recipesDetailFat => 'Matières grasses';

  @override
  String get recipesDetailSaturatedFat => 'Acides gras saturés';

  @override
  String get recipesDetailCarbs => 'Glucides';

  @override
  String get recipesDetailProtein => 'Protéines';

  @override
  String get recipesDetailFibers => 'Fibres';

  @override
  String get recipesDetailSalt => 'Sel';

  @override
  String get recipesDetailPersons => 'Personnes';

  @override
  String get recipesDetailDifficulty => 'Difficulté';

  @override
  String get recipesPrepreparation => 'Préparation';

  @override
  String get recipesIngredients => 'Ingrédients';

  @override
  String get recipesSteps => 'Étapes de préparation';

  @override
  String get recipesKitchens => 'Cuisines';

  @override
  String get recipesCourses => 'Plat';

  @override
  String get recipesRequirements => 'Ustensiles nécessaires';

  @override
  String get water => 'Eau';

  @override
  String get coffee => 'Café';

  @override
  String get tea => 'Thé';

  @override
  String get soda => 'Boisson gazeuse';

  @override
  String get other => 'Autre';

  @override
  String get coffeeBlack => 'Café noir';

  @override
  String get espresso => 'Espresso';

  @override
  String get ristretto => 'Ristretto';

  @override
  String get lungo => 'Lungo';

  @override
  String get americano => 'Americano';

  @override
  String get coffeeWithMilk => 'Café au lait';

  @override
  String get coffeeWithMilkSugar => 'Café au lait + sucre';

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
  String get icedCoffee => 'Café glacé';

  @override
  String get otherCoffee => 'Autre café';

  @override
  String get newDrinkTitle => 'Ajouter une boisson';

  @override
  String get chooseDrink => 'Choisir une boisson';

  @override
  String get chooseCoffeeType => 'Choisir le type de café';

  @override
  String get drinkNameLabel => 'Nom de la boisson';

  @override
  String get nameRequired => 'Le nom est obligatoire';

  @override
  String get amountMlLabel => 'Quantité (ml)';

  @override
  String get amountRequired => 'La quantité est obligatoire';

  @override
  String get enterNumber => 'Entrez un nombre';

  @override
  String get kcalPer100Label => 'kcal pour 100 ml';

  @override
  String get barcodeSearchTooltip => 'Rechercher par code-barres';

  @override
  String get kcalRequired => 'La valeur kcal est obligatoire';

  @override
  String get addDrinkTitle => 'Ajouter une boisson';

  @override
  String get addButton => 'Ajouter';

  @override
  String get addAndLogButton => 'Ajouter et journaliser';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get scanPasteBarcode => 'Scanner / coller le code-barres';

  @override
  String get barcodeLabel => 'Code-barres (EAN/GTIN)';

  @override
  String get enterBarcode => 'Entrez le code-barres';

  @override
  String get searching => 'Recherche...';

  @override
  String get noKcalFoundPrefix => 'Aucune valeur kcal trouvée pour le code-barres ';

  @override
  String get foundPrefix => 'Trouvé : ';

  @override
  String get kcalPer100Unit => ' kcal pour 100g/ml';

  @override
  String get whenDrankTitle => 'Quand consommé ?';

  @override
  String get snack => 'En-cas';

  @override
  String get loginToLog => 'Connectez-vous pour journaliser';

  @override
  String get editDrinkTitle => 'Modifier la boisson';

  @override
  String get nameLabel => 'Nom';

  @override
  String get delete => 'Supprimer';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get added => 'ajouté';

  @override
  String get sportAddTitle => 'Ajouter un sport';

  @override
  String get newSportActivity => 'Nouvelle activité sportive';

  @override
  String get labelSport => 'Sport';

  @override
  String get chooseSport => 'Choisir un sport';

  @override
  String get customSportName => 'Nom du sport';

  @override
  String get enterSportName => 'Veuillez entrer un nom de sport';

  @override
  String get durationMinutes => 'Durée (minutes)';

  @override
  String get invalidDuration => 'Veuillez saisir une durée valide';

  @override
  String get caloriesBurned => 'Calories brûlées';

  @override
  String get invalidCalories => 'Veuillez saisir un nombre de calories valide';

  @override
  String get save => 'Enregistrer';

  @override
  String get encryptionKeyNotFound => 'Clé de chiffrement introuvable.';

  @override
  String get noSportsYet => 'Aucune activité sportive pour le moment.';

  @override
  String get durationLabel => 'Durée (minutes)';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get minutesShort => 'minutes';

  @override
  String get intensityLevel => 'Intensité';

  @override
  String get intensityLight => 'Léger';

  @override
  String get intensityNormal => 'Normal';

  @override
  String get intensityHard => 'Intense';

  @override
  String get intensityVeryHard => 'Très intense';

  @override
  String get userNotLoggedIn => 'Non connecté.';

  @override
  String get sportAdded => 'Activité sportive ajoutée';

  @override
  String get sportRunning => 'Course à pied';

  @override
  String get sportCycling => 'Cyclisme';

  @override
  String get sportSwimming => 'Natation';

  @override
  String get sportWalking => 'Marche';

  @override
  String get sportFitness => 'Fitness';

  @override
  String get sportFootball => 'Football';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportOther => 'Autre';

  @override
  String get deleteSportTitle => 'Supprimer l\'activité sportive';

  @override
  String get deleteSportContent => 'Cette action ne peut pas être annulée.';

  @override
  String get sportDeleted => 'Activité sportive supprimée';

  @override
  String get editSportTitle => 'Modifier l\'activité sportive';

  @override
  String get sportUpdated => 'Activité sportive mise à jour';

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get addSportTitle => 'Ajouter un sport';

  @override
  String get sportLabel => 'Sport';

  @override
  String get customSportLabel => 'Nom du sport';

  @override
  String get customSportRequired => 'Veuillez entrer un nom de sport';

  @override
  String get logSportTitle => 'Journaliser une activité sportive';

  @override
  String get intensityHeavy => 'Intense';

  @override
  String get intensityVeryHeavy => 'Très intense';

  @override
  String get intensityLabel => 'Intensité';

  @override
  String get enterValidDuration => 'Veuillez saisir une durée valide';

  @override
  String get caloriesBurnedLabel => 'Calories brûlées';

  @override
  String get enterValidCalories => 'Veuillez saisir un nombre de calories valide';

  @override
  String get durationShort => 'Durée :';

  @override
  String get caloriesShort => 'Calories :';

  @override
  String get saveSportFailedPrefix => 'Échec de l\'enregistrement :';

  @override
  String get unsavedChangesContent => 'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir les ignorer ?';

  @override
  String get searchFood => 'Rechercher des aliments';

  @override
  String get searchFoodDescription => 'Recherchez des aliments à ajouter à votre journée.';

  @override
  String get scanProduct => 'Scanner un code-barres';

  @override
  String get scanProductDescription => 'Touchez ici pour scanner un produit et l\'ajouter rapidement à votre journée.';

  @override
  String get recentProducts => 'Produits récents';

  @override
  String get recentProductsDescription => 'Ici, vous voyez tous les produits que vous avez ajoutés récemment.';

  @override
  String get favoriteProducts => 'Favoris';

  @override
  String get favoriteProductsDescription => 'Ici, vous pouvez consulter tous vos produits favoris.';

  @override
  String get myProducts => 'Mes produits';

  @override
  String get myProductsDescription => 'Ici, vous pouvez ajouter vos propres produits qui ne sont pas trouvés.';

  @override
  String get meals => 'Repas';

  @override
  String get mealsDescription => 'Ici, vous pouvez voir et journaliser des repas ; un repas est composé de plusieurs produits.';

  @override
  String get mealsAdd => 'Ajouter des repas';

  @override
  String get mealsAddDescription => 'Touchez le bouton + pour créer des repas à partir de plusieurs produits afin d\'ajouter plus rapidement des repas que vous prenez souvent.';

  @override
  String get mealsLog => 'Journaliser des repas';

  @override
  String get mealsLogDescription => 'Touchez le chariot pour ajouter des repas aux journaux.';

  @override
  String get enterMoreChars => 'Veuillez entrer au moins 2 caractères.';

  @override
  String get errorFetch => 'Erreur lors de la récupération';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get noImageSelected => 'Aucune image sélectionnée.';

  @override
  String get aiNoIngredientsFound => 'Aucun résultat de l\'IA.';

  @override
  String aiIngredientsPrompt(Object ingredient) {
    return 'Quels ingrédients voyez-vous ici ? Répondez en français. Ignorez les termes marketing, les noms de produits et les mots non pertinents tels que « zero », « light », etc. Répondez uniquement avec les ingrédients réels contenus dans le produit. Répondez seulement si l\'image montre un produit alimentaire. Répondez sous la forme : $ingredient, $ingredient, ...';
  }

  @override
  String get aiIngredientsFound => 'Ingrédients trouvés :';

  @override
  String get aiIngredientsDescription => 'L\'IA a reconnu les ingrédients suivants :';

  @override
  String get addMeal => 'Composer un repas';

  @override
  String get errorAI => 'Erreur lors de l\'analyse IA :';

  @override
  String get amount => 'Quantité';

  @override
  String get search => 'Rechercher';

  @override
  String get loadMore => 'Charger plus de produits...';

  @override
  String get errorNoBarcode => 'Aucun code-barres trouvé pour ce produit.';

  @override
  String get amountInGrams => 'Quantité (g)';

  @override
  String get errorUserDEKMissing => 'Impossible de récupérer la clé de chiffrement.';

  @override
  String get errorNoIngredientsAdded => 'Ajoutez au moins un produit.';

  @override
  String get mealSavedSuccessfully => 'Repas enregistré !';

  @override
  String get saveMeal => 'Enregistrer le repas';

  @override
  String get errorFetchRecentsProducts => 'Erreur lors de la récupération des produits récents';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get add => 'Ajouter';

  @override
  String get addFoodItem => 'Que voulez-vous ajouter ?';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get addMealT => 'Ajouter un repas';

  @override
  String get recents => 'Récents';

  @override
  String get favorites => 'Favoris';

  @override
  String get searchingProducts => 'Commencez à taper pour rechercher.';

  @override
  String get noProductsFound => 'Aucun produit trouvé.';

  @override
  String get addNewProduct => 'Souhaitez-vous ajouter vous-même un produit ?';

  @override
  String get errorInvalidBarcode => 'Aucun code-barres trouvé pour ce produit.';

  @override
  String get loadMoreResults => 'Charger plus de produits…';

  @override
  String get notTheDesiredResults => 'Ajoutez un nouveau produit';

  @override
  String get addNewProductT => 'Ajouter un nouveau produit';

  @override
  String get errorProductNameRequired => 'Le nom est requis';

  @override
  String get brandName => 'Marque';

  @override
  String get quantity => 'Quantité (ex. 100g, 250ml)';

  @override
  String get nutritionalValuesPer100g => 'Valeurs nutritionnelles pour 100g ou ml';

  @override
  String get calories => 'Énergie (kcal)';

  @override
  String get errorCaloriesRequired => 'Les calories sont requises';

  @override
  String get fat => 'Lipides';

  @override
  String get saturatedFat => '  - Dont saturés';

  @override
  String get carbohydrates => 'Glucides';

  @override
  String get sugars => '  - Dont sucres';

  @override
  String get fiber => 'Fibres';

  @override
  String get proteins => 'Protéines';

  @override
  String get salt => 'Sel';

  @override
  String get errorEncryptionKeyMissing => 'Erreur : impossible de récupérer la clé de chiffrement.';

  @override
  String get saveProduct => 'Enregistrer';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unnamedProduct => 'Nom inconnu';

  @override
  String get logInToSeeRecents => 'Connectez-vous pour voir vos produits récents.';

  @override
  String get noRecentProductsFound => 'Aucun produit récent trouvé.';

  @override
  String get errorLoadingRecentProducts => 'Une erreur est survenue.';

  @override
  String get logInToSeeFavorites => 'Connectez-vous pour voir vos produits favoris.';

  @override
  String get noFavoriteProductsFound => 'Aucun produit favori trouvé.';

  @override
  String get errorLoadingFavoriteProducts => 'Une erreur est survenue.';

  @override
  String get logInToSeeMyProducts => 'Connectez-vous pour voir vos produits.';

  @override
  String get noMyProductsFound => 'Vous n\'avez encore créé aucun produit.';

  @override
  String get errorLoadingMyProducts => 'Une erreur est survenue.';

  @override
  String get unknownBrand => 'Aucune marque';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get sure => 'Êtes-vous sûr de vouloir ';

  @override
  String get willBeDeleted => ' supprimer ?';

  @override
  String get deleted => 'supprimé';

  @override
  String get logInToSeeMeals => 'Connectez-vous pour voir vos repas.';

  @override
  String get errorLoadingMeals => 'Une erreur est survenue.';

  @override
  String get mealExample => 'Exemple de repas';

  @override
  String get createOwnMealsFirst => 'Cliquez sur + pour créer votre premier repas';

  @override
  String get logMeal => 'Journaliser le repas';

  @override
  String get createMealsBeforeLogging => 'Ceci est un exemple. Créez d\'abord un repas personnalisé.';

  @override
  String get unnamedMeal => 'Repas sans nom';

  @override
  String get sureMeal => 'Êtes-vous sûr de vouloir le repas ';

  @override
  String get meal => 'Repas ';

  @override
  String get encryptionKeyError => 'Impossible de récupérer la clé de chiffrement.';

  @override
  String get mealNoIngredients => 'Ce repas n\'a pas d\'ingrédients.';

  @override
  String get mealLoggedSuccessfully => ' ajouté à votre journal.';

  @override
  String get errorSaveMeal => 'Erreur lors de l\'enregistrement du repas :';

  @override
  String get sectie => 'Section';

  @override
  String get log => 'Journal';

  @override
  String get mealAddAtLeastOneIngredient => 'Ajoutez au moins un produit.';

  @override
  String get editMeal => 'Modifier le repas';

  @override
  String get addNewMeal => 'Composer un nouveau repas';

  @override
  String get mealName => 'Nom du repas';

  @override
  String get pleaseEnterMealName => 'Le nom est obligatoire';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get searchProductHint => 'Tapez pour rechercher ou scannez le code-barres';

  @override
  String get selectProduct => 'Choisir un produit';

  @override
  String get scanBarcode => 'Scanner le code-barres pour ce produit';

  @override
  String get searchForBarcode => 'Recherche par code-barres...';

  @override
  String get errorFetchingProductData => 'Produit introuvable sur OpenFoodFacts';

  @override
  String get productNotFound => 'Aucune donnée produit trouvée';

  @override
  String get errorBarcodeFind => 'Erreur lors de la recherche par code-barres : ';

  @override
  String get errorFetchingProductDataBarcode => 'Aucun code-barres trouvé pour ce produit.';

  @override
  String get addIngredient => 'Ajoutez un autre produit';

  @override
  String get editMyProduct => 'Modifier le produit';

  @override
  String get productName => 'Nom du produit';

  @override
  String get productNameRequired => 'Le nom est requis';

  @override
  String get caloriesRequired => 'Les calories sont requises';

  @override
  String get errorUserDEKNotFound => 'Impossible de récupérer la clé de chiffrement.';

  @override
  String get unknownProduct => 'Produit inconnu';

  @override
  String get brand => 'Marque';

  @override
  String get servingSize => 'Taille de la portion';

  @override
  String get nutritionalValuesPer100mlg => 'Valeurs nutritionnelles pour 100g/ml';

  @override
  String get saveMyProduct => 'Enregistrer mon produit';

  @override
  String get amountFor => 'Quantité pour ';

  @override
  String get amountGML => 'Quantité (grammes ou millilitres)';

  @override
  String get gramsMillilitersAbbreviation => 'g/ml';

  @override
  String get invalidAmount => 'Veuillez saisir une quantité valide.';

  @override
  String get addedToLog => ' ajouté à votre journal.';

  @override
  String get errorSaving => 'Erreur lors de l\'enregistrement : ';

  @override
  String get photoAnalyzing => 'Analyse de la photo...';

  @override
  String get ingredientsIdentifying => 'Identification des ingrédients...';

  @override
  String get nutritionalValuesEstimating => 'Estimation des informations nutritionnelles...';

  @override
  String get patientlyWaiting => 'Veuillez patienter...';

  @override
  String get almostDone => 'Presque terminé...';

  @override
  String get processingWithAI => 'Traitement par IA en cours...';

  @override
  String get selectMealType => 'Sélectionnez le type de repas';

  @override
  String get section => 'Section';

  @override
  String get saveNameTooltip => 'Enregistrer';

  @override
  String get noChangesTooltip => 'Aucune modification';

  @override
  String get fillRequiredKcal => 'Remplissez tous les champs obligatoires (kcal).';

  @override
  String get additivesLabel => 'Additifs';

  @override
  String get allergensLabel => 'Allergènes';

  @override
  String get mealAmountLabel => 'Quantité pour le repas';

  @override
  String get addToMealButton => 'Ajouter au repas';

  @override
  String get enterAmount => 'Saisissez une quantité';

  @override
  String get unitLabel => 'Unité';

  @override
  String get gramLabel => 'Grammes (g)';

  @override
  String get milliliterLabel => 'Millilitres (ml)';

  @override
  String get errorLoadingLocal => 'Erreur lors du chargement des données locales : ';

  @override
  String get errorFetching => 'Erreur lors de la récupération : ';

  @override
  String get nameSaved => 'Nom enregistré';

  @override
  String get enterValue => 'Valeur manquante';

  @override
  String get requiredField => 'Champ requis';

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get done => 'Terminé';

  @override
  String get logs => 'Journaux';

  @override
  String get add_food_label => 'Ajouter un aliment';

  @override
  String get add_drink_label => 'Ajouter une boisson';

  @override
  String get add_sport_label => 'Ajouter un sport';

  @override
  String get tutorial_date_title => 'Changer la date';

  @override
  String get tutorial_date_text => 'Touchez ici pour choisir une date ou revenir rapidement à aujourd\'hui.';

  @override
  String get tutorial_barcode_title => 'Scanner un code-barres';

  @override
  String get tutorial_barcode_text => 'Touchez ici pour scanner un produit et l\'ajouter rapidement à votre journée.';

  @override
  String get tutorial_settings_title => 'Paramètres';

  @override
  String get tutorial_settings_text => 'Cette page permet de modifier vos données, l\'heure des notifications ou d\'autres paramètres.';

  @override
  String get tutorial_feedback_title => 'Retour';

  @override
  String get tutorial_feedback_text => 'Ici, vous pouvez donner votre avis sur l\'application. Quelque chose ne fonctionne pas ou vous souhaitez une fonctionnalité ? Dites-le nous !';

  @override
  String get tutorial_calorie_title => 'Résumé des calories';

  @override
  String get tutorial_calorie_text => 'Ici, vous voyez un résumé de votre apport calorique pour la journée.';

  @override
  String get tutorial_mascot_title => 'Reppy';

  @override
  String get tutorial_mascot_text => 'Reppy offre motivation personnelle et conseils !';

  @override
  String get tutorial_water_title => 'Hydratation';

  @override
  String get tutorial_water_text => 'Suivez ici votre consommation d\'eau quotidienne. Le cercle montre combien il vous reste à boire pour atteindre votre objectif.';

  @override
  String get tutorial_additems_title => 'Ajouter des éléments';

  @override
  String get tutorial_additems_text => 'Utilisez ce bouton pour ajouter rapidement des repas, boissons ou activités sportives.';

  @override
  String get tutorial_meals_title => 'Repas';

  @override
  String get tutorial_meals_text => 'Consultez vos repas et modifiez-les en les touchant.';

  @override
  String get updateAvailable => 'Une nouvelle mise à jour est disponible ! Mettez à jour l\'application via TestFlight pour Apple ou via Google Play Store pour Android.';

  @override
  String get announcement_default => 'Annonce';

  @override
  String get water_goal_dialog_title => 'Définir l\'objectif d\'eau';

  @override
  String get water_goal_dialog_label => 'Objectif (ml)';

  @override
  String get enter_valid_number => 'Veuillez saisir un nombre valide';

  @override
  String get water_goal_updated => 'Objectif d\'eau mis à jour';

  @override
  String get error_saving_water_goal => 'Erreur lors de l\'enregistrement de l\'objectif d\'eau : ';

  @override
  String get calorie_goal_dialog_title => 'Définir l\'objectif calorique';

  @override
  String get calorie_goal_dialog_label => 'Objectif quotidien (kcal)';

  @override
  String get calorie_goal_updated => 'Objectif calorique mis à jour';

  @override
  String get error_saving_prefix => 'Échec de l\'enregistrement : ';

  @override
  String get eaten => 'Consommé';

  @override
  String get remaining => 'Restant';

  @override
  String get over_goal => 'Au-dessus de l\'objectif';

  @override
  String get calories_over_goal => 'kcal au-dessus de l\'objectif';

  @override
  String get calories_remaining => 'kcal restants';

  @override
  String get calories_consumed => 'kcal consommés';

  @override
  String get carbs => 'Glucides';

  @override
  String get fats => 'Lipides';

  @override
  String get unit => 'Unité';

  @override
  String get edit_amount_dialog_title_ml => 'Ajuster la quantité (ml)';

  @override
  String get edit_amount_dialog_title_g => 'Ajuster la quantité (g)';

  @override
  String get edit_amount_label_ml => 'Quantité (ml)';

  @override
  String get edit_amount_label_g => 'Quantité (g)';

  @override
  String get totalConsumed => 'Total consommé';

  @override
  String get youHave => 'Vous avez';

  @override
  String get motivational_default_1 => 'Bien joué, continuez comme ça !';

  @override
  String get motivational_default_2 => 'Appuyez sur moi pour voir une nouvelle phrase !';

  @override
  String get motivational_default_3 => 'Chaque pas compte !';

  @override
  String get motivational_default_4 => 'Vous faites du super travail !';

  @override
  String get motivational_default_5 => 'Saviez-vous que fFinder est l\'abréviation de FoodFinder ?';

  @override
  String get motivational_default_6 => 'Vous journalisez mieux que 97 % des gens... probablement.';

  @override
  String get motivational_noEntries_1 => 'Prêt à journaliser votre journée ?';

  @override
  String get motivational_noEntries_2 => 'Un nouveau jour, de nouvelles opportunités !';

  @override
  String get motivational_noEntries_3 => 'Commençons !';

  @override
  String get motivational_noEntries_4 => 'Chaque journée saine commence par une entrée.';

  @override
  String get motivational_noEntries_5 => 'Votre premier repas est caché. Cherchez-le !';

  @override
  String get motivational_drinksOnly_1 => 'Bien d\'avoir déjà journalisé des boissons ! Quel sera votre premier repas ?';

  @override
  String get motivational_drinksOnly_2 => 'L\'hydratation est un bon début. Il est temps de manger aussi.';

  @override
  String get motivational_drinksOnly_3 => 'Bien joué ! Quel sera votre première bouchée ?';

  @override
  String get motivational_overGoal_1 => 'Objectif atteint ! Reposez-vous maintenant.';

  @override
  String get motivational_overGoal_2 => 'Wow, vous êtes au-dessus de votre objectif !';

  @override
  String get motivational_overGoal_3 => 'Bien joué, recommencez demain.';

  @override
  String get motivational_overGoal_4 => 'Super journée, vraiment !';

  @override
  String get motivational_almostGoal_1 => 'Vous y êtes presque !';

  @override
  String get motivational_almostGoal_2 => 'Encore un petit effort !';

  @override
  String get motivational_almostGoal_3 => 'Presque votre objectif calorique !';

  @override
  String get motivational_almostGoal_4 => 'Bien joué ! Attention à la dernière étape.';

  @override
  String get motivational_almostGoal_5 => 'Vous êtes fantastique, presque là !';

  @override
  String get motivational_belowHalf_1 => 'Vous êtes bien parti, continuez !';

  @override
  String get motivational_belowHalf_3 => 'Continuez à journaliser vos repas et boissons.';

  @override
  String get motivational_belowHalf_4 => 'Vous faites du bon travail, persévérez !';

  @override
  String get motivational_lowWater_1 => 'N\'oubliez pas de boire aujourd\'hui !';

  @override
  String get motivational_lowWater_2 => 'Un petit verre d\'eau, c\'est un bon début.';

  @override
  String get motivational_lowWater_3 => 'Chaud ou froid, l\'eau est toujours bonne !';

  @override
  String get motivational_lowWater_4 => 'L\'hydratation est importante !';

  @override
  String get motivational_lowWater_5 => 'Un verre d\'eau peut faire des merveilles.';

  @override
  String get motivational_lowWater_6 => 'Une pause ? Buvez un peu d\'eau.';

  @override
  String get entry_updated => 'Quantité mise à jour';

  @override
  String get errorUpdatingEntry => 'Erreur lors de la mise à jour de la quantité : ';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données : ';

  @override
  String get not_logged_in => 'Non connecté';

  @override
  String get noEntriesForDate => 'Aucun journal pour cette date.';

  @override
  String get thinking => 'En réflexion...';

  @override
  String get sports => 'Activités sportives';

  @override
  String get totalBurned => 'Total brûlé : ';

  @override
  String get unknownSport => 'Sport inconnu';

  @override
  String get errorDeletingSport => 'Erreur lors de la suppression de l\'activité : ';

  @override
  String get errorDeleting => 'Erreur lors de la suppression : ';

  @override
  String get errorCalculating => 'Erreur : les données produit d\'origine sont incomplètes pour un recalcul.';

  @override
  String get appleCancelled => 'Vous avez annulé la connexion Apple.';

  @override
  String get appleFailed => 'Connexion Apple échouée. Réessayez plus tard.';

  @override
  String get appleInvalidResponse => 'Réponse non valide reçue d\'Apple.';

  @override
  String get appleNotHandled => 'Apple n\'a pas pu traiter la demande.';

  @override
  String get appleUnknown => 'Une erreur inconnue est survenue avec Apple.';

  @override
  String get appleGenericError => 'Une erreur est survenue lors de la connexion avec Apple.';

  @override
  String get signInAccountExists => 'Un compte avec cet e-mail existe déjà. Connectez-vous avec une autre méthode.';

  @override
  String get signInCancelled => 'La connexion a été annulée.';

  @override
  String get unknownGoogleSignIn => 'Une erreur inconnue est survenue lors de la connexion avec Google.';

  @override
  String get unknownGitHubSignIn => 'Une erreur inconnue est survenue lors de la connexion avec GitHub.';

  @override
  String get unknownAppleSignIn => 'Une erreur inconnue est survenue lors de la connexion avec Apple.';

  @override
  String get unknownErrorEnglish => 'Erreur inconnue';

  @override
  String get passwordErrorMinLength => 'au moins 6 caractères';

  @override
  String get passwordErrorUpper => 'une majuscule';

  @override
  String get passwordErrorLower => 'une minuscule';

  @override
  String get passwordErrorDigit => 'un chiffre';

  @override
  String get passwordMissingPartsPrefix => 'Votre mot de passe manque : ';

  @override
  String get userNotFoundCreateAccount => 'Aucun compte trouvé pour cet e-mail. Cliquez en bas pour créer un compte.';

  @override
  String get wrongPasswordOrEmail => 'Mot de passe ou e-mail incorrect. Réessayez. Vous n\'avez pas de compte ? Cliquez en bas pour en créer un.';

  @override
  String get emailAlreadyInUse => 'Cet e-mail est déjà utilisé. Essayez de vous connecter.';

  @override
  String get weakPasswordMessage => 'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get invalidEmailMessage => 'L\'adresse e-mail saisie est invalide.';

  @override
  String get authGenericError => 'Une erreur d\'authentification est survenue. Réessayez plus tard.';

  @override
  String get resetPasswordEnterEmailInstruction => 'Entrez votre e-mail pour réinitialiser votre mot de passe.';

  @override
  String get resetPasswordEmailSentTitle => 'E-mail envoyé';

  @override
  String get resetPasswordEmailSentContent => 'Un e-mail a été envoyé pour réinitialiser votre mot de passe. Attention : il peut se trouver dans votre dossier spam. Expéditeur : noreply@pwsmt-fd851.firebaseapp.com';

  @override
  String get okLabel => 'OK';

  @override
  String get genericError => 'Une erreur est survenue.';

  @override
  String get userNotFoundForEmail => 'Aucun compte trouvé pour cet e-mail.';

  @override
  String get loginWelcomeBack => 'Bienvenue !';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get registerSubtitle => 'Inscrivez-vous pour commencer';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'nom@exemple.com';

  @override
  String get loginEnterEmail => 'Entrez l\'e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginMin6Chars => 'Min 6 caractères';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButtonLogin => 'Connexion';

  @override
  String get loginButtonRegister => 'S\'inscrire';

  @override
  String get loginOrContinueWith => 'Ou continuez avec';

  @override
  String get loginWithGoogle => 'Se connecter avec Google';

  @override
  String get loginWithGitHub => 'Se connecter avec GitHub';

  @override
  String get loginWithApple => 'Se connecter avec Apple';

  @override
  String get loginNoAccountQuestion => 'Pas de compte ?';

  @override
  String get loginHaveAccountQuestion => 'Vous avez déjà un compte ?';

  @override
  String get loginCreateAccountAction => 'Créer un compte';

  @override
  String get loginLoginAction => 'Connexion';

  @override
  String get onboardingEnterFirstName => 'Saisissez votre prénom';

  @override
  String get onboardingSelectBirthDate => 'Sélectionnez votre date de naissance';

  @override
  String get onboardingEnterHeight => 'Saisissez votre taille (cm)';

  @override
  String get onboardingEnterWeight => 'Saisissez votre poids (kg)';

  @override
  String get onboardingEnterTargetWeight => 'Saisissez votre poids cible (kg)';

  @override
  String get onboardingEnterValidWeight => 'Veuillez saisir un poids valide';

  @override
  String get onboardingEnterValidHeight => 'Veuillez saisir une taille valide';

  @override
  String get heightBetween => 'La taille doit être entre ';

  @override
  String get and => ' et ';

  @override
  String get liggen => ' cm.';

  @override
  String get weightBetween => 'Le poids doit être entre ';

  @override
  String get kgLiggen => ' kg.';

  @override
  String get enterWaistCircumference => 'Indiquez votre tour de taille (cm)';

  @override
  String get enterValidWaistCircumference => 'Veuillez saisir un tour de taille valide';

  @override
  String get tailleBetween => 'Le tour de taille doit être entre ';

  @override
  String get cmLiggen => ' cm.';

  @override
  String get onboardingEnterValidTargetWeight => 'Veuillez saisir un poids cible valide';

  @override
  String get targetBetween => 'Le poids cible doit être entre ';

  @override
  String get absiVeryLow => 'risque très faible';

  @override
  String get absiLow => 'risque faible';

  @override
  String get absiAverage => 'risque moyen';

  @override
  String get absiElevated => 'risque accru';

  @override
  String get absiHigh => 'risque élevé';

  @override
  String get healthWeight => 'Poids sain pour vous : ';

  @override
  String get healthyBMI => 'IMC sain : ';

  @override
  String get onboardingWeightRangeUnder2 => 'Pour les enfants de moins de 2 ans, on utilise généralement les centiles poids/taille plutôt que l\'IMC.';

  @override
  String get onboardingWeightRangeUnder2Note => 'Utilisez les tableaux poids-pour-taille de l\'OMS/CDC.';

  @override
  String get onboarding_datePickerDone => 'Terminé';

  @override
  String get lmsDataUnavailable => 'Données LMS non disponibles pour cet âge/genre.';

  @override
  String get lmsCheckAssets => 'Vérifiez les assets ou saisissez manuellement le poids cible.';

  @override
  String get lmsDataErrorPrefix => 'Impossible d\'utiliser les données LMS :';

  @override
  String get lmsAssetMissing => 'Vérifiez la présence de l\'asset (assets/cdc/bmiagerev.csv).';

  @override
  String get healthyWeightForYou => 'Poids sain pour vous :';

  @override
  String get onboarding_firstNameTitle => 'Quel est votre prénom ?';

  @override
  String get onboarding_labelFirstName => 'Prénom';

  @override
  String get onboarding_genderTitle => 'Quel est votre genre ?';

  @override
  String get onboarding_genderOptionMan => 'Homme';

  @override
  String get onboarding_genderOptionWoman => 'Femme';

  @override
  String get onboarding_genderOptionOther => 'Autre';

  @override
  String get onboarding_genderOptionPreferNot => 'Préfère ne pas dire';

  @override
  String get onboarding_birthDateTitle => 'Quelle est votre date de naissance ?';

  @override
  String get onboarding_noDateChosen => 'Aucune date sélectionnée';

  @override
  String get onboarding_chooseDate => 'Choisir une date';

  @override
  String get onboarding_heightTitle => 'Quelle est votre taille (cm) ?';

  @override
  String get onboarding_labelHeight => 'Taille en cm';

  @override
  String get onboarding_weightTitle => 'Quel est votre poids (kg) ?';

  @override
  String get onboarding_labelWeight => 'Poids en kg';

  @override
  String get onboarding_waistTitle => 'Quel est votre tour de taille (cm) ?';

  @override
  String get onboarding_labelWaist => 'Tour de taille en cm';

  @override
  String get onboarding_unknownWaist => 'Je ne sais pas';

  @override
  String get onboarding_sleepTitle => 'Combien d\'heures dormez-vous en moyenne par nuit ?';

  @override
  String get onboarding_activityTitle => 'Quel est votre niveau d\'activité quotidien ?';

  @override
  String get onboarding_targetWeightTitle => 'Quel est votre poids cible ?';

  @override
  String get onboarding_labelTargetWeight => 'Poids cible en kg';

  @override
  String get onboarding_goalTitle => 'Quel est votre objectif ?';

  @override
  String get onboarding_notificationsTitle => 'Souhaitez-vous recevoir des notifications ?';

  @override
  String get onboarding_notificationsDescription => 'Vous pouvez activer les notifications pour des rappels de repas afin de ne jamais oublier de manger et d\'ajouter votre alimentation aux journaux.';

  @override
  String get onboarding_notificationsEnable => 'Activer les notifications';

  @override
  String get finish => 'Terminer';

  @override
  String get notificationPermissionDenied => 'Autorisation des notifications refusée.';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get deleteAccountProviderReauthRequired => 'La suppression du compte nécessite une ré-authentification. Connectez-vous avec la méthode d\'origine et réessayez.';

  @override
  String get enterPasswordLabel => 'Mot de passe';

  @override
  String get confirmButtonLabel => 'Confirmer';

  @override
  String get googleSignInCancelledMessage => 'Connexion Google annulée par l\'utilisateur.';

  @override
  String get googleMissingIdToken => 'Impossible d\'obtenir un idToken de Google.';

  @override
  String get appleNullIdentityTokenMessage => 'Apple n\'a pas renvoyé d\'identityToken.';

  @override
  String get deleteSportMessage => 'Êtes-vous sûr de vouloir supprimer cette activité sportive ?';

  @override
  String get notificationBreakfastTitle => 'Il est l\'heure du petit-déjeuner!';

  @override
  String get notificationBreakfastBody => 'Commencez bien votre journée avec un petit-déjeuner nutritif. N\'oubliez pas de le consigner!';

  @override
  String get notificationLunchTitle => 'C\'est l\'heure du déjeuner!';

  @override
  String get notificationLunchBody => 'Rechargez vos batteries pour l\'après-midi. N\'oubliez pas d\'enregistrer votre déjeuner!';

  @override
  String get notificationDinnerTitle => 'Bon appétit!';

  @override
  String get notificationDinnerBody => 'Profitez de votre dîner et pensez à le consigner!';

  @override
  String get heightRange => 'La taille doit être comprise entre 50 et 300 cm.';

  @override
  String get weightRange => 'Le poids doit être compris entre 20 et 800 kg.';

  @override
  String get waistRange => 'Le tour de taille doit être compris entre 30 et 200 cm.';

  @override
  String get targetWeightRange => 'Le poids cible doit être compris entre 20 et 800 kg.';

  @override
  String get sportsCaloriesInfoTitle => 'Activités sportives';

  @override
  String get sportsCaloriesInfoTextOn => 'Votre objectif quotidien est basé sur votre niveau d\'activité. Les calories provenant du sport sont maintenant ajoutées à votre total quotidien.';

  @override
  String get sportsCaloriesInfoTextOff => 'Votre objectif quotidien est basé sur votre niveau d\'activité. Les calories provenant du sport ne sont pas ajoutées par défaut à votre total quotidien. Vous pouvez modifier ce paramètre dans les réglages.';

  @override
  String get ok => 'OK';

  @override
  String get waterWarningSevere => 'Attention : ne buvez pas trop. Bien au-dessus de votre objectif peut être dangereux !';

  @override
  String get includeSportsCaloriesLabel => 'Inclure les calories de sport';

  @override
  String get includeSportsCaloriesSubtitle => 'Ajoutez les calories brûlées lors du sport à votre total quotidien (désactivé par défaut, car l\'activité est déjà prise en compte via votre niveau d\'activité).';

  @override
  String get setAppVersionTitle => 'Définir la version de l\'application';

  @override
  String get setAppVersionSubtitle => 'Modifier le champ version dans Firestore';

  @override
  String get versionLabel => 'Version';

  @override
  String get versionUpdated => 'Version mise à jour :';

  @override
  String get bmiForChildrenTitle => 'Info IMC enfants';

  @override
  String get bmiForChildrenExplanation => 'L\'IMC des enfants est calculé en fonction de l\'âge, du sexe, de la taille et du poids. Au lieu de limites fixes, cette application utilise des percentiles d\'IMC, ce qui rend l\'évaluation mieux adaptée à la croissance des enfants. De petites différences avec d\'autres tableaux d\'IMC sont normales.';
}
