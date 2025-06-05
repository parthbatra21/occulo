import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/auth/logo_animation.dart';
import '../widgets/auth/auth_form.dart';
import '../services/state_checker.dart';
import '../screens/patient_home_screen.dart';

class AuthScreen extends StatefulWidget {
  final String userType;
  const AuthScreen({super.key, required this.userType});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _glassesAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeInOut),
      ),
    );

    _glassesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final auth = FirebaseAuth.instance;
        final stateChecker = Provider.of<StateChecker>(context, listen: false);

        if (_isLogin) {
          // Login existing user
          await auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          // Save user type to shared preferences
          await stateChecker.saveUserType(widget.userType);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Create new user
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          // Update user profile with name
          await userCredential.user?.updateDisplayName(
            _nameController.text.trim(),
          );

          // Save user type to shared preferences
          await stateChecker.saveUserType(widget.userType);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }

        // Add a delay and explicitly check auth state after login/signup
        if (mounted) {
          // Wait for 3 seconds to ensure Firebase Auth state is updated
          await Future.delayed(const Duration(seconds: 3));

          // Force check auth state
          await stateChecker.checkAuthState();

          // Navigate to home screen if still authenticated
          if (stateChecker.authState == AuthState.authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const PatientHomeScreen(),
              ),
              (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (error) {
        String errorMessage = 'Authentication failed';

        if (error.code == 'user-not-found' || error.code == 'wrong-password') {
          errorMessage = 'Invalid email or password';
        } else if (error.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered';
        } else if (error.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        } else if (error.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleAuthMode() {
    if (!_isLoading) {
      setState(() => _isLogin = !_isLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade700,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background animated circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(5),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(5),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const LogoAnimation(),
                            const SizedBox(height: 24),
                            // Tagline
                            AnimatedBuilder(
                              animation: _textAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _textAnimation.value,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Smart Medication Tracking',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: Colors.white.withAlpha(200),
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${widget.userType.toUpperCase()} Portal',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 60),
                            AuthForm(
                              isLogin: _isLogin,
                              isLoading: _isLoading,
                              obscurePassword: _obscurePassword,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              nameController: _nameController,
                              formKey: _formKey,
                              onSubmit: _submitForm,
                              onTogglePassword: _togglePasswordVisibility,
                              onToggleAuthMode: _toggleAuthMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
