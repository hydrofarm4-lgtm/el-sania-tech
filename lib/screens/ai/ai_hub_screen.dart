import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AiHubScreen extends StatelessWidget {
  const AiHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cimorg AI Hub')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/6a4951a109795e7ef91185f0a4ac5f2d.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Powered by NVIDIA Jetson',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildAiFeatureCard(
                  context,
                  title: 'Cam Scan (Pest Detection)',
                  description:
                      'Live camera feed analyzing plants for early signs of diseases or pests.',
                  icon: Icons.camera_alt,
                ),
                _buildAiFeatureCard(
                  context,
                  title: 'Smart Nutrient Controller',
                  description:
                      'AI-driven dynamic calculation for EC/pH balancing based on crop growth stage.',
                  icon: Icons.science,
                ),
                _buildAiFeatureCard(
                  context,
                  title: 'Yield Prediction',
                  description:
                      'Projected harvest date and profitability analysis based on historical data.',
                  icon: Icons.auto_graph,
                ),
                _buildAiFeatureCard(
                  context,
                  title: 'AI Voice Assistant',
                  description:
                      'Voice commands for hands-free greenhouse control and status reports.',
                  icon: Icons.mic,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Module $title is connecting to Jetson...',
                          ),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Initialize Module'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
