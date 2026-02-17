import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'report_upload_screen.dart';
import 'medical_history_screen.dart';
import 'consultation_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data
  List<dynamic> _logs = [];
  List<dynamic> _reports = [];
  Map<String, dynamic> _history = {};
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // Parallel fetching? Or sequential to catch specific permission errors?
      // Sequential is safer for now to handle partial failures.
      try {
        _logs = await ApiService.getHealthLogs(
          userId: widget.patientId,
          token: auth.token!,
        );
      } catch (e) {
        if (e.toString().contains("403"))
          _logs = []; // Permission denied or empty
      }

      try {
        _reports = await ApiService.getReports(
          patientId: widget.patientId,
          token: auth.token!,
          includeData: true,
        );
      } catch (e) {
        if (e.toString().contains("403")) _reports = [];
      }

      try {
        _history = await ApiService.getMedicalHistory(
          patientId: widget.patientId,
          token: auth.token!,
        );
      } catch (e) {
        _history = {}; // Empty or permission issue
      }

      // Pain chart data needs logs.

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final summary =
                  "Category: Medical Report\n"
                  "Patient: ${widget.patientName}\n\n"
                  "--- Medical History ---\n"
                  "${_summarizeHistory()}\n\n"
                  "--- Recent Logs ---\n"
                  "${_logs.take(5).map((l) => "${l['log_date']}: ${l['mood']} (Pain: ${l['pain_level']})").join('\n')}\n";
              Share.share(
                summary,
                subject: "Medical Report - ${widget.patientName}",
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Health Logs"),
            Tab(text: "Reports"),
            Tab(text: "Consultations"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
          ? Center(child: Text("Error: $_errorMsg"))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildLogsTab(),
                _buildReportsTab(),
                ConsultationScreen(
                  patientId: widget.patientId,
                  isDoctor: true,
                ), // Embed screen
              ],
            ),
    );
  }

  // ─── TABS ───

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            "Medical History",
            Icons.history,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalHistoryScreen(
                    patientId: widget.patientId,
                    isDoctor: true,
                  ),
                ),
              );
            },
            content: _history.isEmpty
                ? "No history recorded."
                : _summarizeHistory(),
          ),

          const SizedBox(height: 20),
          const Text(
            "Pain Trends",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 200, child: _buildPainChart()),
        ],
      ),
    );
  }

  String _summarizeHistory() {
    List<String> parts = [];
    if (_history['allergies']?.isNotEmpty == true)
      parts.add("Allergies: ${_history['allergies']}");
    if (_history['chronic_conditions']?.isNotEmpty == true)
      parts.add("Chronic: ${_history['chronic_conditions']}");
    return parts.isEmpty ? "Tap to view details" : parts.join("\n");
  }

  Widget _buildCard(
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? content,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        subtitle: Text(content ?? "Tap to view"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogsTab() {
    if (_logs.isEmpty)
      return const Center(child: Text("No logs or permission denied."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Card(
          child: ListTile(
            title: Text(
              "${log['log_type']} - Pain: ${log['pain_level'] ?? 'N/A'}",
            ), // Use proper casing
            subtitle: Text(log['log_date'] ?? ''),
            trailing: Text(log['mood'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Stack(
      children: [
        _reports.isEmpty
            ? const Center(child: Text("No reports or permission denied."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final r = _reports[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.blueGrey,
                      ),
                      title: Text(r['title']),
                      subtitle: Text(
                        "${r['report_type']} • ${r['created_at'].substring(0, 10)}",
                      ),
                      onTap: () => _previewReport(r),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Open',
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.teal,
                            ),
                            onPressed: () => _previewReport(r),
                          ),
                          IconButton(
                            tooltip: 'Share',
                            icon: const Icon(Icons.share, color: Colors.teal),
                            onPressed: () => _shareReport(r),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "uploadReport",
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReportUploadScreen(patientId: widget.patientId),
                ),
              );
              if (res == true) _loadAllData();
            },
            child: const Icon(Icons.upload_file),
          ),
        ),
      ],
    );
  }

  Uint8List? _decodeReportBytes(Map<String, dynamic> report) {
    final rawData = (report['file_data'] ?? report['data'])?.toString();
    if (rawData == null || rawData.trim().isEmpty) return null;

    final normalized = rawData.trim().startsWith('data:')
        ? rawData.split(',').last
        : rawData;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  bool _isImageFile(String? fileName) {
    if (fileName == null) return false;
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  String _resolveMimeType(String? fileName) {
    final lower = (fileName ?? '').toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

  Future<void> _previewReport(Map<String, dynamic> report) async {
    final bytes = _decodeReportBytes(report);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report file data is missing. Re-upload this report.'),
        ),
      );
      return;
    }

    final fileName = report['file_name']?.toString();
    if (!_isImageFile(fileName)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preview currently supports JPG/PNG. Use Share for other files.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  report['title']?.toString() ?? 'Report Preview',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: InteractiveViewer(
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareReport(Map<String, dynamic> report) async {
    final bytes = _decodeReportBytes(report);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report file data is missing. Re-upload this report.'),
        ),
      );
      return;
    }

    final fileName = report['file_name']?.toString().isNotEmpty == true
        ? report['file_name'].toString()
        : '${report['title'] ?? 'report'}.jpg';
    try {
      final xFile = XFile.fromData(
        bytes,
        name: fileName,
        mimeType: _resolveMimeType(fileName),
      );
      await Share.shareXFiles([
        xFile,
      ], text: "Report: ${report['title'] ?? 'Medical Report'}");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sharing report: $e")));
    }
  }

  Widget _buildPainChart() {
    if (_logs.isEmpty) return const Center(child: Text("No data for chart"));
    // Simple chart implementation (simplified for brevity)
    List<FlSpot> spots = [];
    for (int i = 0; i < _logs.length && i < 7; i++) {
      // Reverse order usually? API returns desc.
      // Let's take last 7 days.
      final log = _logs[i];
      if (log['pain_level'] != null) {
        spots.add(FlSpot(i.toDouble(), (log['pain_level'] as int).toDouble()));
      }
    }
    if (spots.isEmpty) return const Center(child: Text("No pain data"));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(spots: spots, isCurved: true, color: Colors.pink),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
