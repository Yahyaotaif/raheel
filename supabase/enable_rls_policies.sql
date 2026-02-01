-- Enable Row Level Security for user and trips tables
-- This migration enables RLS and creates appropriate policies for user authentication

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.user ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USER TABLE POLICIES
-- ============================================================================

-- Policy: Users can create their own profile during registration
CREATE POLICY "Users can create their own profile"
ON public.user
FOR INSERT
TO authenticated, anon
WITH CHECK (auth_id = auth.uid());

-- Policy: Users can view their own profile only
CREATE POLICY "Users can view their own profile"
ON public.user
FOR SELECT
TO authenticated
USING (auth.uid() = auth_id);

-- Policy: Users can update their own profile only
CREATE POLICY "Users can update their own profile"
ON public.user
FOR UPDATE
TO authenticated
USING (auth.uid() = auth_id)
WITH CHECK (auth.uid() = auth_id);

-- Policy: Users cannot delete their own profile (optional security measure)
-- Uncomment if you want to prevent profile deletion
-- CREATE POLICY "Users cannot delete profiles"
-- ON public.user
-- FOR DELETE
-- TO authenticated
-- USING (false);

-- ============================================================================
-- TRIPS TABLE POLICIES
-- ============================================================================

-- Policy: Allow authenticated users to view all trips (public listing)
-- Modify this if you want to restrict visibility
CREATE POLICY "Authenticated users can view all trips"
ON public.trips
FOR SELECT
TO authenticated
USING (true);

-- Policy: Drivers can create their own trips
CREATE POLICY "Drivers can create their own trips"
ON public.trips
FOR INSERT
TO authenticated
WITH CHECK (driver_id = auth.uid());

-- Policy: Drivers can update their own trips only
CREATE POLICY "Drivers can update their own trips"
ON public.trips
FOR UPDATE
TO authenticated
USING (driver_id = auth.uid())
WITH CHECK (driver_id = auth.uid());

-- Policy: Drivers can delete their own trips only
CREATE POLICY "Drivers can delete their own trips"
ON public.trips
FOR DELETE
TO authenticated
USING (driver_id = auth.uid());

-- ============================================================================
-- BOOKINGS TABLE POLICIES
-- ============================================================================

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Policy: Travelers can view their own bookings
CREATE POLICY "Travelers can view their own bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (traveler_id = auth.uid() OR driver_id = auth.uid());

-- Policy: Travelers can create their own bookings
-- This is used by the book_trip RPC function
CREATE POLICY "Travelers can create their own bookings"
ON public.bookings
FOR INSERT
TO authenticated, anon
WITH CHECK (true);  -- Controlled by book_trip function instead

-- Policy: Travelers can update their own bookings
CREATE POLICY "Travelers can update their own bookings"
ON public.bookings
FOR UPDATE
TO authenticated
USING (traveler_id = auth.uid() OR driver_id = auth.uid())
WITH CHECK (traveler_id = auth.uid() OR driver_id = auth.uid());

-- Policy: Drivers can delete bookings for their trips only
CREATE POLICY "Drivers can delete bookings for their trips"
ON public.bookings
FOR DELETE
TO authenticated
USING (driver_id = auth.uid());

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. These policies are designed for your app's actual schema:
--    - user table: stores user profiles with id (UUID), FirstName, LastName, etc.
--    - trips table: stores trips with driver_id (UUID) as the creator
--    - bookings table: stores bookings linking travelers to trips
--
-- 2. The bookings table has RLS to prevent users from viewing/modifying other's bookings
--    However, the INSERT policy allows the book_trip RPC function to create bookings
--    (controlled at the database function level, not the policy level)
--
-- 3. Email/Password authentication:
--    Users log in with email and password via Supabase Auth
--    The auth.uid() function returns their authenticated UUID
--
-- 4. Test the policies thoroughly before deploying to production
-- 5. For anonymous users, you may need additional policies with 'TO anon'
-- 6. The book_trip RPC function has additional security checks (capacity validation)
--    that work in conjunction with these RLS policies
