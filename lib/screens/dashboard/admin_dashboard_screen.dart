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
              icon: const Icon(Icons.manage_accounts_outlined),
              text: localizations
                  .tabUserRequests, // Treating this as User Management
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
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading insights: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
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
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Permission Denied / Error: ${snapshot.error}\nPlease check your Firebase Firestore Security Rules.',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.maps_home_work_outlined,
                  size: 80,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Greenhouses Found',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Add a default disconnected greenhouse to Firestore
                    final newHouse = {
                      'temperature': null,
                      'humidity': null,
                      'ph': null,
                      'ec': null,
                      'isOnline': false,
                      'mode': 'manual',
                      'actuators': {
                        'led': false,
                        'pump': false,
                        'cooler': false,
                        'fan': false,
                      },
                      'targetMin': 20.0,
                      'targetMax': 30.0,
                    };
                    await FirebaseFirestore.instance
                        .collection('greenhouses')
                        .doc('HOUSE-X1')
                        .set(newHouse);
                    await FirebaseFirestore.instance
                        .collection('greenhouses')
                        .doc('HOUSE-Y2')
                        .set(newHouse);
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'Add Test Greenhouses',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
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
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_gh_fab',
            backgroundColor: AppTheme.primaryGreen,
            onPressed: () async {
              final newHouse = {
                'temperature': null,
                'humidity': null,
                'ph': null,
                'ec': null,
                'isOnline': false,
                'mode': 'manual',
                'actuators': {
                  'led': false,
                  'pump': false,
                  'cooler': false,
                  'fan': false,
                },
                'targetMin': 20.0,
                'targetMax': 30.0,
              };
              final id =
                  'HOUSE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
              await FirebaseFirestore.instance
                  .collection('greenhouses')
                  .doc(id)
                  .set(newHouse);
            },
            child: const Icon(Icons.add, color: Colors.black),
          ),
        );
      },
    );
  }

  Widget _buildWorkforceTab(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading workforce: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final allUsers = docs
            .map((doc) => User.fromMap(doc.id, doc.data()))
            .toList();

        // Only show approved users in the workforce tab (exclude SuperAdmins if needed)
        final workforce = allUsers
            .where((u) => u.isApproved && u.role != UserRole.superAdmin)
            .toList();

        if (workforce.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                Text(
                  "No active workforce found.",
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: workforce.length,
          itemBuilder: (context, index) {
            final user = workforce[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryGreen,
                      ),
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
                          const SizedBox(height: 4),
                          Text(
                            "${user.role?.name.toUpperCase() ?? 'UNKNOWN'} • Active",
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.assignedGreenhouses.isEmpty
                                ? "No assigned locations"
                                : "Assigned: ${user.assignedGreenhouses.join(', ')}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () =>
                          _showUserManagementDialog(context, user, l10n),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmDeleteUser(context, user),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserRequestsTab(AppLocalizations l10n) {
    final authService = context.watch<AuthService>();
    final allUsers = authService.allUsers;

    // Only show pending users in the requests tab
    final pendingUsers = allUsers.where((u) => !u.isApproved).toList();

    if (pendingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              "No pending requests.",
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      );
    }

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
                CircleAvatar(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.amber,
                  ),
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
                      const SizedBox(height: 4),
                      Text(
                        "Status: Pending Approval",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70),
                  onPressed: () =>
                      _showUserManagementDialog(context, user, l10n),
                ),
                if (user.role !=
                    UserRole.superAdmin) // prevent self delete visually
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDeleteUser(context, user),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserManagementDialog(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) {
    // If the user being edited is superAdmin, we shouldn't force them into worker/engineer dropdown
    // unless we also provide a superAdmin option.
    UserRole selectedRole = user.role ?? UserRole.worker;

    // In case the selectedRole isn't one of the options (e.g. they somehow are superAdmin but in this dialog)
    if (selectedRole != UserRole.engineer && selectedRole != UserRole.worker) {
      selectedRole = UserRole.worker;
    }

    List<String> selectedHouses = List.from(user.assignedGreenhouses);
    bool isApproved = user.isApproved;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: Text(
            user.isApproved
                ? "Edit User: ${user.name}"
                : "Approve User: ${user.name}",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    "Is Approved / Active",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: isApproved,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) => setDialogState(() => isApproved = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                const Text("Role:", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF1E1E2C),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),
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
                const Text(
                  "Assigned Greenhouses:",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),

                // Fetch physical greenhouses directly from Firebase dynamically
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('greenhouses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No Greenhouses available.",
                        style: TextStyle(color: Colors.redAccent),
                      );
                    }

                    final allHouses = snapshot.data!.docs
                        .map((doc) => doc.id)
                        .toList();

                    return Column(
                      children: allHouses
                          .map(
                            (id) => CheckboxListTile(
                              title: Text(
                                id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              value: selectedHouses.contains(id),
                              activeColor: AppTheme.primaryGreen,
                              checkColor: Colors.black,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) {
                                    selectedHouses.add(id);
                                  } else {
                                    selectedHouses.remove(id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<AuthService>().updateUser(
                    user.id,
                    selectedRole,
                    selectedHouses,
                    isApproved,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update user: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('SAVE', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          "Delete User?",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          "Are you sure you want to permanently delete ${user.email}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthService>().deleteUser(user.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
