-- 008_seed_sites_and_parts.sql
-- 센터 3곳 추가 (서이천은 이미 존재) + 파트 5개 추가 (지게차는 이미 존재)

-- 센터: 안성, 의왕, 부평
INSERT INTO sites (name, latitude, longitude, radius) VALUES
  ('안성센터', 37.0080, 127.2797, 100),
  ('의왕센터', 37.3449, 126.9685, 100),
  ('부평센터', 37.5074, 126.7218, 100)
ON CONFLICT DO NOTHING;

-- 파트: 지게차(야간), 피커, 피커(야간), 검수, 사무
INSERT INTO parts (name, hourly_wage, daily_wage, description) VALUES
  ('지게차(야간)', 14400, 115200, '지게차 운전 야간 파트'),
  ('피커', 10000, 80000, '피킹 파트'),
  ('피커(야간)', 12000, 96000, '피킹 야간 파트'),
  ('검수', 10000, 80000, '검수 파트'),
  ('사무', 11000, 88000, '사무 파트')
ON CONFLICT DO NOTHING;
