# Fix for Multiple Bookings on Single-Passenger Trips

## Problem
When a driver creates a trip with only 1 passenger capacity, multiple travelers were able to successfully book the same trip. This was caused by a race condition in the booking logic.

### Root Cause
The `book_trip` RPC function (called from traveler_set.dart line 202) was either missing or not properly validating trip capacity before inserting a booking. Without atomic validation at the database level, two travelers could simultaneously:
1. See the trip as available (1 empty seat)
2. Complete payment
3. Call the RPC function
4. Both get successfully booked due to lack of concurrent control

## Solution

### 1. Create the SQL Function in Supabase

The main fix requires creating a proper `book_trip` function in Supabase that:
- **Uses database-level locking** (FOR UPDATE) to prevent race conditions
- **Atomically validates capacity** before inserting the booking
- **Returns success/failure** as JSON for the app to handle

**Steps to apply:**
1. Go to your Supabase dashboard → SQL Editor
2. Copy the entire contents of `supabase/book_trip_function.sql`
3. Run it to create the function

The function:
- Locks the trips row during the transaction
- Counts existing non-completed bookings
- Checks if traveler already booked this trip
- Validates there are available seats
- Only then inserts the booking
- Returns `{success: true}` or `{success: false, error: "reason"}`

### 2. Updated Error Handling in Dart

The `lib/pages/traveler_set.dart` has been updated to:
- Show specific error messages based on the RPC function's error response
- Refresh the trips list after a failed booking so the user sees current availability
- Handle cases like: "Already booked this trip", "Trip not found", "No seats available"

**Changes made:**
- Lines 279-297 in traveler_set.dart now properly parse and display the error message from the RPC function
- The error message is localized to Arabic for better UX

## How It Works

### Before (Race Condition Vulnerability)
```
Traveler A sees: Trip with 1 seat, 0 booked ✓
Traveler B sees: Trip with 1 seat, 0 booked ✓
Traveler A pays ✓
Traveler B pays ✓
Traveler A: .rpc('book_trip') → booked successfully
Traveler B: .rpc('book_trip') → booked successfully ❌ WRONG!
```

### After (With Atomic Function)
```
Traveler A sees: Trip with 1 seat, 0 booked ✓
Traveler B sees: Trip with 1 seat, 0 booked ✓
Traveler A pays ✓
Traveler B pays ✓
Traveler A: .rpc('book_trip') → function locks trips row, validates, books successfully ✓
Traveler B: .rpc('book_trip') → function detects 1 booked, 1 capacity → returns {success: false} ✓
Traveler B sees error: "No seats available"
```

## Testing

To verify the fix works:

1. **Run the SQL function** in Supabase
2. **Test scenario:**
   - Yahya creates a trip with 1 passenger
   - Muhammed logs in, finds and books the trip (should succeed)
   - Muhammed logs out
   - Tahani logs in, finds and tries to book the same trip
   - Tahani's booking should **FAIL** with error: "عذراً، انتهت المقاعد المتاحة في هذه الرحلة"
3. When Yahya logs in, he should only see **Muhammed's card**, not Tahani's

## Technical Details

### Database Locking
The function uses `FOR UPDATE` on the trips table to lock the row during the transaction. This ensures:
- Only one transaction can modify the trips row at a time
- Later transactions wait for earlier ones to complete
- When a late transaction resumes, it sees the updated booking count

### Transaction Isolation
By checking the booking count **inside** the transaction after locking:
- The count is always accurate at the moment of validation
- No other transaction can insert bookings between count and insert
- This guarantees the capacity constraint is never violated

## Rollback Instructions (if needed)

If you need to undo this change:

1. In Supabase SQL Editor, drop the function:
```sql
DROP FUNCTION IF EXISTS book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC);
```

2. Revert the Dart changes to `lib/pages/traveler_set.dart` (lines 279-297)

## Future Improvements

Consider also:
- Adding a database constraint: `ALTER TABLE bookings ADD CONSTRAINT check_trip_capacity CHECK (...)`
- Implementing retry logic with exponential backoff for failed bookings
- Adding audit logging for all booking attempts
- Implementing a webhook to notify driver when trip is fully booked
