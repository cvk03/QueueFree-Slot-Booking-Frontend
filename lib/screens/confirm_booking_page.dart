import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/Machine.dart';
import '../services/firebase_service.dart';

class ConfirmBookingPage extends StatefulWidget {
  final DateTime? slotDate;
  final String? machineId;
  final Machine? machine;

  const ConfirmBookingPage({
    Key? key,
    required this.slotDate,
    required this.machineId,
    this.machine,
  }) : super(key: key);

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  bool isLoading = false;

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('d MMM yyyy  HH:mm').format(dateTime);
  }

  Future<void> _confirmBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseService.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // TODO: Save booking to Firestore
      // Example structure:
      // await _firestore.collection('bookings').add({
      //   'machineId': widget.machineId,
      //   'slotDate': widget.slotDate,
      //   'studentName': user.displayName,
      //   'studentEmail': user.email,
      //   'userId': user.uid,
      //   'createdAt': DateTime.now(),
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back after successful booking
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // Pop back to machines list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ✅ Changed from EdgeInsets.fromSTEB to EdgeInsets.only
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  // ✅ Changed from EdgeInsets.fromSTEB
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 8,
                    right: 20,
                    bottom: 0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Top divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // ✅ Title
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            right: 16,
                          ),
                          child: Text(
                            'Confirm the slot?',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF14181B),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // ✅ Slot details
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Confirm the slot on ${formatDateTime(widget.slotDate)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF57636C),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // ✅ Machine info
                        if (widget.machineId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Machine: ${widget.machineId}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF57636C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        // ✅ Booking summary card
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0E3E7),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking Summary',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF14181B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(
                                    'Machine ID',
                                    widget.machineId ?? 'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow(
                                    'Slot Date & Time',
                                    formatDateTime(widget.slotDate),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow(
                                    'User',
                                    FirebaseService.getUserDisplayName(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              // ✅ Action buttons
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Cancel button
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F4F8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF57636C),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Confirm button
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B39EF),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        )
                            : Text(
                          'Confirm',
                          style: GoogleFonts.lexendDeca(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF57636C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF14181B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}