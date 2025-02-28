import 'package:flutter/material.dart';
import 'package:swd_mobile/components.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  Map<String, bool> _drawerSectionState = {
    "Home": false,
    "Xuất-nhập ngoại": false,
    "Xuất-nhập nội": false,
    "Quản lý hàng hóa": false,
  };

  final List<Widget> tabs = [
    const Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context), // Use the function from components.dart
      drawer: buildNavigationDrawer(context, _drawerSectionState, setState), // Use the drawer function
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "PHIẾU NHẬP KHO",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("+ Thêm hàng từ file ngoài"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("+ Thêm hàng từ hệ thống"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Thông tin chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            buildDropdownField("Nguồn nhận"), // Now available from components.dart
            buildDropdownField("Mã nguồn"), // Now available from components.dart
            buildTextField("Số điện thoại"), // Now available from components.dart
            buildTextField("Địa chỉ", maxLines: 2), // Now available from components.dart
            buildDropdownField("Mã phiếu", isDisabled: true), // Now available from components.dart
            buildTextField("Lý do xuất", maxLines: 2), // Now available from components.dart
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Lưu"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

