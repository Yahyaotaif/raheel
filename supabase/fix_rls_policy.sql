-- Fix the RLS policy to use auth_id instead of id
-- This allows users to update their own profiles correctly

-- Drop the old incorrect policy
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user;

-- Create the corrected policy
CREATE POLICY "Users can update their own profile"
ON public.user
FOR UPDATE
TO authenticated
USING (auth.uid() = auth_id)
WITH CHECK (auth.uid() = auth_id);
