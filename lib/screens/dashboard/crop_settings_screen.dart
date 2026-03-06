import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/iot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class CropSettingsScreen extends StatefulWidget {
  const CropSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CropSettingsScreen> createState() => _CropSettingsScreenState();
}

class _CropSettingsScreenState extends State<CropSettingsScreen> {
  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  @override
  Widget build(BuildContext context) {
    final iotService = context.watch<IoTService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'CROP MANAGEMENT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: StreamBuilder<List<CropProfile>>(
              stream: iotService.cropsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final crops = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return _buildCropCard(crop);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCropForm(context),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCropCard(CropProfile crop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  crop.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => _showCropForm(context, crop: crop),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmDelete(crop),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            _buildThresholdGrid(crop),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdGrid(CropProfile crop) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildThresholdItem(
          'Temperature',
          '${crop.minTemp}°C - ${crop.maxTemp}°C',
          Icons.thermostat,
        ),
        _buildThresholdItem(
          'Humidity',
          '${crop.minHumidity}% - ${crop.maxHumidity}%',
          Icons.water_drop,
        ),
        _buildThresholdItem(
          'pH Level',
          '${crop.minPh} - ${crop.maxPh}',
          Icons.science,
        ),
      ],
    );
  }

  Widget _buildThresholdItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showCropForm(BuildContext context, {CropProfile? crop}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CropForm(crop: crop),
    );
  }

  void _confirmDelete(CropProfile crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Delete Crop Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${crop.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<IoTService>().deleteCrop(crop.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CropForm extends StatefulWidget {
  final CropProfile? crop;
  const _CropForm({this.crop});

  @override
  State<_CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<_CropForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumController;
  late TextEditingController _maxHumController;
  late TextEditingController _minPhController;
  late TextEditingController _maxPhController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crop?.name ?? '');
    _minTempController = TextEditingController(
      text: widget.crop?.minTemp.toString() ?? '',
    );
    _maxTempController = TextEditingController(
      text: widget.crop?.maxTemp.toString() ?? '',
    );
    _minHumController = TextEditingController(
      text: widget.crop?.minHumidity.toString() ?? '',
    );
    _maxHumController = TextEditingController(
      text: widget.crop?.maxHumidity.toString() ?? '',
    );
    _minPhController = TextEditingController(
      text: widget.crop?.minPh.toString() ?? '',
    );
    _maxPhController = TextEditingController(
      text: widget.crop?.maxPh.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.crop == null ? 'ADD NEW CROP' : 'EDIT CROP PROFILE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Crop Name', Icons.eco),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _minTempController,
                      'Min Temp (°C)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      _maxTempController,
                      'Max Temp (°C)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(_minHumController, 'Min Hum (%)'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(_maxHumController, 'Max Hum (%)'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(_minPhController, 'Min pH'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(_maxPhController, 'Max pH'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.crop == null ? 'CREATE PROFILE' : 'UPDATE PROFILE',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, null),
      validator: (v) {
        if (v?.isEmpty ?? true) return 'Required';
        if (double.tryParse(v!) == null) return 'Invalid number';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: icon != null
          ? Icon(icon, color: AppTheme.primaryGreen)
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryGreen),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final minTemp = double.parse(_minTempController.text);
      final maxTemp = double.parse(_maxTempController.text);
      final minHum = double.parse(_minHumController.text);
      final maxHum = double.parse(_maxHumController.text);
      final minPh = double.parse(_minPhController.text);
      final maxPh = double.parse(_maxPhController.text);

      if (minTemp > maxTemp || minHum > maxHum || minPh > maxPh) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Min values cannot be greater than Max values'),
          ),
        );
        return;
      }

      final profile = CropProfile(
        id: widget.crop?.id ?? '',
        name: _nameController.text,
        minTemp: minTemp,
        maxTemp: maxTemp,
        minHumidity: minHum,
        maxHumidity: maxHum,
        minPh: minPh,
        maxPh: maxPh,
      );

      if (widget.crop == null) {
        context.read<IoTService>().addCrop(profile);
      } else {
        context.read<IoTService>().updateCrop(profile);
      }
      Navigator.pop(context);
    }
  }
}
