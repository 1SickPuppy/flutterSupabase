-- Complete job_analyses table with all columns including extras added by app
DROP TABLE IF EXISTS job_analyses CASCADE;

CREATE TABLE job_analyses (
    id BIGSERIAL PRIMARY KEY,

    -- Fields from JobAnalysisModel (camelCase to match Dart)
    "customerName" TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    job TEXT NOT NULL,
    assignment TEXT,
    "preferredDates" JSONB DEFAULT '[]',
    "partsNeeded" JSONB DEFAULT '[]',
    "totalEstimate" DECIMAL(10,2) DEFAULT 0,
    notes TEXT,

    -- Extra fields added by supabase_widget.dart
    user_email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for searching
CREATE INDEX idx_job_analyses_customer_name ON job_analyses("customerName");
CREATE INDEX idx_job_analyses_email ON job_analyses(email);
CREATE INDEX idx_job_analyses_user_email ON job_analyses(user_email);
CREATE INDEX idx_job_analyses_created_at ON job_analyses(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE job_analyses ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own job analyses
CREATE POLICY "Users can view their own job_analyses"
ON job_analyses FOR SELECT
TO authenticated
USING (user_email = auth.email());

-- Policy: Users can insert job analyses
CREATE POLICY "Users can insert job_analyses"
ON job_analyses FOR INSERT
TO authenticated
WITH CHECK (user_email = auth.email());

-- Policy: Users can update their own job analyses
CREATE POLICY "Users can update their own job_analyses"
ON job_analyses FOR UPDATE
TO authenticated
USING (user_email = auth.email());

-- Policy: Users can delete their own job analyses
CREATE POLICY "Users can delete their own job_analyses"
ON job_analyses FOR DELETE
TO authenticated
USING (user_email = auth.email());

-- Add comment
COMMENT ON TABLE job_analyses IS 'Stores job analysis data from voice input and AI extraction. Users can only access their own data via RLS.';
