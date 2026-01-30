-- This SQL will update all 9-digit MobileNumber values to 10 digits by adding a leading 0
-- Make a backup before running in production!

UPDATE "user"
SET "MobileNumber" = '0' || "MobileNumber"
WHERE LENGTH("MobileNumber") = 9
  AND LEFT("MobileNumber", 1) != '0';

-- To verify after running:
-- SELECT "MobileNumber" FROM "user" WHERE LENGTH("MobileNumber") != 10;