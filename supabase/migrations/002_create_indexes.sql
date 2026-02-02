-- 002_create_indexes.sql
-- 인덱스 생성

-- sites
CREATE INDEX idx_sites_name ON sites(name);

-- parts
CREATE INDEX idx_parts_name ON parts(name);

-- workers
CREATE INDEX idx_workers_site_id ON workers(site_id);
CREATE INDEX idx_workers_part_id ON workers(part_id);
CREATE INDEX idx_workers_phone ON workers(phone);
CREATE INDEX idx_workers_role ON workers(role);

-- attendances
CREATE INDEX idx_attendances_worker_id ON attendances(worker_id);
CREATE INDEX idx_attendances_check_in_time ON attendances(check_in_time);
CREATE INDEX idx_attendances_status ON attendances(status);
CREATE INDEX idx_attendances_worker_month
  ON attendances(worker_id, EXTRACT(YEAR FROM check_in_time), EXTRACT(MONTH FROM check_in_time));

-- payrolls
CREATE INDEX idx_payrolls_worker_id ON payrolls(worker_id);
CREATE INDEX idx_payrolls_year_month ON payrolls(year_month);
CREATE INDEX idx_payrolls_is_finalized ON payrolls(is_finalized);
