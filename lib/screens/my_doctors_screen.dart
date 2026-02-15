import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class MyDoctorsScreen extends StatefulWidget {
  const MyDoctorsScreen({super.key});

  @override
  State<MyDoctorsScreen> createState() => _MyDoctorsScreenState();
}

class _MyDoctorsScreenState extends State<MyDoctorsScreen> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await ApiService.getMyDoctors(token: auth.token!);
      setState(() {
        _doctors = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _togglePermission(int index, String key, bool value) async {
    final doc = _doctors[index];
    final currentPerms = Map<String, dynamic>.from(doc['permissions'] ?? {});
    currentPerms[key] = value;

    // Optimistic update
    setState(() {
      _doctors[index]['permissions'] = currentPerms;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await ApiService.updatePermissions(
        doctorId: doc['doctor_id'],
        permissions: Map<String, bool>.from(currentPerms), // Ensure correct type
        token: auth.token!,
      );
    } catch (e) {
      // Revert on failure
      setState(() {
        currentPerms[key] = !value;
        _doctors[index]['permissions'] = currentPerms;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Doctors & Privacy'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text("No doctors linked yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doc = _doctors[index];
                    final perms = doc['permissions'] ?? {};
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.medical_services)),
                            title: Text(doc['doctor_name']),
                            subtitle: Text(doc['specialization']),
                          ),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Share Data:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text("Health Logs & Symptoms"),
                            subtitle: const Text("Allow doctor to see your daily logs"),
                            value: perms['health_logs'] ?? true, // Default True as per implementation
                            onChanged: (v) => _togglePermission(index, 'health_logs', v),
                            activeColor: Colors.teal,
                          ),
                          SwitchListTile(
                            title: const Text("Medical Reports"),
                            subtitle: const Text("Allow doctor to see uploaded reports"),
                            value: perms['reports'] ?? true,
                            onChanged: (v) => _togglePermission(index, 'reports', v),
                            activeColor: Colors.teal,
                          ),
                          SwitchListTile(
                            title: const Text("Medications"),
                            subtitle: const Text("Allow doctor to see your prescriptions"),
                            value: perms['medications'] ?? true,
                            onChanged: (v) => _togglePermission(index, 'medications', v),
                            activeColor: Colors.teal,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
