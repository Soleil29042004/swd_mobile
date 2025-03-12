import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:swd_mobile/components.dart';
import 'package:swd_mobile/pages/inventory.dart';
import 'package:swd_mobile/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "TỔNG QUAN",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 63,
                        title: '63%',
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.yellow,
                        value: 37,
                        title: '37%',
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.square, color: Colors.yellow),
                      const SizedBox(width: 5),
                      Text("Xuất kho"),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Icon(Icons.square, color: Colors.green),
                      const SizedBox(width: 5),
                      Text("Nhập kho"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoCard(Icons.assignment, "Tổng số phiếu", "52"),
              const SizedBox(height: 10),
              _buildInfoCard(Icons.inventory, "Tổng lượng tồn kho", "52,369"),
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
            // Already on home, do nothing
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => InvetoryScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          }
          // Note: index 3 (logout) is already handled in the buildBottomNavigationBar function
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
