import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/pages/profile.dart';
import 'package:raheel/pages/driver_bookings_container.dart';
import 'package:raheel/pages/traveler_set.dart';
import 'package:raheel/pages/traveler_bookings.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const ProfilePage(),
    const DriverBookingsContainer(),
    const TravelerSetPage(),
    const TravelerBookingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: kAppBarColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        iconSize: 28,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            activeIcon: Icon(Icons.directions_car),
            label: 'إنشاء رحلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'البحث عن رحلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            activeIcon: Icon(Icons.event),
            label: 'حجوزاتي',
          ),
        ],
      ),
    );
  }
}
