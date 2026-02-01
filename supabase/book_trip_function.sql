-- Create the book_trip RPC function with atomic capacity validation
-- This function ensures only one booking per available seat by checking capacity atomically

-- First, drop any old overloads if they exist
DROP FUNCTION IF EXISTS book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC);

CREATE OR REPLACE FUNCTION book_trip(
  p_traveler_id UUID,
  p_driver_id UUID,
  p_trip_id BIGINT,
  p_trip_date TEXT,
  p_trip_time TEXT,
  p_booking_fee NUMERIC
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_num_passengers INT;
  v_booked_count INT;
  v_existing_booking_count INT;
  v_traveler_first_name TEXT;
  v_traveler_last_name TEXT;
  v_traveler_phone INT;
  v_traveler_email TEXT;
BEGIN
  -- Get traveler details
  SELECT "FirstName", "LastName", "MobileNumber", "EmailAddress"
  INTO v_traveler_first_name, v_traveler_last_name, v_traveler_phone, v_traveler_email
  FROM "user"
  WHERE auth_id = p_traveler_id;
  
  -- Check if traveler exists
  IF v_traveler_first_name IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Traveler data not found');
  END IF;
  
  -- First, get the trip details and lock the row to prevent race conditions
  SELECT num_passengers INTO v_num_passengers
  FROM trips
  WHERE id = p_trip_id
  FOR UPDATE;  -- Lock the row during this transaction
  
  -- Check if trip exists
  IF v_num_passengers IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Trip not found');
  END IF;
  
  -- Check if traveler already booked this trip (status is not 'completed')
  SELECT COUNT(*) INTO v_existing_booking_count
  FROM bookings
  WHERE trip_id = p_trip_id 
  AND traveler_id = p_traveler_id 
  AND (status IS NULL OR status != 'completed');
  
  IF v_existing_booking_count > 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Already booked this trip');
  END IF;
  
  -- Count current bookings for this trip (only count non-cancelled bookings)
  -- Include bookings with status: NULL (new), 'pending', or 'confirmed'
  SELECT COUNT(*) INTO v_booked_count
  FROM bookings
  WHERE trip_id = p_trip_id 
  AND (status IS NULL OR status IN ('pending', 'confirmed', 'waiting'));
  
  -- Debug logging (will appear in Postgres logs)
  RAISE NOTICE 'Trip ID: %, Capacity: %, Current bookings: %', p_trip_id, v_num_passengers, v_booked_count;
  
  -- Check if there's capacity (strict inequality: must have at least one free seat)
  IF v_booked_count >= v_num_passengers THEN
    RETURN jsonb_build_object('success', false, 'error', 'No seats available');
  END IF;
  
  -- Create the booking with all required denormalized fields
  INSERT INTO bookings (
    trip_id,
    traveler_id,
    driver_id,
    trip_date,
    trip_time,
    booking_fee,
    traveler_first_name,
    traveler_last_name,
    traveler_phone,
    traveler_email,
    status,
    created_at
  )
  VALUES (
    p_trip_id,
    p_traveler_id,
    p_driver_id,
    p_trip_date::date,
    p_trip_time::time,
    p_booking_fee,
    v_traveler_first_name,
    v_traveler_last_name,
    v_traveler_phone,
    v_traveler_email,
    'pending',
    NOW()
  );

  -- Return success confirmation
  RETURN jsonb_build_object(
    'success', true,
    'trip_id', p_trip_id,
    'traveler_id', p_traveler_id,
    'message', 'Booking created successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC) TO authenticated;
GRANT EXECUTE ON FUNCTION book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC) TO anon;

-- Also create a database index to prevent double-booking at the index level
-- This is a backup safety measure in case the function is bypassed somehow
-- Using a partial unique index (only for non-completed bookings)
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_traveler_per_trip 
ON bookings(trip_id, traveler_id) 
WHERE status IS NULL OR status != 'completed';
