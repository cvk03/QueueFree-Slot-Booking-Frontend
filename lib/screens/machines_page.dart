import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/Machine.dart';
import '../services/api-service.dart';
import 'home_page.dart';

class ListMachinesPage extends StatefulWidget {
  const ListMachinesPage({Key? key}) : super(key: key);

  @override
  State<ListMachinesPage> createState() => _ListMachinesPageState();
}

class _ListMachinesPageState extends State<ListMachinesPage> {
  late Future<List<Machine>> _machinesFuture;

  @override
  void initState() {
    super.initState();
    _machinesFuture = ApiService.getMachines();
  }

  void _retryFetch() {
    setState(() {
      _machinesFuture = ApiService.getMachines();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
            'Available machines',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<List<Machine>>(
                          future: _machinesFuture,
                          builder: (context, snapshot) {
                            // Loading state
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading machines...',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              );
                            }

                            // Error state
                            if (snapshot.hasError) {
                              final error = snapshot.error.toString();
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading machines',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        error,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: _retryFetch,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Empty state
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_laundry_service,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No machines available',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Success state
                            final machines = snapshot.data!;
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: machines.length,
                              itemBuilder: (context, index) {
                                final machine = machines[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 8,
                                    right: 16,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: const Color(0x320E151B),
                                          offset: const Offset(0, 1),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 8,
                                        right: 8,
                                        bottom: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Machine Image
                                          Hero(
                                            tag:
                                            'ControllerImage_${machine.machineId}_$index',
                                            transitionOnUserGestures: true,
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              child: Image.asset(
                                                'assets/images/washing_machine.png',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .local_laundry_service,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // Machine Details
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  // ✅ Display machineId
                                                  Text(
                                                    'Machine ${machine.machineId}',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: const Color(
                                                          0xFF14181B),
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // ✅ Display hostel (location)
                                                  Text(
                                                    machine.hostel,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: const Color(
                                                          0xFF57636C),
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Calendar Icon Button
                                          Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.calendar,
                                                color: Color(0xFF4B39EF),
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage(
                                                          eachMachineBooking:
                                                          machine,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}