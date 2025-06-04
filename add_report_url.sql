-- Add report_url column to lab_reports table if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 
                   FROM information_schema.columns 
                   WHERE table_name='lab_reports' AND column_name='report_url') THEN
        ALTER TABLE lab_reports ADD COLUMN report_url TEXT;
    END IF;
END $$;

-- Add report_url column to Radiology table if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 
                   FROM information_schema.columns 
                   WHERE table_name='Radiology' AND column_name='report_url') THEN
        ALTER TABLE "Radiology" ADD COLUMN report_url TEXT;
    END IF;
END $$; 