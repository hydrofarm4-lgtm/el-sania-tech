// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ferme Fraîche';

  @override
  String get autoMode => 'MODE AUTO';

  @override
  String get manualMode => 'MODE MANUEL';

  @override
  String get liveSensors => 'Capteurs en Direct';

  @override
  String get actuatorsRelays => 'Actionneurs & Relais';

  @override
  String get sensorTemp => 'Température';

  @override
  String get sensorHumidity => 'Humidité';

  @override
  String get sensorEC => 'Niveau EC';

  @override
  String get sensorPH => 'Niveau pH';

  @override
  String get sensorWaterLevel => 'Niveau d\'eau';

  @override
  String get sensorLight => 'Lumière';

  @override
  String get sensorSubstrate => 'Humidité du substrat';

  @override
  String get controlLedLights => 'Lumières LED';

  @override
  String get controlWaterPump => 'Pompe à eau';

  @override
  String get controlCoolingSystem => 'Système de refroidissement';

  @override
  String get controlVentilationFans => 'Ventilateurs';

  @override
  String get controlRefillValve => 'Vanne de remplissage';

  @override
  String get language => 'Langue';

  @override
  String get arabic => 'Arabe';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get manage => 'Gérer';

  @override
  String get aiHub => 'Centre IA';

  @override
  String get alerts => 'Alertes';

  @override
  String get tabSensors => 'Capteurs';

  @override
  String get tabControls => 'Contrôles';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get role => 'Rôle';

  @override
  String get roleSuperAdmin => 'Super Administrateur';

  @override
  String get roleEngineer => 'Ingénieur';

  @override
  String get roleWorker => 'Travailleur';

  @override
  String get signInTitle => 'Connectez-vous pour continuer';

  @override
  String get loginButton => 'Connexion';

  @override
  String get invalidEmail => 'Veuillez entrer un email valide';

  @override
  String get invalidCredentials =>
      'Échec de la connexion. Veuillez vérifier vos identifiants.';

  @override
  String get tempDetailsTitle => 'Détails de Température';

  @override
  String get targetRange => 'Plage Cible';

  @override
  String get autoCoolingActive =>
      'Refroidissement Auto: Ventilateurs et Refroidisseur ON';

  @override
  String get autoCoolingStandby => 'Veille Auto: Température Optimale';

  @override
  String get manualControlOnly => 'Mode Manuel: Logique désactivée';

  @override
  String minTemp(Object value) {
    return 'Min: $value°C';
  }

  @override
  String maxTemp(Object value) {
    return 'Max: $value°C';
  }

  @override
  String get currentTemp => 'Température Actuelle';

  @override
  String get tabProjectStatus => 'Status du Projet';

  @override
  String get tabGreenhouses => 'Serres';

  @override
  String get tabWorkforce => 'Effectif';

  @override
  String get investorHub => 'Hub Investisseur';

  @override
  String get marketReadiness => 'Préparation Marché';

  @override
  String get estimatedYield => 'Rendement Estimé';

  @override
  String get activeOperations => 'Opérations Actives';

  @override
  String get periodicReports => 'Rapports Périodiques';

  @override
  String get greenhouseManagement => 'Gestion des Serres';

  @override
  String get cropType => 'Type de Culture';

  @override
  String get plantingDate => 'Date de Plantation';

  @override
  String get harvestDate => 'Date de Récolte';

  @override
  String get climateHealth => 'Santé Climatique';

  @override
  String get workforceManagement => 'Gestion des Effectifs';

  @override
  String get totalPersonnel => 'Personnel Total';

  @override
  String get activeTasks => 'Tâches Actives';

  @override
  String get salariesOverview => 'Aperçu des Salaires';

  @override
  String get reportedIssues => 'Problèmes Signalés';

  @override
  String get assignTask => 'Assigner Tâche';

  @override
  String get tabUserRequests => 'Demandes d\'adhésion';

  @override
  String get loginMode => 'Connexion';

  @override
  String get registerMode => 'S\'inscrire';

  @override
  String get pendingTitle => 'Approbation en attente';

  @override
  String get pendingMessage =>
      'Votre compte est en attente d\'approbation par l\'administrateur. Veuillez patienter.';

  @override
  String get approve => 'Approuver';

  @override
  String get reject => 'Rejeter';

  @override
  String get selectRole => 'Sélectionner un rôle';

  @override
  String get selectGreenhouses => 'Assigner des serres';

  @override
  String get myTasks => 'Mes Tâches';

  @override
  String get taskPending => 'En attente';

  @override
  String get taskInProgress => 'En cours';

  @override
  String get taskCompleted => 'Terminée';

  @override
  String get reportBreakdown => 'Signaler une panne';

  @override
  String get reportDescription => 'Décrivez le problème...';

  @override
  String get sendReport => 'Envoyer le rapport';

  @override
  String get incidentReported => 'Incident signalé avec succès';

  @override
  String get aiInsightPerfect =>
      'Condition: Excellente. Tous les systèmes optimaux.';

  @override
  String get aiInsightGood =>
      'Condition: Bonne. Ajustements mineurs recommandés.';

  @override
  String get aiInsightWarning =>
      'Condition: Avertissement. Paramètres hors plage idéale.';

  @override
  String get aiInsightDanger =>
      'Condition: Critique! Action immédiate requise.';

  @override
  String get healthScore => 'Score de Santé';

  @override
  String get aiInsights => 'Aperçus de l\'IA';

  @override
  String get trend24h => 'Tendance des Capteurs 24h';
}
