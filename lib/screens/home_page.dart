import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Machine.dart';
import '../services/api-service.dart'; // ✅ Added import
import 'confirm_booking_page.dart';

class HomePage extends StatefulWidget {
  final Machine? eachMachineBooking;

  const HomePage({
    Key? key,
    this.eachMachineBooking,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime selectedDate;
  DateTime? selectedSlot; // ✅ Changed from int selectedHour to DateTime
  late Future<List<Map<String, dynamic>>> _slotsFuture; // ✅ Added Future

  @override
  void initState() {
    super.initState();
    // Normalize initial date to midnight
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _fetchSlots(); // ✅ Initial fetch
  }

  // ✅ Fetch slots based on selected date and machine
  void _fetchSlots() {
    setState(() {
      // ✅ Use .id instead of .machineId for the API call
      // ✅ Ensure the date is at midnight (00:00:00)
      final normalizedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      
      _slotsFuture = ApiService.getAvailableSlots(
        widget.eachMachineBooking?.id ?? "",
        normalizedDate,
      );
    });
  }

  String formatDate(DateTime date) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  void _showConfirmBookingDialog(DateTime slotTime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmBookingPage(
        slotDate: slotTime,
        machineId: widget.eachMachineBooking?.machineId,
        machine: widget.eachMachineBooking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final machineId = widget.eachMachineBooking?.machineId ?? "Unknown";
    final machineLocation =
        widget.eachMachineBooking?.hostel ?? "Unknown Location";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Available slots',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Machine Information Card
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Machine: $machineId',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF14181B),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location: $machineLocation',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF57636C),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ✅ Date Picker
                    Text(
                      'Select Date',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF14181B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            // Normalize to midnight
                            selectedDate = DateTime(picked.year, picked.month, picked.day);
                          });
                          _fetchSlots(); // ✅ Refresh slots on date change
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE0E3E7),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(selectedDate),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ✅ Available Time Slots with FutureBuilder
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Time Slots',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF14181B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _slotsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: _fetchSlots,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final slots = snapshot.data ?? [];
                        if (slots.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No slots available for this date.'),
                            ),
                          );
                        }

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slotData = slots[index];
                            DateTime? startTime;

                            // ✅ Handle timestamp format from API: {"seconds": 123, "nanos": 0}
                            if (slotData.containsKey('seconds')) {
                              startTime = DateTime.fromMillisecondsSinceEpoch(
                                  (slotData['seconds'] as int) * 1000);
                            } else {
                              final startTimeStr = slotData['startTime'] ?? slotData['time'] ?? "";
                              if (startTimeStr.isNotEmpty) {
                                startTime = DateTime.tryParse(startTimeStr);
                              }
                            }

                            if (startTime == null) return const SizedBox();
                            
                            // Since it's from available-slots, default to true
                            final isAvailable = slotData['isAvailable'] ?? true;

                            return GestureDetector(
                              onTap: !isAvailable
                                  ? null
                                  : () => _showConfirmBookingDialog(startTime!),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.indigo
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isAvailable
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}