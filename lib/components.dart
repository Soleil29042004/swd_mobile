import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swd_mobile/pages/stock_check_status.dart';
import 'package:swd_mobile/pages/stock_screen.dart';
import 'package:swd_mobile/pages/transaction_status.dart';
import 'package:swd_mobile/services/auth_service.dart';
import 'package:swd_mobile/pages/import.dart';
import 'package:swd_mobile/pages/login.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/export.dart';
import 'package:swd_mobile/pages/inventory.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'Staff',
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.blueAccent,
    centerTitle: true,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/notification', // Ensure this route is defined in your MaterialApp
          );
        },
      ),
    ],
  );
}

Drawer buildNavigationDrawer(BuildContext context, Map<String, bool> drawerSectionState, Function setStateCallback) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        buildUserHeader(),
        ListTile(
          leading: const Icon(Icons.home, color: Colors.blueGrey),
          title: const Text("Home"),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        buildCollapsibleSection(context, "Xuất-nhập kho", Icons.store, [
          buildSubMenu("Phiếu xuất kho", Icons.upload, context),
          buildSubMenu("Phiếu nhập kho", Icons.download, context),
          buildSubMenu("Xét duyệt phiếu", Icons.check, context),
        ], drawerSectionState, setStateCallback),
        buildCollapsibleSection(context, "Quản lý hàng hóa", Icons.warehouse, [
          buildSubMenu("Xét duyệt kiểm kho", Icons.check_box, context),
          buildSubMenu("Tìm hàng hóa", Icons.search, context),
          buildSubMenu("Kiểm kê", Icons.check, context),
        ], drawerSectionState, setStateCallback),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: () => handleLogout(context),
        ),
      ],
    ),
  );
}

UserAccountsDrawerHeader buildUserHeader() {
  return UserAccountsDrawerHeader(
    accountName: FutureBuilder<String>(
      future: _fetchUserFullName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        return Text(
          snapshot.data ?? "Staff Member",
          style: const TextStyle(color: Colors.white),
        );
      },
    ),
    accountEmail: null,
    currentAccountPicture: const CircleAvatar(
      backgroundImage: AssetImage("assets/icons/profile.jpg"),
    ),
    decoration: const BoxDecoration(color: Colors.blueAccent),
  );
}

Future<String> _fetchUserFullName() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return "Staff Member";
    }

    final response = await http.get(
      Uri.parse('https://app-250312143530.azurewebsites.net/api/users/info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['result'] != null) {
        // Use UTF-8 decoding to handle special characters
        String fullName = responseData['result']['fullName'] ?? "Staff Member";
        return utf8.decode(fullName.codeUnits);
      }
    }

    return "Staff Member";
  } catch (e) {
    return "Staff Member";
  }
}

ListTile buildDrawerItem(BuildContext context, String title, IconData icon, int index, Function setStateCallback) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      setStateCallback(() => index);
      Navigator.pop(context);
    },
  );
}

ExpansionTile buildCollapsibleSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
    Map<String, bool> drawerSectionState,
    Function setStateCallback,
    ) {
  return ExpansionTile(
    leading: Icon(icon, color: Colors.blueAccent),
    title: Text(title),
    initiallyExpanded: drawerSectionState[title] ?? false,
    onExpansionChanged: (expanded) {
      setStateCallback(() => drawerSectionState[title] = expanded);
    },
    children: children,
  );
}

Widget buildSubMenu(String title, IconData icon, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 40.0),
    child: ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      onTap: () {
        if (title == "Phiếu nhập kho") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImportTransactionScreen()),
          );
        }
        else if (title == 'Phiếu xuất kho'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExportTransactionScreen()),
          );
        }
        else if (title == 'Xét duyệt kiểm kho'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StockCheckStatusScreen()),
          );
        }
        else if (title == 'Kiểm kê'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StockCheckListScreen()),
          );
        }
        else if (title == 'Tìm hàng hóa'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvetoryScreen()),
          );
        }
        else if (title == 'Xét duyệt phiếu'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionManagementScreen(),
            ),
          );
        };
      },
    ),
  );
}

BottomNavigationBar buildBottomNavigationBar(BuildContext context, int currentIndex, Function(int) onTap) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
    ],
    onTap: (index) {
      if (index == 3) { // Logout button index
        handleLogout(context);
      } else {
        onTap(index);
      }
    },
  );
}

void handleLogout(BuildContext context) async {
  final authService = AuthService(baseUrl: 'https://app-250312143530.azurewebsites.net/api');
  final token = await authService.getToken() ?? '';

  // Call the logout API endpoint
  try {
    final response = await http.post(
      Uri.parse('https://app-250312143530.azurewebsites.net/api/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      // Clear local token
      await authService.logout();

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Handle errors - maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout error: $e')),
    );
  }
}

Widget buildTextField(String label, {TextEditingController? controller, bool isPassword = false, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller, // Now supports a text controller
      obscureText: isPassword, // Now supports password fields
      maxLines: isPassword ? 1 : maxLines, // Ensure password fields are single-line
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

// Define buildDropdownField in components.dart
Widget buildDropdownField(String label, {bool isDisabled = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: isDisabled,
        fillColor: isDisabled ? Colors.grey[300] : null,
      ),
      items: [
        DropdownMenuItem(value: "Option1", child: Text("Option 1")),
        DropdownMenuItem(value: "Option2", child: Text("Option 2")),
      ],
      onChanged: isDisabled ? null : (String? value) {
        print("Selected: $value");
      },
    ),
  );
}

