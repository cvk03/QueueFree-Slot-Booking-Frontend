import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _misController = TextEditingController();
  final _hostelController = TextEditingController();
  
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _misController.dispose();
    _hostelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      _isSignUp ? 'Create Account' : 'Welcome Back',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF14181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Sign up to get started'
                          : 'Sign in to your account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Sign up specific fields
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _misController,
                        decoration: InputDecoration(
                          labelText: 'MIS Number',
                          hintText: 'Enter your MIS number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _hostelController,
                        decoration: InputDecoration(
                          labelText: 'Hostel Name',
                          hintText: 'Enter your hostel name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Error message
                    if (authProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Sign in/up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                          if (_isSignUp) {
                            final success = await authProvider.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              displayName: _nameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              misNumber: _misController.text.trim(),
                              hostelName: _hostelController.text.trim(),
                            );
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/dashboard',
                              );
                            }
                          } else {
                            final success = await authProvider.signIn(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/dashboard',
                              );
                            }
                          }
                        },
                        child: authProvider.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                            : Text(
                          _isSignUp ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Toggle sign up/in
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            authProvider.clearError();
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                          style: const TextStyle(color: Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}