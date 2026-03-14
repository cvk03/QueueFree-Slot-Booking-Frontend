import 'package:flutter/material.dart';

class Booking {
  final DateTime date;
  // Add other fields as needed

  Booking({required this.date});
}

class HomePageModel extends ChangeNotifier {
  /// Local state fields for this page.
  List<DateTime> reservedDates = [];

  void addToReservedDates(DateTime item) {
    reservedDates.add(item);
    notifyListeners();
  }

  void removeFromReservedDates(DateTime item) {
    reservedDates.remove(item);
    notifyListeners();
  }

  void removeAtIndexFromReservedDates(int index) {
    reservedDates.removeAt(index);
    notifyListeners();
  }

  void insertAtIndexInReservedDates(int index, DateTime item) {
    reservedDates.insert(index, item);
    notifyListeners();
  }

  void updateReservedDatesAtIndex(int index, Function(DateTime) updateFn) {
    reservedDates[index] = updateFn(reservedDates[index]);
    notifyListeners();
  }

  /// State fields for stateful widgets in this page.
  DateTimeRange? calendarSelectedDay;
  List<Booking>? calendarPreviousSnapshot;

  /// State fields for ListView widget (pagination).
  List<Booking> bookingsList = [];
  bool isLoadingMore = false;
  bool hasMoreBookings = true;

  HomePageModel() {
    initState();
  }

  void initState() {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Load bookings from your backend
  Future<void> loadBookings({
    required String machineId,
    int pageSize = 25,
  }) async {
    if (isLoadingMore || !hasMoreBookings) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      // Replace this with your actual backend call
      await Future.delayed(const Duration(milliseconds: 500));

      // Example: fetch bookings from your API or Firestore
      final newBookings = await _fetchBookingsFromBackend(machineId, pageSize);

      bookingsList.addAll(newBookings);

      if (newBookings.length < pageSize) {
        hasMoreBookings = false;
      }
    } catch (e) {
      print('Error loading bookings: $e');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh bookings list
  Future<void> refreshBookings({required String machineId}) async {
    bookingsList.clear();
    hasMoreBookings = true;
    await loadBookings(machineId: machineId);
  }

  /// Mock backend call - replace with your actual implementation
  Future<List<Booking>> _fetchBookingsFromBackend(
      String machineId,
      int pageSize,
      ) async {
    // TODO: Replace with actual Firestore or API call
    await Future.delayed(const Duration(milliseconds: 800));
    final now = DateTime.now();
    return [
      Booking(date: DateTime(now.year, now.month, now.day, 10, 0)),
      Booking(date: DateTime(now.year, now.month, now.day, 11, 0)),
      Booking(date: DateTime(now.year, now.month, now.day, 13, 0)),
    ];
  }

  /// Update calendar selected day
  void updateCalendarSelectedDay(DateTimeRange newDate) {
    calendarSelectedDay = newDate;
    notifyListeners();
  }

  /// Get booked hours for a specific date
  Set<int> getBookedHoursForDate(DateTime date) {
    return reservedDates
        .where((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day)
        .map((d) => d.hour)
        .toSet();
  }

  @override
  void dispose() {
    super.dispose();
  }
}