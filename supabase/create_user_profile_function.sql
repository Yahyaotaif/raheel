-- Create a SECURITY DEFINER function to insert user profiles safely
-- This bypasses RLS but validates the auth user exists.

CREATE OR REPLACE FUNCTION public.create_user_profile(
  p_auth_id uuid,
  p_first_name text,
  p_last_name text,
  p_username text,
  p_mobile text,
  p_email text,
  p_password text,
  p_car_type text DEFAULT NULL,
  p_car_plate text DEFAULT NULL,
  p_user_type text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If we have a session, ensure it matches the auth id
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_auth_id THEN
    RAISE EXCEPTION 'Unauthorized: auth id mismatch';
  END IF;

  -- Ensure auth user exists (for cases with no session)
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_auth_id) THEN
    RAISE EXCEPTION 'Auth user not found';
  END IF;

  INSERT INTO public."user" (
    auth_id,
    "FirstName",
    "LastName",
    "Username",
    "MobileNumber",
    "EmailAddress",
    "Password",
    "CarType",
    "CarPlate",
    user_type,
    created_at
  ) VALUES (
    p_auth_id,
    p_first_name,
    p_last_name,
    p_username,
    p_mobile,
    p_email,
    p_password,
    p_car_type,
    p_car_plate,
    p_user_type,
    now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_user_profile(
  uuid, text, text, text, text, text, text, text, text, text
) TO anon, authenticated;
