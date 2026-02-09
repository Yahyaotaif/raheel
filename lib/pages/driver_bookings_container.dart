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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).bookings),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border(bottom: BorderSide(width: 4.0, color: Colors.green.shade600)),
              ),
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 0 
                        ? Colors.green.shade50 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_location,
                          size: 20,
                          color: _tabController.index == 0 
                            ? Colors.green.shade700 
                            : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إنشاء رحلة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _tabController.index == 0 
                              ? Colors.green.shade700 
                              : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 1 
                        ? Colors.blue.shade50 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 20,
                          color: _tabController.index == 1 
                            ? Colors.blue.shade700 
                            : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إدارة الحجوزات',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _tabController.index == 1 
                              ? Colors.blue.shade700 
                              : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              labelPadding: const EdgeInsets.all(8),
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
