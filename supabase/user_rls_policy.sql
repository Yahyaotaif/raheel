-- Enable RLS on the user table
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;

-- Policy: Allow users to select their own row
CREATE POLICY "Users can select their own info"
  ON "user"
  FOR SELECT
  USING (id = auth.uid());

-- Policy: Allow users to update their own row (optional)
CREATE POLICY "Users can update their own info"
  ON "user"
  FOR UPDATE
  USING (id = auth.uid());

-- Policy: Allow users to insert their own row (optional, for sign-up flows)
CREATE POLICY "Users can insert their own info"
  ON "user"
  FOR INSERT
  WITH CHECK (id = auth.uid());
