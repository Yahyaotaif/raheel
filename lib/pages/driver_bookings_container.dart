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
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreateTrip = _tabController.index == 0;
    final activeColor = isCreateTrip ? Colors.green.shade600 : Colors.blue.shade600;
    final inactiveColor = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).bookings,
            style: kAppBarTitleStyle,
          ),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Create Trip Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0 ? Colors.green.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _tabController.index == 0 ? Colors.green.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_location,
                            color: _tabController.index == 0 ? Colors.green.shade700 : inactiveColor,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إنشاء رحلة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 0 ? Colors.green.shade700 : inactiveColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Manage Bookings Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1 ? Colors.blue.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _tabController.index == 1 ? Colors.blue.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment,
                            color: _tabController.index == 1 ? Colors.blue.shade700 : inactiveColor,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إدارة الحجوزات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 1 ? Colors.blue.shade700 : inactiveColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
