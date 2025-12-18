-- Drop existing table and recreate with camelCase column names to match Dart model
DROP TABLE IF EXISTS job_analyses CASCADE;

-- Create job_analyses table with camelCase columns to match JobAnalysisModel
CREATE TABLE job_analyses (
    id BIGSERIAL PRIMARY KEY,
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
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for searching
CREATE INDEX idx_job_analyses_customer_name ON job_analyses("customerName");
CREATE INDEX idx_job_analyses_email ON job_analyses(email);
CREATE INDEX idx_job_analyses_created_at ON job_analyses(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE job_analyses ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Allow authenticated users to read job_analyses"
ON job_analyses FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert job_analyses"
ON job_analyses FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update job_analyses"
ON job_analyses FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to delete job_analyses"
ON job_analyses FOR DELETE TO authenticated USING (true);

-- Add comment
COMMENT ON TABLE job_analyses IS 'Stores job analysis data from voice input and AI extraction (camelCase columns match Dart model)';
