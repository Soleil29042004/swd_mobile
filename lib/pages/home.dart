import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the selected tab
  final List<Widget> tabs = [
    const Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Mail', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  Map<String, bool> _drawerSectionState = {
    "Overview": false,
    "Supplier Transactions": false,
    "Internal Transactions": false,
    "Sales Transactions": false,
    "Inventory Management": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: navigationDrawer(),
      body: tabs[_currentIndex],
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  AppBar appBar() {
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
    );
  }

  Drawer navigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildUserHeader(),
          buildDrawerItem("Overview", Icons.dashboard, "Overview"),
          buildCollapsibleSection("Supplier Transactions", Icons.store, [
            buildSubMenu("Stock Out", Icons.upload),
            buildSubMenu("Stock Out Documents", Icons.description),
            buildSubMenu("Stock In", Icons.download),
            buildSubMenu("Stock In Documents", Icons.assignment),
          ]),
          buildCollapsibleSection("Internal Transactions", Icons.sync_alt, [
            buildSubMenu("Stock Out", Icons.upload),
            buildSubMenu("Stock Out Orders", Icons.list_alt),
            buildSubMenu("Stock In", Icons.download),
            buildSubMenu("Stock In Orders", Icons.assignment),
          ]),
          buildCollapsibleSection("Sales Transactions", Icons.sell, [
            buildSubMenu("Stock Out", Icons.upload),
            buildSubMenu("Stock Out Documents", Icons.description),
            buildSubMenu("Stock In", Icons.download),
            buildSubMenu("Stock In Documents", Icons.assignment),
          ]),
          const Divider(),
          buildDrawerItem("Inventory Management", Icons.inventory, "Inventory Management"),
        ],
      ),
    );
  }

  Widget buildUserHeader() {
    return UserAccountsDrawerHeader(
      accountName: const Text("JadeHwang"),
      accountEmail: null,
      currentAccountPicture: const CircleAvatar(
        backgroundImage: AssetImage("assets/icons/profile.jpg"), // Replace with actual image
      ),
      decoration: const BoxDecoration(color: Colors.blueAccent),
    );
  }

  Widget buildDrawerItem(String title, IconData icon, String key) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        setState(() {
          _currentIndex = 0; // Navigate to respective screen if needed
        });
        Navigator.pop(context);
      },
    );
  }

  Widget buildCollapsibleSection(String title, IconData icon, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      initiallyExpanded: _drawerSectionState[title] ?? false,
      onExpansionChanged: (expanded) {
        setState(() {
          _drawerSectionState[title] = expanded;
        });
      },
      children: children,
    );
  }

  Widget buildSubMenu(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0), // Indentation for submenu
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title),
        onTap: () {},
      ),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Mail"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
