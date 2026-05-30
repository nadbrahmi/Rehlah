-- ── Rehlah · رحلة — Fix checkins schema ──────────────────────────────────────
-- Run in Supabase SQL editor: https://app.supabase.com → SQL Editor
--
-- The original checkins table used jsonb/renamed columns that don't match the
-- app code. This migration replaces it with flat columns the app actually writes.
-- Also adds the missing DELETE policy so the daily upsert (delete+insert) works.

DROP TABLE IF EXISTS checkins;

CREATE TABLE checkins (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id  uuid        REFERENCES patients(id) ON DELETE CASCADE,
  mood        text,          -- emoji character e.g. '😊'
  mood_score  integer,       -- 0 (Awful) … 4 (Great)
  fatigue     numeric,       -- 0–10
  pain        numeric,
  nausea      numeric,
  fever       numeric,
  notes       text,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patient_insert_checkin"  ON checkins FOR INSERT WITH CHECK (true);
CREATE POLICY "patient_read_checkins"   ON checkins FOR SELECT USING (true);
CREATE POLICY "patient_delete_checkins" ON checkins FOR DELETE USING (true);
