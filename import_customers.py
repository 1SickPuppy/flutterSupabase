#!/usr/bin/env python3
"""
Import customers from CSV to Supabase
"""

import csv
import requests
import json
import os

# Load credentials from .env
SUPABASE_URL = "https://mpwjggngupmpurnfdhhm.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wd2pnZ25ndXBtcHVybmZkaGhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3MTY0ODYsImV4cCI6MjA3NTI5MjQ4Nn0.EgZ4vJLTh65v2ohpgeW4JRz1DZ6VQ9t6DFkYGeWPNMA"

# Headers for Supabase REST API
headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

def create_table_sql():
    """Generate SQL to create customers table"""
    return """
    CREATE TABLE IF NOT EXISTS customers (
        id BIGSERIAL PRIMARY KEY,
        customer_number TEXT UNIQUE,
        name TEXT NOT NULL,
        category TEXT,
        postal_code TEXT,
        city TEXT,
        address TEXT,
        phone TEXT,
        cvr_number TEXT,
        invoice_name TEXT,
        invoice_address TEXT,
        invoice_postal_code TEXT,
        invoice_city TEXT,
        invoice_mobile TEXT,
        invoice_email TEXT,
        year TEXT,
        reference TEXT,
        requester TEXT,
        mobile TEXT,
        email TEXT,
        payment_terms TEXT,
        invoice_phone TEXT,
        sync_status TEXT,
        material_discount_group TEXT,
        price_type TEXT,
        remarks TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Create index on customer_number for fast lookups
    CREATE INDEX IF NOT EXISTS idx_customers_customer_number ON customers(customer_number);
    CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
    """

def import_csv_to_supabase(csv_path):
    """Import customers from CSV to Supabase"""

    print(f"📂 Reading CSV file: {csv_path}")

    customers = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for row in reader:
            customer = {
                "customer_number": row.get("Nummer", "").strip(),
                "name": row.get("Navn", "").strip(),
                "category": row.get("Kategori", "").strip(),
                "postal_code": row.get("Postnummer", "").strip(),
                "city": row.get("By", "").strip(),
                "address": row.get("Adresse", "").strip(),
                "phone": row.get("Telefonnummer", "").strip(),
                "cvr_number": row.get("CVR nummer", "").strip(),
                "invoice_name": row.get("Fakturanavn", "").strip(),
                "invoice_address": row.get("Fakturaadresse", "").strip(),
                "invoice_postal_code": row.get("Faktura postnummer", "").strip(),
                "invoice_city": row.get("Faktura by", "").strip(),
                "invoice_mobile": row.get("Faktura mobiltelefonnummer", "").strip(),
                "invoice_email": row.get("Faktura e-mail", "").strip(),
                "year": row.get("Rekvisitionsår", "").strip(),
                "reference": row.get("Reference", "").strip(),
                "requester": row.get("Rekvirenten", "").strip(),
                "mobile": row.get("Mobilnummer", "").strip(),
                "email": row.get("E-mail", "").strip(),
                "payment_terms": row.get("Betalingsbetingelser", "").strip(),
                "invoice_phone": row.get("Faktura telefonnummer", "").strip(),
                "sync_status": row.get("Synkronisering", "").strip(),
                "material_discount_group": row.get("Materiale rabatgruppe", "").strip(),
                "price_type": row.get("Avancetype", "").strip(),
                "remarks": row.get("Bemærkning", "").strip(),
            }
            customers.append(customer)

    print(f"✅ Read {len(customers)} customers from CSV")

    # Insert in batches of 100
    batch_size = 100
    for i in range(0, len(customers), batch_size):
        batch = customers[i:i + batch_size]

        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/customers",
            headers=headers,
            json=batch
        )

        if response.status_code in [200, 201]:
            print(f"✅ Imported batch {i//batch_size + 1} ({len(batch)} customers)")
        else:
            print(f"❌ Error importing batch {i//batch_size + 1}: {response.status_code}")
            print(f"   Response: {response.text}")

            # If table doesn't exist, show SQL
            if "relation" in response.text.lower() and "does not exist" in response.text.lower():
                print("\n⚠️  Table 'customers' doesn't exist. Please create it first:")
                print("\n🔧 Go to your Supabase dashboard → SQL Editor and run:")
                print(create_table_sql())
                return False

    print(f"\n🎉 Successfully imported {len(customers)} customers to Supabase!")
    return True

if __name__ == "__main__":
    csv_file = "developercatfiles/1dscoolcustomers.csv"

    if not os.path.exists(csv_file):
        print(f"❌ CSV file not found: {csv_file}")
        exit(1)

    print("🚀 Starting import...")
    print(f"📍 Supabase URL: {SUPABASE_URL}")
    print()

    success = import_csv_to_supabase(csv_file)

    if not success:
        print("\n💡 Next steps:")
        print("1. Copy the SQL above")
        print("2. Go to https://supabase.com/dashboard")
        print("3. Open SQL Editor")
        print("4. Paste and run the SQL")
        print("5. Run this script again")
