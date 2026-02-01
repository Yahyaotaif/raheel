-- Create a function to sync password to user table
-- This function bypasses RLS using SECURITY DEFINER
CREATE OR REPLACE FUNCTION sync_user_password(
  user_auth_id UUID,
  user_email TEXT,
  hashed_password TEXT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  update_count INT;
BEGIN
  -- Try updating by auth_id first
  UPDATE "user"
  SET "Password" = hashed_password
  WHERE auth_id = user_auth_id;
  
  GET DIAGNOSTICS update_count = ROW_COUNT;
  
  -- If no rows updated, try by email
  IF update_count = 0 THEN
    UPDATE "user"
    SET "Password" = hashed_password
    WHERE "EmailAddress" = user_email;
    
    GET DIAGNOSTICS update_count = ROW_COUNT;
  END IF;
  
  -- Return result
  IF update_count > 0 THEN
    RETURN QUERY SELECT TRUE, 'Password updated successfully'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'No user found to update'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION sync_user_password(UUID, TEXT, TEXT) TO authenticated;
