-- Deletes trips 3+ days older than their trip_date
-- Exposed as RPC via Supabase

CREATE OR REPLACE FUNCTION public.cleanup_old_trips()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Delete trips where trip_date is more than 3 days before today
  DELETE FROM public.trips
  WHERE trip_date < (CURRENT_DATE - INTERVAL '3 days');
END;
$$;

-- Allow clients to execute this function
GRANT EXECUTE ON FUNCTION public.cleanup_old_trips() TO anon;
GRANT EXECUTE ON FUNCTION public.cleanup_old_trips() TO authenticated;
