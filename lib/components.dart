import 'package:flutter/material.dart';
import 'package:swd_mobile/pages/import.dart';
import 'package:swd_mobile/pages/login.dart';
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/export.dart';

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
        buildCollapsibleSection(context, "Xuất-nhập ngoại", Icons.store, [
          buildSubMenu("Phiếu xuất kho", Icons.upload, context),
          buildSubMenu("Phiếu nhập kho", Icons.download, context),
        ], drawerSectionState, setStateCallback),
        buildCollapsibleSection(context, "Xuất-nhập nội", Icons.sync_alt, [
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
    accountName: Text("JadeHwang"),
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
        };
      },
    ),
  );
}

BottomNavigationBar buildBottomNavigationBar(int currentIndex, Function(int) onTap) {
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
    onTap: onTap,
  );
}

void handleLogout(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

Widget buildTextField(String label, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      maxLines: maxLines,
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
