-- COPY AND PASTE THIS ENTIRE BLOCK INTO SUPABASE SQL EDITOR
-- This fixes the double-booking issue where 2 travelers could book a 1-passenger trip

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
  v_booking_id BIGINT;
  v_existing_booking_id BIGINT;
  v_traveler_first_name TEXT;
  v_traveler_last_name TEXT;
  v_traveler_phone INT;
  v_traveler_email TEXT;
BEGIN
  -- Get traveler details
  SELECT "FirstName", "LastName", "MobileNumber", "EmailAddress"
  INTO v_traveler_first_name, v_traveler_last_name, v_traveler_phone, v_traveler_email
  FROM "user"
  WHERE id = p_traveler_id;
  
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
  SELECT id INTO v_existing_booking_id
  FROM bookings
  WHERE trip_id = p_trip_id AND traveler_id = p_traveler_id 
  AND (status IS NULL OR status != 'completed')
  LIMIT 1;
  
  IF v_existing_booking_id IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Already booked this trip');
  END IF;
  
  -- Count current bookings for this trip (excluding completed bookings)
  SELECT COUNT(*) INTO v_booked_count
  FROM bookings
  WHERE trip_id = p_trip_id AND (status IS NULL OR status != 'completed');
  
  -- Check if there's capacity
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
  )
  RETURNING id INTO v_booking_id;
  
  -- Return success with booking ID
  RETURN jsonb_build_object(
    'success', true,
    'booking_id', v_booking_id,
    'message', 'Booking created successfully'
  );
  
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- Grant execute permission to authenticated and anonymous users
GRANT EXECUTE ON FUNCTION book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC) TO authenticated;
GRANT EXECUTE ON FUNCTION book_trip(UUID, UUID, BIGINT, TEXT, TEXT, NUMERIC) TO anon;

-- Also create a database index to prevent double-booking at the index level
-- This is a backup safety measure in case the function is bypassed somehow
-- Using a partial unique index (only for non-completed bookings)
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_traveler_per_trip 
ON bookings(trip_id, traveler_id) 
WHERE status IS NULL OR status != 'completed';
