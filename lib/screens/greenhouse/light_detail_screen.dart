import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock_iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class LightDetailScreen extends StatefulWidget {
  final String greenhouseId;

  const LightDetailScreen({Key? key, required this.greenhouseId})
    : super(key: key);

  @override
  State<LightDetailScreen> createState() => _LightDetailScreenState();
}

class _LightDetailScreenState extends State<LightDetailScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  double? _editingMinLux;
  int? _editingStartHour;
  int? _editingEndHour;

  void _onSaveSettings() {
    iotService.updateLightSettings(
      widget.greenhouseId,
      _editingMinLux ??
          iotService.currentData[widget.greenhouseId]!.targetLightMin,
      _editingStartHour ??
          iotService.currentData[widget.greenhouseId]!.sleepStartHour,
      _editingEndHour ??
          iotService.currentData[widget.greenhouseId]!.sleepEndHour,
    );
    setState(() {
      _editingMinLux = null;
      _editingStartHour = null;
      _editingEndHour = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Lighting settings saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Lighting Details",
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
                final currentLux = ghData.sensors.lightIntensity;
                final isAuto = ghData.mode == DeviceMode.auto;

                final displayMinLux = _editingMinLux ?? ghData.targetLightMin;
                final displayStart = _editingStartHour ?? ghData.sleepStartHour;
                final displayEnd = _editingEndHour ?? ghData.sleepEndHour;

                // Color Logic
                Color indicatorColor = AppTheme.primaryGreen;
                if (currentLux < ghData.targetLightMin) {
                  indicatorColor = Colors.orangeAccent;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          // 1. Lux Display
                          GlassCard(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Text(
                                  "Light Intensity",
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
                                          currentLux.toStringAsFixed(0),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'lx',
                                          style: GoogleFonts.inter(
                                            color: indicatorColor,
                                            fontSize: 20,
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
                          const SizedBox(height: 24),

                          // 2. Settings (Threshold & Sleep Mode)
                          GlassCard(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Auto-Lighting Settings",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Min Lux Slider
                                Text(
                                  "Min Intensity Threshold: ${displayMinLux.round()} lx",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                  ),
                                ),
                                Slider(
                                  value: displayMinLux,
                                  min: 0,
                                  max: 2000,
                                  divisions: 40,
                                  activeColor: AppTheme.primaryGreen,
                                  onChanged: (val) =>
                                      setState(() => _editingMinLux = val),
                                ),
                                const Divider(
                                  color: Colors.white10,
                                  height: 32,
                                ),

                                // Sleep Mode Title
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bedtime,
                                      color: Colors.indigoAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Sleep Mode (Plants Rest)",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildHourPicker(
                                      "Start",
                                      displayStart,
                                      (val) => setState(
                                        () => _editingStartHour = val,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white24,
                                    ),
                                    _buildHourPicker(
                                      "End",
                                      displayEnd,
                                      (val) =>
                                          setState(() => _editingEndHour = val),
                                    ),
                                  ],
                                ),

                                if (_editingMinLux != null ||
                                    _editingStartHour != null ||
                                    _editingEndHour != null) ...[
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

                          // 3. Actuator (LED Lights)
                          _buildLedCard(
                            "LED Grow Lights",
                            ghData.actuators.led,
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

  Widget _buildHourPicker(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        DropdownButton<int>(
          value: value,
          dropdownColor: Color(0xFF1E1E2C),
          underline: SizedBox(),
          style: GoogleFonts.inter(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
          items: List.generate(
            24,
            (i) => DropdownMenuItem(
              value: i,
              child: Text("${i.toString().padLeft(2, '0')}:00"),
            ),
          ),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildLedCard(String title, bool value, bool isAuto) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb,
            color: value ? Colors.yellowAccent : AppTheme.primaryGreen,
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
                    'led',
                    val,
                  ),
          ),
        ],
      ),
    );
  }
}
