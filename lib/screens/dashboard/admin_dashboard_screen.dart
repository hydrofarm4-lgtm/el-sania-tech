import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth_service.dart';
import '../../core/iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'EL SANIA TECHNOLOGY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
            Text(
              localizations.roleSuperAdmin.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.eco_outlined),
            tooltip: 'Crops Management',
            onPressed: () => context.push('/super-admin/crops'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthService>().logout(),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.analytics_outlined),
              text: localizations.tabProjectStatus,
            ),
            Tab(
              icon: const Icon(Icons.grid_view_rounded),
              text: localizations.tabGreenhouses,
            ),
            Tab(
              icon: const Icon(Icons.people_outline),
              text: localizations.tabWorkforce,
            ),
            Tab(
              icon: const Icon(Icons.person_add_outlined),
              text: localizations.tabUserRequests,
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bgImageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProjectStatusTab(localizations),
                _buildGreenhouseTab(localizations),
                _buildWorkforceTab(localizations),
                _buildUserRequestsTab(localizations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('greenhouses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final iot = context.read<IoTService>();

        // Calculate an average health score or find issues
        double totalScore = 0;
        int count = snapshot.data!.docs.length;
        String criticalAlert = "";

        for (var doc in snapshot.data!.docs) {
          final score = iot.calculateHealthScore(doc.data());
          totalScore += score;
          if (score < 50)
            criticalAlert = "Critical: ${doc.id} needs attention!";
        }

        final avgScore = count > 0 ? totalScore / count : 100.0;

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
              const SizedBox(height: 16),
              Text(
                iot.getAIInsight(avgScore, l10n),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (criticalAlert.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  criticalAlert,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectStatusTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIInsightsSection(l10n),
          const SizedBox(height: 24),
          Text(
            l10n.investorHub.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for other investor stats...
          _buildStatRow(l10n.marketReadiness, "92%", Icons.trending_up),
          _buildStatRow(
            l10n.estimatedYield,
            "1.2 Tons",
            Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white54, size: 20),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenhouseTab(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('greenhouses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/greenhouse/${doc.id}'),
                child: ListTile(
                  title: Text(
                    doc.id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${data['cropType'] ?? 'Unknown'} - Health: ${(context.read<IoTService>().calculateHealthScore(data)).toStringAsFixed(0)}%",
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkforceTab(AppLocalizations l10n) {
    return Center(
      child: Text(
        "Workforce Management Under Construction",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildUserRequestsTab(AppLocalizations l10n) {
    final authService = context.watch<AuthService>();
    final pendingUsers = authService.pendingUsers;
    if (pendingUsers.isEmpty)
      return Center(
        child: Text(
          "No pending requests.",
          style: GoogleFonts.inter(color: Colors.white54),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Status: Pending Approval",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showApproveDialog(context, user, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: Text(
                    l10n.approve,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApproveDialog(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) {
    UserRole selectedRole = UserRole.worker;
    List<String> selectedHouses = [];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: Text(
            "Approve User: ${user.email}",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                dropdownColor: const Color(0xFF1E1E2C),
                items: [
                  DropdownMenuItem(
                    value: UserRole.engineer,
                    child: Text(l10n.roleEngineer),
                  ),
                  DropdownMenuItem(
                    value: UserRole.worker,
                    child: Text(l10n.roleWorker),
                  ),
                ],
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
              const SizedBox(height: 16),
              ...['House A', 'House B', 'House C'].map(
                (id) => CheckboxListTile(
                  title: Text(
                    id,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  value: selectedHouses.contains(id),
                  onChanged: (val) => setDialogState(
                    () => val!
                        ? selectedHouses.add(id)
                        : selectedHouses.remove(id),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthService>().approveUser(
                  user.id,
                  selectedRole,
                  selectedHouses,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text(
                'APPROVE',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
