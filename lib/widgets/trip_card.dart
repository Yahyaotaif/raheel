import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';

/// Convert 24-hour time string (HH:MM) to 12-hour format with AM/PM
String convertTo12HourFormatFromString(String timeString) {
  try {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final isPM = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = isPM ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  } catch (e) {
    return timeString; // Return original if parsing fails
  }
}

class TripCard extends StatelessWidget {
  final String tripTime;
  final String destination;
  final String? destinationDescription;
  final String? meetingPoint;
  final int numPassengers;
  final int bookedSeats;
  final double price;
  final String driverName;
  final bool isSelected;
  final VoidCallback onTap;

  const TripCard({
    required this.tripTime,
    required this.destination,
    this.destinationDescription,
    this.meetingPoint,
    required this.numPassengers,
    required this.bookedSeats,
    required this.price,
    required this.driverName,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  int get availableSeats => numPassengers - bookedSeats;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.black12,
            width: isSelected ? 3 : 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time and Selection Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      convertTo12HourFormatFromString(tripTime),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAppBarColor,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kAppBarColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'مختار',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Destination City (اختر المكان)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // حدد مكان الوصول (Arrival Location Description)
                if (destinationDescription != null &&
                    destinationDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مكان الوصول: $destinationDescription',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // حدد مكان الإنطلاق (Departure Location)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'مكان الإنطلاق: ${meetingPoint ?? "غير محدد"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Seats and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Available Seats Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: availableSeats > 2
                            ? Colors.green.withValues(alpha: 0.2)
                            : availableSeats > 0
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_seat, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'المقاعد: $availableSeats/$numPassengers',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: availableSeats > 2
                                  ? Colors.green[800]
                                  : availableSeats > 0
                                  ? Colors.orange[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price (only show if price > 0)
                    if (price > 0)
                      Text(
                        '${price.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kAppBarColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
