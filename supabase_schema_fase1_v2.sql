-- =====================================================
-- DEVELOPERCATDK - FASE 1: Database Schema (V2)
-- Kompatibel med eksisterende job_analyses tabel
-- =====================================================

-- STEP 1: DROP EXISTING TABLES (if they exist)
-- =====================================================
DROP TABLE IF EXISTS parts_orders CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS customers CASCADE;


-- STEP 2: CREATE TABLES
-- =====================================================

-- 1. CUSTOMERS TABLE (Kundekartotek)
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  customer_number TEXT UNIQUE,
  name TEXT NOT NULL,
  category TEXT CHECK (category IN ('Erhverv', 'Privat', 'Offentlig')),

  -- Kontakt information
  address TEXT,
  postal_code TEXT,
  city TEXT,
  phone TEXT,
  mobile TEXT,
  email TEXT,

  -- Firma information
  cvr_number TEXT,

  -- Faktura information
  invoice_name TEXT,
  invoice_address TEXT,
  invoice_postal_code TEXT,
  invoice_city TEXT,
  invoice_email TEXT,
  invoice_phone TEXT,
  payment_terms TEXT,

  -- Kontaktperson
  contact_person TEXT,

  -- Ekstra
  notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Email validation constraint
  CONSTRAINT customers_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL)
);

-- Create indexes for performance
CREATE INDEX idx_customers_name ON customers(name);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_customer_number ON customers(customer_number);
CREATE INDEX idx_customers_category ON customers(category);


-- 2. APPOINTMENTS TABLE (Kalender/Aftaler)
-- Using BIGINT to match job_analyses table
CREATE TABLE appointments (
  id BIGSERIAL PRIMARY KEY,

  -- Relations (using BIGINT to match existing job_analyses table)
  job_analysis_id BIGINT REFERENCES job_analyses(id) ON DELETE SET NULL,
  customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  user_email TEXT NOT NULL, -- Montøren der har aftalen

  -- Appointment detaljer
  title TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  estimated_duration_hours DECIMAL(5,2),

  -- Status tracking
  status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'awaiting_parts', 'completed', 'cancelled')),

  -- Quote/Tilbuds tracking
  quote_status TEXT DEFAULT 'draft' CHECK (quote_status IN ('draft', 'sent', 'accepted', 'rejected')),
  quote_sent_at TIMESTAMPTZ,
  quote_accepted_at TIMESTAMPTZ,
  acceptance_token TEXT UNIQUE, -- For email godkendelse link

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX idx_appointments_job_analysis ON appointments(job_analysis_id);
CREATE INDEX idx_appointments_customer ON appointments(customer_id);
CREATE INDEX idx_appointments_user_email ON appointments(user_email);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_quote_status ON appointments(quote_status);
CREATE INDEX idx_appointments_acceptance_token ON appointments(acceptance_token);


-- 3. PARTS ORDERS TABLE (Reservedele)
CREATE TABLE parts_orders (
  id BIGSERIAL PRIMARY KEY,

  -- Relation
  appointment_id BIGINT REFERENCES appointments(id) ON DELETE CASCADE,

  -- Part detaljer
  part_name TEXT NOT NULL,
  part_sku TEXT,
  quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
  price DECIMAL(10,2),
  supplier TEXT,

  -- Status tracking
  status TEXT DEFAULT 'not_ordered' CHECK (status IN ('not_ordered', 'ordered', 'arrived', 'installed')),
  ordered_at TIMESTAMPTZ,
  arrived_at TIMESTAMPTZ,
  installed_at TIMESTAMPTZ,

  -- Ekstra
  notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_parts_orders_appointment ON parts_orders(appointment_id);
CREATE INDEX idx_parts_orders_status ON parts_orders(status);


-- STEP 3: ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all new tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE parts_orders ENABLE ROW LEVEL SECURITY;

-- CUSTOMERS POLICIES
-- All authenticated users can manage customers
CREATE POLICY "Authenticated users can view customers"
ON customers FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can insert customers"
ON customers FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated users can update customers"
ON customers FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can delete customers"
ON customers FOR DELETE
TO authenticated
USING (true);


-- APPOINTMENTS POLICIES
-- Users can view all appointments (for calendar overview)
CREATE POLICY "Authenticated users can view all appointments"
ON appointments FOR SELECT
TO authenticated
USING (true);

-- Users can only manage their own appointments
CREATE POLICY "Users can insert their own appointments"
ON appointments FOR INSERT
TO authenticated
WITH CHECK (user_email = auth.email());

CREATE POLICY "Users can update their own appointments"
ON appointments FOR UPDATE
TO authenticated
USING (user_email = auth.email());

CREATE POLICY "Users can delete their own appointments"
ON appointments FOR DELETE
TO authenticated
USING (user_email = auth.email());

-- SPECIAL: Allow anonymous users to update quote status via acceptance token
CREATE POLICY "Public can accept/reject quotes via token"
ON appointments FOR UPDATE
TO anon
USING (acceptance_token IS NOT NULL)
WITH CHECK (acceptance_token IS NOT NULL);


-- PARTS ORDERS POLICIES
-- Users can manage parts for appointments they can see
CREATE POLICY "Authenticated users can view parts"
ON parts_orders FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM appointments
    WHERE appointments.id = parts_orders.appointment_id
  )
);

CREATE POLICY "Authenticated users can manage parts"
ON parts_orders FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM appointments
    WHERE appointments.id = parts_orders.appointment_id
  )
);


-- STEP 4: TRIGGERS FOR AUTOMATIC TIMESTAMPS
-- =====================================================

-- Function to update updated_at timestamp (create if not exists)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to customers table
CREATE TRIGGER update_customers_updated_at
  BEFORE UPDATE ON customers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply to appointments table
CREATE TRIGGER update_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply to parts_orders table
CREATE TRIGGER update_parts_orders_updated_at
  BEFORE UPDATE ON parts_orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- STEP 5: HELPER FUNCTIONS
-- =====================================================

-- Generate unique acceptance token for quote acceptance
CREATE OR REPLACE FUNCTION generate_acceptance_token()
RETURNS TEXT AS $$
BEGIN
  RETURN encode(gen_random_bytes(16), 'hex');
END;
$$ LANGUAGE plpgsql;


-- =====================================================
-- DONE! Schema is ready for use.
-- =====================================================

-- Verification query - should show 0 rows for new tables
SELECT
  'customers' as table_name, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'parts_orders', COUNT(*) FROM parts_orders;
