import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth_service.dart';
import '../../core/iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class EngineerDashboard extends StatelessWidget {
  const EngineerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          localizations.roleEngineer.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('greenhouses')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final houses = snapshot.data!.docs;

                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildAIInsightsSection(context, localizations, houses),
                    const SizedBox(height: 24),
                    _buildQuickStats(localizations, houses.length),
                    const SizedBox(height: 24),
                    Text(
                      localizations.manage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (houses.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No greenhouses available.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ...houses.map(
                        (doc) => _buildHouseCard(context, doc.id, doc.data()),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection(
    BuildContext context,
    AppLocalizations l10n,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> houses,
  ) {
    final iot = context.read<IoTService>();
    double totalScore = 0;
    for (var doc in houses) {
      totalScore += iot.calculateHealthScore(doc.data());
    }
    final avgScore = houses.isNotEmpty ? totalScore / houses.length : 100.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryGreen.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              Text(
                l10n.aiInsights,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            iot.getAIInsight(avgScore, l10n),
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations localizations, int count) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.location_city, count.toString(), 'Locations'),
          _statItem(Icons.check_circle_outline, 'Online', 'Status'),
          _statItem(Icons.construction, '0', 'Maintenance'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHouseCard(
    BuildContext context,
    String houseId,
    Map<String, dynamic> data,
  ) {
    final score = context.read<IoTService>().calculateHealthScore(data);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.push('/greenhouse/$houseId'),
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.settings_input_component,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      houseId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Health: ${score.toStringAsFixed(0)}% • ${data['cropType']}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
