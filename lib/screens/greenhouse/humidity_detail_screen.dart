import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock_iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class HumidityDetailScreen extends StatefulWidget {
  final String greenhouseId;

  const HumidityDetailScreen({Key? key, required this.greenhouseId})
    : super(key: key);

  @override
  State<HumidityDetailScreen> createState() => _HumidityDetailScreenState();
}

class _HumidityDetailScreenState extends State<HumidityDetailScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';
  RangeValues? _editingRange;

  void _onSaveRange() {
    if (_editingRange != null) {
      iotService.updateHumidityRange(
        widget.greenhouseId,
        _editingRange!.start,
        _editingRange!.end,
      );
      setState(() {
        _editingRange = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Humidity target range saved!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Humidity Details",
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
                final currentHum = ghData.sensors.humidity;
                final isAuto = ghData.mode == DeviceMode.auto;
                final currentTarget = RangeValues(
                  ghData.targetHumidityMin,
                  ghData.targetHumidityMax,
                );
                final displayRange = _editingRange ?? currentTarget;

                Color indicatorColor = AppTheme.primaryGreen;
                if (currentHum > currentTarget.end) {
                  indicatorColor = Colors.redAccent;
                } else if (currentHum < currentTarget.start) {
                  indicatorColor = Colors.lightBlueAccent;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          // 1. Circular Display
                          GlassCard(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Text(
                                  "Current Humidity",
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
                                          currentHum.toStringAsFixed(1),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 2. Target Range
                          GlassCard(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  "Target Range",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${displayRange.start.round()}% - ${displayRange.end.round()}%",
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
                                  max: 100,
                                  divisions: 100,
                                  activeColor: AppTheme.primaryGreen,
                                  inactiveColor: Colors.white24,
                                  onChanged: (val) =>
                                      setState(() => _editingRange = val),
                                ),
                                if (_editingRange != null) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _onSaveRange,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Save Range"),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 3. Actuator (Ventilation Fans)
                          _buildVentilationCard(
                            "Ventilation Fans",
                            ghData.actuators.fan,
                            isAuto,
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

  Widget _buildVentilationCard(String title, bool value, bool isAuto) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(Icons.air, color: AppTheme.primaryGreen, size: 36),
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
                    'fan',
                    val,
                  ),
          ),
        ],
      ),
    );
  }
}
