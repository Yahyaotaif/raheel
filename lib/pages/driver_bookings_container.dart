import 'package:flutter/material.dart';
import 'package:raheel/pages/driver_set.dart';
import 'package:raheel/pages/driver_bookings.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/l10n/app_localizations.dart';

class DriverBookingsContainer extends StatefulWidget {
  const DriverBookingsContainer({super.key});

  @override
  State<DriverBookingsContainer> createState() => _DriverBookingsContainerState();
}

class _DriverBookingsContainerState extends State<DriverBookingsContainer> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).bookings),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.add_location, size: 20),
              text: 'إنشاء رحلة',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.assignment, size: 20),
              text: 'إدارة الحجوزات',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 4.0,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const DriverSetPage(),
          const DriverBookingsPage(),
        ],
      ),
    );
  }
}
