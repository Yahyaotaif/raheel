# URGENT: How to Fix the Double Booking Issue

## The Problem
Two travelers were able to book a trip with only 1 passenger capacity. This is a race condition that must be fixed at the database level.

## Solution: Execute SQL Function in Supabase

### Step-by-Step Instructions

#### Step 1: Go to Supabase Dashboard
1. Open https://app.supabase.com
2. Select your project
3. Click **SQL Editor** on the left sidebar

#### Step 2: Create a New Query
1. Click **+ New Query**
2. Name it "Fix Double Booking" (optional)

#### Step 3: Copy and Paste the SQL
Copy the ENTIRE contents of the file: `supabase/book_trip_function.sql`

The SQL does:
- ✅ Drops any old version of the function
- ✅ Creates the `book_trip` function with capacity validation
- ✅ Uses database-level locking (FOR UPDATE) to prevent race conditions
- ✅ Adds traveler info fields to bookings
- ✅ Grants permissions to both authenticated and anonymous users
- ✅ Creates a backup UNIQUE constraint to prevent double-booking

#### Step 4: Execute the Query
Click the **RUN** button (play icon) to execute the SQL

You should see output like:
```
Success. No rows returned
```

#### Step 5: Verify the Function Exists
In Supabase SQL Editor, run:
```sql
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'book_trip';
```

You should see `book_trip` in the results.

---

## What This Fixes

### Before the Fix
```
Driver creates trip: num_passengers = 1
Muhammed books → Booked successfully ✗
Tahani books → Booked successfully ✗ (WRONG! Should fail)
```

### After the Fix
```
Driver creates trip: num_passengers = 1
Muhammed books → Booked successfully ✓
Tahani books → Error: "No seats available" ✓ (CORRECT!)
```

---

## How It Works

### Database Locking
The function uses `FOR UPDATE` to lock the trips row during the transaction. This means:
- Only ONE transaction can modify/check that trips row at a time
- When Muhammed's booking transaction runs first, it locks the row
- When Tahani's transaction tries to run, it **waits** for Muhammed's to finish
- Once Muhammed's booking is inserted, the count is updated
- Then Tahani's transaction resumes and sees the count is already 1 (full)
- Tahani's booking is rejected

### The Code Flow
```sql
1. Lock the trips row (FOR UPDATE)
2. Get num_passengers from trips
3. Check if traveler already booked this trip
4. Count existing bookings (excluding completed)
5. If count >= num_passengers → REJECT ❌
6. Otherwise → INSERT booking ✓
```

---

## Testing the Fix

### Test Scenario
1. **Yahya (Driver)** creates a trip with `num_passengers = 1`
2. **Muhammed (Traveler)** finds and books it
   - Expected: ✅ Booking succeeds
   - Muhammed's payment: ✅ Completes
3. **Tahani (Traveler)** finds and tries to book the same trip
   - Expected: ❌ Booking fails with error: "عذراً، انتهت المقاعد المتاحة"
   - Tahani's payment: ❌ Should not reach payment (check UI flow)
4. **Yahya** logs in to view bookings
   - Expected: 👤 Only Muhammed's card appears, NOT Tahani's

### If Test Fails
If both travelers still book successfully:
1. Check that you executed the SQL (Step 4 above)
2. Verify the function exists (Step 5 above)
3. Check Supabase logs for errors
4. Clear the app cache and restart the Android emulator

---

## Backup Safety: Unique Constraint

The SQL also creates a UNIQUE constraint at the database level:
```sql
ALTER TABLE bookings ADD CONSTRAINT unique_traveler_per_trip 
UNIQUE(trip_id, traveler_id) WHERE status != 'completed';
```

This means even if someone bypasses the function, the database will reject duplicate bookings.

---

## Rollback (if needed)

If something goes wrong, you can undo this by running:
```sql
DROP FUNCTION IF EXISTS book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC) CASCADE;
ALTER TABLE bookings DROP CONSTRAINT IF EXISTS unique_traveler_per_trip;
```

---

## Important Notes

⚠️ **Make sure:**
- You run the ENTIRE SQL file (don't skip parts)
- You execute it in your actual Supabase project (not a different one)
- The function has the right column names (check your `bookings` table schema if it fails)

✅ **After running the SQL:**
- Rebuild/restart your Flutter app
- Clear app cache if needed
- Test the scenario above
