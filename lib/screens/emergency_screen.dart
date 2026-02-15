import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<dynamic> _emergencies = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencies();
  }

  Future<void> _loadEmergencies() async {
    final auth = context.read<AuthProvider>();
    try {
      final data = await ApiService.getMyEmergencies(patientId: auth.userId!, token: auth.token!);
      setState(() { _emergencies = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendSOS() async {
    final messageCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.emergency, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Emergency SOS'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Describe your symptoms or emergency. A doctor will be notified immediately.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: messageCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Severe abdominal pain, heavy bleeding, dizziness...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              if (messageCtrl.text.isNotEmpty) Navigator.pop(ctx, true);
            },
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            label: const Text('Send SOS', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _sending = true);
      final auth = context.read<AuthProvider>();
      try {
        await ApiService.createEmergency(patientId: auth.userId!, message: messageCtrl.text, token: auth.token!);
        if (mounted) {
          UiUtils.showSuccess(context, 'Emergency request sent! A doctor will respond soon.');
          _loadEmergencies();
        }
      } catch (e) {
        if (mounted) UiUtils.showError(context, e.toString());
      }
      setState(() => _sending = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF9800);
      case 'accepted': return const Color(0xFF4CAF50);
      case 'resolved': return const Color(0xFF2196F3);
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_top;
      case 'accepted': return Icons.check_circle;
      case 'resolved': return Icons.done_all;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: Column(children: [
        // SOS Button
        Container(
          margin: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: _sending ? null : _sendSOS,
            child: Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _sending
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [const Color(0xFFE53935), const Color(0xFFFF5252)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: (_sending ? Colors.grey : Colors.red).withValues(alpha: 0.4),
                  blurRadius: 24, offset: const Offset(0, 8),
                )],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _sending ? Icons.hourglass_top : Icons.emergency,
                    color: Colors.white, size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_sending ? 'Sending...' : 'TAP FOR EMERGENCY SOS',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('Notify nearest available doctor',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ]),
            ),
          ),
        ),

        // Emergency History
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Icon(Icons.history, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Request History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ]),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _emergencies.isEmpty
                  ? Center(child: Text('No emergency requests yet', style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _emergencies.length,
                      itemBuilder: (_, i) {
                        final e = _emergencies[i];
                        final status = e['status'] ?? 'pending';
                        final color = _statusColor(status);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(_statusIcon(status), color: color, size: 22),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(status.toUpperCase(),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                              ),
                              const Spacer(),
                              Text(e['created_at']?.toString().substring(0, 16) ?? '',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ]),
                            const SizedBox(height: 10),
                            Text(e['message'] ?? '', style: const TextStyle(fontSize: 14)),
                            if (status == 'accepted' && e['consultation_type'] != null) ...[
                              const SizedBox(height: 8),
                              Row(children: [
                                Icon(e['consultation_type'] == 'online' ? Icons.video_call : Icons.directions_walk,
                                    color: const Color(0xFF4CAF50), size: 18),
                                const SizedBox(width: 6),
                                Text('Doctor will ${e['consultation_type'] == 'online' ? 'call you' : 'visit you'}',
                                    style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 13)),
                              ]),
                            ],
                          ]),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
