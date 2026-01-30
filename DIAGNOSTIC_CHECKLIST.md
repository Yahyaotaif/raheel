# Diagnostic Checklist: Double Booking Fix

## 1. Verify SQL Function Exists in Supabase

**Run this query in Supabase SQL Editor:**

```sql
SELECT 
  routine_name,
  routine_type,
  routine_schema
FROM information_schema.routines
WHERE routine_name = 'book_trip';
```

**Expected result:** 
- Should return ONE row with `routine_name = 'book_trip'`

**If you see NO rows:**
- The function was NOT created successfully
- You need to run the SQL from [QUICK_FIX_COPY_PASTE.sql](QUICK_FIX_COPY_PASTE.sql) again
- Make sure you copied the ENTIRE file and ran ALL of it

---

## 2. Verify Index Was Created

**Run this query in Supabase SQL Editor:**

```sql
SELECT indexname
FROM pg_indexes
WHERE tablename = 'bookings' AND indexname LIKE '%unique_traveler%';
```

**Expected result:**
- Should return a row with `idx_unique_traveler_per_trip`

**If you see NO rows:**
- The index wasn't created
- This is OK - it's just a backup safety measure
- The function should still work

---

## 3. Test the Function Directly

**Run this in Supabase SQL Editor:**

```sql
-- First, check if you have any trips
SELECT id, driver_id, num_passengers, trip_date, trip_time
FROM trips
LIMIT 1;
```

**Then use real IDs from your database to test:**

```sql
-- Replace with ACTUAL UUIDs and IDs from your database
SELECT book_trip(
  'ACTUAL-TRAVELER-UUID'::uuid,
  'ACTUAL-DRIVER-UUID'::uuid,
  ACTUAL-TRIP-ID,
  'YYYY-MM-DD',
  'HH:MM',
  5.0::numeric
) as result;
```

**Expected result:**
- Should return JSON like: `{"success": true, "booking_id": 123, ...}`
- Or if trip full: `{"success": false, "error": "No seats available"}`
- Or error if function doesn't exist: `ERROR: function book_trip(...) does not exist`

---

## 4. Possible Issues and Solutions

### Issue A: "Function book_trip does not exist"
**Solution:**
1. The SQL file wasn't executed in Supabase
2. Go to Supabase SQL Editor
3. Copy ENTIRE contents of [QUICK_FIX_COPY_PASTE.sql](QUICK_FIX_COPY_PASTE.sql)
4. Paste it
5. Click RUN

### Issue B: "عذرا الرحلة محجوزة" error in the app
**Possible causes:**
1. ✅ Function doesn't exist → fix with SQL (above)
2. ❌ Payment is failing → check Moyasar webhook
3. ❌ Trip data is missing → verify trip was created with correct columns
4. ❌ Traveler data is missing → verify traveler account has FirstName, LastName, MobileNumber

### Issue C: "Column ... does not exist"
**This means:** The bookings table has different columns than expected
**Solution:**
1. Check your bookings table structure in Supabase:
   ```sql
   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'bookings'
   ORDER BY ordinal_position;
   ```
2. Compare with what the function expects (lines 67-75 of SQL file)
3. Update the SQL function to match your actual schema

---

## 5. Complete Troubleshooting Steps

If the traveler still gets an error when booking:

1. **Check Supabase Logs:**
   - Go to Supabase dashboard
   - Click "Logs" on left sidebar
   - Check for SQL errors

2. **Check Function Permissions:**
   ```sql
   SELECT grantee, privilege_type
   FROM information_schema.role_table_grants
   WHERE table_name = 'bookings';
   ```

3. **Verify Bookings Table Structure:**
   ```sql
   \d bookings  -- Show table structure
   ```

4. **Check if Booking Was Created:**
   ```sql
   SELECT * FROM bookings
   WHERE traveler_id = 'TRAVELER-UUID'
   ORDER BY created_at DESC
   LIMIT 5;
   ```

---

## 6. Next Steps

After verifying the function exists:
1. Clear Android emulator cache
2. Restart the app
3. Test the booking scenario again
4. If it still fails, share:
   - Screenshot of the error message
   - The Supabase Logs output
   - Result of "SELECT FROM information_schema.routines WHERE routine_name = 'book_trip'"
