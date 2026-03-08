import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth_service.dart';
import '../../core/iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({Key? key}) : super(key: key);

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  Timer? _shiftTimer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _shiftTimer?.cancel();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _shiftTimer?.cancel();
    _elapsed = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.read<AuthService>().currentUser;
    final workerId = currentUser?.id ?? 'Unknown';
    final workerName = currentUser?.name ?? 'Worker';
    final iot = context.watch<IoTService>();

    return StreamBuilder<Map<String, WorkerSession>>(
      stream: iot.sessionStream,
      initialData: iot.activeSessions,
      builder: (context, sessionSnapshot) {
        final activeSession = sessionSnapshot.data?[workerId];

        if (activeSession != null &&
            (_shiftTimer == null || !_shiftTimer!.isActive)) {
          _startTimer();
          _elapsed = DateTime.now().difference(activeSession.startTime);
        } else if (activeSession == null &&
            _shiftTimer != null &&
            _shiftTimer!.isActive) {
          _stopTimer();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('assignedTo', isEqualTo: workerId)
              .snapshots(),
          builder: (context, taskSnapshot) {
            final taskDocs = taskSnapshot.data?.docs ?? [];
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  l10n.roleWorker.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => context.read<AuthService>().logout(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/568712db29335598b400ef4651bc962f.jpg',
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                  SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildUserHeader(
                          workerName,
                          workerId,
                          activeSession,
                          l10n,
                          iot,
                        ),
                        const SizedBox(height: 24),
                        if (activeSession != null) ...[
                          _buildSessionInfo(activeSession),
                          const SizedBox(height: 24),
                          _buildSensorOverview(activeSession.greenhouseId, iot),
                          const SizedBox(height: 24),
                        ],
                        _buildTaskList(taskDocs, l10n),
                        const SizedBox(height: 32),
                        if (activeSession != null)
                          _buildActionButtons(
                            activeSession,
                            taskDocs,
                            l10n,
                            iot,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserHeader(
    String name,
    String id,
    WorkerSession? session,
    AppLocalizations l10n,
    IoTService iot,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: session != null
                ? AppTheme.primaryGreen
                : Colors.white10,
            child: Icon(
              session != null ? Icons.bolt : Icons.person_outline,
              color: session != null ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  session != null
                      ? 'Shift Active: ${session.greenhouseId}'
                      : 'No active shift tracking',
                  style: TextStyle(
                    color: session != null
                        ? AppTheme.primaryGreen
                        : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (session == null)
            IconButton(
              onPressed: () => _showScanSimulation(id, iot),
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppTheme.primaryGreen,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(WorkerSession session) {
    return GlassCard(
      color: AppTheme.primaryGreen.withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRACKED TIME',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                _formatDuration(_elapsed),
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.timer, color: AppTheme.primaryGreen, size: 40),
        ],
      ),
    );
  }

  Widget _buildSensorOverview(String houseId, IoTService iot) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: iot.greenhouseStream(houseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!.data();
        if (data == null) return const SizedBox();

        final bool isOnline = data['isOnline'] ?? (data['temperature'] != null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIVE MONITORING',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (!isOnline)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white54,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ESP32 Disconnected (غير متصل)',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildMiniSensorCard(
                      'Temp',
                      '${(data['temperature'] ?? 0).toStringAsFixed(1)}°C',
                      Icons.thermostat,
                      Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniSensorCard(
                      'Humidity',
                      '${(data['humidity'] ?? 0).toStringAsFixed(0)}%',
                      Icons.water_drop,
                      Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniSensorCard(
                      'pH',
                      (data['ph'] ?? 0).toStringAsFixed(1),
                      Icons.science,
                      Colors.purpleAccent,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildMiniSensorCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    List<QueryDocumentSnapshot> taskDocs,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.myTasks.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (taskDocs.isEmpty)
          const Text(
            'No tasks assigned to you.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          )
        else
          ...taskDocs.map((doc) => _buildTaskTile(doc, l10n)),
      ],
    );
  }

  Widget _buildTaskTile(QueryDocumentSnapshot doc, AppLocalizations l10n) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';
    final title = data['title'] ?? 'No Title';
    final description = data['description'] ?? '';
    Color statusColor = status == 'pending'
        ? Colors.white24
        : status == 'inProgress'
        ? Colors.blueAccent
        : AppTheme.primaryGreen;
    String statusLabel = status == 'pending'
        ? l10n.taskPending
        : status == 'inProgress'
        ? l10n.taskInProgress
        : l10n.taskCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: _buildTaskButton(
                      'START',
                      Colors.blueAccent,
                      () => doc.reference.update({'status': 'inProgress'}),
                    ),
                  )
                else if (status == 'inProgress')
                  Expanded(
                    child: _buildTaskButton(
                      'COMPLETE',
                      AppTheme.primaryGreen,
                      () => doc.reference.update({'status': 'completed'}),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskButton(String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        foregroundColor: color,
      ),
      child: Text(label),
    );
  }

  Widget _buildActionButtons(
    WorkerSession session,
    List<QueryDocumentSnapshot> tasks,
    AppLocalizations l10n,
    IoTService iot,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showBreakdownDialog(session.greenhouseId, l10n),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.black),
            label: Text(l10n.reportBreakdown.toUpperCase()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleEndShift(session.workerId, tasks, iot),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('STOP SESSION'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showBreakdownDialog(String houseId, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(
          l10n.reportBreakdown,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.reportDescription,
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final user = context.read<AuthService>().currentUser;
                await FirebaseFirestore.instance.collection('incidents').add({
                  'houseId': houseId,
                  'description': controller.text,
                  'reportedBy': user?.name ?? 'Worker',
                  'reporterUid': user?.id,
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'open',
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.incidentReported),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.sendReport.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _showScanSimulation(String workerId, IoTService iot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Simulate QR Scan',
          style: TextStyle(color: Colors.white),
        ),
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('greenhouses')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data!.docs
                  .map(
                    (doc) => ListTile(
                      title: Text(
                        doc.id,
                        style: const TextStyle(color: AppTheme.primaryGreen),
                      ),
                      onTap: () {
                        iot.startSession(workerId, doc.id);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  void _handleEndShift(
    String workerId,
    List<QueryDocumentSnapshot> tasks,
    IoTService iot,
  ) {
    final missed = tasks
        .where(
          (doc) =>
              (doc.data() as Map<String, dynamic>)['status'] != 'completed',
        )
        .length;
    if (missed > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text(
            'Unfinished Tasks!',
            style: TextStyle(color: Colors.orangeAccent),
          ),
          content: Text('You have $missed tasks remaining. End anyway?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('GO BACK'),
            ),
            TextButton(
              onPressed: () {
                iot.endSession(workerId);
                Navigator.pop(context);
              },
              child: const Text(
                'END SESSION',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    } else {
      iot.endSession(workerId);
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}
