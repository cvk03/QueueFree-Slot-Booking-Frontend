import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/Machine.dart';
import 'models/home_model.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/machines_page.dart';
import 'screens/signin_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomePageModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: MaterialApp(
        title: 'Laundry Booking App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF1F4F8),
          textTheme: TextTheme(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14181B),
            ),
            displayMedium: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14181B),
            ),
            displaySmall: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF14181B),
            ),
            headlineMedium: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF14181B),
            ),
            headlineSmall: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF14181B),
            ),
            titleLarge: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF14181B),
            ),
            titleMedium: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF14181B),
            ),
            titleSmall: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF14181B),
            ),
            bodyLarge: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF14181B),
            ),
            bodyMedium: GoogleFonts.readexPro(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF57636C),
            ),
            bodySmall: GoogleFonts.readexPro(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF57636C),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo,
            elevation: 2,
            centerTitle: false,
            titleTextStyle: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: const Color(0xFF57636C),
            elevation: 8,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/signin': (context) => const SignInPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/list_machines': (context) => const ListMachinesPage(),
          '/profile': (context) => const ProfilePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final machine = settings.arguments as Machine?;
            if (machine == null) {
              return MaterialPageRoute(
                builder: (context) => const ListMachinesPage(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => HomePage(eachMachineBooking: machine),
            );
          }
          return null;
        },
      ),
    );
  }
}

// Auth Wrapper to handle routing based on login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // ✅ If user is logged in, show Dashboard
        if (authProvider.isUserLoggedIn) {
          return const DashboardPage();
        } else {
          // ✅ Otherwise, show SignIn page
          return const SignInPage();
        }
      },
    );
  }
}