import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import 'machines_page.dart';
import 'profile_page.dart';

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  String userName = "User";

  List<Booking> upcomingBookings = [
    Booking(machine: 1, date: DateTime.now().add(const Duration(hours: 2))),
    Booking(machine: 3, date: DateTime.now().add(const Duration(days: 1))),
  ];

  List<Booking> completedBookings = [
    Booking(
        machine: 2,
        date: DateTime.now().subtract(const Duration(days: 1)),
        completed: true),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "User";
      });
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
              CheckboxListTile(
                value: completed,
                onChanged: (_) {},
                title: Text(
                  "Machine no. ${booking.machine}",
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
                  completed
                      ? Container(
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
                      : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          upcomingBookings.remove(booking);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking cancelled'),
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
    return upcomingBookings.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming bookings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ListMachinesPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B39EF),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingBookings.length,
      itemBuilder: (context, index) {
        return bookingCard(upcomingBookings[index]);
      },
    );
  }

  Widget completedTab() {
    return completedBookings.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No completed bookings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedBookings.length,
      itemBuilder: (context, index) {
        return bookingCard(completedBookings[index], completed: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      // ✅ COMPLETE FIX - Removed flexibleSpace, use simpler AppBar
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ Go to Profile Button - Made interactive
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
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
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          // ✅ Book New Slot Button - Made interactive
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ListMachinesPage(),
                  ),
                );
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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
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