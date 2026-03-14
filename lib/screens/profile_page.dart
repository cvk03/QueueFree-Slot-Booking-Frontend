import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late ProfileModel _model;
  late AnimationController _fadeController1;
  late AnimationController _fadeController2;
  late AnimationController _dividerController;
  late AnimationController _containerController1;
  late AnimationController _containerController2;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation1;
  late Animation<double> _fadeAnimation2;
  late Animation<double> _dividerAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;
  late Animation<Offset> _slideAnimation3;
  late Animation<Offset> _slideAnimation4;
  late Animation<Offset> _slideAnimation6;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ProfileModel();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Text animation 1 (Fade + Slide)
    _fadeController1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController1, curve: Curves.easeInOut),
    );
    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0.0, 20.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _fadeController1, curve: Curves.easeInOut),
    );

    // Text animation 2 (Fade + Slide)
    _fadeController2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController2, curve: Curves.easeInOut),
    );
    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0.0, 20.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _fadeController2, curve: Curves.easeInOut),
    );

    // Divider animation
    _dividerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dividerController, curve: Curves.easeInOut),
    );

    // Container animation 1 (200ms delay)
    _containerController1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation3 = Tween<Offset>(
      begin: const Offset(0.0, 60.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _containerController1, curve: Curves.easeInOut),
    );

    // Container animation 2 (300ms delay)
    _containerController2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation4 = Tween<Offset>(
      begin: const Offset(0.0, 60.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _containerController2, curve: Curves.easeInOut),
    );

    // Button animation (400ms delay)
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation6 = Tween<Offset>(
      begin: const Offset(0.0, 60.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Start animations with delays
    _fadeController1.forward();

    Future.delayed(const Duration(milliseconds: 0), () {
      _fadeController2.forward();
      _dividerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _containerController1.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _containerController2.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _fadeController1.dispose();
    _fadeController2.dispose();
    _dividerController.dispose();
    _containerController1.dispose();
    _containerController2.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.indigo,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<ProfileModel>(
            builder: (context, model, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // User name with animation
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation1,
                        child: SlideTransition(
                          position: _slideAnimation1,
                          child: Text(
                            model.displayName,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF14181B),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // User email with animation
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation2,
                        child: SlideTransition(
                          position: _slideAnimation2,
                          child: Text(
                            model.userEmail,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF39D2C0),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Divider with animation
                    FadeTransition(
                      opacity: _dividerAnimation,
                      child: Divider(
                        height: 44,
                        thickness: 1,
                        indent: 24,
                        endIndent: 24,
                        color: const Color(0xFFE0E3E7),
                      ),
                    ),
                    // Edit Profile container with animation
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                      child: SlideTransition(
                        position: _slideAnimation3,
                        child: FadeTransition(
                          opacity: _containerController1,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit Profile coming soon!'),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E3E7),
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8, 12, 8, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8, 0, 0, 0),
                                      child: Icon(
                                        Icons.account_circle_outlined,
                                        color: Color(0xFF14181B),
                                        size: 24,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(12, 0, 0, 0),
                                      child: Text(
                                        'Edit Profile',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF14181B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Give Feedback container with animation
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                      child: SlideTransition(
                        position: _slideAnimation4,
                        child: FadeTransition(
                          opacity: _containerController2,
                          child: Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Feedback coming soon!'),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE0E3E7),
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8, 12, 8, 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8, 0, 0, 0),
                                        child: Icon(
                                          Icons.question_answer_outlined,
                                          color: Color(0xFF14181B),
                                          size: 24,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12, 0, 0, 0),
                                        child: Text(
                                          'Give Feedback',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF14181B),
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Logout button with animation
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 24),
                      child: SlideTransition(
                        position: _slideAnimation6,
                        child: FadeTransition(
                          opacity: _buttonController,
                          child: model.isLoggingOut
                              ? const SizedBox(
                            width: 150,
                            height: 44,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text(
                                      'Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await model.logout();
                                        if (mounted) {
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            '/signin',
                                                (route) => false,
                                          );
                                        }
                                      },
                                      child: const Text('Log Out'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F4F8),
                              side: const BorderSide(
                                color: Color(0xFFE0E3E7),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(38),
                              ),
                              minimumSize: const Size(150, 44),
                            ),
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF14181B),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}