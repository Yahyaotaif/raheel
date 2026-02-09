import 'dart:math';

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
          preferredSize: const Size.fromHeight(150),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tileSize = min(
                  (constraints.maxWidth - 12) / 2,
                  constraints.maxHeight,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SquareTabButton(
                      size: tileSize,
                      isActive: _tabController.index == 0,
                      activeColor: Colors.green.shade700,
                      inactiveColor: inactiveColor,
                      icon: Icons.add_location,
                      label: 'إنشاء رحلة',
                      onTap: () => _tabController.animateTo(0),
                    ),
                    _SquareTabButton(
                      size: tileSize,
                      isActive: _tabController.index == 1,
                      activeColor: Colors.blue.shade700,
                      inactiveColor: inactiveColor,
                      icon: Icons.assignment,
                      label: 'إدارة الحجوزات',
                      onTap: () => _tabController.animateTo(1),
                    ),
                  ],
                );
              },
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

class _SquareTabButton extends StatelessWidget {
  const _SquareTabButton({
    required this.size,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double size;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? activeColor : inactiveColor;
    final foregroundColor = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: size,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: foregroundColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
