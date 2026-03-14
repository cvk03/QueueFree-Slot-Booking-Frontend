import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Machine.dart';
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
  late int selectedHour;
  List<int> bookedHours = [10, 11, 14];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedHour = 8;
  }

  String formatDate(DateTime date) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  void _showConfirmBookingDialog() {
    // Combine date and selected hour
    final slotDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmBookingPage(
        slotDate: slotDateTime,
        machineId: widget.eachMachineBooking?.machineId,
        machine: widget.eachMachineBooking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final machineId = widget.eachMachineBooking?.machineId ?? "Unknown";
    final machineLocation =
        widget.eachMachineBooking?.location ?? "Unknown Location";

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
                            selectedDate = picked;
                          });
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
              // ✅ Available Time Slots
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
                    // ✅ Time Slots Grid
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final hour = 8 + index;
                        final isBooked = bookedHours.contains(hour);

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                            setState(() {
                              selectedHour = hour;
                            });
                            // Show confirmation dialog
                            _showConfirmBookingDialog();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey[300]
                                  : Colors.indigo,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isBooked
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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