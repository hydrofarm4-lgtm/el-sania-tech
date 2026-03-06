import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/mock_iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String bgImageUrl =
        'assets/images/568712db29335598b400ef4651bc962f.jpg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "System Alerts",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bgImageUrl, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: StreamBuilder<List<Alert>>(
              stream: iotService.alertStream,
              initialData: iotService.currentAlerts,
              builder: (context, snapshot) {
                final alerts = snapshot.data ?? [];

                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No alerts yet",
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAlertCard(alert),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    Color levelColor;
    IconData icon;

    switch (alert.level) {
      case AlertLevel.critical:
        levelColor = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      case AlertLevel.warning:
        levelColor = Colors.orangeAccent;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertLevel.info:
        levelColor = AppTheme.primaryGreen;
        icon = Icons.check_circle_outline;
        break;
    }

    return GlassCard(
      blur: 15.0,
      opacity: 0.15,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: levelColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('HH:mm:ss - MMM dd, yyyy').format(alert.timestamp),
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
