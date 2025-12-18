-- Create job_analyses table to match JobAnalysisModel
CREATE TABLE IF NOT EXISTS job_analyses (
    id BIGSERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    job TEXT NOT NULL,
    assignment TEXT,
    preferred_dates JSONB DEFAULT '[]',
    parts_needed JSONB DEFAULT '[]',
    total_estimate DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for searching
CREATE INDEX IF NOT EXISTS idx_job_analyses_customer_name ON job_analyses(customer_name);
CREATE INDEX IF NOT EXISTS idx_job_analyses_email ON job_analyses(email);
CREATE INDEX IF NOT EXISTS idx_job_analyses_created_at ON job_analyses(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE job_analyses ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to read all job analyses
CREATE POLICY "Allow authenticated users to read job_analyses"
ON job_analyses FOR SELECT
TO authenticated
USING (true);

-- Create policy to allow authenticated users to insert job analyses
CREATE POLICY "Allow authenticated users to insert job_analyses"
ON job_analyses FOR INSERT
TO authenticated
WITH CHECK (true);

-- Create policy to allow authenticated users to update their own job analyses
CREATE POLICY "Allow authenticated users to update job_analyses"
ON job_analyses FOR UPDATE
TO authenticated
USING (true);

-- Create policy to allow authenticated users to delete job analyses
CREATE POLICY "Allow authenticated users to delete job_analyses"
ON job_analyses FOR DELETE
TO authenticated
USING (true);

-- Add comment
COMMENT ON TABLE job_analyses IS 'Stores job analysis data from voice input and AI extraction';
