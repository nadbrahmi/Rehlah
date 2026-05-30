-- ── Rehlah · رحلة — Fix checkins schema ──────────────────────────────────────
-- Run in Supabase SQL editor: https://app.supabase.com → SQL Editor
--
-- Uses symptom_scores JSONB so any phase's symptom set works without schema
-- changes: {"fatigue":3,"pain":1} for chemo, {"scan_anxiety":5,...} for monitoring.
-- Also adds the DELETE policy required for the daily upsert (delete + insert).

DROP TABLE IF EXISTS checkins;

CREATE TABLE checkins (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id      uuid        REFERENCES patients(id) ON DELETE CASCADE,
  mood            text,          -- emoji e.g. '😊'
  mood_score      integer,       -- 0 Awful … 4 Great
  symptom_scores  jsonb,         -- {"fatigue":3,"pain":1} — any phase's keys
  notes           text,
  created_at      timestamptz DEFAULT now()
);

ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patient_insert_checkin"  ON checkins FOR INSERT WITH CHECK (true);
CREATE POLICY "patient_read_checkins"   ON checkins FOR SELECT USING (true);
CREATE POLICY "patient_delete_checkins" ON checkins FOR DELETE USING (true);
