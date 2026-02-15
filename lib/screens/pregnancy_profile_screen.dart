import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';

class PregnancyProfileScreen extends StatefulWidget {
  const PregnancyProfileScreen({super.key});

  @override
  State<PregnancyProfileScreen> createState() => _PregnancyProfileScreenState();
}

class _PregnancyProfileScreenState extends State<PregnancyProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _isEditing = false;

  final _lmpController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _conditionsController = TextEditingController();
  String _pregnancyType = 'continue';
  String _bloodGroup = 'O+';
  DateTime? _selectedLmp;

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    try {
      final data = await ApiService.getPregnancyProfile(
        userId: auth.userId!, token: auth.token!,
      );
      if (data.isNotEmpty) {
        setState(() { _profile = data; _loading = false; });
      } else {
        setState(() { _isEditing = true; _loading = false; });
      }
    } catch (_) {
      setState(() { _isEditing = true; _loading = false; });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 60)),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedLmp = date;
        _lmpController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_selectedLmp == null && _profile == null) {
      UiUtils.showError(context, 'Please select your last period date');
      return;
    }
    final auth = context.read<AuthProvider>();
    try {
      if (_profile == null) {
        final data = await ApiService.createPregnancyProfile(
          body: {
            'user_id': auth.userId,
            'last_period_date': _lmpController.text,
            'pregnancy_type': _pregnancyType,
            'blood_group': _bloodGroup,
            'weight': double.tryParse(_weightController.text),
            'height': double.tryParse(_heightController.text),
            'existing_conditions': _conditionsController.text,
          },
          token: auth.token!,
        );
        setState(() { _profile = data; _isEditing = false; });
        if (mounted) UiUtils.showSuccess(context, 'Profile created!');
      } else {
        final data = await ApiService.updatePregnancyProfile(
          userId: auth.userId!,
          body: {
            'pregnancy_type': _pregnancyType,
            'blood_group': _bloodGroup,
            'weight': double.tryParse(_weightController.text),
            'height': double.tryParse(_heightController.text),
            'existing_conditions': _conditionsController.text,
          },
          token: auth.token!,
        );
        setState(() { _profile = data; _isEditing = false; });
        if (mounted) UiUtils.showSuccess(context, 'Profile updated!');
      }
    } catch (e) {
      if (mounted) UiUtils.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Profile'),
        actions: _profile != null && !_isEditing
            ? [IconButton(icon: const Icon(Icons.edit), onPressed: () {
                setState(() {
                  _isEditing = true;
                  _pregnancyType = _profile!['pregnancy_type'] ?? 'continue';
                  _bloodGroup = _profile!['blood_group'] ?? 'O+';
                  _weightController.text = _profile!['weight']?.toString() ?? '';
                  _heightController.text = _profile!['height']?.toString() ?? '';
                  _conditionsController.text = _profile!['existing_conditions'] ?? '';
                });
              })]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing ? _buildForm(theme, isDark) : _buildProfileView(theme, isDark),
    );
  }

  Widget _buildForm(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE91E8C), Color(0xFFFF6EC7)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.pregnant_woman, color: Colors.white, size: 40),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_profile == null ? 'Setup Your Profile' : 'Edit Profile',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_profile == null ? 'Let\'s track your pregnancy journey' : 'Update your information',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),

        // LMP Date
        if (_profile == null) ...[
          _label('Last Period Date (LMP)'),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextField(
                controller: _lmpController,
                decoration: InputDecoration(
                  hintText: 'Tap to select date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Pregnancy Type
        _label('Pregnancy Decision'),
        Row(children: [
          _typeChip('Continue Delivery', 'continue', Icons.child_care, const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          _typeChip('Medical Termination', 'abort', Icons.medical_services, const Color(0xFFFF5722)),
        ]),
        const SizedBox(height: 16),

        // Blood Group
        _label('Blood Group'),
        DropdownButtonFormField<String>(
          value: _bloodGroup,
          items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _bloodGroup = v!),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.bloodtype),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Weight & Height
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Weight (kg)'),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Height (cm)'),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 16),

        _label('Existing Conditions'),
        TextField(
          controller: _conditionsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Diabetes, Thyroid, PCOS...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(_profile == null ? 'Create Profile' : 'Update Profile',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _typeChip(String label, String value, IconData icon, Color color) {
    final selected = _pregnancyType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _pregnancyType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : Colors.transparent, width: 2),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? color : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  Widget _buildProfileView(ThemeData theme, bool isDark) {
    final weeks = _profile!['gestational_weeks'] ?? 0;
    final days = _profile!['gestational_days'] ?? 0;
    final trimester = _profile!['trimester'] ?? 1;
    final dueDate = _profile!['due_date'] ?? '';
    final progress = (weeks / 40).clamp(0.0, 1.0);

    final trimesterColor = trimester == 1
        ? const Color(0xFF4CAF50) : trimester == 2
        ? const Color(0xFFFF9800) : const Color(0xFFE91E8C);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Pregnancy Progress Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFE91E8C), const Color(0xFFFF6EC7).withValues(alpha: 0.8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFFE91E8C).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            SizedBox(
              width: 140, height: 140,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 140, height: 140,
                  child: CircularProgressIndicator(
                    value: progress.toDouble(),
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$weeks', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const Text('weeks', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  if (days > 0) Text('+$days days', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('Trimester $trimester', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Text('Due: ${_formatDate(dueDate)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 20),

        // Info Cards
        Row(children: [
          _infoCard('Blood', _profile!['blood_group'] ?? 'N/A', Icons.bloodtype, const Color(0xFFE53935)),
          const SizedBox(width: 12),
          _infoCard('Weight', '${_profile!['weight'] ?? 'N/A'} kg', Icons.monitor_weight, const Color(0xFF7C4DFF)),
          const SizedBox(width: 12),
          _infoCard('Height', '${_profile!['height'] ?? 'N/A'} cm', Icons.height, const Color(0xFF00BCD4)),
        ]),
        const SizedBox(height: 16),

        // Decision Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(children: [
            Icon(_profile!['pregnancy_type'] == 'continue' ? Icons.child_care : Icons.medical_services,
                color: _profile!['pregnancy_type'] == 'continue' ? const Color(0xFF4CAF50) : const Color(0xFFFF5722), size: 30),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Decision', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(_profile!['pregnancy_type'] == 'continue' ? 'Continuing Delivery' : 'Medical Termination',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        if (_profile!['existing_conditions'] != null && _profile!['existing_conditions'].toString().isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.warning_amber, color: Color(0xFFFF9800), size: 22),
                const SizedBox(width: 8),
                const Text('Existing Conditions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text(_profile!['existing_conditions'], style: TextStyle(color: Colors.grey.shade600)),
            ]),
          ),

        const SizedBox(height: 20),

        // Weekly Tips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: trimesterColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: trimesterColor.withValues(alpha: 0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.lightbulb, color: trimesterColor, size: 22),
              const SizedBox(width: 8),
              Text('Week $weeks Tips', style: TextStyle(color: trimesterColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 10),
            Text(_getWeeklyTip(weeks), style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
          ]),
        ),
      ]),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
  );

  String _formatDate(String d) {
    try { return DateFormat('MMM dd, yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }

  String _getWeeklyTip(int week) {
    if (week <= 4) return 'Your baby is a tiny ball of cells. Start taking folic acid supplements. Avoid alcohol and smoking.';
    if (week <= 8) return 'Baby\'s heart starts beating! You may experience morning sickness. Eat small, frequent meals.';
    if (week <= 12) return 'Baby is now the size of a lime. First trimester screening is recommended. Stay hydrated.';
    if (week <= 16) return 'You may start feeling baby\'s first movements. Energy levels improve. Schedule your mid-pregnancy scan.';
    if (week <= 20) return 'Halfway there! Baby can hear sounds. The anatomy scan is recommended around this time.';
    if (week <= 24) return 'Baby is developing taste buds. You may notice Braxton Hicks contractions. Stay active with gentle exercise.';
    if (week <= 28) return 'Third trimester begins! Baby\'s eyes can open. Glucose screening test is typically done now.';
    if (week <= 32) return 'Baby is gaining weight rapidly. You may feel more tired. Practice breathing exercises for labor.';
    if (week <= 36) return 'Baby is almost full term. Prepare your hospital bag. Discuss birth plan with your doctor.';
    return 'You\'re in the home stretch! Baby could arrive any day. Watch for signs of labor. Stay calm and prepared.';
  }
}
