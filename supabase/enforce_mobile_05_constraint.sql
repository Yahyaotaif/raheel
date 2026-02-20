-- Enforce Saudi local mobile format: 05XXXXXXXX
-- Table: public."user", Column: "MobileNumber"
--
-- This script is safe for existing databases:
-- 1) Adds the CHECK as NOT VALID so existing bad rows won't block deployment.
-- 2) New INSERT/UPDATE rows are enforced immediately.
-- 3) After cleanup, run VALIDATE CONSTRAINT.

-- Optional: inspect existing invalid values first
-- SELECT auth_id, "MobileNumber"
-- FROM public."user"
-- WHERE "MobileNumber" IS NULL
--    OR "MobileNumber" !~ '^05[0-9]{8}$';

ALTER TABLE public."user"
DROP CONSTRAINT IF EXISTS user_mobile_ksa_05_check;

ALTER TABLE public."user"
ADD CONSTRAINT user_mobile_ksa_05_check
CHECK ("MobileNumber" ~ '^05[0-9]{8}$')
NOT VALID;

-- After fixing old invalid rows, validate for full consistency:
-- ALTER TABLE public."user" VALIDATE CONSTRAINT user_mobile_ksa_05_check;
