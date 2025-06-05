import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/state_checker.dart';
import '../../screens/get_started_screen.dart';
import '../../screens/patient_home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final stateChecker = Provider.of<StateChecker>(context);

    // Show loading indicator while checking auth state
    if (stateChecker.authState == AuthState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate based on auth state
    if (stateChecker.authState == AuthState.authenticated) {
      // User is authenticated, check user type
      if (stateChecker.userType == 'patient') {
        return const PatientHomeScreen();
      } else {
        // For guardian or other user types, you can add more screens here
        // For now, we'll use PatientHomeScreen for all authenticated users
        return const PatientHomeScreen();
      }
    } else {
      // User is not authenticated, show get started screen
      return const GetStartedScreen();
    }
  }
}
