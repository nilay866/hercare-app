import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientId;
  final bool isDoctor;

  const ConsultationScreen({super.key, required this.patientId, required this.isDoctor});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<dynamic> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await ApiService.getConsultations(patientId: widget.patientId, token: auth.token!);
      setState(() {
        _consultations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultations'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consultations.isEmpty
              ? const Center(child: Text("No consultation records found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) {
                    final c = _consultations[index];
                    return Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.medical_services, color: Colors.teal),
                        title: Text("Date: ${c['visit_date']} • Dr. ${c['doctor_name']}"),
                        subtitle: Text(c['diagnosis'] ?? 'No diagnosis'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Symptoms: ${c['symptoms'] ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text("Treatment: ${c['treatment_plan'] ?? '-'}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text("Prescription: ${c['prescription_text'] ?? ''}", style: const TextStyle(fontStyle: FontStyle.italic)),
                                if (c['prescriptions'] != null && (c['prescriptions'] as List).isNotEmpty)
                                  ...((c['prescriptions'] as List).map((p) => Text("💊 ${p['name']} - ${p['dosage']} (${p['timing']})"))),
                                
                                const SizedBox(height: 8),
                                if (c['billing_items'] != null && (c['billing_items'] as List).isNotEmpty) ...[
                                  const Divider(),
                                  const Text("Invoice:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...((c['billing_items'] as List).map((b) => Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Text(b['service']), Text("\$${b['cost']}")],
                                  ))),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("\$${c['total_amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                    ],
                                  ),
                                  if (c['payment_status'] != 'paid' && !widget.isDoctor)
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10),
                                       child: ElevatedButton.icon(
                                         icon: const Icon(Icons.payment),
                                         label: const Text("Pay Now (Secure)"),
                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                                         onPressed: () async {
                                           final auth = Provider.of<AuthProvider>(context, listen: false);
                                           try {
                                             await ApiService.payConsultation(consultationId: c['id'], token: auth.token!);
                                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
                                             _loadData(); // Refresh to show paid
                                           } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Error: $e')));
                                           }
                                         },
                                       ),
                                     )
                                  else if (c['payment_status'] == 'paid')
                                    const Padding(padding: EdgeInsets.only(top: 8), child: Text("✅ PAID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                ],
                              ],
                            ),
                          ),
                          ButtonBar(
                            children: [
                                TextButton.icon(
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text("Share Rx"),
                                    onPressed: () {
                                        final rxText = "Prescription for Patient (Date: ${c['visit_date']})\n"
                                        "Dr. ${c['doctor_name']}\n\n"
                                        "Diagnosis: ${c['diagnosis']}\n"
                                        "--- Medicines ---\n"
                                        "${(c['prescriptions'] as List?)?.map((p) => "${p['name']} - ${p['dosage']} (${p['timing']})").join('\n') ?? 'No medicines'}\n\n"
                                        "Get Well Soon!";
                                        Share.share(rxText, subject: "Prescription - ${c['visit_date']}");
                                    },
                                )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: widget.isDoctor
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddConsultationScreen(patientId: widget.patientId)),
                );
                if (result == true) _loadData();
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddConsultationScreen extends StatefulWidget {
  final String patientId;
  const AddConsultationScreen({super.key, required this.patientId});
  @override
  State<AddConsultationScreen> createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final _symptomsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  // Structured Data
  final List<Map<String, dynamic>> _prescriptions = [];
  final List<Map<String, dynamic>> _billingItems = [];
  
  // Prescription Controllers
  final _rxNameCtrl = TextEditingController();
  final _rxDosageCtrl = TextEditingController();
  String _rxTiming = "Morning";
  final List<String> _timings = ["Morning", "Afternoon", "Night", "Twice Daily", "Thrice Daily"];
  
  // Billing Controllers
  final _billServiceCtrl = TextEditingController();
  final _billCostCtrl = TextEditingController();

  bool _isLoading = false;

  void _addRx() {
    if (_rxNameCtrl.text.isEmpty) return;
    setState(() {
      _prescriptions.add({
        "name": _rxNameCtrl.text,
        "dosage": _rxDosageCtrl.text,
        "timing": _rxTiming,
        "duration": "5 days" // Default for now
      });
      _rxNameCtrl.clear(); _rxDosageCtrl.clear();
    });
  }

  void _addBill() {
    if (_billServiceCtrl.text.isEmpty || _billCostCtrl.text.isEmpty) return;
    setState(() {
      _billingItems.add({
        "service": _billServiceCtrl.text,
        "cost": double.tryParse(_billCostCtrl.text) ?? 0.0
      });
      _billServiceCtrl.clear(); _billCostCtrl.clear();
    });
  }

  double get _totalAmount => _billingItems.fold(0.0, (sum, item) => sum + item['cost']);

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await ApiService.createConsultation(
        token: auth.token!,
        body: {
          'doctor_id': auth.userId,
          'patient_id': widget.patientId,
          'visit_date': DateTime.now().toIso8601String().substring(0, 10),
          'symptoms': _symptomsCtrl.text,
          'diagnosis': _diagnosisCtrl.text,
          'treatment_plan': _treatmentCtrl.text,
          'notes': _notesCtrl.text,
          'prescriptions': _prescriptions,
          'billing_items': _billingItems,
          'total_amount': _totalAmount
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Consultation'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _symptomsCtrl, decoration: const InputDecoration(labelText: 'Symptoms 🤒')),
            const SizedBox(height: 10),
            TextField(controller: _diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnosis 🩺')),
            const SizedBox(height: 10),
            TextField(controller: _treatmentCtrl, decoration: const InputDecoration(labelText: 'Treatment / Procedure 💉'), maxLines: 2),
            const SizedBox(height: 20),
            
            // Prescriptions
            const Text("Prescriptions 💊", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._prescriptions.map((p) => ListTile(
                title: Text(p['name']), subtitle: Text("${p['dosage']} - ${p['timing']}"),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _prescriptions.remove(p))),
            )),
            Row(children: [
                Expanded(child: TextField(controller: _rxNameCtrl, decoration: const InputDecoration(labelText: "Medicine Name"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _rxDosageCtrl, decoration: const InputDecoration(labelText: "Dosage"))),
            ]),
            Row(children: [
                Expanded(child: DropdownButton<String>(
                    value: _rxTiming, isExpanded: true,
                    items: _timings.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _rxTiming = v!),
                )),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.teal), onPressed: _addRx)
            ]),
            const Divider(),

            // Billing
            const Text("Billing / Invoice 🧾", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._billingItems.map((b) => ListTile(
                title: Text(b['service']), trailing: Text("\$${b['cost']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
            Row(children: [
                Expanded(child: TextField(controller: _billServiceCtrl, decoration: const InputDecoration(labelText: "Service (e.g. Sonography)"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _billCostCtrl, decoration: const InputDecoration(labelText: "Cost"), keyboardType: TextInputType.number)),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addBill)
            ]),
            const SizedBox(height: 10),
            Text("Total: \$${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.all(16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Record & Generate Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
