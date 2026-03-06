import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock_iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class IrrigationDetailScreen extends StatefulWidget {
  final String greenhouseId;

  const IrrigationDetailScreen({Key? key, required this.greenhouseId})
    : super(key: key);

  @override
  State<IrrigationDetailScreen> createState() => _IrrigationDetailScreenState();
}

class _IrrigationDetailScreenState extends State<IrrigationDetailScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  double? _editingMinMoisture;
  int? _editingDuration;
  List<int>? _editingSchedule;

  void _onSaveSettings() {
    final current = iotService.currentData[widget.greenhouseId]!;
    iotService.updateIrrigationSettings(
      widget.greenhouseId,
      _editingMinMoisture ?? current.targetMoistureMin,
      _editingDuration ?? current.irrigationDurationMinutes,
      _editingSchedule ?? current.scheduledStartMinutes,
    );
    setState(() {
      _editingMinMoisture = null;
      _editingDuration = null;
      _editingSchedule = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Irrigation settings saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Irrigation Management",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bgImageUrl, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          SafeArea(
            child: StreamBuilder<Map<String, GreenhouseData>>(
              stream: iotService.greenhouseStream,
              initialData: iotService.currentData,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    !snapshot.data!.containsKey(widget.greenhouseId)) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                final ghData = snapshot.data![widget.greenhouseId]!;
                final currentMoisture = ghData.sensors.substrateMoisture;
                final isAuto = ghData.mode == DeviceMode.auto;

                final displayMinMoisture =
                    _editingMinMoisture ?? ghData.targetMoistureMin;
                final displayDuration =
                    _editingDuration ?? ghData.irrigationDurationMinutes;
                final displaySchedule =
                    _editingSchedule ?? ghData.scheduledStartMinutes;

                Color indicatorColor = AppTheme.primaryGreen;
                if (currentMoisture < ghData.targetMoistureMin) {
                  indicatorColor = Colors.redAccent;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          // 1. Moisture Circular Display
                          GlassCard(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Text(
                                  "Substrate Moisture",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: indicatorColor.withOpacity(0.5),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: indicatorColor.withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          currentMoisture.toStringAsFixed(1),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '%',
                                          style: GoogleFonts.inter(
                                            color: indicatorColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (currentMoisture < ghData.targetMoistureMin)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      "Emergency Irrigation ON",
                                      style: GoogleFonts.inter(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Schedule & Limits
                          GlassCard(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Irrigation Settings",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Moisture Limit
                                Text(
                                  "Emergency Moisture Level: ${displayMinMoisture.round()}%",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                  ),
                                ),
                                Slider(
                                  value: displayMinMoisture,
                                  min: 0,
                                  max: 100,
                                  divisions: 20,
                                  activeColor: Colors.blueAccent,
                                  onChanged: (val) =>
                                      setState(() => _editingMinMoisture = val),
                                ),
                                const Divider(
                                  color: Colors.white10,
                                  height: 32,
                                ),

                                // Manual Schedule
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: AppTheme.primaryGreen,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Daily Schedule",
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          final mins =
                                              time.hour * 60 + time.minute;
                                          final newSchedule = List<int>.from(
                                            displaySchedule,
                                          );
                                          if (!newSchedule.contains(mins)) {
                                            newSchedule.add(mins);
                                            newSchedule.sort();
                                            setState(
                                              () => _editingSchedule =
                                                  newSchedule,
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text("Add Time"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Schedule Table
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Table(
                                    columnWidths: const {
                                      0: FixedColumnWidth(50),
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                      3: FixedColumnWidth(50),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                        ),
                                        children: [
                                          _buildTableCell("#", isHeader: true),
                                          _buildTableCell(
                                            "Start Time",
                                            isHeader: true,
                                          ),
                                          _buildTableCell(
                                            "Duration",
                                            isHeader: true,
                                          ),
                                          _buildTableCell("", isHeader: true),
                                        ],
                                      ),
                                      ...displaySchedule.asMap().entries.map((
                                        entry,
                                      ) {
                                        int idx = entry.key;
                                        int mins = entry.value;
                                        final h = mins ~/ 60;
                                        final m = mins % 60;
                                        final timeStr =
                                            "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
                                        return TableRow(
                                          children: [
                                            _buildTableCell("${idx + 1}"),
                                            _buildTableCell(timeStr),
                                            _buildTableCell(
                                              "$displayDuration min",
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                final newSchedule =
                                                    List<int>.from(
                                                      displaySchedule,
                                                    );
                                                newSchedule.remove(mins);
                                                setState(
                                                  () => _editingSchedule =
                                                      newSchedule,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                      if (displaySchedule.isEmpty)
                                        TableRow(
                                          children: [
                                            const SizedBox(),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Text(
                                                "No schedule set",
                                                style: GoogleFonts.inter(
                                                  color: Colors.white38,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(),
                                            const SizedBox(),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Duration
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Duration per cycle:",
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const Spacer(),
                                    _buildDurationControl(
                                      displayDuration,
                                      (val) => setState(
                                        () => _editingDuration = val,
                                      ),
                                    ),
                                  ],
                                ),

                                if (_editingMinMoisture != null ||
                                    _editingDuration != null ||
                                    _editingSchedule != null) ...[
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _onSaveSettings,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Apply All Changes"),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Status/Toggle
                          _buildPumpCard(
                            "Main Water Pump",
                            ghData.actuators.waterPump,
                            isAuto,
                          ),

                          const SizedBox(height: 24),
                          // Next Irrigation Info
                          _buildNextIrrigationCard(ghData),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationControl(int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: () => onChanged(value > 1 ? value - 1 : 1),
        ),
        Text(
          "$value min",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }

  Widget _buildPumpCard(String title, bool value, bool isAuto) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            color: value ? Colors.blueAccent : AppTheme.primaryGreen,
            size: 36,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAuto ? Colors.white54 : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.primaryGreen,
            onChanged: isAuto
                ? (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Disable AUTO mode for manual control"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : (val) => iotService.toggleActuator(
                    widget.greenhouseId,
                    'pump',
                    val,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: isHeader ? Colors.white70 : Colors.white,
          fontSize: isHeader ? 12 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNextIrrigationCard(GreenhouseData data) {
    if (data.scheduledStartMinutes.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No irrigation scheduled",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    int minsSinceMidnight = DateTime.now().hour * 60 + DateTime.now().minute;
    int? nextStart = data.scheduledStartMinutes.firstWhere(
      (m) => m > minsSinceMidnight,
      orElse: () => data.scheduledStartMinutes.first,
    );

    int h = nextStart ~/ 60;
    int m = nextStart % 60;
    String timeStr =
        "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.white54),
          const SizedBox(width: 12),
          Text(
            "Next Scheduled Irrigation:",
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: GoogleFonts.inter(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
