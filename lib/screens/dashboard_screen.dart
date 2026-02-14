import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_log_provider.dart';
import '../widgets/stat_card.dart';
import 'add_health_log_screen.dart';
import 'health_history_screen.dart';
import 'reminders_screen.dart';
import 'chat_screen.dart';
import 'symptom_checker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _tips = [
    '💧 Stay hydrated — drink 8 glasses of water daily',
    '🧘 Practice deep breathing to reduce stress',
    '🥗 Eat iron-rich foods during your period',
    '😴 Aim for 7-9 hours of sleep each night',
    '🚶‍♀️ Light exercise can help with cramps',
    '📝 Track your symptoms daily for better insights',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<HealthLogProvider>().fetchLogs(auth.userId!, auth.token!);
      // Try syncing pending logs
      context.read<HealthLogProvider>().syncPending(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final logProv = context.watch<HealthLogProvider>();
    final tip = _tips[DateTime.now().day % _tips.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('HerCare'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout(), tooltip: 'Logout'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: const Color(0xFFE91E8C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Greeting
            Text('Hello, ${auth.userName ?? "User"} 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 4),
            Text('How are you feeling today?', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
            const SizedBox(height: 20),

            // Stats Row
            Row(children: [
              Expanded(child: StatCard(icon: Icons.healing, label: 'Avg Pain', value: logProv.avgPain.toStringAsFixed(1), color: _painColor(logProv.avgPain))),
              const SizedBox(width: 8),
              Expanded(child: StatCard(icon: Icons.list_alt, label: 'Total Logs', value: '${logProv.logs.length}', color: const Color(0xFF7C4DFF))),
              const SizedBox(width: 8),
              Expanded(child: StatCard(icon: Icons.calendar_month, label: 'Next Period', value: logProv.nextPeriod?.substring(5) ?? 'N/A', color: Colors.teal)),
            ]),
            const SizedBox(height: 16),

            // Pending sync indicator
            if (logProv.pendingCount > 0)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${logProv.pendingCount} log(s) waiting to sync', style: const TextStyle(color: Colors.orange))),
                    TextButton(onPressed: () async {
                      final synced = await logProv.syncPending(auth.token!);
                      if (mounted && synced > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Synced $synced log(s)'), backgroundColor: Colors.green));
                        _loadData();
                      }
                    }, child: const Text('Sync', style: TextStyle(color: Colors.orange))),
                  ]),
                ),
              ),

            // Last Log
            if (logProv.lastLog != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE91E8C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.history, color: Color(0xFFE91E8C), size: 20)),
                      const SizedBox(width: 12),
                      const Text('Last Health Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                    const Divider(height: 20),
                    Row(children: [
                      _chip('📅 ${logProv.lastLog!.logDate}'),
                      const SizedBox(width: 8),
                      _chip('😊 ${logProv.lastLog!.mood}'),
                      const SizedBox(width: 8),
                      _chip('💉 Pain: ${logProv.lastLog!.painLevel}'),
                    ]),
                  ]),
                ),
              ),
            ],

            // Health Tip
            const SizedBox(height: 16),
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.lightbulb_outline, color: Colors.teal, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Daily Tip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
                    const SizedBox(height: 4),
                    Text(tip, style: TextStyle(fontSize: 13, color: Colors.teal.shade800)),
                  ])),
                ]),
              ),
            ),

            // Action cards
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ActionCard(icon: Icons.add_circle_outline, title: 'Add Health Log', subtitle: 'Track symptoms, mood & pain', color: const Color(0xFFE91E8C), onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHealthLogScreen()));
              if (result == true) _loadData();
            }),
            const SizedBox(height: 10),
            _ActionCard(icon: Icons.history, title: 'View History', subtitle: 'See, edit & delete past logs', color: const Color(0xFF7C4DFF), onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHistoryScreen()));
              _loadData();
            }),
            const SizedBox(height: 10),
            _ActionCard(icon: Icons.alarm, title: 'Reminders', subtitle: 'Period, meds & appointments', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
            const SizedBox(height: 10),
            _ActionCard(icon: Icons.chat_bubble_outline, title: 'Doctor Chat', subtitle: 'Talk to a healthcare advisor', color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
            const SizedBox(height: 10),
            _ActionCard(icon: Icons.health_and_safety, title: 'Symptom Checker', subtitle: 'AI-powered health analysis', color: Colors.deepPurple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomCheckerScreen()))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );

  Color _painColor(double avg) { if (avg <= 3) return Colors.green; if (avg <= 6) return Colors.orange; return Colors.red; }
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))])),
        Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
      ]))),
    );
  }
}
