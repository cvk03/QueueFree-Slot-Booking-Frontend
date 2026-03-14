import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../services/firebase_service.dart';
import '../services/api-service.dart';
import 'machines_page.dart';
import 'profile_page.dart';

class Booking {
  final String id;
  final String machineReference;
  final String machineId; // Human-readable ID (e.g., "03")
  final DateTime date;
  final bool completed;

  Booking({
    required this.id,
    required this.machineReference,
    required this.machineId,
    required this.date,
    this.completed = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json, {bool completed = false}) {
    return Booking(
      id: json['bookingId'] ?? '',
      machineReference: json['machine_reference'] ?? '',
      machineId: json['machine'] != null && json['machine'].toString().isNotEmpty 
          ? json['machine'].toString() 
          : 'Unknown',
      // ✅ Use .toLocal() to show the correct time in your timezone
      date: json['date'] != null 
          ? DateTime.parse(json['date']).toLocal() 
          : DateTime.now(),
      completed: completed,
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  String userName = "User";
  List<Booking> upcomingBookings = [];
  List<Booking> completedBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadUserName();
    _fetchBookings();
  }

  void _loadUserName() {
    final user = FirebaseService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "User";
      });
    }
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getUpcomingBookings(),
        ApiService.getCompletedBookings(),
      ]);

      if (mounted) {
        setState(() {
          upcomingBookings = (results[0] as List)
              .map((json) => Booking.fromJson(json, completed: false))
              .toList();
          completedBookings = (results[1] as List)
              .map((json) => Booking.fromJson(json, completed: true))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return "${date.day} ${_month(date.month)} ${date.year}  ${_time(date)}";
  }

  String _month(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }

  String _time(DateTime d) {
    int hour = d.hour > 12 ? d.hour - 12 : d.hour;
    if (hour == 0) hour = 12;
    String ampm = d.hour >= 12 ? "PM" : "AM";
    return "$hour:${d.minute.toString().padLeft(2, '0')} $ampm";
  }

  Widget bookingCard(Booking booking, {bool completed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFF1F4F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: completed
              ? Border.all(color: const Color(0xFFE0E3E7), width: 2)
              : null,
          boxShadow: completed
              ? []
              : [
            const BoxShadow(
              blurRadius: 3,
              color: Color(0x25090F13),
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Restored CheckboxListTile layout
              CheckboxListTile(
                value: completed,
                onChanged: (_) {},
                title: Text(
                  "Machine no. ${booking.machineId}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: const Color(0xFF4B39EF),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatDate(booking.date),
                      style: const TextStyle(
                        color: Color(0xFF4B39EF),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (completed)
                    Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Completed",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Implement cancel booking via API
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cancellation not implemented yet'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 120,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Cancel booking",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget upcomingTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _fetchBookings, child: const Text('Retry'))
          ],
        ),
      );
    }

    return upcomingBookings.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No upcoming bookings',
              style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ListMachinesPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    )
        : RefreshIndicator(
            onRefresh: _fetchBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcomingBookings.length,
              itemBuilder: (context, index) => bookingCard(upcomingBookings[index]),
            ),
          );
  }

  Widget completedTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) return const Center(child: Text('Error loading bookings'));

    return completedBookings.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No completed bookings',
              style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    )
        : RefreshIndicator(
            onRefresh: _fetchBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedBookings.length,
              itemBuilder: (context, index) => bookingCard(completedBookings[index], completed: true),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: const Color(0xFF4B39EF),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Go to Profile",
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ListMachinesPage()));
                _fetchBookings(); // Refresh list after coming back from booking
              },
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Book new slot now",
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
          LinearPercentIndicator(
            percent: 0.5,
            lineHeight: 12,
            animation: true,
            progressColor: const Color(0xFF4B39EF),
            backgroundColor: const Color(0xFFF1F4F8),
          ),
          const SizedBox(height: 12),
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              labelColor: const Color(0xFF4B39EF),
              unselectedLabelColor: const Color(0xFF57636C),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                upcomingTab(),
                completedTab(),
              ],
            ),
          )
        ],
      ),
    );
  }
}