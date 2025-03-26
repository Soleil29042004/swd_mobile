import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swd_mobile/components.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/inventory.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String baseUrl = 'https://app-250312143530.azurewebsites.net/api';
  bool isLoading = true;
  UserProfile? userProfile;
  String? errorMessage;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Authentication token not found. Please login again.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['result'] != null) {
          setState(() {
            userProfile = UserProfile.fromJson(responseData['result']);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Invalid response format from server';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load profile: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildNavigationDrawer(context, {}, setState),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorView()
          : _buildProfileContent(),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryScreen()));
          } else if (index == 2) {
            // Already on profile page
          }
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (userProfile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildInfoSection('User Information', [
            {'label': 'User ID', 'value': userProfile!.id},
            {'label': 'User Code', 'value': userProfile!.userCode},
            {'label': 'Username', 'value': userProfile!.userName},
            {'label': 'Full Name', 'value': userProfile!.fullName},
            {'label': 'Email', 'value': userProfile!.email},
            {'label': 'Status', 'value': userProfile!.status ?? 'Active'},
          ]),
          const SizedBox(height: 16),
          _buildInfoSection('Role Information', [
            {'label': 'Role', 'value': userProfile!.role.roleName},
          ]),
          const SizedBox(height: 16),
          _buildInfoSection('Warehouse Information', [
            {'label': 'Warehouse Code', 'value': userProfile!.warehouseCode ?? 'Not available'},
          ]),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // This could navigate to an edit profile page in the future
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing coming soon!')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Logout functionality
                _showLogoutConfirmation(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                // Clear saved credentials
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');

                // Navigate to login screen and clear navigation history
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            utf8.decode(userProfile!.fullName.codeUnits),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  userProfile!.status ?? 'Active',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Map<String, String>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: items.map((item) => _buildInfoItem(item['label']!, item['value']!)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              utf8.decode(label.codeUnits),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              utf8.decode(value.codeUnits),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated User Profile model with removed fields
class UserProfile {
  final String id;
  final String userCode;
  final String userName;
  final String email;
  final String fullName;
  final Role role; // Change to a Role object instead of just roleId string
  final String? status;
  final String? warehouseCode;

  UserProfile({
    required this.id,
    required this.userCode,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.role,
    this.status,
    this.warehouseCode,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      userCode: json['userCode'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] != null ? Role.fromJson(json['role']) : Role(roleId: '', roleType: '', roleName: ''),
      status: json['status'],
      warehouseCode: json['warehouseCode'],
    );
  }
}

// Add a new Role class to represent the nested role object
class Role {
  final String roleId;
  final String roleType;
  final String roleName;

  Role({
    required this.roleId,
    required this.roleType,
    required this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['roleId'] ?? '',
      roleType: json['roleType'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }
}