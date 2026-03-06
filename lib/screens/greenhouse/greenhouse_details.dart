import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../core/iot_service.dart';
import '../../core/app_language_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class GreenhouseDetailsScreen extends StatefulWidget {
  final String greenhouseId;

  const GreenhouseDetailsScreen({Key? key, required this.greenhouseId})
    : super(key: key);

  @override
  State<GreenhouseDetailsScreen> createState() =>
      _GreenhouseDetailsScreenState();
}

class _GreenhouseDetailsScreenState extends State<GreenhouseDetailsScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.greenhouseId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: localizations.language,
            onSelected: (Locale locale) =>
                context.read<AppLanguageProvider>().changeLanguage(locale),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text(localizations.english),
              ),
              PopupMenuItem(
                value: const Locale('ar'),
                child: Text(localizations.arabic),
              ),
              PopupMenuItem(
                value: const Locale('fr'),
                child: Text(localizations.french),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _bgImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppTheme.darkBackground),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: context.read<IoTService>().greenhouseStream(
                widget.greenhouseId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                final ghData = snapshot.data!.data()!;
                final iot = context.read<IoTService>();
                final healthScore = iot.calculateHealthScore(ghData);
                final isAuto = (ghData['mode'] ?? 'manual') == 'auto';
                final activeCropId = ghData['activeCropId'];

                // Find active crop name
                String cropName = 'No Crop Set';
                if (activeCropId != null) {
                  try {
                    cropName = iot.cachedCrops
                        .firstWhere((c) => c.id == activeCropId)
                        .name;
                  } catch (_) {}
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHealthScoreCard(
                            healthScore,
                            cropName,
                            localizations,
                            onTap: () => _showCropSelectionDialog(context, iot),
                          ),
                          const SizedBox(height: 24),
                          _buildModeToggle(isAuto, localizations),
                          const SizedBox(height: 24),
                          _buildTrendChart(widget.greenhouseId, localizations),
                          const SizedBox(height: 32),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 24.0,
                            runSpacing: 24.0,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 450,
                                ),
                                child: _buildSensorsPanel(
                                  ghData,
                                  localizations,
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 450,
                                ),
                                child: _buildControlsPanel(
                                  ghData,
                                  isAuto,
                                  localizations,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 100),
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

  Widget _buildModeToggle(bool isAuto, AppLocalizations localizations) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isAuto ? Icons.auto_mode : Icons.pan_tool_rounded,
                  color: isAuto ? AppTheme.primaryGreen : Colors.orangeAccent,
                ),
                const SizedBox(width: 16),
                Text(
                  isAuto ? localizations.autoMode : localizations.manualMode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAuto ? AppTheme.primaryGreen : Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            Switch.adaptive(
              value: isAuto,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) {
                FirebaseFirestore.instance
                    .collection('greenhouses')
                    .doc(widget.greenhouseId)
                    .update({'mode': val ? 'auto' : 'manual'});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(
    double score,
    String cropName,
    AppLocalizations l10n, {
    VoidCallback? onTap,
  }) {
    Color color = score > 80
        ? AppTheme.primaryGreen
        : (score > 50 ? Colors.orangeAccent : Colors.redAccent);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      color: color.withOpacity(0.05),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  color: color,
                  backgroundColor: Colors.white12,
                ),
              ),
              Text(
                '${score.toStringAsFixed(0)}%',
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.healthScore.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  cropName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.edit, size: 12, color: color.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      "Tap to change crop profile",
                      style: TextStyle(
                        color: color.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<IoTService>().getAIInsight(score, l10n),
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(String houseId, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trend24h.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<IoTService>().getTrendData(houseId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No trend data available",
                      style: TextStyle(color: Colors.white24),
                    ),
                  );
                }

                final docs = snapshot.data!.docs.reversed.toList();
                final spots = <FlSpot>[];
                for (int i = 0; i < docs.length; i++) {
                  final temp = (docs[i].data()['temperature'] ?? 20.0)
                      .toDouble();
                  spots.add(FlSpot(i.toDouble(), temp));
                }

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.primaryGreen,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsPanel(Map<String, dynamic> data, AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sensors, color: AppTheme.primaryGreen, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.liveSensors,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildSensorItem(
                title: l10n.sensorTemp,
                value: '${(data['temperature'] ?? 0.0).toStringAsFixed(1)} °C',
                icon: Icons.thermostat,
                onTap: () => context.push(
                  '/greenhouse/${widget.greenhouseId}/temperature',
                ),
              ),
              _buildSensorItem(
                title: l10n.sensorHumidity,
                value: '${(data['humidity'] ?? 0.0).toStringAsFixed(1)} %',
                icon: Icons.water_drop,
                onTap: () =>
                    context.push('/greenhouse/${widget.greenhouseId}/humidity'),
              ),
              _buildSensorItem(
                title: l10n.sensorEC,
                value: '${(data['ec'] ?? 0.0).toStringAsFixed(2)} mS',
                icon: Icons.bolt,
              ),
              _buildSensorItem(
                title: l10n.sensorPH,
                value: (data['ph'] ?? 0.0).toStringAsFixed(2),
                icon: Icons.science,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(
    Map<String, dynamic> data,
    bool isAuto,
    AppLocalizations l10n,
  ) {
    final actuators = data['actuators'] ?? {};
    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune, color: AppTheme.primaryGreen, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.actuatorsRelays,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActuatorToggle(
            l10n.controlLedLights,
            'led',
            actuators['led'] ?? false,
            isAuto,
          ),
          _buildActuatorToggle(
            l10n.controlWaterPump,
            'pump',
            actuators['pump'] ?? false,
            isAuto,
          ),
          _buildActuatorToggle(
            l10n.controlCoolingSystem,
            'cooler',
            actuators['cooler'] ?? false,
            isAuto,
          ),
          _buildActuatorToggle(
            l10n.controlVentilationFans,
            'fan',
            actuators['fan'] ?? false,
            isAuto,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorItem({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.lightGrey, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActuatorToggle(
    String title,
    String key,
    bool value,
    bool isAutoMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isAutoMode ? Colors.white38 : Colors.white,
              ),
            ),
            Switch.adaptive(
              value: value,
              activeColor: AppTheme.primaryGreen,
              onChanged: isAutoMode
                  ? null
                  : (val) {
                      FirebaseFirestore.instance
                          .collection('greenhouses')
                          .doc(widget.greenhouseId)
                          .update({'actuators.$key': val});
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showCropSelectionDialog(BuildContext context, IoTService iot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Select Crop Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Linking a crop profile will sync dynamic thresholds for health scoring.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: StreamBuilder<List<CropProfile>>(
                  stream: iot.cropsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final crops = snapshot.data!;
                    if (crops.isEmpty) {
                      return const Text(
                        'No crop profiles found.',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        return ListTile(
                          title: Text(
                            crop.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Temp: ${crop.minTemp}-${crop.maxTemp}°C',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          onTap: () {
                            iot.setActiveCrop(widget.greenhouseId, crop.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
