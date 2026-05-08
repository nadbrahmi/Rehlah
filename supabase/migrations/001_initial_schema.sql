-- ── Rehlah · رحلة — Initial Schema ───────────────────────────────────────────
-- Run in Supabase SQL editor or apply via supabase CLI:
--   supabase db push

-- ── patients ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS patients (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name              text NOT NULL,
  date_of_birth     date,
  diagnosis         text,
  protocol_id       text,        -- 'AC-T' | 'TC' | 'CMF' | 'Anastrozole'
  cycle_number      integer DEFAULT 1,
  cycle_start_date  date,
  total_cycles      integer DEFAULT 8,
  invite_code       text UNIQUE NOT NULL,
  invite_expires_at timestamptz DEFAULT now() + interval '14 days',
  invite_status     text DEFAULT 'pending',  -- pending | active | expired
  oncologist_email  text,
  coordinator_email text,
  patient_phone     text,
  patient_email     text,
  created_at        timestamptz DEFAULT now()
);

-- ── medications ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS medications (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id  uuid REFERENCES patients(id) ON DELETE CASCADE,
  name        text NOT NULL,
  dose        text,
  frequency   text,
  emoji       text DEFAULT '💊',
  category    text DEFAULT 'chemo',
  total_supply integer,
  active      boolean DEFAULT true
);

-- ── appointments ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS appointments (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id   uuid REFERENCES patients(id) ON DELETE CASCADE,
  title        text NOT NULL,
  doctor_name  text,
  location     text,
  date_time    timestamptz NOT NULL,
  report_sent  boolean DEFAULT false
);

-- ── checkins ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS checkins (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id      uuid REFERENCES patients(id) ON DELETE CASCADE,
  date            date NOT NULL,
  cycle_day       integer,
  phase           text,
  symptom_scores  jsonb,
  mood_emoji      text,
  mood_label      text,
  patient_note    text,
  created_at      timestamptz DEFAULT now()
);

-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE patients     ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications  ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins     ENABLE ROW LEVEL SECURITY;

-- Patients: public read (invite code lookup is filtered in app); coordinator insert/update
CREATE POLICY "public_invite_lookup"        ON patients FOR SELECT USING (true);
CREATE POLICY "coordinator_insert_patients" ON patients FOR INSERT WITH CHECK (true);
CREATE POLICY "public_activate_patient"     ON patients FOR UPDATE USING (true);

-- Medications: public read; coordinator insert
CREATE POLICY "patient_read_own_meds"       ON medications FOR SELECT USING (true);
CREATE POLICY "coordinator_insert_meds"     ON medications FOR INSERT WITH CHECK (true);

-- Appointments: public read; coordinator insert
CREATE POLICY "patient_read_appointments"   ON appointments FOR SELECT USING (true);
CREATE POLICY "coordinator_insert_apts"     ON appointments FOR INSERT WITH CHECK (true);

-- Checkins: patient insert only
CREATE POLICY "patient_insert_checkin"      ON checkins FOR INSERT WITH CHECK (true);
CREATE POLICY "patient_read_checkins"       ON checkins FOR SELECT USING (true);
