import 'dart:async';
import 'dart:math';

enum DeviceMode { auto, manual }

enum AlertLevel { info, warning, critical }

enum TaskStatus { pending, inProgress, completed }

class Alert {
  final String id;
  final String greenhouseId;
  final String message;
  final DateTime timestamp;
  final AlertLevel level;

  Alert({
    required this.id,
    required this.greenhouseId,
    required this.message,
    required this.timestamp,
    required this.level,
  });
}

class SensorData {
  final double temperature;
  final double humidity;
  final double substrateMoisture;
  final double ec;
  final double ph;
  final double waterLevel;
  final double lightIntensity;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.substrateMoisture,
    required this.ec,
    required this.ph,
    required this.waterLevel,
    required this.lightIntensity,
  });
}

class ActuatorState {
  bool led;
  bool waterPump;
  bool cooler;
  bool fan;
  bool tankRefill;

  ActuatorState({
    this.led = false,
    this.waterPump = false,
    this.cooler = false,
    this.fan = false,
    this.tankRefill = false,
  });
}

class GreenhouseData {
  final String id;
  DeviceMode mode;
  SensorData sensors;
  ActuatorState actuators;
  double targetMin;
  double targetMax;
  DateTime? outOfRangeStartTime;
  bool wasOutOfRange = false;

  // Humidity additions
  double targetHumidityMin;
  double targetHumidityMax;
  DateTime? outOfHumidityRangeStartTime;
  bool wasHumidityOutOfRange = false;

  // Light additions
  double targetLightMin;
  int sleepStartHour; // 0-23
  int sleepEndHour; // 0-23
  DateTime? outOfLightRangeStartTime;
  bool wasLightOutOfRange = false;

  // Irrigation additions
  double targetMoistureMin;
  int irrigationDurationMinutes;
  int get irrigationCyclesPerDay => scheduledStartMinutes.length;
  List<int> scheduledStartMinutes; // Minutes since midnight
  DateTime? outOfMoistureRangeStartTime;
  bool wasMoistureOutOfRange = false;

  GreenhouseData({
    required this.id,
    this.mode = DeviceMode.auto,
    required this.sensors,
    required this.actuators,
    this.targetMin = 22.0,
    this.targetMax = 28.0,
    this.targetHumidityMin = 40.0,
    this.targetHumidityMax = 70.0,
    this.targetLightMin = 600.0,
    this.sleepStartHour = 22, // 10 PM
    this.sleepEndHour = 6, // 6 AM
    this.targetMoistureMin = 30.0,
    this.irrigationDurationMinutes = 9,
    List<int>? manualSchedule,
  }) : scheduledStartMinutes = manualSchedule ?? _generateSchedule(10);

  static List<int> _generateSchedule(int cycles) {
    if (cycles <= 0) return [];
    int interval = 1440 ~/ cycles;
    return List.generate(cycles, (i) => i * interval);
  }
}

class WorkerTask {
  final String id;
  final String greenhouseId;
  final String title;
  final String description;
  TaskStatus status;

  WorkerTask({
    required this.id,
    required this.greenhouseId,
    required this.title,
    required this.description,
    this.status = TaskStatus.pending,
  });

  bool get isDone => status == TaskStatus.completed;
}

class WorkerSession {
  final String workerId;
  final String greenhouseId;
  final DateTime startTime;
  DateTime? endTime;

  WorkerSession({
    required this.workerId,
    required this.greenhouseId,
    required this.startTime,
    this.endTime,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}

class MockIoTService {
  final _random = Random();
  final Map<String, GreenhouseData> _greenhouses = {};
  final List<WorkerTask> _tasks = [];
  final Map<String, WorkerSession?> _activeSessions = {}; // workerId -> session

  final _controller = StreamController<Map<String, GreenhouseData>>.broadcast();
  final _taskController = StreamController<List<WorkerTask>>.broadcast();
  final _sessionController =
      StreamController<Map<String, WorkerSession?>>.broadcast();

  final List<Alert> _alerts = [];
  final _alertController = StreamController<List<Alert>>.broadcast();

  MockIoTService() {
    // Initialize mock data
    _greenhouses['HOUSE A0A3B3'] = GreenhouseData(
      id: 'HOUSE A0A3B3',
      sensors: _generateSensors(),
      actuators: ActuatorState(),
    );
    _greenhouses['HOUSE B2F8C1'] = GreenhouseData(
      id: 'HOUSE B2F8C1',
      sensors: _generateSensors(),
      actuators: ActuatorState(led: true, fan: true),
    );

    // Initialize tasks
    for (var houseId in _greenhouses.keys) {
      _tasks.add(
        WorkerTask(
          id: '${houseId}_1',
          greenhouseId: houseId,
          title: 'Check Irrigation System',
          description: 'Ensure all emitters are clear and pressure is stable.',
        ),
      );
      _tasks.add(
        WorkerTask(
          id: '${houseId}_2',
          greenhouseId: houseId,
          title: 'Pruning & Canopy Management',
          description: 'Remove dead leaves and adjust support wires.',
        ),
      );
      _tasks.add(
        WorkerTask(
          id: '${houseId}_3',
          greenhouseId: houseId,
          title: 'Nutrient Level Verification',
          description: 'Verify pH/EC manually to calibrate sensors.',
        ),
      );
    }

    // Start simulating sensor data updates
    Timer.periodic(const Duration(seconds: 3), (_) {
      for (var k in _greenhouses.keys) {
        final current = _greenhouses[k]!;

        // --- Added: Dynamic Auto Logic ---
        if (current.mode == DeviceMode.auto) {
          // Temperature logic: Cooling/Fans ON if hot
          bool tempNeedsFans = current.sensors.temperature > current.targetMax;

          // Humidity logic: Fans ON if humid (to reduce it)
          bool humidityNeedsFans =
              current.sensors.humidity > current.targetHumidityMax;

          if (tempNeedsFans || humidityNeedsFans) {
            current.actuators.fan = true;
          } else {
            current.actuators.fan = false;
          }

          // Cooler is only for temperature
          if (tempNeedsFans) {
            current.actuators.cooler = true;
          } else {
            current.actuators.cooler = false;
          }

          // Pump is no longer used for humidity auto-control as per user request
          current.actuators.waterPump = false;

          // Light logic with Sleep Mode
          int currentHour = DateTime.now().hour;
          bool isSleepTime;
          if (current.sleepStartHour > current.sleepEndHour) {
            // Overlaps midnight (e.g., 22:00 to 06:00)
            isSleepTime =
                currentHour >= current.sleepStartHour ||
                currentHour < current.sleepEndHour;
          } else {
            // Same day (e.g., 08:00 to 12:00)
            isSleepTime =
                currentHour >= current.sleepStartHour &&
                currentHour < current.sleepEndHour;
          }

          if (isSleepTime) {
            current.actuators.led = false; // Forced OFF
          } else {
            // Normal auto-light logic
            if (current.sensors.lightIntensity < current.targetLightMin) {
              current.actuators.led = true;
            } else {
              current.actuators.led = false;
            }
          }

          // Irrigation / Pump logic
          int minsSinceMidnight =
              DateTime.now().hour * 60 + DateTime.now().minute;
          bool isScheduledIrrigation = current.scheduledStartMinutes.any((
            start,
          ) {
            return minsSinceMidnight >= start &&
                minsSinceMidnight < (start + current.irrigationDurationMinutes);
          });

          bool moistureTooLow =
              current.sensors.substrateMoisture < current.targetMoistureMin;

          if (isScheduledIrrigation || moistureTooLow) {
            current.actuators.waterPump = true;
          } else {
            current.actuators.waterPump = false;
          }
        }

        _greenhouses[k] = GreenhouseData(
          id: current.id,
          mode: current.mode,
          actuators: current.actuators,
          sensors: _generateSensors(base: current.sensors),
          targetMin: current.targetMin,
          targetMax: current.targetMax,
          targetHumidityMin: current.targetHumidityMin,
          targetHumidityMax: current.targetHumidityMax,
          targetLightMin: current.targetLightMin,
          sleepStartHour: current.sleepStartHour,
          sleepEndHour: current.sleepEndHour,
          targetMoistureMin: current.targetMoistureMin,
          irrigationDurationMinutes: current.irrigationDurationMinutes,
          manualSchedule: List.from(current.scheduledStartMinutes),
        );
        _greenhouses[k]!.outOfRangeStartTime = current.outOfRangeStartTime;
        _greenhouses[k]!.wasOutOfRange = current.wasOutOfRange;
        _greenhouses[k]!.outOfHumidityRangeStartTime =
            current.outOfHumidityRangeStartTime;
        _greenhouses[k]!.wasHumidityOutOfRange = current.wasHumidityOutOfRange;
        _greenhouses[k]!.outOfLightRangeStartTime =
            current.outOfLightRangeStartTime;
        _greenhouses[k]!.wasLightOutOfRange = current.wasLightOutOfRange;
        _greenhouses[k]!.outOfMoistureRangeStartTime =
            current.outOfMoistureRangeStartTime;
        _greenhouses[k]!.wasMoistureOutOfRange = current.wasMoistureOutOfRange;

        _checkThresholds(_greenhouses[k]!);
      }
      _controller.add(_greenhouses);
    });
  }

  // --- Streams ---
  Stream<Map<String, GreenhouseData>> get greenhouseStream =>
      _controller.stream;
  Stream<List<WorkerTask>> get taskStream => _taskController.stream;
  Stream<Map<String, WorkerSession?>> get sessionStream =>
      _sessionController.stream;
  Stream<List<Alert>> get alertStream => _alertController.stream;

  // --- Data Accessors ---
  Map<String, GreenhouseData> get currentData => _greenhouses;
  List<WorkerTask> get currentTasks => _tasks;
  Map<String, WorkerSession?> get activeSessions => _activeSessions;
  List<Alert> get currentAlerts => _alerts;

  // --- Session Management ---
  void startSession(String workerId, String houseId) {
    if (_activeSessions[workerId] == null) {
      _activeSessions[workerId] = WorkerSession(
        workerId: workerId,
        greenhouseId: houseId,
        startTime: DateTime.now(),
      );
      _sessionController.add(_activeSessions);
      _addAlert(houseId, 'Shift started by Worker $workerId', AlertLevel.info);
    }
  }

  void endSession(String workerId) {
    final session = _activeSessions[workerId];
    if (session != null) {
      session.endTime = DateTime.now();
      _addAlert(
        session.greenhouseId,
        'Shift completed by Worker $workerId. Duration: ${session.duration.inMinutes} mins.',
        AlertLevel.info,
      );

      // Check if any tasks were missed
      final missedTasks = _tasks
          .where((t) => t.greenhouseId == session.greenhouseId && !t.isDone)
          .length;
      if (missedTasks > 0) {
        _addAlert(
          session.greenhouseId,
          'Performance Warning: Worker $workerId left $missedTasks tasks unfinished.',
          AlertLevel.warning,
        );
      }

      _activeSessions[workerId] = null;
      _sessionController.add(_activeSessions);
    }
  }

  // --- Task Management ---
  void updateTaskStatus(String taskId, TaskStatus status) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].status = status;
      _taskController.add(_tasks);
    }
  }

  void reportIncident(String houseId, String description, String reporter) {
    _addAlert(
      houseId,
      'INCIDENT REPORTED by $reporter: $description',
      AlertLevel.critical,
    );
  }

  void _checkThresholds(GreenhouseData data) {
    final temp = data.sensors.temperature;
    final isOutOfRange = temp < data.targetMin || temp > data.targetMax;

    if (isOutOfRange && !data.wasOutOfRange) {
      // Just went out of range
      data.wasOutOfRange = true;
      data.outOfRangeStartTime = DateTime.now();

      final level = temp > data.targetMax
          ? AlertLevel.critical
          : AlertLevel.warning;
      final msg = temp > data.targetMax
          ? "Critical: Temperature high (${temp.toStringAsFixed(1)}°C) in ${data.id}"
          : "Warning: Temperature low (${temp.toStringAsFixed(1)}°C) in ${data.id}";

      _addAlert(data.id, msg, level);
    } else if (!isOutOfRange && data.wasOutOfRange) {
      // Just returned to range
      final duration = DateTime.now().difference(data.outOfRangeStartTime!);
      data.wasOutOfRange = false;

      final msg =
          "Resolved: Temperature back to normal in ${data.id}. Was out of range for ${duration.inMinutes}m ${duration.inSeconds % 60}s.";
      _addAlert(data.id, msg, AlertLevel.info);
    }

    // Humidity Check
    final humidity = data.sensors.humidity;
    final isHumidOutOfRange =
        humidity < data.targetHumidityMin || humidity > data.targetHumidityMax;

    if (isHumidOutOfRange && !data.wasHumidityOutOfRange) {
      data.wasHumidityOutOfRange = true;
      data.outOfHumidityRangeStartTime = DateTime.now();

      final msg = humidity > data.targetHumidityMax
          ? "Warning: Humidity high (${humidity.toStringAsFixed(1)}%) in ${data.id}"
          : "Warning: Humidity low (${humidity.toStringAsFixed(1)}%) in ${data.id}";

      _addAlert(data.id, msg, AlertLevel.warning);
    } else if (!isHumidOutOfRange && data.wasHumidityOutOfRange) {
      final duration = DateTime.now().difference(
        data.outOfHumidityRangeStartTime!,
      );
      data.wasHumidityOutOfRange = false;

      final msg =
          "Resolved: Humidity back to normal in ${data.id}. Was out of range for ${duration.inMinutes}m ${duration.inSeconds % 60}s.";
      _addAlert(data.id, msg, AlertLevel.info);
    }

    // Light Check
    final light = data.sensors.lightIntensity;
    final isLightLow = light < data.targetLightMin;

    if (isLightLow && !data.wasLightOutOfRange) {
      data.wasLightOutOfRange = true;
      data.outOfLightRangeStartTime = DateTime.now();
      _addAlert(
        data.id,
        "Warning: Light intensity low (${light.toStringAsFixed(0)} lx) in ${data.id}",
        AlertLevel.warning,
      );
    } else if (!isLightLow && data.wasLightOutOfRange) {
      final duration = DateTime.now().difference(
        data.outOfLightRangeStartTime!,
      );
      data.wasLightOutOfRange = false;
      _addAlert(
        data.id,
        "Resolved: Light intensity back to normal in ${data.id}. Was low for ${duration.inMinutes}m ${duration.inSeconds % 60}s.",
        AlertLevel.info,
      );
    }

    // Moisture Check
    final moisture = data.sensors.substrateMoisture;
    final isMoistureLow = moisture < data.targetMoistureMin;

    if (isMoistureLow && !data.wasMoistureOutOfRange) {
      data.wasMoistureOutOfRange = true;
      data.outOfMoistureRangeStartTime = DateTime.now();
      _addAlert(
        data.id,
        "Critical: Substrate moisture low (${moisture.toStringAsFixed(1)}%) in ${data.id}. Irrigation triggered.",
        AlertLevel.critical,
      );
    } else if (!isMoistureLow && data.wasMoistureOutOfRange) {
      final duration = DateTime.now().difference(
        data.outOfMoistureRangeStartTime!,
      );
      data.wasMoistureOutOfRange = false;
      _addAlert(
        data.id,
        "Resolved: Moisture level restored in ${data.id}. Was dry for ${duration.inMinutes}m ${duration.inSeconds % 60}s.",
        AlertLevel.info,
      );
    }
  }

  void _addAlert(String ghId, String message, AlertLevel level) {
    final alert = Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      greenhouseId: ghId,
      message: message,
      timestamp: DateTime.now(),
      level: level,
    );
    _alerts.insert(0, alert);
    if (_alerts.length > 50) _alerts.removeLast();
    _alertController.add(_alerts);
  }

  SensorData _generateSensors({SensorData? base}) {
    if (base == null) {
      return SensorData(
        temperature: 20.0 + _random.nextDouble() * 10, // 20-30 C
        humidity: 50.0 + _random.nextDouble() * 30, // 50-80 %
        substrateMoisture: 40.0 + _random.nextDouble() * 40, // 40-80 %
        ec: 1.0 + _random.nextDouble() * 2, // 1.0 - 3.0
        ph: 5.5 + _random.nextDouble() * 1.5, // 5.5 - 7.0
        waterLevel: 20.0 + _random.nextDouble() * 80, // 20-100 %
        lightIntensity: 400.0 + _random.nextDouble() * 600, // 400-1000 lux
      );
    } else {
      // Add slight variations to simulate realistic sensor jitter
      return SensorData(
        temperature: base.temperature + (_random.nextDouble() * 0.4 - 0.2),
        humidity: base.humidity + (_random.nextDouble() * 1.0 - 0.5),
        substrateMoisture:
            base.substrateMoisture + (_random.nextDouble() * 1.0 - 0.5),
        ec: base.ec + (_random.nextDouble() * 0.04 - 0.02),
        ph: base.ph + (_random.nextDouble() * 0.02 - 0.01),
        waterLevel: base.waterLevel + (_random.nextDouble() * 0.2 - 0.1),
        lightIntensity:
            base.lightIntensity + (_random.nextDouble() * 10.0 - 5.0),
      );
    }
  }

  void toggleMode(String id) {
    if (_greenhouses.containsKey(id)) {
      final current = _greenhouses[id]!;
      current.mode = current.mode == DeviceMode.auto
          ? DeviceMode.manual
          : DeviceMode.auto;
      _controller.add(_greenhouses);
    }
  }

  void toggleActuator(String id, String actuatorType, bool value) {
    if (_greenhouses.containsKey(id)) {
      final current = _greenhouses[id]!;
      // If in auto mode, refuse manual changes
      if (current.mode == DeviceMode.auto) return;

      switch (actuatorType) {
        case 'led':
          current.actuators.led = value;
          break;
        case 'pump':
          current.actuators.waterPump = value;
          break;
        case 'cooler':
          current.actuators.cooler = value;
          break;
        case 'fan':
          current.actuators.fan = value;
          break;
        case 'refill':
          current.actuators.tankRefill = value;
          break;
      }
      _controller.add(_greenhouses);
    }
  }

  void updateTargetRange(String id, double min, double max) {
    if (_greenhouses.containsKey(id)) {
      _greenhouses[id]!.targetMin = min;
      _greenhouses[id]!.targetMax = max;
      _controller.add(_greenhouses);
    }
  }

  void updateHumidityRange(String id, double min, double max) {
    if (_greenhouses.containsKey(id)) {
      _greenhouses[id]!.targetHumidityMin = min;
      _greenhouses[id]!.targetHumidityMax = max;
      _controller.add(_greenhouses);
    }
  }

  void updateLightSettings(String id, double min, int start, int end) {
    if (_greenhouses.containsKey(id)) {
      _greenhouses[id]!.targetLightMin = min;
      _greenhouses[id]!.sleepStartHour = start;
      _greenhouses[id]!.sleepEndHour = end;
      _controller.add(_greenhouses);
    }
  }

  void updateIrrigationSettings(
    String id,
    double minMoisture,
    int duration,
    List<int> schedule,
  ) {
    if (_greenhouses.containsKey(id)) {
      _greenhouses[id]!.targetMoistureMin = minMoisture;
      _greenhouses[id]!.irrigationDurationMinutes = duration;
      _greenhouses[id]!.scheduledStartMinutes = List.from(schedule)..sort();
      _controller.add(_greenhouses);
    }
  }
}

// Global instance for the app to use
final iotService = MockIoTService();
