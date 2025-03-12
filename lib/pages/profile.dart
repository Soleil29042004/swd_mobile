import 'package:flutter/material.dart';
import 'package:swd_mobile/components.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/inventory.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2; // Set to profile index

  final TextEditingController _userCodeController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleIdController = TextEditingController();
  final TextEditingController _warehouseCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildNavigationDrawer(context, {}, setState),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage("assets/icons/profile.jpg"),
              ),
              const SizedBox(height: 16),
              Text(
                "User Profile",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Information Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildTextField("User Code", controller: _userCodeController),
                      buildTextField("Username", controller: _userNameController),
                      buildTextField("Full Name", controller: _fullNameController),
                      buildTextField("Email", controller: _emailController),
                      buildTextField("Password", controller: _passwordController, isPassword: true),
                      buildTextField("Role ID", controller: _roleIdController),
                      buildTextField("Warehouse Code", controller: _warehouseCodeController),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile Updated')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Change Password Section
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildTextField("Current Password", isPassword: true),
                      buildTextField("New Password", isPassword: true),
                      buildTextField("Confirm New Password", isPassword: true),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password Changed')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _currentIndex,
            (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on index
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => InvetoryScreen()));
          } else if (index == 2) {
          }
          // Note: index 3 (logout) is already handled in the buildBottomNavigationBar function
        },
      ),
    );
  }
}
