import 'package:flutter/material.dart';
import 'package:swd_mobile/api/auth_service.dart';
import 'package:swd_mobile/api/stockcheck_api.dart';
import 'package:swd_mobile/pages/import.dart';
import 'package:swd_mobile/pages/login.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/export.dart';
import 'package:swd_mobile/pages/inventory.dart';
import 'package:swd_mobile/pages/stock_check.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void navigateToStockCheck(BuildContext context) async {
  final authService = AuthService();
  final token = await authService.getToken() ?? '';

  final stockCheckApiService = StockCheckApiService(
    baseUrl: 'http://localhost:8080', // Use same base URL as AuthService
    token: token,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StockCheckMainScreen(apiService: stockCheckApiService),
    ),
  );
}

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
        ], drawerSectionState, setStateCallback),
        buildCollapsibleSection(context, "Quản lý hàng hóa", Icons.warehouse, [
          buildSubMenu("Thêm hàng hóa", Icons.upload, context),
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
  return const UserAccountsDrawerHeader(
    accountName: Text("Jade Hwang"),
    accountEmail: null,
    currentAccountPicture: CircleAvatar(
      backgroundImage: AssetImage("assets/icons/profile.jpg"),
    ),
    decoration: BoxDecoration(color: Colors.blueAccent),
  );
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
            MaterialPageRoute(builder: (context) => const ImportPage()),
          );
        }
        else if (title == 'Phiếu xuất kho'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExportPage()),
          );
        }
        else if (title == 'Kiểm kê'){
          navigateToStockCheck(context);
        }
        else if (title == 'Tìm hàng hóa'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvetoryScreen()),
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
  final authService = AuthService();
  final token = await authService.getToken() ?? '';

  // Call the logout API endpoint
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      // Clear local token
      await authService.clearToken();

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

