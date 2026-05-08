-- ── Rehlah · رحلة — Labs Schema ──────────────────────────────────────────────

-- ── labs ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS labs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id   uuid REFERENCES patients(id) ON DELETE CASCADE,
  panel_name   text NOT NULL,
  date         date NOT NULL,
  ai_summary   text,
  created_at   timestamptz DEFAULT now()
);

-- ── lab_metrics ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lab_metrics (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lab_id         uuid REFERENCES labs(id) ON DELETE CASCADE,
  name           text NOT NULL,
  value          double precision NOT NULL,
  unit           text DEFAULT '',
  normal_min     double precision,
  normal_max     double precision,
  previous_value double precision
);

-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE labs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patient_read_labs"              ON labs        FOR SELECT USING (true);
CREATE POLICY "coordinator_insert_labs"        ON labs        FOR INSERT WITH CHECK (true);
CREATE POLICY "patient_read_lab_metrics"       ON lab_metrics FOR SELECT USING (true);
CREATE POLICY "coordinator_insert_lab_metrics" ON lab_metrics FOR INSERT WITH CHECK (true);
