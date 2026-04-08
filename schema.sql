```sql
-- Enable pg_crypto for UUID generation
CREATE EXTENSION IF NOT EXISTS pg_crypto;

-- Users table (maps to Supabase auth.users)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Freelancer profiles
CREATE TABLE freelancer_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  business_name TEXT,
  contact_email TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- NDA Templates
CREATE TABLE nda_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  content TEXT NOT NULL,
  is_public BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Generated NDAs
CREATE TABLE generated_ndas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  freelancer_id UUID NOT NULL REFERENCES freelancer_profiles(id),
  template_id UUID REFERENCES nda_templates(id),
  client_name TEXT NOT NULL,
  client_email TEXT NOT NULL,
  custom_content TEXT,
  status TEXT NOT NULL DEFAULT 'draft', -- draft, sent, signed, expired
  signed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_freelancer_profiles_user_id ON freelancer_profiles(user_id);
CREATE INDEX idx_generated_ndas_freelancer_id ON generated_ndas(freelancer_id);
CREATE INDEX idx_generated_ndas_status ON generated_ndas(status);
CREATE INDEX idx_nda_templates_is_public ON nda_templates(is_public);

-- Timestamp triggers
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_freelancer_profiles_timestamp
BEFORE UPDATE ON freelancer_profiles
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_nda_templates_timestamp
BEFORE UPDATE ON nda_templates
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_generated_ndas_timestamp
BEFORE UPDATE ON generated_ndas
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- RLS Policies
ALTER TABLE freelancer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE nda_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_ndas ENABLE ROW LEVEL SECURITY;

-- Freelancer profiles RLS
CREATE POLICY freelancer_profiles_owner_policy ON freelancer_profiles
  USING (user_id = auth.uid());

CREATE POLICY freelancer_profiles_select_policy ON freelancer_profiles
  FOR SELECT USING (true);

-- NDA Templates RLS
CREATE POLICY nda_templates_owner_policy ON nda_templates
  USING (created_by = auth.uid() OR is_public = true);

CREATE POLICY nda_templates_insert_policy ON nda_templates
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY nda_templates_update_policy ON nda_templates
  FOR UPDATE USING (created_by = auth.uid());

CREATE POLICY nda_templates_delete_policy ON nda_templates
  FOR DELETE USING (created_by = auth.uid());

-- Generated NDAs RLS
CREATE POLICY generated_ndas_owner_policy ON generated_ndas
  USING (freelancer_id IN (
    SELECT id FROM freelancer_profiles WHERE user_id = auth.uid()
  ));

CREATE POLICY generated_ndas_insert_policy ON generated_ndas
  FOR INSERT WITH CHECK (
    freelancer_id IN (
      SELECT id FROM freelancer_profiles WHERE user_id = auth.uid()
    )
  );

-- Seed data (public templates)
INSERT INTO nda_templates (id, title, description, content, is_public, created_at, updated_at)
VALUES 
(
  gen_random_uuid(),
  'Standard Mutual NDA',
  'Basic mutual non-disclosure agreement',
  'This Mutual Non-Disclosure Agreement (the "Agreement") is made between [Disclosing Party] and [Receiving Party]...',
  true,
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Freelancer NDA',
  'One-way NDA protecting freelancer work',
  'This Non-Disclosure Agreement (the "Agreement") is made between [Client Name] ("Disclosing Party") and [Freelancer Name] ("Receiving Party")...',
  true,
  NOW(),
  NOW()
);
```