// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fresh Farm';

  @override
  String get autoMode => 'AUTO MODE';

  @override
  String get manualMode => 'MANUAL MODE';

  @override
  String get liveSensors => 'Live Sensors';

  @override
  String get actuatorsRelays => 'Actuators & Relays';

  @override
  String get sensorTemp => 'Temperature';

  @override
  String get sensorHumidity => 'Humidity';

  @override
  String get sensorEC => 'EC Level';

  @override
  String get sensorPH => 'pH Level';

  @override
  String get sensorWaterLevel => 'Water Level';

  @override
  String get sensorLight => 'Light';

  @override
  String get sensorSubstrate => 'Substrate Moisture';

  @override
  String get controlLedLights => 'LED Lights';

  @override
  String get controlWaterPump => 'Water Pump';

  @override
  String get controlCoolingSystem => 'Cooling System';

  @override
  String get controlVentilationFans => 'Ventilation Fans';

  @override
  String get controlRefillValve => 'Refill Valve';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get manage => 'Manage';

  @override
  String get aiHub => 'AI Hub';

  @override
  String get alerts => 'Alerts';

  @override
  String get tabSensors => 'Sensors';

  @override
  String get tabControls => 'Controls';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get role => 'Role';

  @override
  String get roleSuperAdmin => 'Super Admin';

  @override
  String get roleEngineer => 'Engineer';

  @override
  String get roleWorker => 'Worker';

  @override
  String get signInTitle => 'Sign In to continue';

  @override
  String get loginButton => 'Login';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get invalidCredentials =>
      'Login failed. Please check your credentials.';

  @override
  String get tempDetailsTitle => 'Temperature Details';

  @override
  String get targetRange => 'Target Range';

  @override
  String get autoCoolingActive => 'Auto-Cooling Active: Fans & Cooler ON';

  @override
  String get autoCoolingStandby => 'Auto-Cooling Standby: Temp Optimal';

  @override
  String get manualControlOnly => 'Manual Mode: Auto-logic disabled';

  @override
  String minTemp(Object value) {
    return 'Min: $value°C';
  }

  @override
  String maxTemp(Object value) {
    return 'Max: $value°C';
  }

  @override
  String get currentTemp => 'Current Temperature';

  @override
  String get tabProjectStatus => 'Project Status';

  @override
  String get tabGreenhouses => 'Greenhouses';

  @override
  String get tabWorkforce => 'Workforce';

  @override
  String get investorHub => 'Investor Hub';

  @override
  String get marketReadiness => 'Market Readiness';

  @override
  String get estimatedYield => 'Estimated Yield';

  @override
  String get activeOperations => 'Active Operations';

  @override
  String get periodicReports => 'Periodic Reports';

  @override
  String get greenhouseManagement => 'Greenhouse Management';

  @override
  String get cropType => 'Crop Type';

  @override
  String get plantingDate => 'Planting Date';

  @override
  String get harvestDate => 'Harvest Date';

  @override
  String get climateHealth => 'Climate Health';

  @override
  String get workforceManagement => 'Workforce Management';

  @override
  String get totalPersonnel => 'Total Personnel';

  @override
  String get activeTasks => 'Active Tasks';

  @override
  String get salariesOverview => 'Salaries Overview';

  @override
  String get reportedIssues => 'Reported Issues';

  @override
  String get assignTask => 'Assign Task';

  @override
  String get tabUserRequests => 'User Requests';

  @override
  String get loginMode => 'Login';

  @override
  String get registerMode => 'Register';

  @override
  String get pendingTitle => 'Approval Pending';

  @override
  String get pendingMessage =>
      'Your account is pending admin approval. Please wait.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get selectRole => 'Select Role';

  @override
  String get selectGreenhouses => 'Assign Greenhouses';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get taskPending => 'Pending';

  @override
  String get taskInProgress => 'In Progress';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get reportBreakdown => 'Report Breakdown';

  @override
  String get reportDescription => 'Describe the issue...';

  @override
  String get sendReport => 'Send Report';

  @override
  String get incidentReported => 'Incident reported successfully';

  @override
  String get aiInsightPerfect => 'Condition: Excellent. All systems optimal.';

  @override
  String get aiInsightGood => 'Condition: Good. Minor adjustments recommended.';

  @override
  String get aiInsightWarning =>
      'Condition: Warning. One or more parameters outside ideal range.';

  @override
  String get aiInsightDanger =>
      'Condition: Critical! Immediate action required.';

  @override
  String get healthScore => 'Health Score';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get trend24h => '24h Sensor Trend';
}
