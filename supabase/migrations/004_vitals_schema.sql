-- 004_vitals_schema.sql
-- Clinical vitals log — one row per reading, all columns nullable (log any subset)

CREATE TABLE IF NOT EXISTS vitals (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id     UUID        NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  weight_kg      NUMERIC(5,2),
  systolic_bp    INTEGER,
  diastolic_bp   INTEGER,
  heart_rate_bpm INTEGER,
  temperature_c  NUMERIC(4,1),
  spo2_pct       INTEGER,
  glucose_mmol   NUMERIC(4,1),
  cycle_day      INTEGER,
  phase          TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE vitals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "patient_insert_vital" ON vitals FOR INSERT WITH CHECK (true);
CREATE POLICY "patient_read_vitals"  ON vitals FOR SELECT USING (true);

CREATE INDEX IF NOT EXISTS vitals_patient_id_idx ON vitals(patient_id);
CREATE INDEX IF NOT EXISTS vitals_created_at_idx ON vitals(created_at DESC);
