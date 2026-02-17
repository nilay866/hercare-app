import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/phase2_models.dart';
import '../../providers/appointment_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? doctorId;

  const BookAppointmentScreen({
    Key? key,
    this.doctorId,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late TextEditingController _reasonController;
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDoctor;
  String _appointmentType = 'consultation';

  final List<String> _appointmentTypes = [
    'consultation',
    'follow-up',
    'emergency',
    'routine-checkup',
  ];

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _selectedDoctor = widget.doctorId;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(Duration(days: 90));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  void _bookAppointment(BuildContext context) async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Combine date and time
    final timeList = _selectedTime!.split(':');
    final isPM = _selectedTime!.contains('PM');
    var hour = int.parse(timeList[0]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final appointmentDateTime = _selectedDate!.copyWith(hour: hour);

    final appointmentProvider = context.read<AppointmentProvider>();
    
    final result = await appointmentProvider.bookAppointment(
      doctorId: _selectedDoctor!,
      appointmentDate: appointmentDateTime,
      appointmentType: _appointmentType,
      notes: _reasonController.text.isNotEmpty ? _reasonController.text : null,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appointmentProvider.error ?? 'Failed to book appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Selection
            const Text(
              'Select Doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _selectedDoctor,
                  hint: const Text('Choose a doctor'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'doc1', child: Text('Dr. Smith')),
                    DropdownMenuItem(value: 'doc2', child: Text('Dr. Johnson')),
                    DropdownMenuItem(value: 'doc3', child: Text('Dr. Williams')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDoctor = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Appointment Type
            const Text(
              'Appointment Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _appointmentType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _appointmentTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.replaceAll('-', ' ').toUpperCase(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _appointmentType = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select a date'
                          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slot Selection
            if (_selectedDate != null) ...[
              const Text(
                'Select Time Slot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  final isSelected = _selectedTime == slot;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedTime = slot);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.blue[50] : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Reason/Notes
            const Text(
              'Reason for Visit (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or reason for visit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),

            // Book Button
            Consumer<AppointmentProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () => _bookAppointment(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
