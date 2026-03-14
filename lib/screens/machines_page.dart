import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/Machine.dart';
import 'home_page.dart';

Future<List<Machine>> fetchMachines() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return List.generate(
    5,
        (i) => Machine(
      machineId: 'WM${i + 1}',
      location: 'Vishalgad Hostel',
    ),
  );
}

class ListMachinesPage extends StatefulWidget {
  const ListMachinesPage({Key? key}) : super(key: key);

  @override
  State<ListMachinesPage> createState() => _ListMachinesPageState();
}

class _ListMachinesPageState extends State<ListMachinesPage> {
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
                          future: fetchMachines(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final machines = snapshot.data!;
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: machines.length,
                              itemBuilder: (context, index) {
                                final machine = machines[index];
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 8, 16, 0),
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
                                      padding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          16, 8, 8, 8),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          // ✅ Machine Image
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
                                          // ✅ Machine Details
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 0, 0, 0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsetsDirectional
                                                      .only(bottom: 8),
                                                  child: Text(
                                                    machine.machineId,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: const Color(
                                                          0xFF14181B),
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  machine.location ??
                                                      'Unknown Location',
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
                                          // ✅ Calendar Icon - Navigate to HomePage
                                          IconButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.calendar,
                                              color: Color(0xFF4B39EF),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              // ✅ Navigate to HomePage with Machine object
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