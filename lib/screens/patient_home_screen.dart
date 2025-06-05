import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/state_checker.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ooculo'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _showSignOutDialog();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Vision',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildVisionTab();
      case 2:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${_auth.currentUser?.displayName ?? 'Patient'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your vision assistant is ready',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Vision Assistant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // Navigate to vision assistant
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionTab() {
    return Container(
      color: Colors.blue.shade50,
      child: const Center(
        child: Text(
          'Vision Assistant Coming Soon',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text(
              'Account Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            title: Text(
              'Vision Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Vision Preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Device Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red.shade700),
              title: Text(
                'Sign Out',
                style: TextStyle(color: Colors.red.shade700),
              ),
              onTap: () async {
                await _showSignOutDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Are you sure you want to sign out?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                await StateChecker().signOut();
              },
            ),
          ],
        );
      },
    );
  }
}
