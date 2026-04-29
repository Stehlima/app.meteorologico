-- =====================================================
-- SCHEMA ClimaBrasil - Execute no SQL Editor do Supabase
-- =====================================================

-- Tabela de histórico de buscas climáticas
CREATE TABLE IF NOT EXISTS weather_history (
  id          BIGSERIAL PRIMARY KEY,
  city        TEXT NOT NULL,
  temp        INTEGER NOT NULL,
  description TEXT NOT NULL,
  humidity    INTEGER NOT NULL,
  wind_speedy TEXT NOT NULL,
  condition   TEXT,
  queried_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índice para buscas rápidas por cidade
CREATE INDEX IF NOT EXISTS idx_weather_history_city
  ON weather_history (city, queried_at DESC);

-- View: última consulta por cidade (sem redundância)
CREATE OR REPLACE VIEW latest_weather_per_city AS
SELECT DISTINCT ON (city)
  id, city, temp, description, humidity, wind_speedy, condition, queried_at
FROM weather_history
ORDER BY city, queried_at DESC;

-- View: 10 buscas mais recentes (para o histórico da tela)
CREATE OR REPLACE VIEW recent_searches AS
SELECT id, city, temp, description, humidity, wind_speedy, condition, queried_at
FROM weather_history
ORDER BY queried_at DESC
LIMIT 10;

-- RLS: habilitar Row Level Security (permite acesso anônimo de leitura)
ALTER TABLE weather_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura pública" ON weather_history
  FOR SELECT USING (true);

CREATE POLICY "Inserção pública" ON weather_history
  FOR INSERT WITH CHECK (true);
