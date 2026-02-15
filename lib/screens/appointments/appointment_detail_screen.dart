import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/phase2_models.dart';
import '../../../providers/appointment_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Appointment? _appointment;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  void _loadAppointment() {
    final provider = context.read<AppointmentProvider>();
    _appointment = provider.appointments.firstWhere(
      (a) => a.id == widget.appointmentId,
      orElse: () => Appointment(
        id: widget.appointmentId,
        doctorId: '',
        patientId: '',
        appointmentDate: DateTime.now(),
        status: 'pending',
        appointmentType: 'consultation',
      ),
    );
    setState(() {});
  }

  void _cancelAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performCancel();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _performCancel() async {
    if (_appointment == null) return;

    final provider = context.read<AppointmentProvider>();
    final success = await provider.cancelAppointment(_appointment!.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')),
      );
      _loadAppointment();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to cancel appointment')),
      );
    }
  }

  void _rescheduleAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: const Text('Reschedule feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointment Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final appointment = _appointment!;

    Color statusColor;
    switch (appointment.status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final isUpcoming = appointment.appointmentDate.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointment Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr. ${appointment.doctorId}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment.appointmentType.replaceAll('-', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  _buildDetailSection(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    content: dateFormat.format(appointment.appointmentDate),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    icon: Icons.access_time,
                    title: 'Time',
                    content: timeFormat.format(appointment.appointmentDate),
                  ),
                  const SizedBox(height: 20),

                  // Reason (if available)
                  if (appointment.reason != null) ...[
                    _buildDetailSection(
                      icon: Icons.description,
                      title: 'Reason for Visit',
                      content: appointment.reason!,
                      isMultiline: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Notes (if available)
                  if (appointment.notes != null) ...[
                    _buildDetailSection(
                      icon: Icons.note,
                      title: 'Doctor Notes',
                      content: appointment.notes!,
                      isMultiline: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Location (if available)
                  if (appointment.location != null) ...[
                    _buildDetailSection(
                      icon: Icons.location_on,
                      title: 'Location',
                      content: appointment.location!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Contact doctor (if confirmed and upcoming)
                  if (appointment.status == 'confirmed' && isUpcoming) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your appointment is confirmed. The doctor will be available at the scheduled time.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            if (isUpcoming && appointment.status != 'cancelled')
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : _rescheduleAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Reschedule Appointment',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: provider.isLoading ? null : _cancelAppointment,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Cancel Appointment',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
