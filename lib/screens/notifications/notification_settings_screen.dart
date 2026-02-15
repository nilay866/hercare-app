import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late Map<String, bool> _preferences;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NotificationProvider>();
    _preferences = Map<String, bool>.from(provider.notificationPreferences);
    
    // Initialize with default preferences if empty
    if (_preferences.isEmpty) {
      _preferences = {
        'email': true,
        'sms': true,
        'push': true,
        'appointment_reminders': true,
        'lab_results': true,
        'prescription_updates': true,
        'general_updates': false,
        'marketing': false,
      };
    }
  }

  void _savePreferences() async {
    setState(() => _isSaving = true);

    final provider = context.read<NotificationProvider>();
    final success = await provider.updateNotificationPreferences(_preferences);

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to save settings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Notification Channels Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Channels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceSwitch(
                    key: 'email',
                    title: 'Email Notifications',
                    description: 'Receive notifications via email',
                    icon: Icons.mail_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'sms',
                    title: 'SMS Notifications',
                    description: 'Receive notifications via SMS',
                    icon: Icons.sms_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'push',
                    title: 'Push Notifications',
                    description: 'Receive notifications in the app',
                    icon: Icons.notifications_outlined,
                  ),
                ],
              ),
            ),

            const Divider(),

            // Notification Types Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceSwitch(
                    key: 'appointment_reminders',
                    title: 'Appointment Reminders',
                    description: 'Get reminded about upcoming appointments',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'lab_results',
                    title: 'Lab Results',
                    description: 'Notified when lab results are ready',
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'prescription_updates',
                    title: 'Prescription Updates',
                    description: 'Notified about prescription changes',
                    icon: Icons.medication,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'general_updates',
                    title: 'General Updates',
                    description: 'Receive general health and wellness updates',
                    icon: Icons.info_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceSwitch(
                    key: 'marketing',
                    title: 'Marketing Emails',
                    description: 'Receive promotional and marketing emails',
                    icon: Icons.mail_outline,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info box
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can always control notification delivery through your device settings as well.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: (_isSaving || provider.isLoading) ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving || provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Preferences',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String key,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _preferences[key] ?? false,
            onChanged: (value) {
              setState(() {
                _preferences[key] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
