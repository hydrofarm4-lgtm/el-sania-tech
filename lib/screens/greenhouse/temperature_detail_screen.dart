import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock_iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class TemperatureDetailScreen extends StatefulWidget {
  final String greenhouseId;

  const TemperatureDetailScreen({Key? key, required this.greenhouseId})
    : super(key: key);

  @override
  State<TemperatureDetailScreen> createState() =>
      _TemperatureDetailScreenState();
}

class _TemperatureDetailScreenState extends State<TemperatureDetailScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  // Local state for UI during editing
  RangeValues? _editingRange;

  void _onSaveRange() {
    if (_editingRange != null) {
      iotService.updateTargetRange(
        widget.greenhouseId,
        _editingRange!.start,
        _editingRange!.end,
      );
      setState(() {
        _editingRange = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Target range saved successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          localizations.tempDetailsTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
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
          // High-Res Background
          Image.asset(_bgImageUrl, fit: BoxFit.cover),
          // Blur effect
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
                final isAuto = ghData.mode == DeviceMode.auto;
                final currentTemp = ghData.sensors.temperature;
                final currentTarget = RangeValues(
                  ghData.targetMin,
                  ghData.targetMax,
                );

                // Use editing range if user is dragging, otherwise use server range
                final displayRange = _editingRange ?? currentTarget;

                // Color Logic for Temperature Circle
                Color tempIndicatorColor =
                    AppTheme.primaryGreen; // Default Green (In range)
                String autoLogicStatus = localizations.manualControlOnly;
                Color statusColor = Colors.orangeAccent;

                if (currentTemp > currentTarget.end) {
                  tempIndicatorColor = Colors.redAccent; // High
                } else if (currentTemp < currentTarget.start) {
                  tempIndicatorColor = Colors.lightBlueAccent; // Low
                }

                if (isAuto) {
                  if (currentTemp > currentTarget.end) {
                    autoLogicStatus = localizations.autoCoolingActive;
                    statusColor = Colors.redAccent;
                  } else if (currentTemp >= currentTarget.start &&
                      currentTemp <= currentTarget.end) {
                    autoLogicStatus = localizations.autoCoolingStandby;
                    statusColor = AppTheme.primaryGreen;
                  } else {
                    autoLogicStatus = localizations.autoCoolingStandby;
                    statusColor = Colors.lightBlueAccent;
                  }
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // --- 1. Top Section: Circular Temperature Display ---
                          GlassCard(
                            blur: 15.0,
                            opacity: 0.15,
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Text(
                                  localizations.currentTemp,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: tempIndicatorColor.withOpacity(
                                        0.5,
                                      ),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: tempIndicatorColor.withOpacity(
                                          0.2,
                                        ),
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
                                          currentTemp.toStringAsFixed(1),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '°C',
                                          style: GoogleFonts.inter(
                                            color: tempIndicatorColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- 2. Target Range Logic Card ---
                          GlassCard(
                            blur: 15.0,
                            opacity: 0.15,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  localizations.targetRange,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${displayRange.start.round()}°C - ${displayRange.end.round()}°C',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RangeSlider(
                                  values: displayRange,
                                  min: 0,
                                  max: 50,
                                  divisions: 50,
                                  activeColor: AppTheme.primaryGreen,
                                  inactiveColor: Colors.white24,
                                  labels: RangeLabels(
                                    '${displayRange.start.round()}°C',
                                    '${displayRange.end.round()}°C',
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _editingRange = values;
                                    });
                                  },
                                ),
                                if (_editingRange != null) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _onSaveRange,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Save Range Changes"),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // Auto Logic Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    autoLogicStatus,
                                    style: GoogleFonts.inter(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- 3. Actuators Section (Symmetric Toggle Cards) ---
                          Row(
                            children: [
                              Expanded(
                                child: _buildActuatorCard(
                                  localizations.controlVentilationFans,
                                  'fan',
                                  ghData.actuators.fan,
                                  isAuto,
                                  Icons.air,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildActuatorCard(
                                  localizations.controlCoolingSystem,
                                  'cooler',
                                  ghData.actuators.cooler,
                                  isAuto,
                                  Icons.ac_unit,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildActuatorCard(
    String title,
    String key,
    bool value,
    bool isAutoMode,
    IconData icon,
  ) {
    return GlassCard(
      blur: 15.0,
      opacity: 0.1,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 36),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAutoMode ? Colors.white54 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.primaryGreen,
            // Only allow manual toggle if mode is MANUAL
            onChanged: isAutoMode
                ? (val) {
                    // Show a snackbar or message if user tries to tap while auto
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Disable AUTO mode to control manually"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : (val) {
                    iotService.toggleActuator(widget.greenhouseId, key, val);
                  },
          ),
        ],
      ),
    );
  }
}
