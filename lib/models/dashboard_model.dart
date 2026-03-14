import 'package:flutter/material.dart';

class Booking {
  final int machine;
  final DateTime date;
  final bool completed;

  Booking({
    required this.machine,
    required this.date,
    this.completed = false,
  });
}

class DashboardModel extends ChangeNotifier {
  /// Tab controller
  TabController? tabBarController;

  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  /// Checkbox states for upcoming bookings
  final Map<Booking, bool> checkboxUpcomingMap = {};

  List<Booking> get checkedUpcomingItems =>
      checkboxUpcomingMap.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  /// Checkbox states for completed bookings
  final Map<Booking, bool> checkboxCompletedMap = {};

  List<Booking> get checkedCompletedItems =>
      checkboxCompletedMap.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // Add booking data
  List<Booking> upcomingBookings = [];
  List<Booking> completedBookings = [];

  // Cancel booking
  void cancelBooking(Booking booking) {
    upcomingBookings.remove(booking);
    notifyListeners();
  }

  // Mark as completed
  void completeBooking(Booking booking) {
    upcomingBookings.remove(booking);
    completedBookings.add(Booking(
      machine: booking.machine,
      date: booking.date,
      completed: true,
    ));
    notifyListeners();
  }

  void dispose() {
    tabBarController?.dispose();
    super.dispose();
  }
}