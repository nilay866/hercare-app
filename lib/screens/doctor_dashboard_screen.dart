import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/app_logger.dart';
import '../services/log_exporter.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'patient_detail_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _patients = [];
  List<dynamic> _emergencies = [];
  bool _isLoading = true;

  // Mock Medicine Data
  final List<Map<String, String>> _medicines = [
    {"name": "Paracetamol", "type": "Tablet", "stock": "500"},
    {"name": "Ibuprofen", "type": "Tablet", "stock": "300"},
    {"name": "Amoxicillin", "type": "Capsule", "stock": "200"},
    {"name": "Cetirizine", "type": "Tablet", "stock": "450"},
    {"name": "Metformin", "type": "Tablet", "stock": "150"},
    {"name": "Aspirin", "type": "Tablet", "stock": "400"},
    {"name": "Omeprazole", "type": "Capsule", "stock": "250"},
    {"name": "Simvastatin", "type": "Tablet", "stock": "180"},
    {"name": "Losartan", "type": "Tablet", "stock": "220"},
    {"name": "Albuterol", "type": "Inhaler", "stock": "50"},
    {"name": "Gabapentin", "type": "Capsule", "stock": "120"},
    {"name": "Hydrochlorothiazide", "type": "Tablet", "stock": "300"},
    {"name": "Sertraline", "type": "Tablet", "stock": "140"},
    {"name": "Montelukast", "type": "Tablet", "stock": "210"},
    {"name": "Escitalopram", "type": "Tablet", "stock": "160"},
    {"name": "Prednisone", "type": "Tablet", "stock": "600"},
    {"name": "Furosemide", "type": "Tablet", "stock": "190"},
    {"name": "Pantoprazole", "type": "Tablet", "stock": "280"},
    {"name": "Trazodone", "type": "Tablet", "stock": "90"},
    {"name": "Fluticasone", "type": "Nasal Spray", "stock": "75"},
  ];
  List<Map<String, String>> _filteredMedicines = [];
  String _medSearch = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB visibility
    });
    _filteredMedicines = _medicines;
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final token = await _resolveAuthToken(auth);
      final patients = await ApiService.getMyPatients(
        doctorId: auth.userId!,
        token: token,
      );
      // Fetch Pending Emergencies (Global feed)
      final emergencies = await ApiService.getPendingEmergencies(token: token);

      setState(() {
        _patients = patients;
        _emergencies = emergencies;
        _isLoading = false;
      });
    } catch (e) {
      await AppLogger.log(
        'DoctorDashboard._loadData',
        'Failed to load doctor dashboard data',
        error: e,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _showAddPatientDialog() {
    // ... (Keep existing implementation or move to separate widget)
    // For brevity, using simplified version here or reusing existing logic
    // I'll reuse the logic but need to copy it back or reference.
    // Given the length, I'll put a placeholder call to a method I'll ensure remains efficient.
    _registerPatientDialog();
  }

  void _registerPatientDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Create Patient Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);
                      try {
                        final auth = Provider.of<AuthProvider>(
                          this.context,
                          listen: false,
                        );
                        final token = await _resolveAuthToken(auth);
                        final result = await ApiService.registerPatientByDoctor(
                          name: nameController.text,
                          age: int.tryParse(ageController.text) ?? 25,
                          token: token,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context); // Close Register Dialog
                        _loadData(); // Refresh list

                        // Show Success & Share Dialog
                        if (!mounted) return;
                        _showSuccessDialog(result, nameController.text);
                      } catch (e) {
                        await AppLogger.log(
                          'DoctorDashboard._registerPatientDialog',
                          'Failed to create patient record',
                          error: e,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                        if (mounted) {
                          setState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result, String name) {
    final shareCode = (result['share_code'] ?? '').toString();
    final inviteText =
        "Hello $name,\n\n"
        "Your medical record is ready in HerCare.\n"
        "Open app: http://hercare-app-frontend-cszaiz.s3-website.ap-south-1.amazonaws.com\n"
        "1. Sign up as Patient\n"
        "2. Open 'Link Records'\n"
        "3. Enter this code: $shareCode";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success & Invite 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            Text("Patient $name Registered!"),
            const SizedBox(height: 20),
            const Text(
              "Share these details with the patient:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(inviteText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text("Share Invite"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(text: inviteText, subject: "HerCare App Invite"),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> _resolveAuthToken(AuthProvider auth) async {
    final providerToken = auth.token?.trim();
    if (providerToken != null && providerToken.isNotEmpty) {
      return providerToken;
    }

    final storedToken = await TokenStorage.read('token');
    if (storedToken != null && storedToken.trim().isNotEmpty) {
      await AppLogger.log(
        'DoctorDashboard._resolveAuthToken',
        'Recovered token from storage',
      );
      return storedToken.trim();
    }

    await AppLogger.log(
      'DoctorDashboard._resolveAuthToken',
      'Authentication token missing',
    );
    throw Exception("Authentication token missing. Please login again.");
  }

  Future<void> _showDebugLogBox() async {
    var logs = await AppLogger.readAll();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Debug Logs'),
          content: Container(
            width: 760,
            height: 320,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: logs.isEmpty
                ? const Center(child: Text('No logs captured yet'))
                : SingleChildScrollView(
                    child: SelectableText(
                      logs.reversed.join('\n\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AppLogger.clear();
                logs = [];
                if (context.mounted) {
                  setDialogState(() {});
                }
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () async {
                final text = logs.reversed.join('\n\n');
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs copied to clipboard')),
                  );
                }
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () async {
                final text = logs.reversed.join('\n\n');
                final fileName =
                    'hercare_debug_${DateTime.now().millisecondsSinceEpoch}.txt';
                final exported = await exportLogTextFile(
                  fileName: fileName,
                  text: text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        exported
                            ? 'Downloaded $fileName'
                            : 'File download not supported here. Use Copy instead.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Export .txt'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${auth.userName ?? "Doctor"}'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
            Tab(text: "Emergency Room", icon: Icon(Icons.emergency)),
            Tab(text: "My Patients", icon: Icon(Icons.people)),
            Tab(text: "Inventory", icon: Icon(Icons.medication)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugLogBox,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildEmergencyTab(),
                _buildPatientsTab(),
                _buildInventoryTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: _showAddPatientDialog,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  // ─── TABS ───

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Today's Appts",
                  value: "3",
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ), // Mocked for now
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: "Emergencies",
                  value: "${_emergencies.length}",
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Total Patients",
                  value: "${_patients.length}",
                  icon: Icons.group,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: "Earnings",
                  value: "\$1.2k",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Upcoming Appointments (Today)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Mock Appointments List
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("JS"),
              ),
              title: const Text("Jane Smith - 10:00 AM"),
              subtitle: const Text("Routine Checkup"),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Join"),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text("ED"),
              ),
              title: const Text("Emma Davis - 02:30 PM"),
              subtitle: const Text("Ultrasound Review"),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Join"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    if (_emergencies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text("No pending emergencies locally!"),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emergencies.length,
      itemBuilder: (context, index) {
        final e = _emergencies[index];
        return Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.campaign, color: Colors.red),
            title: Text(e['patient_name'] ?? 'Unknown Patient'),
            subtitle: Text(e['message']),
            trailing: ElevatedButton(
              onPressed: () => _acceptEmergency(e['id']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Respond"),
            ),
          ),
        );
      },
    );
  }

  Future<void> _acceptEmergency(String id) async {
    // Logic to accept
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feature: Accept Emergency (Coming Soon)")),
    );
  }

  Widget _buildPatientsTab() {
    if (_patients.isEmpty) {
      return const Center(
        child: Text(
          "No linked patients. Use Dashboard to manage Appointments.",
        ),
      );
    }
    return ListView.builder(
      itemCount: _patients.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final p = _patients[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(p['name'][0])),
            title: Text(p['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Age: ${p['age'] ?? 'N/A'} • ${p['pregnancy_type'] ?? 'General'}",
                ),
                if (p['share_code'] != null)
                  Text(
                    "Link Code: ${p['share_code']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDetailScreen(
                    patientId: p['patient_id'],
                    patientName: p['name'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: "Search Medicines",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                _medSearch = val.toLowerCase();
                _filteredMedicines = _medicines
                    .where((m) => m['name']!.toLowerCase().contains(_medSearch))
                    .toList();
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMedicines.length,
            itemBuilder: (context, index) {
              final m = _filteredMedicines[index];
              return ListTile(
                leading: const Icon(
                  Icons.medication_liquid,
                  color: Colors.teal,
                ),
                title: Text(m['name']!),
                subtitle: Text(m['type']!),
                trailing: Text(
                  "Stock: ${m['stock']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
