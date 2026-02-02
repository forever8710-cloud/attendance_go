-- 004_setup_rls.sql
-- Row Level Security 설정

-- RLS 활성화
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE payrolls ENABLE ROW LEVEL SECURITY;

-- sites: 모든 인증된 사용자가 조회 가능
CREATE POLICY sites_select ON sites FOR SELECT
  USING (auth.role() = 'authenticated');

-- parts: 모든 인증된 사용자가 조회 가능
CREATE POLICY parts_select ON parts FOR SELECT
  USING (auth.role() = 'authenticated');

-- workers: 자신의 정보 조회
CREATE POLICY worker_select_own ON workers FOR SELECT
  USING (auth.uid() = id);

-- workers: 관리자는 같은 사업장 근로자 조회
CREATE POLICY manager_select_site ON workers FOR SELECT
  USING (
    site_id IN (
      SELECT site_id FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- workers: 관리자만 등록/수정/삭제
CREATE POLICY manager_insert_workers ON workers FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );

CREATE POLICY manager_update_workers ON workers FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );

CREATE POLICY manager_delete_workers ON workers FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- attendances: 근로자 자신의 기록 조회
CREATE POLICY worker_own_attendance ON attendances FOR SELECT
  USING (worker_id = auth.uid());

-- attendances: 근로자 자신의 기록 생성
CREATE POLICY worker_create_attendance ON attendances FOR INSERT
  WITH CHECK (worker_id = auth.uid());

-- attendances: 근로자 자신의 퇴근 기록 수정
CREATE POLICY worker_update_own_attendance ON attendances FOR UPDATE
  USING (worker_id = auth.uid());

-- attendances: 관리자는 같은 사업장 출퇴근 기록 조회
CREATE POLICY manager_view_site_attendance ON attendances FOR SELECT
  USING (
    worker_id IN (
      SELECT w1.id FROM workers w1
      JOIN workers w2 ON w1.site_id = w2.site_id
      WHERE w2.id = auth.uid() AND w2.role = 'manager'
    )
  );

-- payrolls: 근로자 자신의 급여 조회
CREATE POLICY worker_own_payroll ON payrolls FOR SELECT
  USING (worker_id = auth.uid());

-- payrolls: 관리자는 같은 사업장 급여 조회/생성
CREATE POLICY manager_view_site_payroll ON payrolls FOR SELECT
  USING (
    worker_id IN (
      SELECT w1.id FROM workers w1
      JOIN workers w2 ON w1.site_id = w2.site_id
      WHERE w2.id = auth.uid() AND w2.role = 'manager'
    )
  );

CREATE POLICY manager_create_payroll ON payrolls FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );

CREATE POLICY manager_update_payroll ON payrolls FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM workers WHERE id = auth.uid() AND role = 'manager'
    )
  );
