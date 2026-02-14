import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_log_provider.dart';
import 'edit_health_log_screen.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) context.read<HealthLogProvider>().fetchLogs(auth.userId!, auth.token!);
  }

  Future<void> _delete(String logId) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Log?'), content: const Text('This cannot be undone.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red)))],
    ));
    if (confirm == true) {
      try {
        await context.read<HealthLogProvider>().deleteLog(logId, context.read<AuthProvider>().token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Log deleted'), backgroundColor: Colors.orange));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logProv = context.watch<HealthLogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Health History')),
      body: logProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
          : logProv.logs.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16),
                  Text('No health logs yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                ]))
              : RefreshIndicator(
                  onRefresh: () async => _load(),
                  color: const Color(0xFFE91E8C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16), itemCount: logProv.logs.length,
                    itemBuilder: (_, i) {
                      final log = logProv.logs[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 16, color: Color(0xFFE91E8C)), const SizedBox(width: 6),
                            Text(log.logDate, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE91E8C))),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(log.logType, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w500))),
                            const Spacer(),
                            IconButton(icon: const Icon(Icons.edit, size: 20, color: Color(0xFF7C4DFF)), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditHealthLogScreen(log: log))); if (r == true) _load(); }),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _delete(log.id!)),
                          ]),
                          const Divider(height: 16),
                          Row(children: [
                            Expanded(child: Row(children: [Icon(Icons.healing, size: 18, color: _painC(log.painLevel)), const SizedBox(width: 6), Text('Pain: ${log.painLevel}/10', style: TextStyle(color: _painC(log.painLevel), fontWeight: FontWeight.w500))])),
                            Expanded(child: Row(children: [Icon(Icons.water_drop, size: 18, color: _bleedC(log.bleedingLevel)), const SizedBox(width: 6), Text(log.bleedingLevel, style: TextStyle(color: _bleedC(log.bleedingLevel), fontWeight: FontWeight.w500))])),
                          ]),
                          if (log.mood.isNotEmpty) ...[const SizedBox(height: 8), Row(children: [const Icon(Icons.mood, size: 18, color: Color(0xFF7C4DFF)), const SizedBox(width: 6), Text('Mood: ${log.mood}')])],
                          if (log.notes.isNotEmpty) ...[const SizedBox(height: 8), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.notes, size: 18, color: Colors.teal), const SizedBox(width: 6), Expanded(child: Text(log.notes, style: TextStyle(color: Colors.grey.shade700)))])],
                        ])),
                      );
                    },
                  ),
                ),
    );
  }

  Color _painC(int l) { if (l <= 3) return Colors.green; if (l <= 6) return Colors.orange; return Colors.red; }
  Color _bleedC(String l) { switch (l) { case 'light': return Colors.green; case 'medium': return Colors.orange; case 'heavy': return Colors.red; default: return Colors.grey; } }
}
