-- Test Query: Verify book_trip function exists and works
-- Run this in Supabase SQL Editor to verify the function is properly installed

-- 1. Check if the function exists
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name = 'book_trip';

-- 2. Get its signature
SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'book_trip' AND n.nspname = 'public';

-- 3. Test the function with sample data (you'll need real IDs from your database)
-- First, get a real trip ID to test with:
SELECT id, driver_id, num_passengers 
FROM trips 
LIMIT 1;

-- 4. If the function exists and you have a trip, test it:
-- SELECT book_trip(
--   'uuid-of-traveler'::uuid,
--   'uuid-of-driver'::uuid,
--   trip_id_number,
--   'YYYY-MM-DD',
--   'HH:MM',
--   5.0::numeric
-- );
